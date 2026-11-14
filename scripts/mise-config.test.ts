#!/usr/bin/env bun

import { describe, expect, it } from "bun:test";
import { spawnSync } from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";
import { repoFile, repoRoot } from "./repo-file.ts";

const configDir = repoFile("mise");
const entryConfigs = ["config.dev-posix.toml", "config.dev-windows.toml", "config.server-pi.toml", "config.ci.toml"];
const devConfig = "config.dev.toml";
const interactiveConfig = "config.interactive.toml";
const allToolsConfig = "conf.d/00-tools-all.toml";
const bunConfig = "config.bun.toml";
// cmd の PATH 上限（8191）対策。上げる前に Windows で PATH 長を測り 1,000 文字以上残す
const WINDOWS_TOOL_BUDGET = 31;

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
  delete env.MISE_CONFIG_DIR;
  delete env.MISE_CONFIG_FILE;
  delete env.MISE_GLOBAL_CONFIG_FILE;
  delete env.MISE_ENV;
  return env;
};

const configPaths = (overrides: NodeJS.ProcessEnv, cwd = repoRoot): string[] => {
  const result = spawnSync("mise", ["config", "ls", "--json"], {
    cwd,
    encoding: "utf8",
    env: { ...cleanMiseEnv(), ...overrides },
  });
  if (result.status !== 0) {
    throw new Error(`mise config ls failed from ${cwd}: ${result.stderr}`);
  }
  // Windows は \ 区切り（mise/ と混在）で返すため、区切りを / にそろえる
  const entries = JSON.parse(result.stdout) as { path: string }[];
  return entries.map((entry) => entry.path.replaceAll("\\", "/"));
};

const settingsFrom = (overrides: NodeJS.ProcessEnv, cwd = repoRoot): Map<string, { value: string; source: string }> => {
  const result = spawnSync("mise", ["settings"], {
    cwd,
    encoding: "utf8",
    env: { ...cleanMiseEnv(), ...overrides },
  });
  if (result.status !== 0) {
    throw new Error(`mise settings failed from ${cwd}: ${result.stderr}`);
  }
  const settings = new Map<string, { value: string; source: string }>();
  for (const line of result.stdout.split("\n")) {
    const match = line.match(/^(\S+)\s+(\S+)\s+(.+)$/);
    if (match) {
      const [, key, value, source] = match;
      if (key && value && source) {
        settings.set(key, { value, source });
      }
    }
  }
  return settings;
};

const hasConfig = (paths: string[], file: string): boolean => paths.some((entry) => entry.endsWith(`/mise/${file}`));

