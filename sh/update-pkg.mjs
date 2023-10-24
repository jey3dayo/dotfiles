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
  await $`npm -g update`;

  let nodePkgs = ["npm-check-updates", "neovim"];
  await $`npm -g i ${nodePkgs}`;
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

await Promise.all([
  $`asdf plugin update --all`,
  $`sheldon lock --update`,
  updateNodePkgs(),
  updatePythonPkgs(),
  updateBrew(),
  updateNvim(),
  updateRepos(),
]);
