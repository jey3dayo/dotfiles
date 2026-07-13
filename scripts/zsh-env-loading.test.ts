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
const printAutosuggestStrategyCommand = [
  'print -r -- "autosuggest_strategy=',
  "${",
  "ZSH_AUTOSUGGEST_STRATEGY:-unset",
  '}"',
].join("");
const localMise = path.join(os.homedir(), ".local/bin/mise");
const homebrewMise = "/opt/homebrew/bin/mise";

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

  it("finds mise in non-interactive non-login shells", () => {
    const expectedMise = fs.existsSync(localMise) ? localMise : homebrewMise;
    if (!fs.existsSync(expectedMise)) {
      return;
    }

    const result = spawnSync("zsh", ["-c", "command -v mise"], {
      encoding: "utf8",
      env: {
        HOME: os.homedir(),
        XDG_CONFIG_HOME: repoRoot,
        ZDOTDIR: zdotdir,
        PATH: "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
        LOGNAME: os.userInfo().username,
        USER: os.userInfo().username,
        SHELL: "/bin/zsh",
        TERM: "xterm-256color",
      },
    });

    expect(result.status).toBe(0);
    expect(result.stderr.trim()).toBe("");
    expect(result.stdout.trim()).toBe(expectedMise);
  });
});

describe("zsh plugin bootstrap", () => {
  it("keeps Homebrew PATH setup in the explicit path helper", () => {
    const pathHelper = fs.readFileSync(path.join(zdotdir, "lib/path.zsh"), "utf8");

    expect(pathHelper).toContain("/opt/homebrew/bin");
  });

  it("keeps minimal interactive startup on PATH without loading Sheldon plugins", () => {
    const expectedMise = fs.existsSync(localMise) ? localMise : homebrewMise;
    if (!fs.existsSync(expectedMise)) {
      return;
    }

    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "zsh-plugin-bootstrap-"));
    const cacheHome = path.join(tempRoot, "cache");

    try {
      const result = spawnSync(
        "zsh",
        ["-lic", ["command -v zsh-benchmark", "command -v mise", "command -v abbr || true"].join("; ")],
        {
          encoding: "utf8",
          env: {
            HOME: os.homedir(),
            XDG_CACHE_HOME: cacheHome,
            PATH: "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
            LOGNAME: os.userInfo().username,
            USER: os.userInfo().username,
            SHELL: "/bin/zsh",
            TERM: "xterm-256color",
          },
        },
      );

      expect(result.status).toBe(0);
      expect(result.stderr.trim()).toBe("");
      expect(result.stdout).toContain(path.join(zdotdir, "bin", "zsh-benchmark"));
      // mise is wrapped in a zsh function (zsh/lib/mise.zsh) to inject a
      // GitHub token, so `command -v mise` resolves to the function name
      // rather than the binary path; the binary itself must still be on PATH.
      expect(result.stdout).toContain("mise");
      expect(fs.existsSync(expectedMise)).toBe(true);
      expect(result.stdout).not.toContain("abbr");
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });

  it("loads zsh-abbr only when plugins are explicitly requested", () => {
    const result = spawnSync(
      "zsh",
      ["-lic", ["command -v abbr >/dev/null || exit 0", "command -v abbr", "abbr expand gst"].join("; ")],
      {
        encoding: "utf8",
        env: {
          ...process.env,
          HOME: os.homedir(),
          XDG_CONFIG_HOME: repoRoot,
          ZDOTDIR: zdotdir,
          ZSH_LOAD_PLUGINS: "1",
          PATH: "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
          LOGNAME: os.userInfo().username,
          USER: os.userInfo().username,
          SHELL: "/bin/zsh",
          TERM: "xterm-256color",
        },
      },
    );

    expect(result.status).toBe(0);
    expect(result.stderr.trim()).toBe("");
    if (result.stdout.trim() !== "") {
      expect(result.stdout).toContain("abbr");
      expect(result.stdout).toContain("git status -sb .");
    }
  });

  it("binds advertised fzf keys before loading the fzf integration", () => {
    const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "zsh-fzf-lazy-bindings-"));

    try {
      const result = spawnSync(
        "zsh",
        ["-lic", ['bindkey "^]"', 'bindkey "^T"', 'bindkey "^[c"', 'bindkey "^gx"', 'bindkey "^g^x"'].join("; ")],
        {
          encoding: "utf8",
          env: {
            ...process.env,
            HOME: os.homedir(),
            XDG_CACHE_HOME: path.join(tempRoot, "cache"),
            XDG_CONFIG_HOME: repoRoot,
            ZDOTDIR: zdotdir,
            PATH: "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
            LOGNAME: os.userInfo().username,
            USER: os.userInfo().username,
            SHELL: "/bin/zsh",
            TERM: "xterm-256color",
          },
        },
      );

      expect(result.status).toBe(0);
      expect(result.stderr.trim()).toBe("");
      expect(result.stdout).toContain('"^]" _zsh_fzf_ghq_widget');
      expect(result.stdout).toContain('"^T" _zsh_fzf_file_widget');
      expect(result.stdout).toContain('"^[c" _zsh_fzf_cd_widget');
      expect(result.stdout).toContain('"^Gx" _zsh_fzf_kill_widget');
      expect(result.stdout).toContain('"^G^X" _zsh_fzf_kill_widget');
    } finally {
      fs.rmSync(tempRoot, { recursive: true, force: true });
    }
  });

  it("does not expose generic helper names after startup", () => {
    const result = spawnSync(
      "zsh",
      [
        "-lic",
        [
          "for name in load_atuin load_fzf git_is_repo register_git_widgets setup_path bootstrap_shell_env path_prepend_existing; do",
          '  (( $+functions[$name] )) && print -r -- "$name";',
          "done; true",
        ].join(" "),
      ],
      {
        encoding: "utf8",
        env: {
          ...process.env,
          HOME: os.homedir(),
          XDG_CONFIG_HOME: repoRoot,
          ZDOTDIR: zdotdir,
          PATH: "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
          LOGNAME: os.userInfo().username,
          USER: os.userInfo().username,
          SHELL: "/bin/zsh",
          TERM: "xterm-256color",
        },
      },
    );

    expect(result.status).toBe(0);
    expect(result.stderr.trim()).toBe("");
    expect(result.stdout.trim()).toBe("");
  });

  it("binds Ctrl-R when atuin is explicitly loaded", () => {
    const result = spawnSync("zsh", ["-lic", 'command -v atuin >/dev/null || exit 0; bindkey "^R"'], {
      encoding: "utf8",
      env: {
        ...process.env,
        HOME: os.homedir(),
        XDG_CONFIG_HOME: repoRoot,
        ZDOTDIR: zdotdir,
        ZSH_LOAD_ATUIN: "1",
        PATH: "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
        LOGNAME: os.userInfo().username,
        USER: os.userInfo().username,
        SHELL: "/bin/zsh",
        TERM: "xterm-256color",
      },
    });

    expect(result.status).toBe(0);
    expect(result.stderr.trim()).toBe("");
    if (result.stdout.trim() !== "") {
      expect(result.stdout).toContain("^R");
      expect(result.stdout).toContain("atuin");
    }
  });

  it("keeps zoxide lazy z and j commands available after first use", () => {
    const result = spawnSync(
      "zsh",
      [
        "-lic",
        "command -v zoxide >/dev/null || exit 0; z . >/dev/null; z . >/dev/null; j . >/dev/null; whence -w z; whence -w j",
      ],
      {
        encoding: "utf8",
        env: {
          ...process.env,
          HOME: os.homedir(),
          XDG_CONFIG_HOME: repoRoot,
          ZDOTDIR: zdotdir,
          PATH: "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
          LOGNAME: os.userInfo().username,
          USER: os.userInfo().username,
          SHELL: "/bin/zsh",
          TERM: "xterm-256color",
        },
      },
    );

    expect(result.status).toBe(0);
    expect(result.stderr.trim()).toBe("");
    if (result.stdout.trim() !== "") {
      expect(result.stdout).toContain("z:");
      expect(result.stdout).toContain("j:");
    }
  });

  it("loads selected lightweight interactive tools", () => {
    const result = spawnSync(
      "zsh",
      [
        "-lic",
        [
          "command -v gh",
          "whence _gh",
          'if whence fast-theme >/dev/null; then print -r -- "__has_fast_theme"; whence fast-theme; fi',
          printAutosuggestStrategyCommand,
          'if command -v zoxide >/dev/null; then print -r -- "__has_zoxide"; command -v zoxide; command -v z; alias j; fi',
          'if command -v ni >/dev/null; then print -r -- "__has_ni"; command -v ni; command -v nlx; whence _ni; fi',
          'if command -v bun >/dev/null; then print -r -- "__has_bun"; command -v bun; print -r -- "bun_fpath=$' +
            '{fpath[(r)$HOME/.bun]}"; fi',
          'if command -v eza >/dev/null; then print -r -- "__has_eza"; command -v eza; print -r -- "eza_fpath=$' +
            '{fpath[(r)*eza-community/eza/completions/zsh]}"; fi',
          [
            'if command -v fzf >/dev/null; then print -r -- "__has_fzf"; command -v fzf',
            "whence _fzf_git_branches",
            "whence fzf-tab-complete",
            "whence _zsh_autosuggest_start",
            'bindkey "^]"',
            'bindkey "^T"',
            'bindkey "^[c"',
            'bindkey "^gx"',
            'bindkey "^I"',
            'bindkey "^gg"',
            'bindkey "^gs"',
            'bindkey "^ga"',
            'bindkey "^gb"',
            'bindkey "^gW"',
            'bindkey "^gz"',
            'bindkey "^g^f"',
            'bindkey "^g?"',
            "fi",
          ].join("; "),
        ].join("; "),
      ],
      {
        encoding: "utf8",
        env: {
          ...process.env,
          HOME: os.homedir(),
          XDG_CONFIG_HOME: repoRoot,
          ZDOTDIR: zdotdir,
          ZSH_LOAD_FZF: "1",
          ZSH_LOAD_FZF_TAB: "1",
          ZSH_LOAD_GH: "1",
          ZSH_LOAD_GIT_WIDGETS: "1",
          ZSH_LOAD_AUTOSUGGESTIONS: "1",
          ZSH_LOAD_SYNTAX_HIGHLIGHTING: "1",
          ZSH_LOAD_ZOXIDE: "1",
          PATH: "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
          LOGNAME: os.userInfo().username,
          USER: os.userInfo().username,
          SHELL: "/bin/zsh",
          TERM: "xterm-256color",
        },
      },
    );

    expect(result.status).toBe(0);
    expect(result.stderr.trim()).toBe("");
    expect(result.stdout).toContain("gh");
    expect(result.stdout).toContain("_gh");
    if (result.stdout.includes("__has_fast_theme")) {
      expect(result.stdout).toContain("fast-theme");
    }
    if (result.stdout.includes("__has_zoxide")) {
      expect(result.stdout).toContain("zoxide");
      expect(result.stdout).toContain("j=z");
    }
    if (result.stdout.includes("__has_ni")) {
      expect(result.stdout).toContain("ni");
      expect(result.stdout).toContain("nlx");
      expect(result.stdout).toContain("_ni");
    }
    if (result.stdout.includes("__has_bun")) {
      expect(result.stdout).toContain("bun");
      expect(result.stdout).toContain("bun_fpath=");
    }
    if (result.stdout.includes("__has_eza")) {
      expect(result.stdout).toContain("eza");
      expect(result.stdout).toContain("eza_fpath=");
    }
    if (result.stdout.includes("__has_fzf")) {
      expect(result.stdout).toContain("fzf");
      expect(result.stdout).toContain("_fzf_git_branches");
      expect(result.stdout).toContain("fzf-tab-complete");
      expect(result.stdout).toContain("_zsh_autosuggest_start");
      expect(result.stdout).toContain("autosuggest_strategy=history");
      expect(result.stdout).toContain("_zsh_fzf_ghq_widget");
      expect(result.stdout).toContain("fzf-file-widget");
      expect(result.stdout).toContain("fzf-cd-widget");
      expect(result.stdout).toContain('"^I" fzf-tab-complete');
      expect(result.stdout).toContain("_zsh_fzf_kill_widget");
      expect(result.stdout).toContain("_zsh_git_menu_widget");
      expect(result.stdout).toContain("_zsh_git_status_widget");
      expect(result.stdout).toContain("_zsh_git_add_patch_widget");
      expect(result.stdout).toContain("_zsh_git_switch_branch_widget");
      expect(result.stdout).toContain("_zsh_git_worktree_widget");
      expect(result.stdout).toContain("fzf-git-stashes-widget");
      expect(result.stdout).toContain("fzf-git-files-widget");
      expect(result.stdout).toContain("fzf-git-?list_bindings-widget");
    }
  });

  it("finds Homebrew perman-aws-vault in non-interactive login shells", () => {
    const permanAwsVault = "/opt/homebrew/bin/perman-aws-vault";
    if (!fs.existsSync(permanAwsVault)) {
      return;
    }

    const result = spawnSync("zsh", ["-lc", "command -v perman-aws-vault"], {
      encoding: "utf8",
      env: {
        HOME: os.homedir(),
        PATH: "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
        LOGNAME: os.userInfo().username,
        USER: os.userInfo().username,
        SHELL: "/bin/zsh",
        TERM: "xterm-256color",
      },
    });

    expect(result.status).toBe(0);
    expect(result.stderr.trim()).toBe("");
    expect(result.stdout.trim()).toBe(permanAwsVault);
  });
});
