#!/usr/bin/env tsx

import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";
import { execSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const repoRoot = path.resolve(__dirname, "../..");
const sourcesFile = path.join(repoRoot, "nix", "agent-skills-sources.nix");
const syncScript = path.join(repoRoot, "agents", "scripts", "skills-sync-inputs.ts");
const localSkillsDir = path.join(repoRoot, "agents", "skills");

const args = process.argv.slice(2);

const usage = (code = 0) => {
  const message = `
Usage:
  skills-add <source> [options]
  skills-add --list <source>

Source formats (vercel-labs/skills compatible):
  owner/repo
  https://github.com/owner/repo
  https://github.com/owner/repo/tree/<ref>/<path>
  https://gitlab.com/owner/repo
  git@github.com:owner/repo.git
  /local/path/to/repo

Options:
  -l, --list              List discovered skills only
  -s, --skill <skills...> Add only specified skills
  --all                   Add all skills (default when no --skill)
  -y, --yes               Auto-approve if confirmation is needed
  --dry-run               Show changes without writing files
  -g, --global            No-op (managed by Nix in this repo)
  -a, --agent             No-op (managed by Nix in this repo)

Examples:
  mise run skills:add -- vercel-labs/agent-skills
  mise run skills:add -- https://github.com/vercel-labs/skills/tree/main/skills/find-skills
  mise run skills:add -- --list vercel-labs/skills
  mise run skills:add -- vercel-labs/agent-skills --skill web-design-guidelines
`;
  if (code === 0) {
    console.log(message);
  } else {
    console.error(message);
  }
  process.exit(code);
};

const isTruthy = (value) => {
  if (!value) return false;
  const normalized = String(value).toLowerCase();
  return !["0", "false", "no", "off"].includes(normalized);
};

if (!fs.existsSync(sourcesFile)) {
  console.error(`Missing file: ${sourcesFile}`);
  process.exit(1);
}

const sourceContent = fs.readFileSync(sourcesFile, "utf8");

const countChar = (str, char) => {
  let count = 0;
  for (const ch of str) {
    if (ch === char) count += 1;
  }
  return count;
};

const stripCommentsAndStrings = (line) =>
  line
    .replace(/"([^"\\]|\\.)*"/g, "")
    .replace(/#.*/, "");

const extractSourceBlocks = (content) => {
  const lines = content.split(/\r?\n/);
  let depth = 0;
  const sources = [];
  let current = null;
  for (let i = 0; i < lines.length; i += 1) {
    const raw = lines[i];
    const sanitized = stripCommentsAndStrings(raw);
    if (depth === 1 && !current) {
      const match = sanitized.match(/^\s*([A-Za-z0-9_-]+)\s*=\s*\{\s*$/);
      if (match) {
        current = {
          name: match[1],
          start: i,
          end: null,
          url: null,
          flake: null,
        };
      }
    } else if (current) {
      const urlMatch = sanitized.match(/^\s*url\s*=\s*"([^"]+)"\s*;/);
      if (urlMatch) current.url = urlMatch[1];
      const flakeMatch = sanitized.match(/^\s*flake\s*=\s*(true|false)\s*;/);
      if (flakeMatch) current.flake = flakeMatch[1] === "true";
    }

    depth += countChar(sanitized, "{") - countChar(sanitized, "}");

    if (current && depth === 1) {
      current.end = i;
      sources.push(current);
      current = null;
    }
  }
  return { lines, sources };
};

const normalizeUrl = (url) => {
  if (!url) return null;
  let normalized = url;
  if (normalized.startsWith("github:")) {
    normalized = normalized.replace(/^github:/, "https://github.com/");
  } else if (normalized.startsWith("git+")) {
    normalized = normalized.replace(/^git\+/, "");
  }
  if (normalized.startsWith("path:")) {
    const rel = normalized.slice("path:".length);
    return path.resolve(repoRoot, rel);
  }
  normalized = normalized.replace(/\.git$/, "");
  normalized = normalized.split("?")[0].split("#")[0];
  return normalized;
};

const sanitizeName = (value) =>
  value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+/, "")
    .replace(/-+$/, "");

