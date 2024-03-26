#!/usr/bin/env zx
import os from "os";

const homeDir = os.homedir();
const platform = os.platform();

if (platform === "linux") $`sudo whoami`;

// python
async function updatePythonPkgs() {
  let pkgs = ["pip", "ruff"];

  try {
    await $`pip3 install -U ${pkgs}`;
    await $`pip3 list --format json --outdated | jq .[].name | xargs -r pip3 install -U`;
    // await $`pipx reinstall-all`
    await $`pipx upgrade-all`;
  } catch (e) {
    console.log(e);
  }
}

// node
async function updateNodePkgs() {
  let pkgs = [
    "npm-check-updates",
    "neovim",
    "husky",
    "@bufbuild/protoc-gen-es",
    "@connectrpc/protoc-gen-connect-es",
    "aicommits",
    "textlint",
    "textlint-rule-preset-ja-technical-writing",
  ];

  try {
    await $`bun i --global ${pkgs}`;
    await $`bun -g update`;
  } catch (e) {
    console.log(e);
  }
}

async function updateApt() {
  if (platform !== "linux") return;

  try {
    await $`sudo apt update`;
    await $`sudo apt upgrade -y`;
  } catch (e) {
    console.log(e);
  }
}

async function updateBrew() {
  if (platform !== "darwin") return;

  try {
    await $`brew update`;
    await $`brew upgrade`;
    await $`brew cleanup`;
  } catch (e) {
    console.log(e);
  }
}

async function updateNvim() {
  try {
    await $`nvim --headless "+Lazy! sync" +qa`;
    await $`nvim --headless "+MasonUpdate" +qa`;
    await $`nvim --headless "+TSUpdateSync" +qa`;
    // await $`brew reinstall neovim`;
  } catch (e) {
    console.log(e);
  }
}

async function updateRepos() {
  try {
    await $`(cd ${homeDir}/src/github.com/dimdenGD/OldTweetDeck && git pull origin main)`;
    await $`(cd ${homeDir}/src/github.com/junegunn/fzf && git pull origin master)`;
    await $`(cd ${homeDir}/Library/Caches/Homebrew/neovim--git && git pull origin master)`;
  } catch (e) {
    console.log(e);
  }
}

async function updateMise() {
  try {
    await $`mise upgrade`;
    await $`mise install node@16`;
    await $`mise install node@18`;
    await $`mise install node@20`;
  } catch (e) {
    console.log(e);
  }
}

async function pruneDocker() {
  try {
    await $`echo "y" | docker image prune --filter "dangling=true" -a`;
  } catch (e) {
    console.log(e);
  }
}

await Promise.all([
  $`sheldon lock --update`,
  updateNodePkgs(),
  updatePythonPkgs(),
  updateBrew(),
  updateApt(),
  updateNvim(),
  updateRepos(),
  updateMise(),
  pruneDocker(),
]);
