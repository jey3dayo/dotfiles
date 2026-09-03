#!/usr/bin/env bun

import { describe, expect, it } from "bun:test";
import { spawnSync } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { repoFile } from "./repo-file.ts";

const scriptPath = repoFile("scripts", "bootstrap.sh");
const isWindows = process.platform === "win32";

const makeExecutable = (filePath: string, content: string): void => {
  fs.writeFileSync(filePath, content, "utf8");
  fs.chmodSync(filePath, 0o755);
};

// PATH holds only the fake bin so "missing command" cases stay missing: on Linux
// /bin is a symlink to /usr/bin, where git/zsh/curl exist. sh is invoked by
// absolute path because Bun resolves the executable through the given PATH.
const runBootstrap = (pathPrefix: string[]) =>
  spawnSync("/bin/sh", [scriptPath], {
    encoding: "utf8",
    env: {
      ...process.env,
      PATH: pathPrefix.join(":"),
    },
    input: "n\n",
  });

(isWindows ? describe.skip : describe)("scripts/bootstrap.sh", () => {
  it("exits when uname is not Darwin", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "bootstrap-test-"));
    const fakeBin = path.join(tempRoot, "bin");
    fs.mkdirSync(fakeBin, { recursive: true });
    makeExecutable(
      path.join(fakeBin, "uname"),
      `#!/bin/sh
echo Linux
`,
    );

    try {
      const result = runBootstrap([fakeBin]);
      expect(result.status).not.toBe(0);
      expect(result.stderr).toMatch(/macOS only/);
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });

  it("exits when git is missing on Darwin", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "bootstrap-test-"));
    const fakeBin = path.join(tempRoot, "bin");
    fs.mkdirSync(fakeBin, { recursive: true });
    makeExecutable(
      path.join(fakeBin, "uname"),
      `#!/bin/sh
case "$1" in
  -s) echo Darwin ;;
  -m) echo arm64 ;;
  *) echo Darwin ;;
esac
`,
    );

    try {
      const result = runBootstrap([fakeBin]);
      expect(result.status).not.toBe(0);
      expect(result.stderr).toMatch(/git is not installed/);
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });

  it("skips Homebrew install when brew is already on PATH", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "bootstrap-test-"));
    const fakeBin = path.join(tempRoot, "bin");
    fs.mkdirSync(fakeBin, { recursive: true });
    makeExecutable(
      path.join(fakeBin, "uname"),
      `#!/bin/sh
case "$1" in
  -s) echo Darwin ;;
  -m) echo arm64 ;;
  *) echo Darwin ;;
esac
`,
    );
    for (const name of ["git", "zsh", "curl"]) {
      makeExecutable(path.join(fakeBin, name), "#!/bin/sh\nexit 0\n");
    }
    makeExecutable(
      path.join(fakeBin, "brew"),
      `#!/bin/sh
if [ "$1" = "--version" ]; then
  echo "Homebrew 4.0.0"
  exit 0
fi
exit 1
`,
    );
    // builtin-only: no external binary is reachable through the fake PATH
    makeExecutable(
      path.join(fakeBin, "head"),
      `#!/bin/sh
while IFS= read -r line; do
  printf '%s\\n' "$line"
done
`,
    );

    try {
      const result = runBootstrap([fakeBin]);
      expect(result.status).toBe(0);
      expect(result.stdout).toMatch(/Homebrew is already installed/);
      expect(result.stdout).not.toMatch(/Installing Homebrew/);
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });
});