const toPathUrl = (absPath) => {
  const rel = path.relative(repoRoot, absPath).replace(/\\/g, "/");
  const normalized = rel.startsWith(".") ? rel : `./${rel}`;
  return `path:${normalized}`;
};

const toGitUrl = (value) => {
  if (value.startsWith("git+")) return value;
  if (value.startsWith("git@")) {
    const match = value.match(/^git@([^:]+):(.+)$/);
    if (match) {
      return `git+ssh://git@${match[1]}/${match[2]}`;
    }
  }
  if (value.startsWith("ssh://")) return `git+${value}`;
  if (value.startsWith("http://") || value.startsWith("https://")) return `git+${value}`;
  return value;
};

const existingSources = extractSourceBlocks(sourceContent);
const existingSourceNames = new Set(existingSources.sources.map((s) => s.name));

const uniqueSourceName = (base) => {
  let name = sanitizeName(base || "skills-source");
  if (!name) name = "skills-source";
  let candidate = name;
  let counter = 2;
  while (existingSourceNames.has(candidate)) {
    candidate = `${name}-${counter}`;
    counter += 1;
  }
  existingSourceNames.add(candidate);
  return candidate;
};

const looksLikeSource = (value) => {
  if (!value) return false;
  if (fs.existsSync(value)) return true;
  if (/^https?:\/\//i.test(value)) return true;
  if (/^[\w.-]+\/[\w.-]+$/.test(value)) return true;
  if (/^git@/.test(value)) return true;
  if (/\.git$/.test(value)) return true;
  return false;
};

const parseSourceInput = (value) => {
  if (fs.existsSync(value)) {
    const abs = path.resolve(value);
    return { kind: "local", path: abs, hintPath: null };
  }
  if (/^[\w.-]+\/[\w.-]+$/.test(value)) {
    return {
      kind: "github",
      url: `https://github.com/${value}`,
      owner: value.split("/")[0],
      repo: value.split("/")[1],
      ref: null,
      hintPath: null,
    };
  }
  if (/^https?:\/\//i.test(value)) {
    try {
      const parsed = new URL(value);
      const host = parsed.hostname.toLowerCase();
      const parts = parsed.pathname.replace(/^\/+/, "").split("/");
      if (host.includes("github.com") && parts.length >= 2) {
        const owner = parts[0];
        const repo = parts[1].replace(/\.git$/, "");
        let ref = null;
        let hintPath = null;
        if (parts[2] === "tree" && parts.length >= 4) {
          ref = parts[3];
          hintPath = parts.slice(4).join("/") || null;
        }
        return { kind: "github", url: parsed.origin + `/${owner}/${repo}`, owner, repo, ref, hintPath };
      }
      if (host.includes("gitlab.com") && parts.length >= 2) {
        const owner = parts[0];
        const repo = parts[1].replace(/\.git$/, "");
        let ref = null;
        let hintPath = null;
        if (parts[2] === "-" && parts[3] === "tree" && parts.length >= 5) {
          ref = parts[4];
          hintPath = parts.slice(5).join("/") || null;
        }
        return { kind: "gitlab", url: parsed.origin + `/${owner}/${repo}`, owner, repo, ref, hintPath };
      }
      return { kind: "git", url: value, ref: null, hintPath: null };
    } catch {
      return { kind: "git", url: value, ref: null, hintPath: null };
    }
  }
  if (/^git@/.test(value)) {
    return { kind: "git", url: value, ref: null, hintPath: null };
  }
  if (/\.git$/.test(value)) {
    return { kind: "git", url: value, ref: null, hintPath: null };
  }
  return null;
};

const parseFrontmatter = (content) => {
  if (!content.startsWith("---")) return { name: null, internal: false };
  const lines = content.split(/\r?\n/);
  let endIdx = -1;
  for (let i = 1; i < lines.length; i += 1) {
    if (lines[i].trim() === "---") {
      endIdx = i;
      break;
    }
  }
  if (endIdx === -1) return { name: null, internal: false };
  const frontmatter = lines.slice(1, endIdx);
  let name = null;
  let internal = false;
  let metadataIndent = null;
  for (const line of frontmatter) {
    const nameMatch = line.match(/^name\s*:\s*(.+)\s*$/);
    if (nameMatch && !name) {
      name = nameMatch[1].replace(/^"|"$/g, "").trim();
    }
    const metadataMatch = line.match(/^(\s*)metadata\s*:\s*$/);
    if (metadataMatch) {
      metadataIndent = metadataMatch[1].length;
    } else if (metadataIndent !== null) {
      const indentMatch = line.match(/^(\s*)\S/);
      if (indentMatch && indentMatch[1].length <= metadataIndent) {
        metadataIndent = null;
      }
    }
    if (metadataIndent !== null) {
      const internalMatch = line.match(/internal\s*:\s*(true|false)/i);
      if (internalMatch && internalMatch[1].toLowerCase() === "true") {
        internal = true;
      }
    }
    if (/^internal\s*:\s*true\s*$/i.test(line)) {
      internal = true;
    }
  }
  return { name, internal };
};

const readSkillInfo = (skillDir) => {
  const skillFile = path.join(skillDir, "SKILL.md");
  if (!fs.existsSync(skillFile)) return null;
  const content = fs.readFileSync(skillFile, "utf8");
  const meta = parseFrontmatter(content);
  return { file: skillFile, meta };
};

const discoverSkills = ({ repoPath, pathHint }) => {
  const includeInternal = isTruthy(process.env.INSTALL_INTERNAL_SKILLS);
  const candidateRoots = [
    "skills",
    "skills/.curated",
    "skills/.experimental",
    "skills/.system",
    ".agents/skills",
    ".agent/skills",
    ".augment/skills",
    ".claude/skills",
    ".cursor/skills",
  ];

  const skillRoots = [];
  const skillMap = new Map();
  let impliedSkill = null;

  let restrictedRoot = null;
  if (pathHint) {
    const hintAbs = path.join(repoPath, pathHint);
    if (fs.existsSync(hintAbs)) {
      if (fs.statSync(hintAbs).isFile()) {
        restrictedRoot = path.dirname(hintAbs);
      } else {
        const skillFile = path.join(hintAbs, "SKILL.md");
        if (fs.existsSync(skillFile)) {
          const info = readSkillInfo(hintAbs);
          if (info && (includeInternal || !info.meta.internal)) {
            impliedSkill = path.basename(hintAbs);
          }
          restrictedRoot = path.dirname(hintAbs);
        } else {
          restrictedRoot = hintAbs;
        }
      }
    }
  }

  const rootsToScan = restrictedRoot
    ? [restrictedRoot]
    : [repoPath, ...candidateRoots.map((root) => path.join(repoPath, root))];

  const uniqueRoots = new Set();
  for (const root of rootsToScan) {
    if (!root || !fs.existsSync(root) || !fs.statSync(root).isDirectory()) {
      continue;
    }
    const normalized = path.resolve(root);
    if (uniqueRoots.has(normalized)) continue;
    uniqueRoots.add(normalized);

    const rootSkillFile = path.join(normalized, "SKILL.md");
    if (fs.existsSync(rootSkillFile)) {
      const info = readSkillInfo(normalized);
      if (info && (includeInternal || !info.meta.internal)) {
        skillMap.set("__root__", {
          id: "__root__",
          dir: normalized,
          meta: info.meta,
          root: normalized,
        });
        skillRoots.push(normalized);
      }
    }

    const entries = fs.readdirSync(normalized, { withFileTypes: true });
    for (const entry of entries) {
      if (!entry.isDirectory()) continue;
      const skillDir = path.join(normalized, entry.name);
      const info = readSkillInfo(skillDir);
      if (!info) continue;
      if (!includeInternal && info.meta.internal) continue;
      skillMap.set(entry.name, {
        id: entry.name,
        dir: skillDir,
        meta: info.meta,
        root: normalized,
      });
      if (!skillRoots.includes(normalized)) {
        skillRoots.push(normalized);
      }
    }
  }

  const skills = Array.from(skillMap.values()).filter((skill) => skill.id !== "__root__");
  const rootSkill = skillMap.get("__root__") || null;

  return {
    skills,
    rootSkill,
    skillRoots,
    impliedSkill,
  };
};

const deriveCatalogs = ({ sourceName, skillRoots, repoPath }) => {
  const relRoots = skillRoots.map((root) => {
    const rel = path.relative(repoPath, root) || ".";
    return rel.replace(/\\/g, "/");
  });

  const unique = Array.from(new Set(relRoots));
  if (unique.length === 0) {
    return { baseDir: ".", catalogs: {} };
  }

  let primary = null;
  if (unique.includes("skills")) {
    primary = "skills";
  } else if (unique.length === 1) {
    primary = unique[0];
  } else if (unique.includes(".")) {
    primary = ".";
  } else {
    primary = unique[0];
  }

  const catalogs = {};
  const usedKeys = new Set();
  const addCatalog = (key, value) => {
    let candidate = key;
    let counter = 2;
    while (usedKeys.has(candidate)) {
      candidate = `${key}-${counter}`;
      counter += 1;
    }
    usedKeys.add(candidate);
    catalogs[candidate] = value;
  };

  for (const root of unique) {
    if (root === primary) {
      addCatalog(sourceName, root);
      continue;
    }
    let suffix = root.replace(/^\.\//, "");
    if (primary !== "." && suffix.startsWith(`${primary}/`)) {
      suffix = suffix.slice(primary.length + 1);
    }
    suffix = suffix.replace(/^\.+/, "");
    suffix = suffix.replace(/\//g, "-");
    suffix = suffix.replace(/[^a-zA-Z0-9-]+/g, "-");
    suffix = suffix.replace(/^-+/, "").replace(/-+$/, "");
    const key = suffix ? `${sourceName}-${suffix}` : `${sourceName}-extra`;
    addCatalog(key, root);
  }

  return { baseDir: ".", catalogs };
};

const updateSelectionInLines = (lines, sourceName, skillsToAdd) => {
  const escapeRegExp = (str) => str.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const sourceLineRe = new RegExp(
    `^(\\s*)${escapeRegExp(sourceName)}\\s*=\\s*\\{\\s*$`,
  );
  let inSource = false;
  let braceDepth = 0;
  let sourceIndent = "";
  let selectionStart = -1;
  let selectionEnd = -1;
  let selectionIndent = "";
  let itemIndent = "";
  let sourceEnd = -1;

  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i];
    if (!inSource) {
      const match = line.match(sourceLineRe);
      if (match) {
        inSource = true;
        sourceIndent = match[1] ?? "";
        braceDepth = 1;
        continue;
      }
    } else {
      if (selectionStart === -1) {
        const selMatch = line.match(/^(\s*)selection\.enable\s*=\s*\[/);
        if (selMatch) {
          selectionStart = i;
          selectionIndent = selMatch[1] ?? "";
          if (/selection\.enable\s*=\s*\[.*\];/.test(line)) {
            selectionEnd = i;
          }
        }
      } else if (selectionEnd === -1) {
        if (/^\s*];\s*$/.test(line)) {
          selectionEnd = i;
        }
      }

      const sanitized = stripCommentsAndStrings(line);
      braceDepth += countChar(sanitized, "{") - countChar(sanitized, "}");
      if (braceDepth === 0) {
        sourceEnd = i;
        break;
      }
    }
  }

  if (!inSource) {
    throw new Error(`Source not found in ${path.relative(repoRoot, sourcesFile)}: ${sourceName}`);
  }
  if (sourceEnd === -1) {
    throw new Error(`Failed to find end of source block: ${sourceName}`);
  }

  const parseInlineItems = (text) => {
    const matches = text.match(/"([^"]+)"/g) || [];
    return matches.map((m) => m.slice(1, -1));
  };

  let existing = [];
  if (selectionStart !== -1) {
    if (selectionEnd === -1) {
      throw new Error(`Failed to find end of selection.enable list for ${sourceName}`);
    }
    if (selectionStart === selectionEnd) {
      const inlineMatch = lines[selectionStart].match(
        /selection\.enable\s*=\s*\[(.*)\];/,
      );
      if (inlineMatch) {
        existing = parseInlineItems(inlineMatch[1]);
      }
    } else {
      for (let i = selectionStart + 1; i < selectionEnd; i += 1) {
        const line = lines[i];
        const matches = line.match(/"([^"]+)"/g);
        if (!matches) continue;
        for (const match of matches) {
          existing.push(match.slice(1, -1));
        }
      }
      if (selectionStart + 1 < selectionEnd) {
        const firstItemLine = lines[selectionStart + 1];
        const indentMatch = firstItemLine.match(/^(\s*)\S/);
        if (indentMatch) {
          itemIndent = indentMatch[1];
        }
      }
    }
  }

  if (!selectionIndent) {
    selectionIndent = `${sourceIndent}  `;
  }
  if (!itemIndent) {
    itemIndent = `${selectionIndent}  `;
  }

  const existingSet = new Set(existing);
  const added = [];
  const already = [];
  for (const skill of skillsToAdd) {
    if (existingSet.has(skill)) {
      already.push(skill);
    } else {
      existingSet.add(skill);
      added.push(skill);
    }
  }

  if (added.length === 0) {
    return { lines, added, already, changed: false };
  }

  const sorted = Array.from(existingSet).sort((a, b) => a.localeCompare(b));
  const newListLines = [
    `${selectionIndent}selection.enable = [`,
    ...sorted.map((skill) => `${itemIndent}"${skill}"`),
    `${selectionIndent}];`,
  ];

  if (selectionStart !== -1) {
    lines.splice(selectionStart, selectionEnd - selectionStart + 1, ...newListLines);
  } else {
    lines.splice(sourceEnd, 0, ...newListLines);
  }

  return { lines, added, already, changed: true };
};

