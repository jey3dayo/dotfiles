#!/usr/bin/env bun

import * as fs from "node:fs";
import * as path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "bun:test";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, "..", "..");
const nixBin = "/nix/var/nix/profiles/default/bin/nix";
const flakeUrl = `git+file://${repoRoot}`;
const user = process.env.USER ?? "t00114";
const bundledCodeReviewer = fs.readFileSync(
  path.join(repoRoot, "agents", "src", "agents", "code-reviewer.md"),
  "utf8",
);
let cachedBuildResult:
  | (ReturnType<typeof spawnSync> & {
      activateScript?: string;
    })
  | null = null;

const evalMergedAgent = (externalAgentsPath: string) =>
  spawnSync(
    nixBin,
    [
      "eval",
      "--impure",
      "--json",
      "--expr",
      `let
         pkgs = import <nixpkgs> {};
         agentLib = import ${JSON.stringify(path.join(repoRoot, "agents", "nix", "lib.nix"))} {
           inherit pkgs;
           nixlib = pkgs.lib;
         };
         distributionResult = agentLib.scanDistribution ${JSON.stringify(path.join(repoRoot, "agents", "src"))};
         sources = {
           ext = {
             path = ${JSON.stringify(path.join(repoRoot, "agents", "src", "skills"))};
             agentsPath = builtins.path {
               path = ${JSON.stringify(externalAgentsPath)};
               name = "external-agents";
             };
           };
         };
         externalAgents = agentLib.discoverExternalAssets {
           inherit sources;
           assetType = "agents";
           enabledSources = ["ext"];
         };
         mergedAgents = externalAgents // distributionResult.agents;
       in
         {
           path = mergedAgents."code-reviewer".path;
           source = mergedAgents."code-reviewer".source;
         }`,
    ],
    {
      cwd: repoRoot,
      encoding: "utf8",
      env: {
        ...process.env,
        NIX_CONFIG: "experimental-features = nix-command flakes",
      },
    },
  );

const evalKeepTargets = () =>
  spawnSync(
    nixBin,
    [
      "eval",
      "--json",
      "--impure",
      "--expr",
      `let
         flake = builtins.getFlake "${flakeUrl}";
         homeConfig = builtins.getAttr "${user}" flake.outputs.homeConfigurations;
         names = builtins.attrNames homeConfig.config.home.file;
       in
         builtins.filter (n: builtins.match ".*(\\\\.claude/skills|\\\\.codex/rules)/\\\\.keep$" n != null) names`,
    ],
    {
      cwd: repoRoot,
      encoding: "utf8",
      env: {
        ...process.env,
        NIX_CONFIG: "experimental-features = nix-command flakes",
      },
    },
  );

const evalCommandTargets = () =>
  spawnSync(
    nixBin,
    [
      "eval",
      "--json",
      "--impure",
      "--expr",
      `let
         flake = builtins.getFlake "${flakeUrl}";
         homeConfig = builtins.getAttr "${user}" flake.outputs.homeConfigurations;
         names = builtins.attrNames homeConfig.config.home.file;
       in
         builtins.filter (n: builtins.match ".*(\\\\.claude|\\\\.codex)/commands/.*" n != null) names`,
    ],
    {
      cwd: repoRoot,
      encoding: "utf8",
      env: {
        ...process.env,
        NIX_CONFIG: "experimental-features = nix-command flakes",
      },
    },
  );

const evalSourceHomeLink = () =>
  spawnSync(
    nixBin,
    [
      "eval",
      "--json",
      "--impure",
      "--expr",
      `let
         flake = builtins.getFlake "${flakeUrl}";
         homeConfig = builtins.getAttr "${user}" flake.outputs.homeConfigurations;
       in
         homeConfig.config.programs.agent-skills.sources."lum1104-understand-anything".homeLinks.".understand-anything-plugin"`,
    ],
    {
      cwd: repoRoot,
      encoding: "utf8",
      env: {
        ...process.env,
        NIX_CONFIG: "experimental-features = nix-command flakes",
      },
    },
  );

const evalDuplicateHomeLinks = (sourceAPath: string, sourceBPath: string) =>
  spawnSync(
    nixBin,
    [
      "eval",
      "--impure",
      "--expr",
      `let
         flake = builtins.getFlake "${flakeUrl}";
         pkgs = import flake.inputs.nixpkgs { system = builtins.currentSystem; };
         hm = flake.inputs.home-manager;
         config = hm.lib.homeManagerConfiguration {
           inherit pkgs;
           modules = [
             (import ${JSON.stringify(path.join(repoRoot, "agents", "nix", "module.nix"))})
             {
               home.username = "${user}";
               home.homeDirectory = "/tmp/agent-skills-home-links";
               home.stateVersion = "24.11";
               programs.agent-skills = {
                 enable = true;
                 sources = {
                   source-a = {
                     path = builtins.path {
                       path = ${JSON.stringify(sourceAPath)};
                       name = "source-a";
                     };
                     homeLinks = {
                       ".duplicate-plugin-root" = builtins.path {
                         path = ${JSON.stringify(sourceAPath)};
                         name = "duplicate-a";
                       };
                     };
                   };
                   source-b = {
                     path = builtins.path {
                       path = ${JSON.stringify(sourceBPath)};
                       name = "source-b";
                     };
                     homeLinks = {
                       ".duplicate-plugin-root" = builtins.path {
                         path = ${JSON.stringify(sourceBPath)};
                         name = "duplicate-b";
                       };
                     };
                   };
                 };
                 skills.enable = null;
               };
             }
           ];
         };
       in
         builtins.attrNames config.config.home.file`,
    ],
    {
      cwd: repoRoot,
      encoding: "utf8",
      env: {
        ...process.env,
        NIX_CONFIG: "experimental-features = nix-command flakes",
      },
    },
  );

