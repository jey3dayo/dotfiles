#!/usr/bin/env bun

import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";

import { describe, expect, it } from "bun:test";

import {
  buildSourceBlock,
  countChar,
  deriveAssets,
  extractSourceBlocks,
  insertSourceBlock,
  isTruthy,
  normalizeUrl,
  parseFrontmatter,
  parseGitHubUrl,
  sanitizeName,
  stripComments,
  updateSelectionInLines,
} from "./utils.ts";

// ============================================================
// countChar
// ============================================================
describe("countChar", () => {
  it("counts single occurrence", () => {
    expect(countChar("{abc}", "{")).toBe(1);
  });
  it("counts multiple occurrences", () => {
    expect(countChar("{{}}", "{")).toBe(2);
  });
  it("returns 0 when char not found", () => {
    expect(countChar("no braces", "{")).toBe(0);
  });
  it("handles empty string", () => {
    expect(countChar("", "{")).toBe(0);
  });
  it("counts closing braces", () => {
    expect(countChar("a } b } c", "}")).toBe(2);
  });
});

// ============================================================
// stripComments
// ============================================================
describe("stripComments", () => {
  it("strips trailing comment", () => {
    expect(stripComments('url = "value"; # comment')).toBe('url = "value"; ');
  });
  it("strips full-line comment", () => {
    expect(stripComments("# full comment")).toBe("");
  });
  it("returns line unchanged when no comment", () => {
    expect(stripComments("no comment here")).toBe("no comment here");
  });
  it("handles empty string", () => {
    expect(stripComments("")).toBe("");
  });
  it("only strips from first #", () => {
    expect(stripComments("x = 1; # a # b")).toBe("x = 1; ");
  });
});

// ============================================================
// sanitizeName
// ============================================================
describe("sanitizeName", () => {
  it("lowercases and replaces slashes", () => {
    expect(sanitizeName("owner/repo")).toBe("owner-repo");
  });
  it("replaces spaces with hyphens", () => {
    expect(sanitizeName("Hello World 123")).toBe("hello-world-123");
  });
  it("strips leading dashes", () => {
    expect(sanitizeName("-leading-dash")).toBe("leading-dash");
  });
  it("strips trailing dashes", () => {
    expect(sanitizeName("trailing-dash-")).toBe("trailing-dash");
  });
  it("collapses consecutive special chars", () => {
    expect(sanitizeName("a  b--c")).toBe("a-b-c");
  });
  it("handles already-clean name", () => {
    expect(sanitizeName("my-skill")).toBe("my-skill");
  });
});

// ============================================================
// isTruthy
// ============================================================
describe("isTruthy", () => {
  it("returns true for '1'", () => expect(isTruthy("1")).toBe(true));
  it("returns true for 'true'", () => expect(isTruthy("true")).toBe(true));
  it("returns true for 'yes'", () => expect(isTruthy("yes")).toBe(true));
  it("returns false for '0'", () => expect(isTruthy("0")).toBe(false));
  it("returns false for 'false'", () => expect(isTruthy("false")).toBe(false));
  it("returns false for 'no'", () => expect(isTruthy("no")).toBe(false));
  it("returns false for 'off'", () => expect(isTruthy("off")).toBe(false));
  it("returns false for undefined", () => expect(isTruthy(undefined)).toBe(false));
  it("returns false for empty string", () => expect(isTruthy("")).toBe(false));
  it("is case-insensitive", () => expect(isTruthy("FALSE")).toBe(false));
});

// ============================================================
// normalizeUrl
// ============================================================
describe("normalizeUrl", () => {
  const root = "/home/user/dotfiles";

  it("converts github: prefix to https", () => {
    expect(normalizeUrl("github:owner/repo", root)).toBe("https://github.com/owner/repo");
  });
  it("strips git+ prefix", () => {
    expect(normalizeUrl("git+https://github.com/owner/repo.git", root)).toBe("https://github.com/owner/repo");
  });
  it("strips .git suffix", () => {
    expect(normalizeUrl("https://github.com/owner/repo.git", root)).toBe("https://github.com/owner/repo");
  });
  it("strips ?ref= query param", () => {
    expect(normalizeUrl("https://github.com/owner/repo?ref=main", root)).toBe("https://github.com/owner/repo");
  });
  it("lowercases github.com URLs", () => {
    expect(normalizeUrl("https://github.com/Owner/Repo", root)).toBe("https://github.com/owner/repo");
  });
  it("does NOT lowercase non-github URLs", () => {
    expect(normalizeUrl("https://gitlab.com/Owner/Repo", root)).toBe("https://gitlab.com/Owner/Repo");
  });
  it("resolves path: relative to repoRoot", () => {
    expect(normalizeUrl("path:./agents/skills/foo", root)).toBe(
      path.resolve(root, "./agents/skills/foo"),
    );
  });
  it("returns null for falsy input", () => {
    expect(normalizeUrl("", root)).toBe(null);
  });
});