const buildSourceBlock = ({
  sourceName,
  url,
  flake,
  baseDir,
  catalogs,
  selection,
}) => {
  const lines = [];
  lines.push(`  ${sourceName} = {`);
  lines.push(`    url = "${url}";`);
  lines.push(`    flake = ${flake ? "true" : "false"};`);
  lines.push(`    baseDir = "${baseDir}";`);
  lines.push(`    catalogs = {`);
  const catalogKeys = Object.keys(catalogs).sort((a, b) => a.localeCompare(b));
  for (const key of catalogKeys) {
    lines.push(`      ${key} = "${catalogs[key]}";`);
  }
  lines.push("    };");
  lines.push("    selection.enable = [");
  const sorted = Array.from(selection).sort((a, b) => a.localeCompare(b));
  for (const skill of sorted) {
    lines.push(`      "${skill}"`);
  }
  lines.push("    ];");
  lines.push("  };");
  return lines;
};

const insertSourceBlock = (lines, blockLines) => {
  let insertIndex = -1;
  let depth = 0;
  for (let i = 0; i < lines.length; i += 1) {
    const sanitized = stripCommentsAndStrings(lines[i]);
    depth += countChar(sanitized, "{") - countChar(sanitized, "}");
    if (depth === 0) {
      insertIndex = i;
      break;
    }
  }
  if (insertIndex === -1) {
    throw new Error("Failed to find end of sources file for insertion.");
  }
  const updated = lines.slice(0, insertIndex);
  updated.push(...blockLines);
  updated.push(...lines.slice(insertIndex));
  return updated;
};