describe("mise config layout and tool isolation", () => {
  it("publishes the correct MISE_ENV to GUI applications (entry goes last)", () => {
    const macosConfig = fs.readFileSync(path.join(configDir, "config.macos.toml"), "utf8");

    expect(macosConfig).toContain('launchctl setenv MISE_ENV "macos,bun,interactive,dev,dev-posix"');
    expect(macosConfig).not.toMatch(/(^|\s)launchctl setenv MISE_(GLOBAL_)?CONFIG_FILE/m);
  });

  it("keeps config.toml settings-only (no [tools])", () => {
    expect(readTools("config.toml")).toEqual(new Map());
  });

  it("defines common tools only in conf.d/00-tools-all.toml", () => {
    const allTools = readTools(allToolsConfig);
    expect(allTools.size).toBeGreaterThan(0);
    expect(allTools.has("node")).toBe(true);
    expect(allTools.has("github:astral-sh/uv")).toBe(true);
    expect(allTools.has("shellcheck")).toBe(true);
    expect(allTools.has("shfmt")).toBe(true);
    expect(allTools.has("yamllint")).toBe(true);
  });

  it("defines bun only in config.bun.toml", () => {
    const bunTools = readTools(bunConfig);
    expect(bunTools.size).toBe(1);
    expect(bunTools.has("bun")).toBe(true);
  });

  it("has no duplicated key/value across all entry configs", () => {
    const tools = entryConfigs.map(readTools);
    const allKeys = new Set(tools.flatMap((config) => [...config.keys()]));
    for (const key of allKeys) {
      const values = tools.map((config) => config.get(key)).filter((v) => v !== undefined);
      if (values.length > 1) {
        const uniqueValues = new Set(values);
        expect(uniqueValues.size).toBe(values.length); // All different or no duplicates
      }
    }
  });

  it("keeps common tools out of interactive, dev, and entry configs", () => {
    const allTools = readTools(allToolsConfig);
    const otherConfigs = [interactiveConfig, devConfig, ...entryConfigs];

    for (const file of otherConfigs) {
      const tools = readTools(file);
      for (const key of allTools.keys()) {
        if (tools.has(key)) {
          throw new Error(`${key} should not be in ${file} (it's in ${allToolsConfig})`);
        }
      }
    }
  });

  it("keeps bun out of interactive, dev, and entry configs", () => {
    const otherConfigs = [interactiveConfig, devConfig, ...entryConfigs];

    for (const file of otherConfigs) {
      const tools = readTools(file);
      if (tools.has("bun")) {
        throw new Error(`bun should not be in ${file} (it's in ${bunConfig})`);
      }
    }
  });

  it("keeps dev tools out of interactive and entry configs", () => {
    const devTools = readTools(devConfig);
    const otherConfigs = [interactiveConfig, ...entryConfigs];

    for (const file of otherConfigs) {
      const tools = readTools(file);
      for (const key of devTools.keys()) {
        if (tools.has(key)) {
          throw new Error(`${key} should not be in ${file} (it's in ${devConfig})`);
        }
      }
    }
  });

  it("keeps config.dev.toml tools-only", () => {
    const sections = fs
      .readFileSync(path.join(configDir, devConfig), "utf8")
      .split("\n")
      .map((line) => line.trim())
      .filter((line) => line.startsWith("[") && line.endsWith("]"));

    expect(sections).toEqual(["[tools]"]);
  });

  it("keeps interactive tools out of the entry configs", () => {
    const interactiveTools = readTools(interactiveConfig);

    expect(interactiveTools.size).toBeGreaterThan(0);
    for (const file of entryConfigs) {
      const tools = readTools(file);
      for (const key of interactiveTools.keys()) {
        if (tools.has(key)) {
          throw new Error(`${key} should not be in ${file} (it's in ${interactiveConfig})`);
        }
      }
    }
  });

  it("keeps CI config isolated (no interactive or dev tools)", () => {
    const ciTools = readTools("config.ci.toml");
    const interactiveTools = readTools(interactiveConfig);
    const devTools = readTools(devConfig);

    for (const key of interactiveTools.keys()) {
      if (ciTools.has(key)) {
        throw new Error(`${key} from interactive should not be in CI config`);
      }
    }
    for (const key of devTools.keys()) {
      if (ciTools.has(key)) {
        throw new Error(`${key} from dev should not be in CI config`);
      }
    }
  });

  // Windows 不要の tool は config.dev-posix.toml の Windows 除外区画へ置く
  it("keeps the Windows tool set within the PATH length budget", () => {
    const windowsConfigs = [allToolsConfig, bunConfig, interactiveConfig, devConfig, "config.dev-windows.toml"];
    // os = [...] に windows を含まない tool は Windows では読まれない
    const runsOnWindows = (value: string) => {
      // taplo が長い行の配列を折り返すため閉じ括弧は求めない
      const os = value.match(/\bos\s*=\s*\[([^\]]*)/);
      return os === null || os[1]?.includes('"windows"') === true;
    };
    const windowsTools = new Set(
      windowsConfigs.flatMap((file) =>
        [...readTools(file)].filter(([, value]) => runsOnWindows(value)).map(([key]) => key),
      ),
    );

    expect(windowsTools.size).toBeLessThanOrEqual(WINDOWS_TOOL_BUDGET);
  });

  it("discovers config from $HOME (entry goes last so entry settings win)", () => {
    const paths = configPaths({ MISE_ENV: "bun,interactive,dev,dev-posix" }, repoRoot);

    expect(hasConfig(paths, "config.toml")).toBe(true);
    expect(hasConfig(paths, allToolsConfig)).toBe(true);
    expect(hasConfig(paths, bunConfig)).toBe(true);
    expect(hasConfig(paths, interactiveConfig)).toBe(true);
    expect(hasConfig(paths, devConfig)).toBe(true);
    expect(hasConfig(paths, "config.dev-posix.toml")).toBe(true);
  });

  it("loads macOS overlay when selected", () => {
    const paths = configPaths({ MISE_ENV: "macos,bun,interactive,dev,dev-posix" });

    expect(hasConfig(paths, "config.macos.toml")).toBe(true);
    expect(hasConfig(paths, bunConfig)).toBe(true);
    expect(hasConfig(paths, interactiveConfig)).toBe(true);
    expect(hasConfig(paths, devConfig)).toBe(true);
    expect(hasConfig(paths, "config.dev-posix.toml")).toBe(true);
  });

  it("loads server-pi with interactive (no bun, no dev)", () => {
    const paths = configPaths({ MISE_ENV: "interactive,server-pi" });

    expect(hasConfig(paths, "config.server-pi.toml")).toBe(true);
    expect(hasConfig(paths, interactiveConfig)).toBe(true);
    expect(hasConfig(paths, bunConfig)).toBe(false);
    expect(hasConfig(paths, devConfig)).toBe(false);
    expect(readTools("config.server-pi.toml").has("hadolint")).toBe(false);
  });

  it("loads Windows overlays (entry goes last)", () => {
    const paths = configPaths({ MISE_ENV: "bun,interactive,dev,dev-windows" });

    expect(hasConfig(paths, "config.dev-windows.toml")).toBe(true);
    expect(hasConfig(paths, bunConfig)).toBe(true);
    expect(hasConfig(paths, interactiveConfig)).toBe(true);
    expect(hasConfig(paths, devConfig)).toBe(true);
  });

  it("keeps CI isolated (bun,ci only; no interactive, no dev)", () => {
    const paths = configPaths({ MISE_ENV: "bun,ci" });

    expect(hasConfig(paths, "config.ci.toml")).toBe(true);
    expect(hasConfig(paths, bunConfig)).toBe(true);
    expect(hasConfig(paths, allToolsConfig)).toBe(true);
    expect(hasConfig(paths, "config.dev-posix.toml")).toBe(false);
    expect(hasConfig(paths, interactiveConfig)).toBe(false);
    expect(hasConfig(paths, devConfig)).toBe(false);
  });

  it("applies entry-specific jobs setting (Unix=8, CI=4, Pi=2)", () => {
    const unixSettings = settingsFrom({ MISE_ENV: "bun,interactive,dev,dev-posix" });
    const ciSettings = settingsFrom({ MISE_ENV: "bun,ci" });
    const piSettings = settingsFrom({ MISE_ENV: "interactive,server-pi" });

    expect(unixSettings.get("jobs")?.value).toBe("8");
    expect(ciSettings.get("jobs")?.value).toBe("4");
    expect(piSettings.get("jobs")?.value).toBe("2");
  });

  it("uses config.<machine>.toml naming (no entry.* files)", () => {
    const machineConfigs = [
      "config.dev-posix.toml",
      "config.dev-windows.toml",
      "config.server-pi.toml",
      "config.ci.toml",
    ];
    const legacyEntryFiles = [
      "entry.workstation-unix.toml",
      "entry.workstation-windows.toml",
      "entry.server-pi.toml",
      "entry.ci.toml",
      "config.shared.toml",
      "config.workstation.toml",
      "config.workstation-unix.toml",
      "config.workstation-windows.toml",
      "conf.d/00-tools-common.toml",
    ];

    for (const file of machineConfigs) {
      if (!fs.existsSync(path.join(configDir, file))) {
        throw new Error(`${file} should exist`);
      }
    }
    for (const file of legacyEntryFiles) {
      if (fs.existsSync(path.join(configDir, file))) {
        throw new Error(`${file} should be removed`);
      }
    }
  });

  it("creates conf.d/00-tools-all.toml for common tools", () => {
    expect(fs.existsSync(path.join(configDir, allToolsConfig))).toBe(true);
  });

  it("creates config.bun.toml for bun", () => {
    expect(fs.existsSync(path.join(configDir, bunConfig))).toBe(true);
  });
});
