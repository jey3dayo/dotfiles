#!/usr/bin/env tsx

import { describe, it } from "node:test";
import * as assert from "node:assert/strict";

import {
  buildSourceBlock,
  countChar,
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
    assert.equal(countChar("{abc}", "{"), 1);
  });
  it("counts multiple occurrences", () => {
    assert.equal(countChar("{{}}", "{"), 2);
  });
  it("returns 0 when char not found", () => {
    assert.equal(countChar("no braces", "{"), 0);
  });
  it("handles empty string", () => {
    assert.equal(countChar("", "{"), 0);
  });
  it("counts closing braces", () => {
    assert.equal(countChar("a } b } c", "}"), 2);
  });
});

// ============================================================
// stripComments
// ============================================================
describe("stripComments", () => {
  it("strips trailing comment", () => {
    assert.equal(stripComments('url = "value"; # comment'), 'url = "value"; ');
  });
  it("strips full-line comment", () => {
    assert.equal(stripComments("# full comment"), "");
  });
  it("returns line unchanged when no comment", () => {
    assert.equal(stripComments("no comment here"), "no comment here");
  });
  it("handles empty string", () => {
    assert.equal(stripComments(""), "");
  });
  it("only strips from first #", () => {
    assert.equal(stripComments("x = 1; # a # b"), "x = 1; ");
  });
});

// ============================================================
// sanitizeName
// ============================================================
describe("sanitizeName", () => {
  it("lowercases and replaces slashes", () => {
    assert.equal(sanitizeName("owner/repo"), "owner-repo");
  });
  it("replaces spaces with hyphens", () => {
    assert.equal(sanitizeName("Hello World 123"), "hello-world-123");
  });
  it("strips leading dashes", () => {
    assert.equal(sanitizeName("-leading-dash"), "leading-dash");
  });
  it("strips trailing dashes", () => {
    assert.equal(sanitizeName("trailing-dash-"), "trailing-dash");
  });
  it("collapses consecutive special chars", () => {
    assert.equal(sanitizeName("a  b--c"), "a-b-c");
  });
  it("handles already-clean name", () => {
    assert.equal(sanitizeName("my-skill"), "my-skill");
  });
});

// ============================================================
// isTruthy
// ============================================================
describe("isTruthy", () => {
  it("returns true for '1'", () => assert.equal(isTruthy("1"), true));
  it("returns true for 'true'", () => assert.equal(isTruthy("true"), true));
  it("returns true for 'yes'", () => assert.equal(isTruthy("yes"), true));
  it("returns false for '0'", () => assert.equal(isTruthy("0"), false));
  it("returns false for 'false'", () => assert.equal(isTruthy("false"), false));
  it("returns false for 'no'", () => assert.equal(isTruthy("no"), false));
  it("returns false for 'off'", () => assert.equal(isTruthy("off"), false));
  it("returns false for undefined", () => assert.equal(isTruthy(undefined), false));
  it("returns false for empty string", () => assert.equal(isTruthy(""), false));
  it("is case-insensitive", () => assert.equal(isTruthy("FALSE"), false));
});

