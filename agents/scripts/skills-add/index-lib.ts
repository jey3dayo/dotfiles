import * as fs from "node:fs";
import * as path from "node:path";

import type { DiscoveryResult, ParsedSource, SkillInfo } from "./types.ts";
import { isTruthy, parseFrontmatter, parseGitHubUrl, parseGitLabUrl } from "./utils.ts";

export interface CliOptions {
  list: boolean;
  all: boolean;
  skills: string[];
  yes: boolean;
  dryRun: boolean;
  global: boolean;
  agent: boolean;
  sourceOverride: string | null;
}

export interface ParsedCliArgs {
  options: CliOptions;
  positional: string[];
}

export class CliArgumentError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "CliArgumentError";
  }
}

export const looksLikeSource = (
  value: string,
  existsSync: (input: string) => boolean = fs.existsSync,
): boolean => {
  if (!value) return false;
  if (existsSync(value)) return true;
  if (/^https?:\/\//i.test(value)) return true;
  if (/^[\w.-]+\/[\w.-]+$/.test(value)) return true;
  if (/^git@/.test(value)) return true;
  if (/\.git$/.test(value)) return true;
  return false;
};

export const parseSourceInput = (
  value: string,
  options: {
    existsSync?: (input: string) => boolean;
    resolvePath?: (input: string) => string;
  } = {},
): ParsedSource | null => {
  const existsSync = options.existsSync ?? fs.existsSync;
  const resolvePath = options.resolvePath ?? path.resolve;

  if (existsSync(value)) {
    const abs = resolvePath(value);
    return { kind: "local", path: abs, hintPath: null };
  }

  if (/^[\w.-]+\/[\w.-]+$/.test(value)) {
    const [owner, repo] = value.split("/");
    if (!owner || !repo) return null;
    return {
      kind: "github",
      url: `https://github.com/${owner}/${repo}`,
      owner,
      repo,
      ref: null,
      hintPath: null,
    };
  }

  if (/^https?:\/\//i.test(value)) {
    try {
      const parsed = new URL(value);
      const host = parsed.hostname.toLowerCase();
      if (host.includes("github.com")) {
        return parseGitHubUrl(parsed);
      }
      if (host.includes("gitlab.com")) {
        return parseGitLabUrl(parsed);
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

export const parseArgs = (args: string[]): ParsedCliArgs => {
  const parsed: ParsedCliArgs = {
    options: {
      list: false,
      all: false,
      skills: [],
      yes: false,
      dryRun: false,
      global: false,
      agent: false,
      sourceOverride: null,
    },
    positional: [],
  };

  let i = 0;
  while (i < args.length) {
    const arg = args[i];
    if (arg === "--list" || arg === "-l") {
      parsed.options.list = true;
      i += 1;
      continue;
    }
    if (arg === "--all") {
      parsed.options.all = true;
      i += 1;
      continue;
    }
    if (arg === "--skill" || arg === "-s") {
      i += 1;
      while (i < args.length && !args[i].startsWith("-")) {
        parsed.options.skills.push(args[i]);
        i += 1;
      }
      continue;
    }
    if (arg === "--yes" || arg === "-y") {
      parsed.options.yes = true;
      i += 1;
      continue;
    }
    if (arg === "--dry-run") {
      parsed.options.dryRun = true;
      i += 1;
      continue;
    }
    if (arg === "--global" || arg === "-g") {
      parsed.options.global = true;
      i += 1;
      continue;
    }
    if (arg === "--agent" || arg === "-a") {
      parsed.options.agent = true;
      i += 1;
      continue;
    }
    if (arg === "--source" || arg === "--src") {
      const next = args[i + 1];
      if (!next) {
        throw new CliArgumentError("Missing value for --source");
      }
      parsed.options.sourceOverride = next;
      i += 2;
      continue;
    }
    if (arg.startsWith("-")) {
      throw new CliArgumentError(`Unknown option: ${arg}`);
    }
    parsed.positional.push(arg);
    i += 1;
  }

  return parsed;
};

const readSkillInfo = (skillDir: string): { meta: { name: string | null; internal: boolean } } | null => {
  const skillFile = path.join(skillDir, "SKILL.md");
  if (!fs.existsSync(skillFile)) return null;
  const content = fs.readFileSync(skillFile, "utf8");
  const meta = parseFrontmatter(content);
  return { meta };
};

export const discoverSkills = ({
  repoPath,
  pathHint,
}: {
  repoPath: string;
  pathHint: string | null;
}): DiscoveryResult => {
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

  const skillRoots: string[] = [];
  const skillMap = new Map<string, SkillInfo>();
  let impliedSkill: string | null = null;

  let restrictedRoot: string | null = null;
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

  const uniqueRoots = new Set<string>();
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
  const rootSkill = skillMap.get("__root__") ?? null;

  return {
    skills,
    rootSkill,
    skillRoots,
    impliedSkill,
  };
};
