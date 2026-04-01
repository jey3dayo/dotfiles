# Centralized dotfiles sync targets.
# Paths on left are destination paths relative to $HOME.
{
  entryPointFiles = {
    ".gitconfig" = "home/.gitconfig";
    ".npmrc" = "home/.npmrc";
    ".tmux.conf" = "home/.tmux.conf";
    ".zshenv" = "home/.zshenv";
    ".zshrc" = "home/.zshrc";
  };

  # Some CLIs resolve their config by checking the on-disk file itself and fail
  # when Home Manager deploys a symlink into $HOME.
  materializedEntryPointFiles = {
    ".aicommits" = ".aicommits";
    ".opencommit" = "opencommit/.opencommit";
  };

  bashFiles = {
    ".bashrc" = "bash/.bashrc";
    ".bash_profile" = "bash/.bash_profile";
  };

  sshFiles = {
    ".ssh/config" = "ssh/config";
  };

  awsumeFiles = {
    ".awsume/config.yaml" = "awsume/config.yaml";
  };
}
