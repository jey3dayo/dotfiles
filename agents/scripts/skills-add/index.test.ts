#!/usr/bin/env bun

import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { describe, expect, it } from "bun:test";

import {
  CliArgumentError,
  discoverSkills,
  looksLikeSource,
  parseArgs,
  parseSourceInput,
} from "./index-lib.ts";

const writeSkill = (dir: string, name: string, internal = false): void => {
  fs.mkdirSync(dir, { recursive: true });
  const internalLine = internal ? "internal: true\n" : "";
  fs.writeFileSync(dir + "/SKILL.md", `---\nname: ${name}\n${internalLine}---\n`, "utf8");
};

describe("skills-add/index-lib parseArgs", () => {
  it("parses flags, skills, positional args", () => {
    const parsed = parseArgs([
      "--list",
      "--all",
      "--skill",
      "skill-a",
      "skill-b",
      "--yes",
      "--dry-run",
      "--global",
      "--agent",
      "--source",
      "custom-source",
      "owner/repo",
    ]);

    expect(parsed.options).toEqual({
      list: true,
      all: true,
      skills: ["skill-a", "skill-b"],
      yes: true,
      dryRun: true,
      global: true,
      agent: true,
      sourceOverride: "custom-source",
    });
    expect(parsed.positional).toEqual(["owner/repo"]);
  });

  it("throws when --source has no value", () => {
    expect(() => parseArgs(["--source"])).toThrow(CliArgumentError);
  });

  it("throws on unknown option", () => {
    expect(() => parseArgs(["--unknown"])).toThrow(/Unknown option/);
  });
});

describe("skills-add/index-lib looksLikeSource", () => {
  it("treats existing path as source", () => {
    const result = looksLikeSource("relative/path", (input) => input === "relative/path");
    expect(result).toBe(true);
  });

  it("detects http, short owner/repo, and git patterns", () => {
    expect(looksLikeSource("https://github.com/o/r")).toBe(true);
    expect(looksLikeSource("owner/repo")).toBe(true);
    expect(looksLikeSource("git@github.com:o/r.git")).toBe(true);
    expect(looksLikeSource("ssh://example")).toBe(false);
  });
});

describe("skills-add/index-lib parseSourceInput", () => {
  it("parses local source path", () => {
    const parsed = parseSourceInput("skills/local", {
      existsSync: (input) => input === "skills/local",
      resolvePath: (input) => `/abs/${input}`,
    });
    expect(parsed).toEqual({
      kind: "local",
      path: "/abs/skills/local",
      hintPath: null,
    });
  });

  it("parses owner/repo shorthand as github source", () => {
    const parsed = parseSourceInput("owner/repo", { existsSync: () => false });
    expect(parsed).toEqual({
      kind: "github",
      url: "https://github.com/owner/repo",
      owner: "owner",
      repo: "repo",
      ref: null,
      hintPath: null,
    });
  });

  it("parses github tree URL with ref and hintPath", () => {
    const parsed = parseSourceInput(
      "https://github.com/owner/repo/tree/main/skills/my-skill",
      {
        existsSync: () => false,
      },
    );
    expect(parsed).toEqual({
      kind: "github",
      url: "https://github.com/owner/repo",
      owner: "owner",
      repo: "repo",
      ref: "main",
      hintPath: "skills/my-skill",
    });
  });

  it("parses gitlab tree URL with ref and hintPath", () => {
    const parsed = parseSourceInput(
      "https://gitlab.com/group/repo/-/tree/v1.2.3/skills/sample",
      {
        existsSync: () => false,
      },
    );
    expect(parsed).toEqual({
      kind: "gitlab",
      url: "https://gitlab.com/group/repo",
      owner: "group",
      repo: "repo",
      ref: "v1.2.3",
      hintPath: "skills/sample",
    });
  });

  it("falls back to generic git source for non-github/gitlab URLs", () => {
    const parsed = parseSourceInput("https://example.com/repo.git", {
      existsSync: () => false,
    });
    expect(parsed).toEqual({
      kind: "git",
      url: "https://example.com/repo.git",
      ref: null,
      hintPath: null,
    });
  });

  it("returns null for unsupported value", () => {
    expect(parseSourceInput("not-a-source", { existsSync: () => false })).toBe(null);
  });
});

