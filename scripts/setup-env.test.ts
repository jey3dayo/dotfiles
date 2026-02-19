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
const repoRoot = path.resolve(__dirname, "..");
const scriptPath = path.join(repoRoot, "scripts", "setup-env.sh");

const makeExecutable = (filePath: string, content: string): void => {
  fs.writeFileSync(filePath, content, "utf8");
  fs.chmodSync(filePath, 0o755);
};

const runSetupEnv = ({
  xdgConfigHome,
  pathPrefix,
  extraEnv = {},
}: {
  xdgConfigHome: string;
  pathPrefix: string[];
  extraEnv?: Record<string, string>;
}) =>
  spawnSync("sh", [scriptPath], {
    encoding: "utf8",
    env: {
      ...process.env,
      XDG_CONFIG_HOME: xdgConfigHome,
      PATH: [...pathPrefix, "/usr/bin", "/bin"].join(":"),
      ...extraEnv,
    },
  });

describe("scripts/setup-env.sh", () => {
  it("fails when .env is missing", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "setup-env-test-"));
    const configHome = path.join(tempRoot, "config");
    fs.mkdirSync(configHome, { recursive: true });

    try {
      const result = runSetupEnv({
        xdgConfigHome: configHome,
        pathPrefix: [],
      });
      assert.notEqual(result.status, 0);
      assert.match(result.stderr, /CRITICAL: .*\.env not found/);
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });

  it("fails when dotenvx command is missing", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "setup-env-test-"));
    const configHome = path.join(tempRoot, "config");
    fs.mkdirSync(configHome, { recursive: true });
    fs.writeFileSync(path.join(configHome, ".env"), "SECRET=1\n", "utf8");
    fs.writeFileSync(path.join(configHome, ".env.keys"), "key", "utf8");

    try {
      const result = runSetupEnv({
        xdgConfigHome: configHome,
        pathPrefix: [],
      });
      assert.notEqual(result.status, 0);
      assert.match(result.stderr, /CRITICAL: dotenvx not found/);
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });

  it("generates .env.local when missing", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "setup-env-test-"));
    const configHome = path.join(tempRoot, "config");
    const fakeBin = path.join(tempRoot, "bin");
    const logFile = path.join(tempRoot, "dotenvx.log");
    fs.mkdirSync(configHome, { recursive: true });
    fs.mkdirSync(fakeBin, { recursive: true });

    fs.writeFileSync(path.join(configHome, ".env"), "SECRET=from-env\n", "utf8");
    fs.writeFileSync(path.join(configHome, ".env.keys"), "private-key", "utf8");

    makeExecutable(
      path.join(fakeBin, "dotenvx"),
      `#!/usr/bin/env sh
echo "$*" >> "${logFile}"
printf '%s\\n' "SECRET=decrypted"
`,
    );

    try {
      const result = runSetupEnv({
        xdgConfigHome: configHome,
        pathPrefix: [fakeBin],
      });

      assert.equal(result.status, 0);
      assert.match(result.stdout, /\.env\.local updated successfully/);
      const envLocal = path.join(configHome, ".env.local");
      assert.equal(fs.readFileSync(envLocal, "utf8"), "SECRET=decrypted\n");
      assert.match(fs.readFileSync(logFile, "utf8"), /decrypt -f/);
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });

  it("skips decryption when .env.local is newer", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "setup-env-test-"));
    const configHome = path.join(tempRoot, "config");
    const fakeBin = path.join(tempRoot, "bin");
    const logFile = path.join(tempRoot, "dotenvx.log");
    fs.mkdirSync(configHome, { recursive: true });
    fs.mkdirSync(fakeBin, { recursive: true });

    const envFile = path.join(configHome, ".env");
    const envLocal = path.join(configHome, ".env.local");
    fs.writeFileSync(envFile, "SECRET=from-env\n", "utf8");
    fs.writeFileSync(path.join(configHome, ".env.keys"), "private-key", "utf8");
    fs.writeFileSync(envLocal, "SECRET=existing\n", "utf8");

    const now = Date.now();
    fs.utimesSync(envFile, new Date(now - 60_000), new Date(now - 60_000));
    fs.utimesSync(envLocal, new Date(now), new Date(now));

    makeExecutable(
      path.join(fakeBin, "dotenvx"),
      `#!/usr/bin/env sh
echo "$*" >> "${logFile}"
printf '%s\\n' "SECRET=decrypted"
`,
    );

    try {
      const result = runSetupEnv({
        xdgConfigHome: configHome,
        pathPrefix: [fakeBin],
      });

      assert.equal(result.status, 0);
      assert.equal(fs.existsSync(logFile), false);
      assert.equal(fs.readFileSync(envLocal, "utf8"), "SECRET=existing\n");
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });

  it("updates .env.local when .env is newer", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "setup-env-test-"));
    const configHome = path.join(tempRoot, "config");
    const fakeBin = path.join(tempRoot, "bin");
    const logFile = path.join(tempRoot, "dotenvx.log");
    fs.mkdirSync(configHome, { recursive: true });
    fs.mkdirSync(fakeBin, { recursive: true });

    const envFile = path.join(configHome, ".env");
    const envLocal = path.join(configHome, ".env.local");
    fs.writeFileSync(envFile, "SECRET=from-env\n", "utf8");
    fs.writeFileSync(path.join(configHome, ".env.keys"), "private-key", "utf8");
    fs.writeFileSync(envLocal, "SECRET=old\n", "utf8");

    const now = Date.now();
    fs.utimesSync(envLocal, new Date(now - 60_000), new Date(now - 60_000));
    fs.utimesSync(envFile, new Date(now), new Date(now));

    makeExecutable(
      path.join(fakeBin, "dotenvx"),
      `#!/usr/bin/env sh
echo "$*" >> "${logFile}"
printf '%s\\n' "SECRET=new"
`,
    );

    try {
      const result = runSetupEnv({
        xdgConfigHome: configHome,
        pathPrefix: [fakeBin],
      });

      assert.equal(result.status, 0);
      assert.match(result.stdout, /Updating \.env\.local/);
      assert.equal(fs.readFileSync(envLocal, "utf8"), "SECRET=new\n");
      assert.match(fs.readFileSync(logFile, "utf8"), /decrypt -f/);
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });
});
