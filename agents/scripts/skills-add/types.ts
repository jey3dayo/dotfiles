export interface SourceBlock {
  name: string;
  start: number;
  end: number | null;
  url: string | null;
  flake: boolean | null;
}

export interface ParsedSource {
  kind: "local" | "github" | "gitlab" | "git";
  path?: string;
  url?: string;
  owner?: string;
  repo?: string;
  ref?: string | null;
  hintPath?: string | null;
}

export interface SkillInfo {
  id: string;
  dir: string;
  meta: { name: string | null; internal: boolean };
  root: string;
}

export interface DiscoveryResult {
  skills: SkillInfo[];
  rootSkill: SkillInfo | null;
  skillRoots: string[];
  impliedSkill: string | null;
}

export interface SelectionUpdateResult {
  lines: string[];
  added: string[];
  already: string[];
  changed: boolean;
}

export interface ExistingSources {
  lines: string[];
  sources: SourceBlock[];
}

export interface DeriveCatalogsParams {
  sourceName: string;
  skillRoots: string[];
  repoPath: string;
}

export interface DeriveCatalogsResult {
  baseDir: string;
  catalogs: Record<string, string>;
}

export interface BuildSourceBlockParams {
  sourceName: string;
  url: string;
  flake: boolean;
  baseDir: string;
  catalogs: Record<string, string>;
  selection: string[];
}
