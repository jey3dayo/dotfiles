#!/usr/bin/env bun

import { describe, expect, it } from "bun:test";

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
    expect(countChar("{a{b}}", "{")).toBe(2);
    expect(countChar("{a{b}}", "}")).toBe(2);
    expect(countChar("", "{")).toBe(0);
  });

  it("stripComments removes trailing comment part only", () => {
    expect(stripComments('  url = "x"; # comment')).toBe('  url = "x"; ');
    expect(stripComments("# comment only")).toBe("");
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
    expect(sources.length).toBe(3);
    expect(sources[0]).toEqual({
      name: "source-b",
      url: "github:owner/b",
      flake: true,
    });
    expect(sources[2]).toEqual({
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

    expect(lines).toEqual([
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
    expect(range).toEqual({ inputsStart: 1, inputsEnd: 3 });
  });

  it("ensureInputsBlock throws when inputs block is missing", () => {
    expect(() => ensureInputsBlock(["{", '  description = "x";', "}"])).toThrow(/Failed to locate inputs block/);
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
    expect(updated).toMatch(/# Agent-skills external sources/);
    expect(updated).toMatch(/a = \{/);
    expect(updated).toMatch(/b = \{/);
    expect(updated.indexOf("a = {") < updated.indexOf("b = {")).toBeTruthy();
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
    expect(updated).toMatch(/new-source = \{/);
    expect(updated).not.toMatch(/old-source = \{/);
  });

  it("syncFlakeInputsFromSources preserves CRLF line endings", () => {
    const sourceContent = "{\n  src = {\n    url = \"github:o/src\";\n  };\n}";
    const flakeContent = "{\r\n  inputs = {\r\n  };\r\n}\r\n";

    const updated = syncFlakeInputsFromSources(sourceContent, flakeContent);
    expect(updated).toMatch(/\r\n/);
    expect(updated).not.toMatch(/(?<!\r)\n/);
  });
});
