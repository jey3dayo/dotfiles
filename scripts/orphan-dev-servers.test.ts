#!/usr/bin/env bun

import { afterEach, describe, expect, it } from "bun:test";
import { spawnSync } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { repoFile } from "./repo-file.ts";

const scriptPath = repoFile("scripts", "orphan-dev-servers.sh");
const isWindows = process.platform === "win32";
const myUid = process.getuid?.() ?? 0;

type PsRow = { pid: number; ppid: number; uid?: number; etime?: string; command: string };

const psLine = ({ pid, ppid, uid = myUid, etime = "01:02:03", command }: PsRow): string =>
  `${String(pid).padStart(6)} ${String(ppid).padStart(6)} ${uid} ${etime} ${command}`;

const tempDirs: string[] = [];

const makeTempDir = (): string => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "orphan-dev-servers-test-"));
  tempDirs.push(dir);
  return dir;
};

const runAudit = ({
  rows,
  args = [],
  uname = "Darwin",
  stubOsascript,
}: {
  rows: PsRow[];
  args?: string[];
  uname?: string;
  stubOsascript?: { exitCode: number };
}) => {
  const dir = makeTempDir();
  const psInput = path.join(dir, "ps.txt");
  fs.writeFileSync(psInput, `${rows.map(psLine).join("\n")}\n`, "utf8");

  const stubDir = path.join(dir, "bin");
  fs.mkdirSync(stubDir);
  const osascriptCalledMarker = path.join(dir, "osascript-called");
  if (stubOsascript) {
    const stubPath = path.join(stubDir, "osascript");
    fs.writeFileSync(stubPath, `#!/bin/sh\ntouch "${osascriptCalledMarker}"\nexit ${stubOsascript.exitCode}\n`, "utf8");
    fs.chmodSync(stubPath, 0o755);
  }

  const result = spawnSync("bash", [scriptPath, ...args], {
    encoding: "utf8",
    env: {
      ...process.env,
      PATH: [stubDir, "/usr/bin", "/bin"].join(":"),
      ORPHAN_PS_INPUT: psInput,
      ORPHAN_UNAME: uname,
    },
  });
  return { ...result, osascriptCalled: fs.existsSync(osascriptCalledMarker) };
};

const orphanVite: PsRow = {
  pid: 11240,
  ppid: 1,
  etime: "10-09:08:47",
  command: "/Users/me/.mise/installs/pnpm/12.16.1/pnpm exec vite --host 127.0.0.1 --port 4175 --strictPort",
};

afterEach(() => {
  for (const dir of tempDirs.splice(0)) {
    fs.rmSync(dir, { recursive: true, force: true });
  }
});

(isWindows ? describe.skip : describe)("scripts/orphan-dev-servers.sh", () => {
  it("reports ppid 1 dev servers as PID, elapsed time and command separated by tabs, and exits 1", () => {
    const result = runAudit({
      rows: [
        orphanVite,
        { pid: 84492, ppid: 1, etime: "08-21:10:26", command: "mise run app:dev:browser" },
        { pid: 900, ppid: 1, command: "/path/to/workerd serve config.capnp" },
      ],
    });

    expect(result.status).toBe(1);
    expect(result.stdout.trimEnd().split("\n")).toEqual([
      `11240\t10-09:08:47\t${orphanVite.command}`,
      "84492\t08-21:10:26\tmise run app:dev:browser",
      "900\t01:02:03\t/path/to/workerd serve config.capnp",
    ]);
  });

  it("exits 0 and says no orphans when nothing matches", () => {
    const result = runAudit({ rows: [{ pid: 100, ppid: 1, command: "/sbin/launchd" }] });

    expect(result.status).toBe(0);
    expect(result.stdout.trim()).toBe("取り残された dev サーバーはありません");
  });

  it("ignores matching commands whose parent is not launchd", () => {
    const result = runAudit({ rows: [{ ...orphanVite, ppid: 4321 }] });

    expect(result.status).toBe(0);
    expect(result.stdout).not.toContain("11240");
  });

  it("ignores processes owned by another user", () => {
    const result = runAudit({ rows: [{ ...orphanVite, uid: myUid + 1 }] });

    expect(result.status).toBe(0);
    expect(result.stdout).not.toContain("11240");
  });

  it("ignores legitimate ppid 1 residents", () => {
    const result = runAudit({
      rows: [
        { pid: 200, ppid: 1, command: "/bin/sh -lc exec /Users/me/.local/bin/some-launchd-agent" },
        {
          pid: 201,
          ppid: 1,
          command:
            "/Users/me/.mise/installs/node/26.13.0/bin/node /Users/me/.local/npm-global/lib/node_modules/@jackwener/opencli/dist/src/daemon.js",
        },
        {
          pid: 202,
          ppid: 1,
          command: "/Users/me/.mise/installs/python/3.15/bin/python3 -m http.server 6101 --bind 127.0.0.1",
        },
        { pid: 203, ppid: 1, command: "node server.js" },
        { pid: 204, ppid: 1, command: "bun run dev.ts" },
        { pid: 205, ppid: 1, command: "/usr/bin/python3 worker.py" },
        { pid: 206, ppid: 1, command: "/Applications/Invite.app/Contents/MacOS/Invite" },
      ],
    });

    expect(result.status).toBe(0);
    expect(result.stdout.trim()).toBe("取り残された dev サーバーはありません");
  });

  it("does not count children of an orphaned pnpm exec vite", () => {
    const result = runAudit({
      rows: [
        orphanVite,
        {
          pid: 11300,
          ppid: 11240,
          command: "/Users/me/.mise/installs/node/26.13.0/bin/node /repo/node_modules/vite/bin/vite.js --port 4175",
        },
        { pid: 11301, ppid: 11300, command: "workerd serve --binary" },
      ],
    });

    expect(result.status).toBe(1);
    expect(result.stdout.trimEnd().split("\n")).toEqual([`11240\t10-09:08:47\t${orphanVite.command}`]);
  });

  it("skips with exit 0 on non-darwin platforms even when orphans exist", () => {
    const result = runAudit({ rows: [orphanVite], uname: "Linux" });

    expect(result.status).toBe(0);
    expect(result.stdout).toContain("skip");
    expect(result.stdout).not.toContain("11240");
  });

  it("does not send a notification without --notify", () => {
    const result = runAudit({ rows: [orphanVite], stubOsascript: { exitCode: 0 } });

    expect(result.status).toBe(1);
    expect(result.osascriptCalled).toBe(false);
  });

  it("sends a notification with --notify and keeps the detection exit code", () => {
    const result = runAudit({ rows: [orphanVite], args: ["--notify"], stubOsascript: { exitCode: 0 } });

    expect(result.status).toBe(1);
    expect(result.osascriptCalled).toBe(true);
  });

  it("keeps the detection exit code when the notification command fails", () => {
    const result = runAudit({ rows: [orphanVite], args: ["--notify"], stubOsascript: { exitCode: 1 } });

    expect(result.status).toBe(1);
    expect(result.stdout).toContain("11240");
  });

  it("does not notify when nothing is detected", () => {
    const result = runAudit({
      rows: [{ pid: 100, ppid: 1, command: "/sbin/launchd" }],
      args: ["--notify"],
      stubOsascript: { exitCode: 0 },
    });

    expect(result.status).toBe(0);
    expect(result.osascriptCalled).toBe(false);
  });

  it("rejects unknown options with exit 2 instead of reporting a detection result", () => {
    const result = runAudit({ rows: [orphanVite], args: ["--kill"] });

    expect(result.status).toBe(2);
  });
});