// ============================================================
// extractSourceBlocks
// ============================================================
describe("extractSourceBlocks", () => {
  it("parses a single source block", () => {
    const content = `{
  source-a = {
    url = "github:owner/repo";
    flake = false;
  };
}`;
    const { sources } = extractSourceBlocks(content);
    expect(sources.length).toBe(1);
    expect(sources[0].name).toBe("source-a");
    expect(sources[0].url).toBe("github:owner/repo");
    expect(sources[0].flake).toBe(false);
    expect(sources[0].start).toBe(1);
    expect(sources[0].end).toBe(4);
  });

  it("ignores comment lines when parsing", () => {
    const content = `# top comment
{
  # section comment
  source-a = {
    url = "github:owner/repo"; # inline comment
  };
}`;
    const { sources } = extractSourceBlocks(content);
    expect(sources.length).toBe(1);
    expect(sources[0].name).toBe("source-a");
    expect(sources[0].url).toBe("github:owner/repo");
  });

  it("parses multiple source blocks", () => {
    const content = `{
  source-a = {
    url = "github:owner/repo-a";
    flake = false;
  };
  source-b = {
    url = "github:owner/repo-b";
    flake = true;
  };
}`;
    const { sources } = extractSourceBlocks(content);
    expect(sources.length).toBe(2);
    expect(sources[0].name).toBe("source-a");
    expect(sources[1].name).toBe("source-b");
    expect(sources[1].flake).toBe(true);
  });

  it("handles source with no url or flake", () => {
    const content = `{
  minimal-source = {
    baseDir = ".";
  };
}`;
    const { sources } = extractSourceBlocks(content);
    expect(sources.length).toBe(1);
    expect(sources[0].name).toBe("minimal-source");
    expect(sources[0].url).toBe(null);
    expect(sources[0].flake).toBe(null);
  });

  it("returns split lines", () => {
    const content = "{\n}";
    const { lines } = extractSourceBlocks(content);
    expect(lines).toEqual(["{", "}"]);
  });
});

// ============================================================
// parseFrontmatter
// ============================================================
describe("parseFrontmatter", () => {
  it("extracts name from frontmatter", () => {
    const content = `---
name: My Skill
---
content here`;
    const result = parseFrontmatter(content);
    expect(result.name).toBe("My Skill");
    expect(result.internal).toBe(false);
  });

  it("detects internal: true at top level", () => {
    const content = `---
name: Internal Skill
internal: true
---
content`;
    const result = parseFrontmatter(content);
    expect(result.name).toBe("Internal Skill");
    expect(result.internal).toBe(true);
  });

  it("detects internal: true nested under metadata", () => {
    const content = `---
name: Nested Internal
metadata:
  internal: true
---
content`;
    const result = parseFrontmatter(content);
    expect(result.name).toBe("Nested Internal");
    expect(result.internal).toBe(true);
  });

  it("returns nulls when no frontmatter delimiter", () => {
    const result = parseFrontmatter("Some content without frontmatter");
    expect(result.name).toBe(null);
    expect(result.internal).toBe(false);
  });

  it("returns nulls when closing --- is missing", () => {
    const result = parseFrontmatter("---\nname: Orphan");
    expect(result.name).toBe(null);
    expect(result.internal).toBe(false);
  });

  it("strips surrounding quotes from name", () => {
    const content = `---
name: "Quoted Name"
---`;
    const result = parseFrontmatter(content);
    expect(result.name).toBe("Quoted Name");
  });
});