const buildActivationScript = () => {
  if (cachedBuildResult) {
    return cachedBuildResult;
  }

  const result = spawnSync(
    nixBin,
    [
      "build",
      `.#homeConfigurations.${user}.activationPackage`,
      "--impure",
      "--no-link",
      "--print-out-paths",
    ],
    {
      cwd: repoRoot,
      encoding: "utf8",
      env: {
        ...process.env,
        NIX_CONFIG: "experimental-features = nix-command flakes",
      },
    },
  );

  if (result.status !== 0) {
    cachedBuildResult = result;
    return result;
  }

  const activatePath = path.join(result.stdout.trim(), "activate");
  cachedBuildResult = {
    ...result,
    activateScript: fs.readFileSync(activatePath, "utf8"),
  };
  return cachedBuildResult;
};

describe("agents/nix/module.nix", () => {
  it("preserves bundled code-reviewer agent when an external source ships the same ID", () => {
    const tempRoot = fs.mkdtempSync(path.join(fs.realpathSync.native(process.env.TMPDIR ?? "/tmp"), "ext-agents-"));

    try {
      const externalAgentsPath = path.join(tempRoot, "agents");
      fs.mkdirSync(externalAgentsPath, { recursive: true });
      fs.writeFileSync(path.join(externalAgentsPath, "code-reviewer.md"), "external override\n", "utf8");

      const result = evalMergedAgent(externalAgentsPath);

      expect(result.status).toBe(0);
      expect(result.stderr).toBe("");

      const evaluated = JSON.parse(result.stdout) as { path: string; source: string };

      expect(evaluated.source).toBe("distribution");
      expect(fs.readFileSync(evaluated.path, "utf8")).toBe(bundledCodeReviewer);
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  }, 15_000);

  it("materializes keep files for target directories instead of symlinking them from home.file", () => {
    const keepResult = evalKeepTargets();
    expect(keepResult.status).toBe(0);
    expect(JSON.parse(keepResult.stdout)).toEqual([]);

    const buildResult = buildActivationScript();
    expect(buildResult.status).toBe(0);
    expect(buildResult.activateScript).toContain("agent-skills-materialized-keep");
    expect(buildResult.activateScript).toContain('$HOME/.claude/skills/.keep');
    expect(buildResult.activateScript).toContain('$HOME/.codex/rules/.keep');
    expect(buildResult.activateScript).toContain("install -m 600 /dev/null");
  }, 60_000);

  it("does not deploy external commands to the codex target", () => {
    const commandResult = evalCommandTargets();
    expect(commandResult.status).toBe(0);

    const commandTargets = JSON.parse(commandResult.stdout) as string[];
    expect(commandTargets.some((target) => target.startsWith(".claude/commands/"))).toBe(true);
    expect(commandTargets.some((target) => target.startsWith(".codex/commands/"))).toBe(false);

    const buildResult = buildActivationScript();
    expect(buildResult.status).toBe(0);
    expect(buildResult.activateScript).toContain('$HOME/.claude/commands');
    expect(buildResult.activateScript).not.toContain('mkdir -p "$HOME/.codex/commands"');
    expect(buildResult.activateScript).toContain('target_dir="$HOME/.codex/commands"');
    expect(buildResult.activateScript).toContain('keep_file="$target_dir/.keep"');
  }, 60_000);

  it("exposes source-level homeLinks for selected external sources", () => {
    const result = evalSourceHomeLink();
    expect(result.status).toBe(0);
    expect(JSON.parse(result.stdout)).toContain("understand-anything-plugin");
  }, 30_000);

  it("fails evaluation when multiple selected sources define the same homeLinks destination", () => {
    const tempRoot = fs.mkdtempSync(path.join(fs.realpathSync.native(process.env.TMPDIR ?? "/tmp"), "home-links-"));

    try {
      const sourceAPath = path.join(tempRoot, "source-a");
      const sourceBPath = path.join(tempRoot, "source-b");

      fs.mkdirSync(path.join(sourceAPath, "skill-a"), { recursive: true });
      fs.mkdirSync(path.join(sourceBPath, "skill-b"), { recursive: true });
      fs.writeFileSync(path.join(sourceAPath, "skill-a", "SKILL.md"), "# skill-a\n", "utf8");
      fs.writeFileSync(path.join(sourceBPath, "skill-b", "SKILL.md"), "# skill-b\n", "utf8");

      const result = evalDuplicateHomeLinks(sourceAPath, sourceBPath);
      expect(result.status).not.toBe(0);
      expect(result.stderr).toContain("homeLinks");
      expect(result.stderr).toContain(".duplicate-plugin-root");
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  }, 30_000);
});
