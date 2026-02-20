import * as path from "node:path";

import type {
  BuildSourceBlockParams,
  DeriveCatalogsParams,
  DeriveCatalogsResult,
  ExistingSources,
  ParsedSource,
  SelectionUpdateResult,
  SourceBlock,
} from "./types.ts";

export const isTruthy = (value: string | undefined): boolean => {
  if (!value) return false;
  const normalized = String(value).toLowerCase();
  return !["0", "false", "no", "off"].includes(normalized);
};

export const countChar = (str: string, char: string): number => {
  let count = 0;
  for (const ch of str) {
    if (ch === char) count += 1;
  }
  return count;
};

export const stripComments = (line: string): string => line.replace(/#.*/, "");

export const extractSourceBlocks = (content: string): ExistingSources => {
  const lines = content.split(/\r?\n/);
  let depth = 0;
  const sources: SourceBlock[] = [];
  let current: SourceBlock | null = null;
  for (let i = 0; i < lines.length; i += 1) {
    const raw = lines[i];
    const sanitized = stripComments(raw);
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

export const normalizeUrl = (url: string, repoRoot: string): string | null => {
  if (!url) return null;
  let normalized = url;

  if (normalized.startsWith("github:")) {
    normalized = `https://github.com/${normalized.slice("github:".length)}`;
  }

  if (normalized.startsWith("git+")) {
    normalized = normalized.replace(/^git\+/, "");
  }

  if (normalized.startsWith("path:")) {
    const rel = normalized.slice("path:".length);
    return path.resolve(repoRoot, rel);
  }

  normalized = normalized.replace(/\.git$/, "");
  normalized = normalized.split("?")[0].split("#")[0];

  return normalized.startsWith("https://github.com/") ? normalized.toLowerCase() : normalized;
};

export const sanitizeName = (value: string): string =>
  value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+/, "")
    .replace(/-+$/, "");

export const toGitUrl = (value: string): string => {
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

export const parseFrontmatter = (content: string): { name: string | null; internal: boolean } => {
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
  let name: string | null = null;
  let internal = false;
  let metadataIndent: number | null = null;
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

export const deriveCatalogs = ({
  sourceName,
  skillRoots,
  repoPath,
}: DeriveCatalogsParams): DeriveCatalogsResult => {
  const relRoots = skillRoots.map((root) => {
    const rel = path.relative(repoPath, root) || ".";
    return rel.replace(/\\/g, "/");
  });

  const unique = Array.from(new Set(relRoots));
  if (unique.length === 0) {
    return { baseDir: ".", catalogs: {} };
  }

  let primary: string | null = null;
  if (unique.includes("skills")) {
    primary = "skills";
  } else if (unique.length === 1) {
    primary = unique[0];
  } else if (unique.includes(".")) {
    primary = ".";
  } else {
    primary = unique[0];
  }

  const catalogs: Record<string, string> = {};
  const usedKeys = new Set<string>();
  const addCatalog = (key: string, value: string): void => {
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

export const updateSelectionInLines = (
  lines: string[],
  sourceName: string,
  skillsToAdd: string[],
): SelectionUpdateResult => {
  const escapeRegExp = (str: string): string => str.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const sourceLineRe = new RegExp(`^(\\s*)${escapeRegExp(sourceName)}\\s*=\\s*\\{\\s*$`);
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

      const sanitized = stripComments(line);
      braceDepth += countChar(sanitized, "{") - countChar(sanitized, "}");
      if (braceDepth === 0) {
        sourceEnd = i;
        break;
      }
    }
  }

  if (!inSource) {
    throw new Error(`Source not found: ${sourceName}`);
  }
  if (sourceEnd === -1) {
    throw new Error(`Failed to find end of source block: ${sourceName}`);
  }

  const parseInlineItems = (text: string): string[] => {
    const matches = text.match(/"([^"]+)"/g) || [];
    return matches.map((m) => m.slice(1, -1));
  };

  let existing: string[] = [];
  if (selectionStart !== -1) {
    if (selectionEnd === -1) {
      throw new Error(`Failed to find end of selection.enable list for ${sourceName}`);
    }
    if (selectionStart === selectionEnd) {
      const inlineMatch = lines[selectionStart].match(/selection\.enable\s*=\s*\[(.*)\];/);
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
  const added: string[] = [];
  const already: string[] = [];
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

export const buildSourceBlock = ({
  sourceName,
  url,
  flake,
  baseDir,
  catalogs,
  selection,
}: BuildSourceBlockParams): string[] => {
  const lines: string[] = [];
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

export const insertSourceBlock = (lines: string[], blockLines: string[]): string[] => {
  let insertIndex = -1;
  let depth = 0;
  let seenPositiveDepth = false;
  for (let i = 0; i < lines.length; i += 1) {
    const sanitized = stripComments(lines[i]);
    depth += countChar(sanitized, "{") - countChar(sanitized, "}");
    if (depth > 0) seenPositiveDepth = true;
    if (seenPositiveDepth && depth === 0) {
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

export const parseGitHubUrl = (parsed: URL): ParsedSource | null => {
  const parts = parsed.pathname.replace(/^\/+/, "").split("/");
  if (parts.length < 2) return null;
  const owner = parts[0];
  const repo = parts[1].replace(/\.git$/, "");
  let ref: string | null = null;
  let hintPath: string | null = null;
  if (parts[2] === "tree" && parts.length >= 4) {
    ref = parts[3];
    hintPath = parts.slice(4).join("/") || null;
  }
  return { kind: "github", url: `${parsed.origin}/${owner}/${repo}`, owner, repo, ref, hintPath };
};

export const parseGitLabUrl = (parsed: URL): ParsedSource | null => {
  const parts = parsed.pathname.replace(/^\/+/, "").split("/");
  if (parts.length < 2) return null;
  const owner = parts[0];
  const repo = parts[1].replace(/\.git$/, "");
  let ref: string | null = null;
  let hintPath: string | null = null;
  if (parts[2] === "-" && parts[3] === "tree" && parts.length >= 5) {
    ref = parts[4];
    hintPath = parts.slice(5).join("/") || null;
  }
  return { kind: "gitlab", url: `${parsed.origin}/${owner}/${repo}`, owner, repo, ref, hintPath };
};