const parseArgs = () => {
  if (args.length === 0 || args.includes("-h") || args.includes("--help")) {
    usage(args.length === 0 ? 1 : 0);
  }

  const options = {
    list: false,
    all: false,
    skills: [],
    yes: false,
    dryRun: false,
    global: false,
    agent: false,
    sourceOverride: null,
  };
  const positional = [];

  let i = 0;
  while (i < args.length) {
    const arg = args[i];
    if (arg === "--list" || arg === "-l") {
      options.list = true;
      i += 1;
      continue;
    }
    if (arg === "--all") {
      options.all = true;
      i += 1;
      continue;
    }
    if (arg === "--skill" || arg === "-s") {
      i += 1;
      while (i < args.length && !args[i].startsWith("-")) {
        options.skills.push(args[i]);
        i += 1;
      }
      continue;
    }
    if (arg === "--yes" || arg === "-y") {
      options.yes = true;
      i += 1;
      continue;
    }
    if (arg === "--dry-run") {
      options.dryRun = true;
      i += 1;
      continue;
    }
    if (arg === "--global" || arg === "-g") {
      options.global = true;
      i += 1;
      continue;
    }
    if (arg === "--agent" || arg === "-a") {
      options.agent = true;
      i += 1;
      continue;
    }
    if (arg === "--source" || arg === "--src") {
      const next = args[i + 1];
      if (!next) {
        console.error("Missing value for --source");
        usage(1);
      }
      options.sourceOverride = next;
      i += 2;
      continue;
    }
    if (arg.startsWith("-")) {
      console.error(`Unknown option: ${arg}`);
      usage(1);
    }
    positional.push(arg);
    i += 1;
  }

  return { options, positional };
};

