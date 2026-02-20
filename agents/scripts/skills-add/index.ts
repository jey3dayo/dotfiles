#!/usr/bin/env tsx

import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";
import { execSync } from "node:child_process";
import { fileURLToPath } from "node:url";

import type { ExistingSources } from "./types.ts";
import {
  CliArgumentError,
  discoverSkills,
  looksLikeSource,
  parseArgs,
  parseSourceInput,
} from "./index-lib.ts";
import {
  buildSourceBlock,
  deriveCatalogs,
  extractSourceBlocks,
  insertSourceBlock,
  normalizeUrl,
  sanitizeName,
  toGitUrl,
  updateSelectionInLines,
} from "./utils.ts";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const repoRoot = path.resolve(__dirname, "../../..");
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

if (!fs.existsSync(sourcesFile)) {
  console.error(`Missing file: ${sourcesFile}`);
  process.exit(1);
}

const sourceContent = fs.readFileSync(sourcesFile, "utf8");

const existingSources: ExistingSources = extractSourceBlocks(sourceContent);
const existingSourceNames = new Set(existingSources.sources.map((s) => s.name));

const uniqueSourceName = (base: string): string => {
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

const toPathUrl = (absPath: string): string => {
  const rel = path.relative(repoRoot, absPath).replace(/\\/g, "/");
  const normalized = rel.startsWith(".") ? rel : `./${rel}`;
  return `path:${normalized}`;
};

if (args.length === 0 || args.includes("-h") || args.includes("--help")) {
  usage(args.length === 0 ? 1 : 0);
}

let parsedArgs: ReturnType<typeof parseArgs>;
try {
  parsedArgs = parseArgs(args);
} catch (error) {
  if (error instanceof CliArgumentError) {
    console.error(error.message);
    usage(1);
  }
  throw error;
}

const { options, positional } = parsedArgs;

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
  const skillIds = positional.filter(Boolean);
  if (skillIds.length === 0) {
    console.error("No skill IDs provided.");
    usage(1);
  }
  const sourceFilter = options.sourceOverride || null;
  if (sourceFilter && !existingSourceNames.has(sourceFilter)) {
    console.error(`Unknown source: ${sourceFilter}`);
    process.exit(1);
  }
  let catalogMap: Map<string, string> | null = null;
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
  } catch {
    console.error("Failed to resolve skill sources via `nix run .#list`.");
    process.exit(1);
  }

  const additionsBySource = new Map<string, string[]>();
  for (const skillId of skillIds) {
    const sourceName = sourceFilter || catalogMap!.get(skillId);
    if (!sourceName) {
      console.error(`Unable to resolve source for ${skillId}`);
      process.exit(1);
    }
    if (!additionsBySource.has(sourceName)) {
      additionsBySource.set(sourceName, []);
    }
    additionsBySource.get(sourceName)!.push(skillId);
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
  console.warn(
    "Multiple sources provided; only the first one will be processed in this implementation.",
  );
}

const sourceInput = positional[0];
const parsedSource = parseSourceInput(sourceInput);
if (!parsedSource) {
  console.error(`Unsupported source: ${sourceInput}`);
  process.exit(1);
}

let repoPath: string | null = null;
let tempDir: string | null = null;
let sourceUrl: string | null = null;
let sourceNameHint: string | null = null;
let sourceName: string | null = null;
let existingSourceName: string | null = null;
let localDestPath: string | null = null;
let ref: string | null = parsedSource.ref ?? null;
let hintPath: string | null = parsedSource.hintPath ?? null;

if (parsedSource.kind === "local") {
  repoPath = parsedSource.path!;
  const baseName = sanitizeName(path.basename(repoPath)) || "local-skills";
  const candidateDest = path.join(localSkillsDir, baseName);
  const candidateUrl = toPathUrl(candidateDest);
  const match = existingSources.sources.find(
    (source) =>
      normalizeUrl(source.url!, repoRoot) === normalizeUrl(candidateUrl, repoRoot),
  );
  if (match) {
    existingSourceName = match.name;
    sourceName = match.name;
    const relPath = match.url?.startsWith("path:") ? match.url.slice("path:".length) : null;
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
    sourceUrl = `git+${parsedSource.url!.replace(/\.git$/, "")}.git`;
    sourceNameHint = `${parsedSource.owner}-${parsedSource.repo}`;
  } else {
    sourceUrl = toGitUrl(parsedSource.url!);
    const base = parsedSource.url!.split("/").pop() || "skills-source";
    sourceNameHint = base.replace(/\.git$/, "");
  }
  const match = existingSources.sources.find(
    (source) =>
      normalizeUrl(source.url!, repoRoot) === normalizeUrl(sourceUrl!, repoRoot),
  );
  existingSourceName = match ? match.name : null;
  sourceName = existingSourceName || uniqueSourceName(sourceNameHint!);

  tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "skills-add-"));
  const cloneUrl =
    parsedSource.kind === "github" || parsedSource.kind === "gitlab"
      ? parsedSource.url!.replace(/\.git$/, "") + ".git"
      : parsedSource.url!;
  const cloneArgs = ["clone", "--depth", "1", cloneUrl, tempDir];
  execSync(`git ${cloneArgs.map((arg) => `"${arg}"`).join(" ")}`, { stdio: "inherit" });
  repoPath = tempDir;
  if (ref) {
    execSync(`git -C "${repoPath}" fetch --depth 1 origin "${ref}"`, { stdio: "inherit" });
    execSync(`git -C "${repoPath}" checkout "${ref}"`, { stdio: "inherit" });
  }
}

const discovery = discoverSkills({ repoPath: repoPath!, pathHint: hintPath });
let skills = discovery.skills.map((s) => s.id);

if (skills.length === 0 && discovery.rootSkill) {
  skills = [sourceName!];
  if (
    discovery.rootSkill.meta?.name &&
    discovery.rootSkill.meta.name !== sourceName
  ) {
    console.warn(
      `Root SKILL.md name "${discovery.rootSkill.meta.name}" differs from source name "${sourceName}". Using "${sourceName}" for selection.`,
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

let selectedSkills: string[] = [];
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
  sourceName: sourceName!,
  skillRoots: discovery.skillRoots,
  repoPath: repoPath!,
});

let newLines = existingSources.lines.slice();
let anyChanges = false;

if (!existingSourceName) {
  const isDefaultBranch = ref === "main" || ref === "master";
  const finalUrl =
    ref && !isDefaultBranch
      ? sourceUrl!.startsWith("github:")
        ? `${sourceUrl}/${ref}`
        : sourceUrl!.includes("?")
          ? `${sourceUrl}&ref=${ref}`
          : `${sourceUrl}?ref=${ref}`
      : sourceUrl!;
  const newSourceBlock = buildSourceBlock({
    sourceName: sourceName!,
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
  const result = updateSelectionInLines(newLines, sourceName!, selectedSkills);
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
  const resolvedRepo = path.resolve(repoPath!);
  const resolvedDest = path.resolve(localDestPath);
  if (resolvedRepo !== resolvedDest) {
    execSync(`rsync -a --delete "${resolvedRepo}/" "${resolvedDest}/"`, { stdio: "inherit" });
  }
}

const eol = sourceContent.includes("\r\n") ? "\r\n" : "\n";
fs.writeFileSync(sourcesFile, newLines.join(eol), "utf8");
execSync(`tsx "${syncScript}"`, { cwd: repoRoot, stdio: "inherit" });
console.log(`Updated ${path.relative(repoRoot, sourcesFile)}.`);
console.log("Run `mise run skills:install` to apply changes.");
