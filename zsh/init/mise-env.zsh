# Mise environment detection
# Automatically selects the appropriate mise config based on the environment
# This must run early to set MISE_CONFIG_FILE before mise is activated

# Source environment detection script if it exists
if [[ -f "${HOME}/src/github.com/jey3dayo/dotfiles/scripts/setup-mise-env.sh" ]]; then
    source "${HOME}/src/github.com/jey3dayo/dotfiles/scripts/setup-mise-env.sh"
fi
