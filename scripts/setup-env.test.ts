#!/usr/bin/env bun

import { describe, expect, it } from "bun:test";
import { spawn, spawnSync } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, "..");
const scriptPath = path.join(repoRoot, "scripts", "setup-env.sh");
const isWindows = process.platform === "win32";

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

const spawnSetupEnv = ({
  xdgConfigHome,
  pathPrefix,
  extraEnv = {},
}: {
  xdgConfigHome: string;
  pathPrefix: string[];
  extraEnv?: Record<string, string>;
}) =>
  spawn("sh", [scriptPath], {
    env: {
      ...process.env,
      XDG_CONFIG_HOME: xdgConfigHome,
      PATH: [...pathPrefix, "/usr/bin", "/bin"].join(":"),
      ...extraEnv,
    },
  });

(isWindows ? describe.skip : describe)("scripts/setup-env.sh", () => {
  it("fails when .env is missing", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "setup-env-test-"));
    const configHome = path.join(tempRoot, "config");
    fs.mkdirSync(configHome, { recursive: true });

    try {
      const result = runSetupEnv({
        xdgConfigHome: configHome,
        pathPrefix: [],
      });
      expect(result.status).not.toBe(0);
      expect(result.stderr).toMatch(/CRITICAL: .*\.env not found/);
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
      expect(result.status).not.toBe(0);
      expect(result.stderr).toMatch(/CRITICAL: dotenvx not found/);
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

      expect(result.status).toBe(0);
      expect(result.stdout).toMatch(/\.env\.local updated successfully/);
      const envLocal = path.join(configHome, ".env.local");
      expect(fs.readFileSync(envLocal, "utf8")).toBe("SECRET=decrypted\n");
      expect(fs.readFileSync(logFile, "utf8")).toMatch(/decrypt -f/);
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

      expect(result.status).toBe(0);
      expect(fs.existsSync(logFile)).toBe(false);
      expect(fs.readFileSync(envLocal, "utf8")).toBe("SECRET=existing\n");
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

      expect(result.status).toBe(0);
      expect(result.stdout).toMatch(/Updating \.env\.local/);
      expect(fs.readFileSync(envLocal, "utf8")).toBe("SECRET=new\n");
      expect(fs.readFileSync(logFile, "utf8")).toMatch(/decrypt -f/);
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });

  it("allows concurrent setup-env runs without false failures", async () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "setup-env-test-"));
    const configHome = path.join(tempRoot, "config");
    const fakeBin = path.join(tempRoot, "bin");
    fs.mkdirSync(configHome, { recursive: true });
    fs.mkdirSync(fakeBin, { recursive: true });

    fs.writeFileSync(path.join(configHome, ".env"), "SECRET=from-env\n", "utf8");
    fs.writeFileSync(path.join(configHome, ".env.keys"), "private-key\n", "utf8");

    makeExecutable(
      path.join(fakeBin, "dotenvx"),
      `#!/usr/bin/env sh
sleep 0.2
printf '%s\\n' "SECRET=decrypted"
`,
    );

    const collect = (child: ReturnType<typeof spawnSetupEnv>) =>
      new Promise<{ code: number | null; stdout: string; stderr: string }>((resolve) => {
        let stdout = "";
        let stderr = "";
        child.stdout.on("data", (chunk) => {
          stdout += chunk.toString();
        });
        child.stderr.on("data", (chunk) => {
          stderr += chunk.toString();
        });
        child.on("close", (code) => {
          resolve({ code, stdout, stderr });
        });
      });

    try {
      const first = spawnSetupEnv({
        xdgConfigHome: configHome,
        pathPrefix: [fakeBin],
      });
      const second = spawnSetupEnv({
        xdgConfigHome: configHome,
        pathPrefix: [fakeBin],
      });

      const [firstResult, secondResult] = await Promise.all([collect(first), collect(second)]);

      expect(firstResult.code).toBe(0);
      expect(firstResult.stderr).toBe("");
      expect(secondResult.code).toBe(0);
      expect(secondResult.stderr).toBe("");
      expect(fs.readFileSync(path.join(configHome, ".env.local"), "utf8")).toBe("SECRET=decrypted\n");
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });
});