describe("skills-add/index-lib discoverSkills", () => {
  it("discovers visible skills and excludes internal by default", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "skills-add-discover-"));
    const originalEnv = process.env.INSTALL_INTERNAL_SKILLS;
    delete process.env.INSTALL_INTERNAL_SKILLS;

    try {
      writeSkill(path.join(tempRoot, "skills", "public-skill"), "Public");
      writeSkill(path.join(tempRoot, "skills", "private-skill"), "Private", true);

      const result = discoverSkills({ repoPath: tempRoot, pathHint: null });
      const ids = result.skills.map((skill) => skill.id).sort();

      expect(ids).toEqual(["public-skill"]);
      expect(result.impliedSkill).toBe(null);
      expect(result.skillRoots.length).toBe(1);
      expect(result.skillRoots[0]).toMatch(/\/skills$/);
    } finally {
      if (originalEnv === undefined) {
        delete process.env.INSTALL_INTERNAL_SKILLS;
      } else {
        process.env.INSTALL_INTERNAL_SKILLS = originalEnv;
      }
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });

  it("includes internal skills when INSTALL_INTERNAL_SKILLS is truthy", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "skills-add-internal-"));
    const originalEnv = process.env.INSTALL_INTERNAL_SKILLS;
    process.env.INSTALL_INTERNAL_SKILLS = "1";

    try {
      writeSkill(path.join(tempRoot, "skills", "public-skill"), "Public");
      writeSkill(path.join(tempRoot, "skills", "private-skill"), "Private", true);

      const result = discoverSkills({ repoPath: tempRoot, pathHint: null });
      const ids = result.skills.map((skill) => skill.id).sort();
      expect(ids).toEqual(["private-skill", "public-skill"]);
    } finally {
      if (originalEnv === undefined) {
        delete process.env.INSTALL_INTERNAL_SKILLS;
      } else {
        process.env.INSTALL_INTERNAL_SKILLS = originalEnv;
      }
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });

  it("derives implied skill from path hint that points to a skill directory", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "skills-add-hint-"));
    const originalEnv = process.env.INSTALL_INTERNAL_SKILLS;
    delete process.env.INSTALL_INTERNAL_SKILLS;

    try {
      writeSkill(path.join(tempRoot, "skills", "find-skills"), "Find Skills");
      writeSkill(path.join(tempRoot, "skills", "other-skill"), "Other");

      const result = discoverSkills({
        repoPath: tempRoot,
        pathHint: "skills/find-skills",
      });

      expect(result.impliedSkill).toBe("find-skills");
      const ids = result.skills.map((skill) => skill.id).sort();
      expect(ids).toEqual(["find-skills", "other-skill"]);
    } finally {
      if (originalEnv === undefined) {
        delete process.env.INSTALL_INTERNAL_SKILLS;
      } else {
        process.env.INSTALL_INTERNAL_SKILLS = originalEnv;
      }
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });

  it("discovers Claude Code plugin format (.claude-plugin/plugin.json) as a skill", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "skills-add-plugin-"));
    const originalEnv = process.env.INSTALL_INTERNAL_SKILLS;
    delete process.env.INSTALL_INTERNAL_SKILLS;

    try {
      const pluginDir = path.join(tempRoot, "plugins", "feature-dev");
      fs.mkdirSync(path.join(pluginDir, ".claude-plugin"), { recursive: true });
      fs.writeFileSync(
        path.join(pluginDir, ".claude-plugin", "plugin.json"),
        JSON.stringify({ name: "feature-dev", version: "1.0.0" }),
        "utf8",
      );

      const result = discoverSkills({
        repoPath: tempRoot,
        pathHint: "plugins/feature-dev",
      });

      expect(result.impliedSkill).toBe("feature-dev");
      const ids = result.skills.map((skill) => skill.id).sort();
      expect(ids).toEqual(["feature-dev"]);
    } finally {
      if (originalEnv === undefined) {
        delete process.env.INSTALL_INTERNAL_SKILLS;
      } else {
        process.env.INSTALL_INTERNAL_SKILLS = originalEnv;
      }
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });
});
