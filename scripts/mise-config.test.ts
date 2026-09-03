#!/usr/bin/env bun

import { describe, expect, it } from "bun:test";
import { spawnSync } from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";
import { repoFile, repoRoot } from "./repo-file.ts";

const configDir = repoFile("mise");
const osConfigs = ["config.default.toml", "config.windows.toml", "config.pi.toml"];
const workstationConfig = "config.workstation.toml";

const readTools = (file: string): Map<string, string> => {
  const tools = new Map<string, string>();
  let inTools = false;

  for (const sourceLine of fs.readFileSync(path.join(configDir, file), "utf8").split("\n")) {
    const line = sourceLine.trim();
    if (line === "[tools]") {
      inTools = true;
      continue;
    }
    if (inTools && line.startsWith("[")) {
      inTools = false;
    }
    if (!inTools || line.length === 0 || line.startsWith("#")) {
      continue;
    }

    const match = line.match(/^(?:"([^"]+)"|([^=\s]+))\s*=\s*([^#]+?)(?:\s+#.*)?$/);
    if (match === null) {
      continue;
    }
    const key = match[1] ?? match[2];
    const value = match[3]?.trim();
    if (key !== undefined && value !== undefined) {
      tools.set(key, value);
    }
  }

  return tools;
};

const cleanMiseEnv = (): NodeJS.ProcessEnv => {
  const env = { ...process.env };
  delete env.MISE_CONFIG_FILE;
  delete env.MISE_GLOBAL_CONFIG_FILE;
  delete env.MISE_ENV;
  return env;
};

const configPaths = (overrides: NodeJS.ProcessEnv): string[] => {
  const result = spawnSync("mise", ["config", "ls", "--json"], {
    cwd: repoRoot,
    encoding: "utf8",
    env: { ...cleanMiseEnv(), ...overrides },
  });
  if (result.status !== 0) {
    throw new Error(`mise config ls failed: ${result.stderr}`);
  }
  return [...result.stdout.matchAll(/"path"\s*:\s*"([^"]+)"/g)].map((match) => match[1] ?? "");
};

const hasConfig = (paths: string[], file: string): boolean => paths.some((entry) => entry.endsWith(`/mise/${file}`));

describe("shared mise tool overlay", () => {
  it("keeps config.toml settings-only", () => {
    expect(readTools("config.toml")).toEqual(new Map());
  });

  it("has no duplicated key/value across default, Windows, and Pi configs", () => {
    const tools = osConfigs.map(readTools);
    const common = [...tools[0].entries()].filter(([key, value]) => tools.every((config) => config.get(key) === value));

    expect(common).toEqual([]);
  });

  it("has no duplicated key/value between default and Windows configs", () => {
    const defaultTools = readTools("config.default.toml");
    const windowsTools = readTools("config.windows.toml");
    const common = [...defaultTools.entries()].filter(([key, value]) => windowsTools.get(key) === value);

    expect(common).toEqual([]);
  });

  it("keeps workstation tools out of all other config files", () => {
    const workstationTools = readTools(workstationConfig);
    const otherConfigs = [...osConfigs, "config.shared.toml"];

    for (const file of otherConfigs) {
      const tools = readTools(file);
      for (const key of workstationTools.keys()) {
        expect(tools.has(key)).toBe(false);
      }
    }
  });

  it("keeps config.workstation.toml tools-only", () => {
    const sections = fs
      .readFileSync(path.join(configDir, workstationConfig), "utf8")
      .split("\n")
      .map((line) => line.trim())
      .filter((line) => line.startsWith("[") && line.endsWith("]"));

    expect(sections).toEqual(["[tools]"]);
  });

  it("keeps the common latest pins only in config.shared.toml", () => {
    const shared = readTools("config.shared.toml");
    const expectedSharedKeys = [
      "actionlint",
      "biome",
      "eza",
      "fd",
      "github:astral-sh/uv",
      "github:cli/cli",
      "gitleaks",
      "go",
      "jq",
      "node",
      "npm:@antfu/ni",
      "npm:@dotenvx/dotenvx",
      "npm:@google/design.md",
      "npm:@sasazame/ccresume",
      "npm:@upstash/context7-mcp",
      "npm:aicommits",
      "npm:markdown-link-check",
      "npm:markdownlint-cli2",
      "npm:npm-check-updates",
      "npm:o3-search-mcp",
      "npm:opencommit",
      "npm:textlint",
      "npm:textlint-rule-preset-ja-technical-writing",
      "npm:tsx",
      "pipx:beautysh",
      "pnpm",
      "prettier",
      "stylua",
      "taplo",
      "yazi",
    ];

    expect([...shared.keys()].sort()).toEqual([...expectedSharedKeys].sort());
    for (const file of osConfigs) {
      const tools = readTools(file);
      for (const key of expectedSharedKeys) {
        expect(tools.has(key)).toBe(false);
      }
    }
  });

  it("loads the selected default config and shared overlay", () => {
    const paths = configPaths({
      MISE_CONFIG_FILE: repoFile("mise", "config.default.toml"),
      MISE_ENV: "shared",
    });

    expect(hasConfig(paths, "config.default.toml")).toBe(true);
    expect(hasConfig(paths, "config.shared.toml")).toBe(true);
  });

  it("loads the workstation overlay when selected", () => {
    const paths = configPaths({
      MISE_CONFIG_FILE: repoFile("mise", "config.default.toml"),
      MISE_ENV: "shared,workstation",
    });

    expect(hasConfig(paths, "config.shared.toml")).toBe(true);
    expect(hasConfig(paths, workstationConfig)).toBe(true);
  });

  it("keeps the macOS overlay when shared is also selected", () => {
    const paths = configPaths({
      MISE_CONFIG_FILE: repoFile("mise", "config.default.toml"),
      MISE_ENV: "macos,shared",
    });

    expect(hasConfig(paths, "config.default.toml")).toBe(true);
    expect(hasConfig(paths, "config.macos.toml")).toBe(true);
    expect(hasConfig(paths, "config.shared.toml")).toBe(true);
  });

  it("loads the selected Pi config and shared overlay", () => {
    const paths = configPaths({
      MISE_CONFIG_FILE: repoFile("mise", "config.pi.toml"),
      MISE_ENV: "shared",
    });

    expect(hasConfig(paths, "config.pi.toml")).toBe(true);
    expect(hasConfig(paths, "config.shared.toml")).toBe(true);
    expect(readTools("config.pi.toml").has("hadolint")).toBe(false);
  });

  it("loads the Windows global config and shared overlay", () => {
    const paths = configPaths({
      MISE_GLOBAL_CONFIG_FILE: repoFile("mise", "config.windows.toml"),
      MISE_ENV: "shared",
    });

    expect(hasConfig(paths, "config.windows.toml")).toBe(true);
    expect(hasConfig(paths, "config.shared.toml")).toBe(true);
  });

  it("keeps CI isolated from default, shared, and workstation overlays", () => {
    const paths = configPaths({
      MISE_CONFIG_FILE: repoFile("mise", "config.ci.toml"),
      MISE_ENV: "",
    });

    expect(hasConfig(paths, "config.ci.toml")).toBe(true);
    expect(hasConfig(paths, "config.default.toml")).toBe(false);
    expect(hasConfig(paths, "config.shared.toml")).toBe(false);
    expect(hasConfig(paths, workstationConfig)).toBe(false);
  });
});
