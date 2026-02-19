#!/usr/bin/env tsx

import * as assert from "node:assert/strict";
import { describe, it } from "node:test";

import {
  buildAgentEntries,
  countChar,
  ensureInputsBlock,
  extractSources,
  stripComments,
  syncFlakeInputsFromSources,
} from "./skills-sync-inputs-lib.ts";

describe("skills-sync-inputs-lib", () => {
  it("countChar counts all matching characters", () => {
    assert.equal(countChar("{a{b}}", "{"), 2);
    assert.equal(countChar("{a{b}}", "}"), 2);
    assert.equal(countChar("", "{"), 0);
  });

  it("stripComments removes trailing comment part only", () => {
    assert.equal(stripComments('  url = "x"; # comment'), '  url = "x"; ');
    assert.equal(stripComments("# comment only"), "");
  });

  it("extractSources parses source blocks from nix text", () => {
    const sourceContent = `{
  source-b = {
    url = "github:owner/b";
    flake = true;
  };
  source-a = {
    url = "github:owner/a"; # inline
    flake = false;
  };
  source-no-url = {
    flake = false;
  };
}`;

    const sources = extractSources(sourceContent);
    assert.equal(sources.length, 3);
    assert.deepEqual(sources[0], {
      name: "source-b",
      url: "github:owner/b",
      flake: true,
    });
    assert.deepEqual(sources[2], {
      name: "source-no-url",
      url: null,
      flake: false,
    });
  });

  it("buildAgentEntries sorts by source name and defaults flake to false", () => {
    const lines = buildAgentEntries([
      { name: "zeta", url: "github:o/zeta", flake: null },
      { name: "alpha", url: "github:o/alpha", flake: true },
      { name: "no-url", url: null, flake: false },
    ]);

    assert.deepEqual(lines, [
      "    alpha = {",
      '      url = "github:o/alpha";',
      "      flake = true;",
      "    };",
      "    zeta = {",
      '      url = "github:o/zeta";',
      "      flake = false;",
      "    };",
    ]);
  });

  it("ensureInputsBlock returns inputs range", () => {
    const lines = [
      "{",
      "  inputs = {",
      '    nixpkgs.url = "github:NixOS/nixpkgs";',
      "  };",
      "}",
    ];
    const range = ensureInputsBlock(lines);
    assert.deepEqual(range, { inputsStart: 1, inputsEnd: 3 });
  });

  it("ensureInputsBlock throws when inputs block is missing", () => {
    assert.throws(
      () => ensureInputsBlock(["{", '  description = "x";', "}"]),
      /Failed to locate inputs block/,
    );
  });

  it("syncFlakeInputsFromSources inserts block when marker is absent", () => {
    const sourceContent = `{
  b = {
    url = "github:o/b";
    flake = false;
  };
  a = {
    url = "github:o/a";
    flake = true;
  };
}`;

    const flakeContent = `{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };
}`;

    const updated = syncFlakeInputsFromSources(sourceContent, flakeContent);
    assert.match(updated, /# Agent-skills external sources/);
    assert.match(updated, /a = \{/);
    assert.match(updated, /b = \{/);
    assert.ok(updated.indexOf("a = {") < updated.indexOf("b = {"));
  });

  it("syncFlakeInputsFromSources replaces existing marker block", () => {
    const sourceContent = `{
  new-source = {
    url = "github:o/new";
    flake = false;
  };
}`;
    const flakeContent = `{
  inputs = {
    # Agent-skills external sources (flake = false: raw git repos)
    old-source = {
      url = "github:o/old";
      flake = false;
    };
    # END Agent-skills external sources
    nixpkgs.url = "github:NixOS/nixpkgs";
  };
}`;

    const updated = syncFlakeInputsFromSources(sourceContent, flakeContent);
    assert.match(updated, /new-source = \{/);
    assert.doesNotMatch(updated, /old-source = \{/);
  });

  it("syncFlakeInputsFromSources preserves CRLF line endings", () => {
    const sourceContent = "{\n  src = {\n    url = \"github:o/src\";\n  };\n}";
    const flakeContent = "{\r\n  inputs = {\r\n  };\r\n}\r\n";

    const updated = syncFlakeInputsFromSources(sourceContent, flakeContent);
    assert.match(updated, /\r\n/);
    assert.doesNotMatch(updated, /(?<!\r)\n/);
  });
});
