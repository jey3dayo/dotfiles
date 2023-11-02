#!/usr/bin/env zx

let homeDir = os.homedir();

// python
async function updatePythonPkgs() {
  await $`pip3 install --upgrade pip`;
  await $`pip3 list --format json --outdated | jq .[].name | xargs pip3 install -U`;
  // await $`pipx reinstall-all`
  await $`pipx upgrade-all`;
}

// node
async function updateNodePkgs() {
  let nodePkgs = ["npm-check-updates", "neovim", "husky", "@bufbuild/protoc-gen-es", "@connectrpc/protoc-gen-connect-es", "aicommits"];
  await $`bun i --g ${nodePkgs}`;
  await $`bun -g update`;
}

async function updateBrew() {
  try {
    await $`brew update`;
    await $`brew upgrade`;
    await $`brew cleanup`;

  } catch (e) {
  }
}

async function updateNvim() {
  await $`nvim --headless "+Lazy! sync" +qa`;
  await $`nvim --headless "+MasonUpdate" +qa`;
  await $`nvim --headless "+TSUpdateSync" +qa`;
}

async function updateRepos() {
  await $`(cd ${homeDir}/src/github.com/dimdenGD/OldTweetDeck && git pull origin main)`;
}

async function updateRtx() {
  await $`rtx install node@16`;
  await $`rtx install node@18`;
  await $`rtx install node@20`;
}

await Promise.all([
  $`rtx upgrade`,
  $`sheldon lock --update`,
  updateNodePkgs(),
  updatePythonPkgs(),
  updateBrew(),
  updateNvim(),
  updateRepos(),
  updateRtx(),
]);