// ============================================================
// buildSourceBlock
// ============================================================
describe("buildSourceBlock", () => {
  it("generates correct block with catalogs and selection", () => {
    const lines = buildSourceBlock({
      sourceName: "test-source",
      url: "github:owner/repo",
      flake: false,
      baseDir: ".",
      catalogs: { "test-source": "skills" },
      selection: ["skill-b", "skill-a"],
    });
    expect(lines).toEqual([
      "  test-source = {",
      '    url = "github:owner/repo";',
      "    flake = false;",
      '    baseDir = ".";',
      "    catalogs = {",
      '      test-source = "skills";',
      "    };",
      "    selection.enable = [",
      '      "skill-a"',
      '      "skill-b"',
      "    ];",
      "  };",
    ]);
  });

  it("sorts selection alphabetically", () => {
    const lines = buildSourceBlock({
      sourceName: "src",
      url: "github:o/r",
      flake: false,
      baseDir: ".",
      catalogs: {},
      selection: ["zzz", "aaa", "mmm"],
    });
    // selection items are formatted as `      "name"` (quoted string only, no `=` or `;`)
    const selectionLines = lines.filter((l) => /^\s+"[^"]+"\s*$/.test(l));
    expect(selectionLines).toEqual(['      "aaa"', '      "mmm"', '      "zzz"']);
  });

  it("sets flake = true when flake is true", () => {
    const lines = buildSourceBlock({
      sourceName: "src",
      url: "github:o/r",
      flake: true,
      baseDir: ".",
      catalogs: {},
      selection: [],
    });
    expect(lines.some((l) => l.includes("flake = true;"))).toBeTruthy();
  });

  it("emits assets block when agents or commands are provided", () => {
    const lines = buildSourceBlock({
      sourceName: "src",
      url: "github:o/r",
      flake: false,
      baseDir: ".",
      assets: {
        agents: "plugins/codex/agents",
        commands: "plugins/codex/commands",
      },
      catalogs: { src: "plugins/codex/skills" },
      selection: ["skill-a"],
    });

    expect(lines).toContain("    assets = {");
    expect(lines).toContain('      agents = "plugins/codex/agents";');
    expect(lines).toContain('      commands = "plugins/codex/commands";');
  });

  it("sorts multiple catalogs alphabetically", () => {
    const lines = buildSourceBlock({
      sourceName: "src",
      url: "github:o/r",
      flake: false,
      baseDir: ".",
      catalogs: { "src-z": "z", "src-a": "a" },
      selection: [],
    });
    const catIndex = lines.indexOf("    catalogs = {");
    expect(catIndex !== -1).toBeTruthy();
    expect(lines[catIndex + 1].includes("src-a")).toBeTruthy();
    expect(lines[catIndex + 2].includes("src-z")).toBeTruthy();
  });
});

// ============================================================
// deriveAssets
// ============================================================
describe("deriveAssets", () => {
  it("detects sibling agents and commands for plugin-style skill roots", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "skills-add-assets-"));

    try {
      fs.mkdirSync(path.join(tempRoot, "plugins", "codex", "skills"), {
        recursive: true,
      });
      fs.mkdirSync(path.join(tempRoot, "plugins", "codex", "agents"), {
        recursive: true,
      });
      fs.mkdirSync(path.join(tempRoot, "plugins", "codex", "commands"), {
        recursive: true,
      });

      expect(
        deriveAssets({
          repoPath: tempRoot,
          skillRoots: [path.join(tempRoot, "plugins", "codex", "skills")],
        }),
      ).toEqual({
        agents: "plugins/codex/agents",
        commands: "plugins/codex/commands",
      });
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });

  it("returns empty assets for non-plugin roots", () => {
    expect(
      deriveAssets({
        repoPath: "/repo",
        skillRoots: ["/repo/skills"],
      }),
    ).toEqual({});
  });
});

