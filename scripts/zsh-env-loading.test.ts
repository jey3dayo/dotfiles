#!/usr/bin/env bun

import { describe, expect, it } from "bun:test";
import { spawnSync } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, "..");
const zdotdir = path.join(repoRoot, "zsh");
const printPasswordCommand = ["print -r -- ", "${", "GOG_KEYRING_PASSWORD:-unset", "}"].join("");

describe("zsh/.zshenv", () => {
  it("loads .env.local for non-interactive shells", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "zsh-env-loading-"));
    const configHome = path.join(tempRoot, "config");
    const homeDir = path.join(tempRoot, "home");

    fs.mkdirSync(configHome, { recursive: true });
    fs.mkdirSync(homeDir, { recursive: true });
    fs.writeFileSync(path.join(configHome, ".env.local"), 'export GOG_KEYRING_PASSWORD="test-password"\n', "utf8");

    try {
      const result = spawnSync("zsh", ["-c", printPasswordCommand], {
        encoding: "utf8",
        env: {
          HOME: homeDir,
          XDG_CONFIG_HOME: configHome,
          ZDOTDIR: zdotdir,
          PATH: "/usr/bin:/bin",
          LOGNAME: "tester",
          USER: "tester",
        },
      });

      expect(result.status).toBe(0);
      expect(result.stdout.trim()).toBe("test-password");
      expect(result.stderr.trim()).toBe("");
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });
});