// ============================================================
// normalizeUrl
// ============================================================
describe("normalizeUrl", () => {
  const root = "/home/user/dotfiles";

  it("converts github: prefix to https", () => {
    assert.equal(normalizeUrl("github:owner/repo", root), "https://github.com/owner/repo");
  });
  it("strips git+ prefix", () => {
    assert.equal(
      normalizeUrl("git+https://github.com/owner/repo.git", root),
      "https://github.com/owner/repo",
    );
  });
  it("strips .git suffix", () => {
    assert.equal(
      normalizeUrl("https://github.com/owner/repo.git", root),
      "https://github.com/owner/repo",
    );
  });
  it("strips ?ref= query param", () => {
    assert.equal(
      normalizeUrl("https://github.com/owner/repo?ref=main", root),
      "https://github.com/owner/repo",
    );
  });
  it("lowercases github.com URLs", () => {
    assert.equal(
      normalizeUrl("https://github.com/Owner/Repo", root),
      "https://github.com/owner/repo",
    );
  });
  it("does NOT lowercase non-github URLs", () => {
    assert.equal(
      normalizeUrl("https://gitlab.com/Owner/Repo", root),
      "https://gitlab.com/Owner/Repo",
    );
  });
  it("resolves path: relative to repoRoot", () => {
    assert.equal(normalizeUrl("path:./agents/skills/foo", root), `${root}/agents/skills/foo`);
  });
  it("returns null for falsy input", () => {
    assert.equal(normalizeUrl("", root), null);
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
    assert.equal(sources.length, 1);
    assert.equal(sources[0].name, "source-a");
    assert.equal(sources[0].url, "github:owner/repo");
    assert.equal(sources[0].flake, false);
    assert.equal(sources[0].start, 1);
    assert.equal(sources[0].end, 4);
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
    assert.equal(sources.length, 1);
    assert.equal(sources[0].name, "source-a");
    assert.equal(sources[0].url, "github:owner/repo");
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
    assert.equal(sources.length, 2);
    assert.equal(sources[0].name, "source-a");
    assert.equal(sources[1].name, "source-b");
    assert.equal(sources[1].flake, true);
  });

  it("handles source with no url or flake", () => {
    const content = `{
  minimal-source = {
    baseDir = ".";
  };
}`;
    const { sources } = extractSourceBlocks(content);
    assert.equal(sources.length, 1);
    assert.equal(sources[0].name, "minimal-source");
    assert.equal(sources[0].url, null);
    assert.equal(sources[0].flake, null);
  });

  it("returns split lines", () => {
    const content = "{\n}";
    const { lines } = extractSourceBlocks(content);
    assert.deepEqual(lines, ["{", "}"]);
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
    assert.equal(result.name, "My Skill");
    assert.equal(result.internal, false);
  });

  it("detects internal: true at top level", () => {
    const content = `---
name: Internal Skill
internal: true
---
content`;
    const result = parseFrontmatter(content);
    assert.equal(result.name, "Internal Skill");
    assert.equal(result.internal, true);
  });

  it("detects internal: true nested under metadata", () => {
    const content = `---
name: Nested Internal
metadata:
  internal: true
---
content`;
    const result = parseFrontmatter(content);
    assert.equal(result.name, "Nested Internal");
    assert.equal(result.internal, true);
  });

  it("returns nulls when no frontmatter delimiter", () => {
    const result = parseFrontmatter("Some content without frontmatter");
    assert.equal(result.name, null);
    assert.equal(result.internal, false);
  });

  it("returns nulls when closing --- is missing", () => {
    const result = parseFrontmatter("---\nname: Orphan");
    assert.equal(result.name, null);
    assert.equal(result.internal, false);
  });

  it("strips surrounding quotes from name", () => {
    const content = `---
name: "Quoted Name"
---`;
    const result = parseFrontmatter(content);
    assert.equal(result.name, "Quoted Name");
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
    assert.deepEqual(lines, [
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
    assert.deepEqual(selectionLines, ['      "aaa"', '      "mmm"', '      "zzz"']);
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
    assert.ok(lines.some((l) => l.includes("flake = true;")));
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
    assert.ok(catIndex !== -1);
    assert.ok(lines[catIndex + 1].includes("src-a"));
    assert.ok(lines[catIndex + 2].includes("src-z"));
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
    assert.ok(blockStart !== -1, "block should be present");
    assert.ok(blockStart < lastBrace, "block should appear before closing brace");
  });

  it("inserts block when { is the first non-comment line", () => {
    const lines = ["{", "  source-a = {", "  };", "}"];
    const block = ["  new-source = {", "  };"];
    const result = insertSourceBlock(lines, block);
    assert.ok(result.includes("  new-source = {"));
    assert.equal(result[result.length - 1], "}");
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
    assert.ok(blockStart !== -1);
    assert.ok(blockStart < lastBrace);
    // Original source-a should still be present
    assert.ok(result.some((l) => l.includes("source-a")));
  });

  it("throws when no valid insertion point found", () => {
    assert.throws(() => insertSourceBlock(["no braces here"], ["block"]), /Failed to find end/);
  });

  it("preserves all original lines around the block", () => {
    const lines = ["{", "  existing = {};", "}"];
    const block = ["  new = {};"];
    const result = insertSourceBlock(lines, block);
    assert.equal(result[0], "{");
    assert.equal(result[1], "  existing = {};");
    assert.equal(result[2], "  new = {};");
    assert.equal(result[3], "}");
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
    assert.equal(result.changed, true);
    assert.deepEqual(result.added, ["my-skill"]);
    assert.deepEqual(result.already, []);
    assert.ok(result.lines.some((l) => l.includes("selection.enable")));
    assert.ok(result.lines.some((l) => l.includes('"my-skill"')));
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
    assert.equal(result.changed, true);
    assert.deepEqual(result.added, ["new-skill"]);
    assert.deepEqual(result.already, []);
    assert.ok(result.lines.some((l) => l.includes('"existing-skill"')));
    assert.ok(result.lines.some((l) => l.includes('"new-skill"')));
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
    assert.equal(result.changed, false);
    assert.deepEqual(result.added, []);
    assert.deepEqual(result.already, ["existing-skill"]);
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
    assert.equal(result.changed, true);
    assert.deepEqual(result.added, ["new-skill"]);
    assert.ok(result.lines.some((l) => l.includes('"existing-skill"')));
    assert.ok(result.lines.some((l) => l.includes('"new-skill"')));
  });

  it("adds multiple skills at once", () => {
    const lines = ["{", "  my-source = {", '    url = "github:o/r";', "  };", "}"];
    const result = updateSelectionInLines(lines, "my-source", ["skill-c", "skill-a", "skill-b"]);
    assert.equal(result.changed, true);
    assert.equal(result.added.length, 3);
    // Output should be sorted
    const skillLines = result.lines.filter((l) => l.match(/"skill-[abc]"/));
    assert.equal(skillLines[0].trim(), '"skill-a"');
    assert.equal(skillLines[1].trim(), '"skill-b"');
    assert.equal(skillLines[2].trim(), '"skill-c"');
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
    assert.equal(result.changed, true);
    assert.deepEqual(result.added, ["skill-b"]);
    assert.deepEqual(result.already, ["skill-a"]);
  });

  it("throws when source is not found", () => {
    const lines = ["{", "  other-source = {", "  };", "}"];
    assert.throws(
      () => updateSelectionInLines(lines, "missing-source", ["skill"]),
      /Source not found/,
    );
  });
});

// ============================================================
// parseGitHubUrl
// ============================================================
describe("parseGitHubUrl", () => {
  it("parses basic owner/repo URL", () => {
    const result = parseGitHubUrl(new URL("https://github.com/millionco/react-doctor"));
    assert.deepEqual(result, {
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
    assert.equal(result?.repo, "react-doctor");
  });

  // https://github.com/millionco/react-doctor/tree/main/skills/react-doctor
  it("parses tree/branch/path URL: extracts ref and hintPath", () => {
    const url = "https://github.com/millionco/react-doctor/tree/main/skills/react-doctor";
    const result = parseGitHubUrl(new URL(url));
    assert.deepEqual(result, {
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
    assert.equal(result?.ref, "main");
    assert.equal(result?.hintPath, null);
  });

  it("parses tree/tag URL", () => {
    const result = parseGitHubUrl(
      new URL("https://github.com/millionco/react-doctor/tree/v1.2.3"),
    );
    assert.equal(result?.ref, "v1.2.3");
    assert.equal(result?.hintPath, null);
  });

  // https://github.com/millionco/react-doctor/skills/react-doctor
  // tree/ がないため hintPath は取得できない（制限）
  it("ignores subpath when tree/ segment is absent", () => {
    const url = "https://github.com/millionco/react-doctor/skills/react-doctor";
    const result = parseGitHubUrl(new URL(url));
    assert.deepEqual(result, {
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
    assert.equal(result?.ref, null);
    assert.equal(result?.hintPath, null);
  });

  it("returns null when only owner is present", () => {
    // pathname has only 1 segment
    const result = parseGitHubUrl(new URL("https://github.com/millionco"));
    assert.equal(result, null);
  });

  // github.com/millionco/react-doctor/tree/main/skills/react-doctor
  // （プロトコルなし）は new URL() でパースできないため parseGitHubUrl の対象外。
  // looksLikeSource でも false を返すため、CLIへの入力として認識されない。
  it("— NOTE: bare github.com/owner/repo/... (no https://) is NOT a valid URL for this parser", () => {
    assert.throws(() => new URL("github.com/millionco/react-doctor/tree/main/skills/react-doctor"));
  });
});