// ============================================================
// insertSourceBlock
// ============================================================
describe("insertSourceBlock", () => {
  it("inserts block before closing brace of outer set (comment header)", () => {
    const lines = [
      "# Agent skills source definitions",
      "{",
      "  source-a = {",
      '    url = "github:owner/repo";',
      "    flake = false;",
      "  };",
      "}",
    ];
    const block = ["  new-source = {", "  };"];
    const result = insertSourceBlock(lines, block);
    // Block should appear before the last "}"
    const lastBrace = result.lastIndexOf("}");
    const blockStart = result.indexOf("  new-source = {");
    expect(blockStart !== -1).toBeTruthy();
    expect(blockStart < lastBrace).toBeTruthy();
  });

  it("inserts block when { is the first non-comment line", () => {
    const lines = ["{", "  source-a = {", "  };", "}"];
    const block = ["  new-source = {", "  };"];
    const result = insertSourceBlock(lines, block);
    expect(result.includes("  new-source = {")).toBeTruthy();
    expect(result[result.length - 1]).toBe("}");
  });

  it("inserts block correctly with nested catalogs structure", () => {
    const lines = [
      "{",
      "  source-a = {",
      "    catalogs = {",
      '      cat1 = "skills";',
      "    };",
      '    url = "github:owner/repo";',
      "  };",
      "}",
    ];
    const block = ["  new-source = {", "  };"];
    const result = insertSourceBlock(lines, block);
    const lastBrace = result.lastIndexOf("}");
    const blockStart = result.indexOf("  new-source = {");
    expect(blockStart !== -1).toBeTruthy();
    expect(blockStart < lastBrace).toBeTruthy();
    // Original source-a should still be present
    expect(result.some((l) => l.includes("source-a"))).toBeTruthy();
  });

  it("throws when no valid insertion point found", () => {
    expect(() => insertSourceBlock(["no braces here"], ["block"])).toThrow(/Failed to find end/);
  });

  it("preserves all original lines around the block", () => {
    const lines = ["{", "  existing = {};", "}"];
    const block = ["  new = {};"];
    const result = insertSourceBlock(lines, block);
    expect(result[0]).toBe("{");
    expect(result[1]).toBe("  existing = {};");
    expect(result[2]).toBe("  new = {};");
    expect(result[3]).toBe("}");
  });
});

// ============================================================
// updateSelectionInLines
// ============================================================
describe("updateSelectionInLines", () => {
  it("adds selection.enable when none exists", () => {
    const lines = [
      "{",
      "  my-source = {",
      '    url = "github:owner/repo";',
      "    flake = false;",
      "  };",
      "}",
    ];
    const result = updateSelectionInLines(lines, "my-source", ["my-skill"]);
    expect(result.changed).toBe(true);
    expect(result.added).toEqual(["my-skill"]);
    expect(result.already).toEqual([]);
    expect(result.lines.some((l) => l.includes("selection.enable"))).toBeTruthy();
    expect(result.lines.some((l) => l.includes('"my-skill"'))).toBeTruthy();
  });

  it("adds to existing selection.enable list", () => {
    const lines = [
      "{",
      "  my-source = {",
      '    url = "github:owner/repo";',
      "    selection.enable = [",
      '      "existing-skill"',
      "    ];",
      "  };",
      "}",
    ];
    const result = updateSelectionInLines(lines, "my-source", ["new-skill"]);
    expect(result.changed).toBe(true);
    expect(result.added).toEqual(["new-skill"]);
    expect(result.already).toEqual([]);
    expect(result.lines.some((l) => l.includes('"existing-skill"'))).toBeTruthy();
    expect(result.lines.some((l) => l.includes('"new-skill"'))).toBeTruthy();
  });

  it("reports already-present skills without changing", () => {
    const lines = [
      "{",
      "  my-source = {",
      "    selection.enable = [",
      '      "existing-skill"',
      "    ];",
      "  };",
      "}",
    ];
    const result = updateSelectionInLines(lines, "my-source", ["existing-skill"]);
    expect(result.changed).toBe(false);
    expect(result.added).toEqual([]);
    expect(result.already).toEqual(["existing-skill"]);
  });

  it("handles inline list format", () => {
    const lines = [
      "{",
      '  my-source = { selection.enable = ["existing-skill"]; };',
      "}",
    ];
    // inline single-line source block: sourceLineRe won't match this form,
    // so this is a limitation; test with multi-line format
    const linesMulti = [
      "{",
      "  my-source = {",
      '    selection.enable = ["existing-skill"];',
      "  };",
      "}",
    ];
    const result = updateSelectionInLines(linesMulti, "my-source", ["new-skill"]);
    expect(result.changed).toBe(true);
    expect(result.added).toEqual(["new-skill"]);
    expect(result.lines.some((l) => l.includes('"existing-skill"'))).toBeTruthy();
    expect(result.lines.some((l) => l.includes('"new-skill"'))).toBeTruthy();
  });

  it("adds multiple skills at once", () => {
    const lines = ["{", "  my-source = {", '    url = "github:o/r";', "  };", "}"];
    const result = updateSelectionInLines(lines, "my-source", ["skill-c", "skill-a", "skill-b"]);
    expect(result.changed).toBe(true);
    expect(result.added.length).toBe(3);
    // Output should be sorted
    const skillLines = result.lines.filter((l) => l.match(/"skill-[abc]"/));
    expect(skillLines[0].trim()).toBe('"skill-a"');
    expect(skillLines[1].trim()).toBe('"skill-b"');
    expect(skillLines[2].trim()).toBe('"skill-c"');
  });

  it("separates added vs already in mixed input", () => {
    const lines = [
      "{",
      "  my-source = {",
      "    selection.enable = [",
      '      "skill-a"',
      "    ];",
      "  };",
      "}",
    ];
    const result = updateSelectionInLines(lines, "my-source", ["skill-a", "skill-b"]);
    expect(result.changed).toBe(true);
    expect(result.added).toEqual(["skill-b"]);
    expect(result.already).toEqual(["skill-a"]);
  });

  it("throws when source is not found", () => {
    const lines = ["{", "  other-source = {", "  };", "}"];
    expect(() => updateSelectionInLines(lines, "missing-source", ["skill"])).toThrow(/Source not found/);
  });
});

