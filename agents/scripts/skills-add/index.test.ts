#!/usr/bin/env tsx

import * as assert from "node:assert/strict";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { describe, it } from "node:test";

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

    assert.deepEqual(parsed.options, {
      list: true,
      all: true,
      skills: ["skill-a", "skill-b"],
      yes: true,
      dryRun: true,
      global: true,
      agent: true,
      sourceOverride: "custom-source",
    });
    assert.deepEqual(parsed.positional, ["owner/repo"]);
  });

  it("throws when --source has no value", () => {
    assert.throws(() => parseArgs(["--source"]), CliArgumentError);
  });

  it("throws on unknown option", () => {
    assert.throws(() => parseArgs(["--unknown"]), /Unknown option/);
  });
});

describe("skills-add/index-lib looksLikeSource", () => {
  it("treats existing path as source", () => {
    const result = looksLikeSource("relative/path", (input) => input === "relative/path");
    assert.equal(result, true);
  });

  it("detects http, short owner/repo, and git patterns", () => {
    assert.equal(looksLikeSource("https://github.com/o/r"), true);
    assert.equal(looksLikeSource("owner/repo"), true);
    assert.equal(looksLikeSource("git@github.com:o/r.git"), true);
    assert.equal(looksLikeSource("ssh://example"), false);
  });
});

describe("skills-add/index-lib parseSourceInput", () => {
  it("parses local source path", () => {
    const parsed = parseSourceInput("skills/local", {
      existsSync: (input) => input === "skills/local",
      resolvePath: (input) => `/abs/${input}`,
    });
    assert.deepEqual(parsed, {
      kind: "local",
      path: "/abs/skills/local",
      hintPath: null,
    });
  });

  it("parses owner/repo shorthand as github source", () => {
    const parsed = parseSourceInput("owner/repo", { existsSync: () => false });
    assert.deepEqual(parsed, {
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
    assert.deepEqual(parsed, {
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
    assert.deepEqual(parsed, {
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
    assert.deepEqual(parsed, {
      kind: "git",
      url: "https://example.com/repo.git",
      ref: null,
      hintPath: null,
    });
  });

  it("returns null for unsupported value", () => {
    assert.equal(parseSourceInput("not-a-source", { existsSync: () => false }), null);
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

      assert.deepEqual(ids, ["public-skill"]);
      assert.equal(result.impliedSkill, null);
      assert.equal(result.skillRoots.length, 1);
      assert.match(result.skillRoots[0], /\/skills$/);
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
      assert.deepEqual(ids, ["private-skill", "public-skill"]);
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

      assert.equal(result.impliedSkill, "find-skills");
      const ids = result.skills.map((skill) => skill.id).sort();
      assert.deepEqual(ids, ["find-skills", "other-skill"]);
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