const { options, positional } = parseArgs();

if (options.global || options.agent) {
  console.warn("Note: --global/--agent are no-ops; this repo manages skills via Nix.");
}

const hasSkillSelector = options.all || options.skills.length > 0;
const useSourceMode = positional.some((value) => looksLikeSource(value));

if (!useSourceMode && positional.length === 0 && !options.sourceOverride) {
  console.error("No source specified.");
  usage(1);
}

const legacyMode = !useSourceMode && (positional.length > 0 || options.sourceOverride);

if (legacyMode) {
  // Legacy mode: treat positional args as skill ids and map via nix list
  const skillIds = positional.filter(Boolean);
  if (skillIds.length === 0) {
    console.error("No skill IDs provided.");
    usage(1);
  }
  let sourceFilter = options.sourceOverride || null;
  if (sourceFilter && !existingSourceNames.has(sourceFilter)) {
    console.error(`Unknown source: ${sourceFilter}`);
    process.exit(1);
  }
  let catalogMap = null;
  try {
    const output = execSync("nix run .#list", {
      cwd: repoRoot,
      stdio: ["ignore", "pipe", "pipe"],
    }).toString();
    const data = JSON.parse(output);
    catalogMap = new Map();
    for (const skill of data.skills || []) {
      catalogMap.set(skill.id, skill.source);
    }
  } catch (error) {
    console.error("Failed to resolve skill sources via `nix run .#list`.");
    process.exit(1);
  }

  const additionsBySource = new Map();
  for (const skillId of skillIds) {
    const sourceName = sourceFilter || catalogMap.get(skillId);
    if (!sourceName) {
      console.error(`Unable to resolve source for ${skillId}`);
      process.exit(1);
    }
    if (!additionsBySource.has(sourceName)) {
      additionsBySource.set(sourceName, []);
    }
    additionsBySource.get(sourceName).push(skillId);
  }

  const eol = sourceContent.includes("\r\n") ? "\r\n" : "\n";
  let lines = sourceContent.split(eol);
  let anyChanges = false;

  for (const [sourceName, skillsToAdd] of additionsBySource.entries()) {
    const uniqueSkills = Array.from(new Set(skillsToAdd));
    const result = updateSelectionInLines(lines, sourceName, uniqueSkills);
    lines = result.lines;
    if (result.added.length > 0) {
      anyChanges = true;
      console.log(`Added to ${sourceName}: ${result.added.join(", ")}`);
    }
    if (result.already.length > 0) {
      console.log(`Already enabled in ${sourceName}: ${result.already.join(", ")}`);
    }
  }

  if (!anyChanges) {
    console.log("No changes made.");
    process.exit(0);
  }

  if (options.dryRun) {
    console.log("Dry run enabled. No files were modified.");
    process.exit(0);
  }

  fs.writeFileSync(sourcesFile, lines.join(eol), "utf8");
  execSync(`tsx "${syncScript}"`, { cwd: repoRoot, stdio: "inherit" });
  console.log(`Updated ${path.relative(repoRoot, sourcesFile)}.`);
  console.log("Run `mise run skills:install` to apply changes.");
  process.exit(0);
}