// ============================================================
// parseGitHubUrl
// ============================================================
describe("parseGitHubUrl", () => {
  it("parses basic owner/repo URL", () => {
    const result = parseGitHubUrl(new URL("https://github.com/millionco/react-doctor"));
    expect(result).toEqual({
      kind: "github",
      url: "https://github.com/millionco/react-doctor",
      owner: "millionco",
      repo: "react-doctor",
      ref: null,
      hintPath: null,
    });
  });

  it("strips .git suffix from repo name", () => {
    const result = parseGitHubUrl(new URL("https://github.com/millionco/react-doctor.git"));
    expect(result?.repo).toBe("react-doctor");
  });

  // https://github.com/millionco/react-doctor/tree/main/skills/react-doctor
  it("parses tree/branch/path URL: extracts ref and hintPath", () => {
    const url = "https://github.com/millionco/react-doctor/tree/main/skills/react-doctor";
    const result = parseGitHubUrl(new URL(url));
    expect(result).toEqual({
      kind: "github",
      url: "https://github.com/millionco/react-doctor",
      owner: "millionco",
      repo: "react-doctor",
      ref: "main",
      hintPath: "skills/react-doctor",
    });
  });

  it("parses tree/branch URL without subpath", () => {
    const result = parseGitHubUrl(
      new URL("https://github.com/millionco/react-doctor/tree/main"),
    );
    expect(result?.ref).toBe("main");
    expect(result?.hintPath).toBe(null);
  });

  it("parses tree/tag URL", () => {
    const result = parseGitHubUrl(
      new URL("https://github.com/millionco/react-doctor/tree/v1.2.3"),
    );
    expect(result?.ref).toBe("v1.2.3");
    expect(result?.hintPath).toBe(null);
  });

  // https://github.com/millionco/react-doctor/skills/react-doctor
  // tree/ がないため hintPath は取得できない（制限）
  it("ignores subpath when tree/ segment is absent", () => {
    const url = "https://github.com/millionco/react-doctor/skills/react-doctor";
    const result = parseGitHubUrl(new URL(url));
    expect(result).toEqual({
      kind: "github",
      url: "https://github.com/millionco/react-doctor",
      owner: "millionco",
      repo: "react-doctor",
      ref: null,
      hintPath: null, // skills/react-doctor は無視される
    });
  });

  it("treats blob/ path the same as unknown segment (no ref/hintPath)", () => {
    const url = "https://github.com/millionco/react-doctor/blob/main/README.md";
    const result = parseGitHubUrl(new URL(url));
    expect(result?.ref).toBe(null);
    expect(result?.hintPath).toBe(null);
  });

  it("returns null when only owner is present", () => {
    // pathname has only 1 segment
    const result = parseGitHubUrl(new URL("https://github.com/millionco"));
    expect(result).toBe(null);
  });

  // github.com/millionco/react-doctor/tree/main/skills/react-doctor
  // （プロトコルなし）は new URL() でパースできないため parseGitHubUrl の対象外。
  // looksLikeSource でも false を返すため、CLIへの入力として認識されない。
  it("— NOTE: bare github.com/owner/repo/... (no https://) is NOT a valid URL for this parser", () => {
    expect(() => new URL("github.com/millionco/react-doctor/tree/main/skills/react-doctor")).toThrow();
  });
});
