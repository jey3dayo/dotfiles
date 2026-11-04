#!/usr/bin/env bun

import { afterAll, describe, expect, it } from "bun:test";
import { spawnSync } from "node:child_process";
import { chmodSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { repoFile } from "./repo-file.ts";

const scriptPath = repoFile("scripts", "claude-plugins.py");
const dirs: string[] = [];
afterAll(() => {
  for (const d of dirs) rmSync(d, { recursive: true, force: true });
});

type Fixture = {
  list: string;
  markets: object[];
  plugins: object[];
  enabledPlugins: Record<string, boolean>;
};

const run = (f: Fixture) => {
  const dir = mkdtempSync(join(tmpdir(), "claude-plugins-test-"));
  dirs.push(dir);
  writeFileSync(join(dir, "plugins.toml"), f.list);
  writeFileSync(join(dir, "markets.json"), JSON.stringify(f.markets).replaceAll("__DIR__", dir));
  writeFileSync(join(dir, "plugins.json"), JSON.stringify(f.plugins));
  writeFileSync(join(dir, "settings.json"), JSON.stringify({ enabledPlugins: f.enabledPlugins }));
  const fake = join(dir, "claude");
  writeFileSync(
    fake,
    `#!/bin/sh\nif [ "$2" = marketplace ]; then cat "${dir}/markets.json"; else cat "${dir}/plugins.json"; fi\n`,
  );
  chmodSync(fake, 0o755);
  return spawnSync("python3", [scriptPath], {
    encoding: "utf8",
    env: {
      ...process.env,
      PATH: `${dir}:${process.env.PATH}`,
      CLAUDE_PLUGINS_PUBLIC: join(dir, "plugins.toml"),
      CLAUDE_PLUGINS_LOCAL: join(dir, "plugins.toml"),
      CLAUDE_CONFIG_DIR: dir,
    },
  });
};

const list = `[marketplaces.m]\nsource = "Org/Repo#stable"\n\n[plugins]\nuser = ["p@m"]\n`;
const market = { name: "m", source: "github", repo: "org/repo", ref: "stable" };

describe("claude-plugins.py", () => {
  it("ref 付き marketplace を repo#ref で比較して一致とみなす", () => {
    const r = run({
      list,
      markets: [market],
      plugins: [{ id: "p@m", scope: "user", enabled: true }],
      enabledPlugins: { "p@m": true },
    });
    expect(r.stdout).toContain("差分なし");
    expect(r.status).toBe(0);
  }, 30_000);

  it("ローカルパスの source はリストのディレクトリ基準で解決して比較する", () => {
    const r = run({
      list: `[marketplaces.m]\nsource = "./mk"\n\n[plugins]\nuser = ["p@m"]\n`,
      markets: [{ name: "m", source: "directory", path: "__DIR__/mk" }],
      plugins: [{ id: "p@m", scope: "user", enabled: true }],
      enabledPlugins: { "p@m": true },
    });
    expect(r.stdout).toContain("差分なし");
    expect(r.status).toBe(0);
  }, 30_000);

  it("ref が違えば MISMATCH でエラー", () => {
    const r = run({
      list,
      markets: [{ ...market, ref: "main" }],
      plugins: [{ id: "p@m", scope: "user", enabled: true }],
      enabledPlugins: { "p@m": true },
    });
    expect(r.stdout).toContain("MISMATCH");
    expect(r.status).toBe(1);
  }, 30_000);

  it("user 設定で無効なら merged が有効でも不足扱い、上書きは報告", () => {
    const r = run({
      list,
      markets: [market],
      plugins: [{ id: "p@m", scope: "user", enabled: true }],
      enabledPlugins: { "p@m": false },
    });
    expect(r.stdout).toContain("disabled p@m");
    expect(r.stdout).toContain("override p@m");
    expect(r.status).toBe(2);
  }, 30_000);

  it("user 設定で有効なら project 側で無効でも差分なし（上書きは報告のみ）", () => {
    const r = run({
      list,
      markets: [market],
      plugins: [{ id: "p@m", scope: "user", enabled: false }],
      enabledPlugins: { "p@m": true },
    });
    expect(r.stdout).toContain("override p@m");
    expect(r.stdout).toContain("差分なし");
    expect(r.status).toBe(0);
  }, 30_000);
});
