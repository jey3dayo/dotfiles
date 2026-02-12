# Centralized dotfiles sync targets (home.file mappings)
# Paths on left are destination paths relative to $HOME.
{
  entryPointFiles = {
    ".aicommits" = ".aicommits";
    ".gitconfig" = "home/.gitconfig";
    ".tmux.conf" = "home/.tmux.conf";
    ".zshenv" = "home/.zshenv";
    ".zshrc" = "home/.zshrc";
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