if (positional.length === 0) {
  console.error("No source specified.");
  usage(1);
}

if (positional.length > 1) {
  console.warn("Multiple sources provided; only the first one will be processed in this implementation.");
}

const sourceInput = positional[0];
const parsedSource = parseSourceInput(sourceInput);
if (!parsedSource) {
  console.error(`Unsupported source: ${sourceInput}`);
  process.exit(1);
}

let repoPath = null;
let tempDir = null;
let sourceUrl = null;
let sourceNameHint = null;
let sourceName = null;
let existingSourceName = null;
let localDestPath = null;
let ref = parsedSource.ref || null;
let hintPath = parsedSource.hintPath || null;

if (parsedSource.kind === "local") {
  repoPath = parsedSource.path;
  const baseName = sanitizeName(path.basename(repoPath)) || "local-skills";
  const candidateDest = path.join(localSkillsDir, baseName);
  const candidateUrl = toPathUrl(candidateDest);
  const match = existingSources.sources.find((source) =>
    normalizeUrl(source.url) === normalizeUrl(candidateUrl)
  );
  if (match) {
    existingSourceName = match.name;
    sourceName = match.name;
    const relPath = match.url.startsWith("path:") ? match.url.slice("path:".length) : null;
    localDestPath = relPath ? path.resolve(repoRoot, relPath) : candidateDest;
    sourceUrl = match.url;
  } else {
    sourceName = uniqueSourceName(baseName);
    localDestPath = path.join(localSkillsDir, sourceName);
    sourceUrl = toPathUrl(localDestPath);
  }
} else {
  if (parsedSource.kind === "github") {
    sourceUrl = `github:${parsedSource.owner}/${parsedSource.repo}`;
    sourceNameHint = `${parsedSource.owner}-${parsedSource.repo}`;
  } else if (parsedSource.kind === "gitlab") {
    sourceUrl = `git+${parsedSource.url.replace(/\.git$/, "")}.git`;
    sourceNameHint = `${parsedSource.owner}-${parsedSource.repo}`;
  } else {
    sourceUrl = toGitUrl(parsedSource.url);
    const base = parsedSource.url.split("/").pop() || "skills-source";
    sourceNameHint = base.replace(/\.git$/, "");
  }
  const match = existingSources.sources.find((source) =>
    normalizeUrl(source.url) === normalizeUrl(sourceUrl)
  );
  existingSourceName = match ? match.name : null;
  sourceName = existingSourceName || uniqueSourceName(sourceNameHint);

  tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "skills-add-"));
  const cloneUrl = parsedSource.kind === "github" || parsedSource.kind === "gitlab"
    ? parsedSource.url.replace(/\.git$/, "") + ".git"
    : parsedSource.url;
  const cloneArgs = ["clone", "--depth", "1", cloneUrl, tempDir];
  execSync(`git ${cloneArgs.map((arg) => `"${arg}"`).join(" ")}`, { stdio: "inherit" });
  repoPath = tempDir;
  if (ref) {
    execSync(`git -C "${repoPath}" fetch --depth 1 origin "${ref}"`, { stdio: "inherit" });
    execSync(`git -C "${repoPath}" checkout "${ref}"`, { stdio: "inherit" });
  }
}

