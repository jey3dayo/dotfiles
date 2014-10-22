# rbenv path
export MANPATH=/opt/local/man:$MANPATH

path=(
    /usr/local/bin(N-/)
    /usr/local/sbin(N-/)
    $HOME/bin(N-/)
    $HOME/sbin(N-/)
    $HOME/local/bin(N-/)
    $HOME/.rbenv/versions/1.9.3-p429/bin(N-/)
    /usr/local/wine/bin(N-/)
    /usr/local/lib/ruby/gems/2.1.0/gems/tmuxinator-0.6.7/bin(N-/)
    $HOME/.go(N-/)
    $path
)

case ${OSTYPE} in
  darwin*)
  USERDIR="/Users/`whoami`"
  ;;
  linux*)
  USERDIR="/home/`whoami`"
  ;;
esac

# perl
export PERL_LOCAL_LIB_ROOT="$USERDIR/perl5:$PERL_LOCAL_LIB_ROOT";
export PERL_MB_OPT="--install_base "$USERDIR/perl5"";
export PERL_MM_OPT="INSTALL_BASE=$USERDIR/perl5";
export PERL5LIB="$USERDIR/perl5/lib/perl5:$PERL5LIB";
export PATH="$USERDIR/perl5/bin:$PATH";

if [ -d ${HOME}/.rbenv ] ; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init - zsh)"
fi

if [ -d ${HOME}/.plenv ] ; then
  export PATH="$HOME/.plenv/bin:$PATH"
  eval "$(plenv init - zsh)"
fi

if [ -d `brew --prefix nvm` ] ; then
  source $(brew --prefix nvm)/nvm.sh
fi
