source "/Users/t00114/.local/share/sheldon/repos/github.com/romkatv/zsh-defer/zsh-defer.plugin.zsh"
autoload -Uz compinit && zsh-defer compinit
zsh-defer source "/Users/t00114/.local/share/sheldon/repos/github.com/olets/zsh-abbr/zsh-abbr.plugin.zsh"
zsh-defer source "/Users/t00114/.local/share/sheldon/repos/github.com/ohmyzsh/ohmyzsh/lib/clipboard.zsh"
zsh-defer source "/Users/t00114/.local/share/sheldon/repos/github.com/ohmyzsh/ohmyzsh/lib/functions.zsh"
zsh-defer source "/Users/t00114/.local/share/sheldon/repos/github.com/ohmyzsh/ohmyzsh/plugins/git/git.plugin.zsh"
zsh-defer source "/Users/t00114/.local/share/sheldon/downloads/raw.githubusercontent.com/ogham/exa/master/completions/zsh/_exa"
zsh-defer -s -z ln -sf "/Users/t00114/.local/share/sheldon/downloads/raw.githubusercontent.com/ogham/exa/master/completions/zsh/_exa" "${HOME}/.zfunc/_exa"
zsh-defer source "/Users/t00114/.local/share/sheldon/repos/github.com/zsh-users/zsh-completions/zsh-completions.plugin.zsh"
fpath=( "/Users/t00114/.local/share/sheldon/repos/github.com/zsh-users/zsh-completions/src" $fpath )
zsh-defer source "/Users/t00114/.local/share/sheldon/repos/github.com/nix-community/nix-zsh-completions/nix-zsh-completions.plugin.zsh"
fpath=( "/Users/t00114/.local/share/sheldon/repos/github.com/nix-community/nix-zsh-completions" $fpath )
zsh-defer source "/Users/t00114/.local/share/sheldon/repos/github.com/zsh-users/zsh-autosuggestions/zsh-autosuggestions.zsh"
zsh-defer source "/Users/t00114/.local/share/sheldon/repos/github.com/zdharma-continuum/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
zsh-defer source "/Users/t00114/.local/share/sheldon/repos/github.com/ajeetdsouza/zoxide/zoxide.plugin.zsh"
zsh-defer source $ZDOTDIR/hook/zoxide_post.zsh
zsh-defer source "/Users/t00114/.local/share/sheldon/repos/github.com/azu/ni.zsh/ni.plugin.zsh"
eval "$(starship init zsh)"
/Users/t00114/.local/share/sheldon/repos/github.com/junegunn/fzf/install --bin > /dev/null 
[[ ! $PATH =~ /Users/t00114/.local/share/sheldon/repos/github.com/junegunn/fzf ]] && export PATH="$PATH:/Users/t00114/.local/share/sheldon/repos/github.com/junegunn/fzf/bin"
source "/Users/t00114/.local/share/sheldon/repos/github.com/junegunn/fzf/shell/completion.zsh"
source "/Users/t00114/.local/share/sheldon/repos/github.com/junegunn/fzf/shell/key-bindings.zsh"
zsh-defer source "/Users/t00114/.local/share/sheldon/repos/github.com/mollifier/anyframe/anyframe.plugin.zsh"
zsh-defer source $ZDOTDIR/hook/anyframe_post.zsh
