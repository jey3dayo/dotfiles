#!/usr/bin/env zx
import os from "os";

const homeDir = os.homedir();
const platform = os.platform();

if (platform === "linux") {
  $`sudo whoami`;
}

// python
async function updatePythonPkgs() {
  let pkgs = ["pip", "ruff"];
  await $`pip3 install -U ${pkgs}`;

  await $`pip3 list --format json --outdated | jq .[].name | xargs -r pip3 install -U`;
  // await $`pipx reinstall-all`
  await $`pipx upgrade-all`;
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
  await $`bun i --global ${pkgs}`;
  await $`bun -g update`;
}

async function updateApt() {
  if (platform !== "linux") return;

  try {
    await $`sudo apt update`;
    await $`sudo apt upgrade -y`;
  } catch (e) {}
}

async function updateBrew() {
  if (platform !== "darwin") return;

  try {
    await $`brew update`;
    await $`brew upgrade`;
    await $`brew cleanup`;
  } catch (e) {}
}

async function updateNvim() {
  await $`nvim --headless "+Lazy! sync" +qa`;
  await $`nvim --headless "+MasonUpdate" +qa`;
  await $`nvim --headless "+TSUpdateSync" +qa`;
}

async function updateRepos() {
  await $`(cd ${homeDir}/src/github.com/dimdenGD/OldTweetDeck && git pull origin main)`;
  await $`(cd ${homeDir}/src/github.com/junegunn/fzf && git pull origin main)`;
}

async function updateMise() {
  await $`mise install node@16`;
  await $`mise install node@18`;
  await $`mise install node@20`;
}

await Promise.all([
  $`mise upgrade`,
  $`sheldon lock --update`,
  updateNodePkgs(),
  updatePythonPkgs(),
  updateBrew(),
  updateApt(),
  updateNvim(),
  updateRepos(),
  updateMise(),
]);
