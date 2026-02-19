#!/usr/bin/env tsx

import * as assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { describe, it } from "node:test";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const sourceScript = path.join(__dirname, "setup-gitleaks.sh");

const makeExecutable = (filePath: string, content: string): void => {
  fs.writeFileSync(filePath, content, "utf8");
  fs.chmodSync(filePath, 0o755);
};

const createTempRepo = (): {
  root: string;
  scriptPath: string;
  fakeBin: string;
  logsDir: string;
} => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "setup-gitleaks-test-"));
  const scriptsDir = path.join(root, "scripts");
  const fakeBin = path.join(root, "bin");
  const logsDir = path.join(root, "logs");

  fs.mkdirSync(scriptsDir, { recursive: true });
  fs.mkdirSync(fakeBin, { recursive: true });
  fs.mkdirSync(logsDir, { recursive: true });

  const scriptPath = path.join(scriptsDir, "setup-gitleaks.sh");
  fs.copyFileSync(sourceScript, scriptPath);
  fs.chmodSync(scriptPath, 0o755);

  return { root, scriptPath, fakeBin, logsDir };
};

const installFakePreCommit = (fakeBin: string, logsDir: string): void => {
  makeExecutable(
    path.join(fakeBin, "pre-commit"),
    `#!/usr/bin/env sh
echo "$*" >> "${path.join(logsDir, "pre-commit.log")}"
if [ "$1" = "--version" ]; then
  echo "pre-commit 3.0.0"
  exit 0
fi
exit 0
`,
  );
};

const installFakeGitleaks = (fakeBin: string, logsDir: string): void => {
  makeExecutable(
    path.join(fakeBin, "gitleaks"),
    `#!/usr/bin/env sh
echo "$*" >> "${path.join(logsDir, "gitleaks.log")}"
if [ "$1" = "version" ]; then
  echo "8.20.0"
  exit 0
fi
if [ "$1" = "detect" ]; then
  report_path=""
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --report-path)
        report_path="$2"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done

  if [ -n "$report_path" ]; then
    mode="\${FAKE_GITLEAKS_BASELINE_MODE:-findings}"
    if [ "$mode" = "clean" ]; then
      printf '[]\\n' > "$report_path"
      exit 0
    fi
    printf '%s\\n' '[' > "$report_path"
    printf '%s\\n' '  {"Fingerprint":"fingerprint-a"},' >> "$report_path"
    printf '%s\\n' '  {"Fingerprint":"fingerprint-a"},' >> "$report_path"
    printf '%s\\n' '  {"Fingerprint":"fingerprint-b"}' >> "$report_path"
    printf '%s\\n' ']' >> "$report_path"
    exit 1
  fi

  exit "\${FAKE_GITLEAKS_SCAN_STATUS:-0}"
fi
exit 0
`,
  );
};

const runSetupGitleaks = ({
  repoRoot,
  scriptPath,
  pathPrefix,
  args = [],
  stdin = "",
  env = {},
}: {
  repoRoot: string;
  scriptPath: string;
  pathPrefix: string[];
  args?: string[];
  stdin?: string;
  env?: Record<string, string>;
}) =>
  spawnSync("sh", [scriptPath, ...args], {
    cwd: repoRoot,
    encoding: "utf8",
    input: stdin,
    env: {
      ...process.env,
      PATH: [...pathPrefix, "/usr/bin", "/bin"].join(":"),
      ...env,
    },
  });

describe("scripts/setup-gitleaks.sh", () => {
  it("prints help with --help", () => {
    const repo = createTempRepo();
    try {
      const result = runSetupGitleaks({
        repoRoot: repo.root,
        scriptPath: repo.scriptPath,
        pathPrefix: [],
        args: ["--help"],
      });

      assert.equal(result.status, 0);
      assert.match(result.stdout, /Usage:/);
    } finally {
      fs.rmSync(repo.root, { recursive: true, force: true });
    }
  });

  it("fails when gitleaks is missing", () => {
    const repo = createTempRepo();
    try {
      const result = runSetupGitleaks({
        repoRoot: repo.root,
        scriptPath: repo.scriptPath,
        pathPrefix: [],
      });

      assert.notEqual(result.status, 0);
      assert.match(result.stderr, /gitleaks is not installed/);
    } finally {
      fs.rmSync(repo.root, { recursive: true, force: true });
    }
  });

  it("creates fingerprint baseline from findings and runs hooks", () => {
    const repo = createTempRepo();
    installFakeGitleaks(repo.fakeBin, repo.logsDir);
    installFakePreCommit(repo.fakeBin, repo.logsDir);

    try {
      const result = runSetupGitleaks({
        repoRoot: repo.root,
        scriptPath: repo.scriptPath,
        pathPrefix: [repo.fakeBin],
        args: ["--create-baseline"],
      });

      assert.equal(result.status, 0);
      const ignorePath = path.join(repo.root, ".gitleaksignore");
      assert.equal(fs.existsSync(ignorePath), true);
      const ignoreContent = fs.readFileSync(ignorePath, "utf8");
      assert.match(ignoreContent, /fingerprint-a/);
      assert.match(ignoreContent, /fingerprint-b/);
      const lines = ignoreContent.trim().split("\n");
      assert.equal(lines.filter((line) => line === "fingerprint-a").length, 1);

      const preCommitLog = fs.readFileSync(path.join(repo.logsDir, "pre-commit.log"), "utf8");
      assert.match(preCommitLog, /install/);
      assert.match(preCommitLog, /autoupdate/);
      assert.match(preCommitLog, /run gitleaks --all-files/);
    } finally {
      fs.rmSync(repo.root, { recursive: true, force: true });
    }
  });

  it("writes header baseline when no secrets are found", () => {
    const repo = createTempRepo();
    installFakeGitleaks(repo.fakeBin, repo.logsDir);
    installFakePreCommit(repo.fakeBin, repo.logsDir);

    try {
      const result = runSetupGitleaks({
        repoRoot: repo.root,
        scriptPath: repo.scriptPath,
        pathPrefix: [repo.fakeBin],
        args: ["--create-baseline"],
        env: {
          FAKE_GITLEAKS_BASELINE_MODE: "clean",
        },
      });

      assert.equal(result.status, 0);
      const ignorePath = path.join(repo.root, ".gitleaksignore");
      assert.equal(fs.existsSync(ignorePath), true);
      const ignoreContent = fs.readFileSync(ignorePath, "utf8");
      assert.match(ignoreContent, /# Gitleaks Ignore File/);
      assert.match(ignoreContent, /Generate\/update with/);
    } finally {
      fs.rmSync(repo.root, { recursive: true, force: true });
    }
  });
});
