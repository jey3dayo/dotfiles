#!/usr/bin/env bun

import { describe, expect, it } from "bun:test";
import * as fs from "node:fs";
import { repoFile } from "./repo-file.ts";

const scriptPath = repoFile("mise", "lib", "run-ts-tests.sh");

describe("mise/lib/run-ts-tests.sh discovery roots", () => {
  const source = fs.readFileSync(scriptPath, "utf8");

  it("searches scripts and bin for bun test files", () => {
    expect(source).toContain('search_roots+=("scripts")');
    expect(source).toContain('search_roots+=("bin")');
  });

  it("does not search the removed agents/scripts tree", () => {
    expect(source).not.toContain("agents/scripts");
  });
});