const discovery = discoverSkills({ repoPath, pathHint: hintPath });
let skills = discovery.skills.map((s) => s.id);

if (skills.length === 0 && discovery.rootSkill) {
  skills = [sourceName];
  if (discovery.rootSkill.meta?.name && discovery.rootSkill.meta.name !== sourceName) {
    console.warn(
      `Root SKILL.md name \"${discovery.rootSkill.meta.name}\" differs from source name \"${sourceName}\". Using \"${sourceName}\" for selection.`,
    );
  }
}

let impliedSkill = discovery.impliedSkill;
if (impliedSkill && !skills.includes(impliedSkill)) {
  impliedSkill = null;
}

if (options.list) {
  const sorted = skills.slice().sort((a, b) => a.localeCompare(b));
  console.log(sorted.join("\n"));
  process.exit(0);
}

let selectedSkills = [];
if (impliedSkill && !hasSkillSelector) {
  selectedSkills = [impliedSkill];
} else if (options.all || options.skills.includes("*")) {
  selectedSkills = skills;
} else if (options.skills.length > 0) {
  selectedSkills = options.skills;
} else {
  selectedSkills = skills;
}

const missing = selectedSkills.filter((skill) => !skills.includes(skill));
if (missing.length > 0) {
  console.error(`Unknown skills: ${missing.join(", ")}`);
  process.exit(1);
}

if (selectedSkills.length === 0) {
  console.error("No skills discovered.");
  process.exit(1);
}

const { baseDir, catalogs } = deriveCatalogs({
  sourceName,
  skillRoots: discovery.skillRoots,
  repoPath,
});

let newLines = existingSources.lines.slice();
let anyChanges = false;

if (!existingSourceName) {
  const finalUrl = ref
    ? (sourceUrl.includes("?") ? `${sourceUrl}&ref=${ref}` : `${sourceUrl}?ref=${ref}`)
    : sourceUrl;
  const newSourceBlock = buildSourceBlock({
    sourceName,
    url: finalUrl,
    flake: false,
    baseDir,
    catalogs,
    selection: selectedSkills,
  });
  newLines = insertSourceBlock(newLines, newSourceBlock);
  anyChanges = true;
  console.log(`Added new source: ${sourceName}`);
} else {
  const result = updateSelectionInLines(newLines, sourceName, selectedSkills);
  newLines = result.lines;
  if (result.added.length > 0) {
    anyChanges = true;
    console.log(`Added to ${sourceName}: ${result.added.join(", ")}`);
  }
  if (result.already.length > 0) {
    console.log(`Already enabled in ${sourceName}: ${result.already.join(", ")}`);
  }
}

if (!anyChanges) {
  console.log("No changes made.");
  process.exit(0);
}

if (options.dryRun) {
  console.log("Dry run enabled. No files were modified.");
  process.exit(0);
}

if (parsedSource.kind === "local" && localDestPath) {
  fs.mkdirSync(localSkillsDir, { recursive: true });
  const resolvedRepo = path.resolve(repoPath);
  const resolvedDest = path.resolve(localDestPath);
  if (resolvedRepo !== resolvedDest) {
    execSync(`rsync -a --delete \"${resolvedRepo}/\" \"${resolvedDest}/\"`, { stdio: "inherit" });
  }
}

const eol = sourceContent.includes("\r\n") ? "\r\n" : "\n";
fs.writeFileSync(sourcesFile, newLines.join(eol), "utf8");
execSync(`tsx "${syncScript}"`, { cwd: repoRoot, stdio: "inherit" });
console.log(`Updated ${path.relative(repoRoot, sourcesFile)}.`);
console.log("Run `mise run skills:install` to apply changes.");
