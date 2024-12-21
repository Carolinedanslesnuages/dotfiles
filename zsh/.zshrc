# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =============================================================================
# Zsh Configuration File (.zshrc)
# =============================================================================
# This file configures your Zsh environment using Oh My Zsh,
# with additional plugins and aliases to enhance productivity.
# =============================================================================

# ------------------------------
# 1. Basic Configuration
# ------------------------------

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set Powerlevel10k as the Zsh theme.
ZSH_THEME="powerlevel10k/powerlevel10k"

# Define the list of plugins to load.
# Adding plugins enhances the functionality of your shell.
plugins=(
  git                      # Git integration
  zsh-autosuggestions      # Automatic suggestions based on history
  zsh-syntax-highlighting  # Syntax highlighting for commands
  common-aliases           # Common aliases for simplifying commands
  sudo                     # Allows prefixing commands with sudo using "sudo !!"
  colored-man-pages        # Colored man pages for better readability
  extract                  # Easily extract archives with a single command
)

# Load Oh My Zsh with the defined plugins.
source $ZSH/oh-my-zsh.sh

# ------------------------------
# 2. Environment Variables
# ------------------------------

# Add Volta to your PATH for managing Node.js versions.
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# SOPS (encryption tool) configuration
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/key.txt"

# Preferred editor
export EDITOR='vim'

# Set language and encoding
export LANG=en_US.UTF-8

# ------------------------------
# 3. Custom Aliases
# ------------------------------

# Aliases to simplify common commands.
alias ll='ls -la'
alias gs='git status'
alias gp='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gc='git commit'
alias ga='git add'
alias gl='git log --oneline --graph --decorate --all'
alias ..='cd ..'
alias ...='cd ../..'
alias mkdir='mkdir -p'  # Create parent directories as needed

# Alias to reload Zsh configuration
alias reload='source ~/.zshrc'

# ------------------------------
# 4. Custom Functions
# ------------------------------

# Function to quickly navigate to projects
function proj() {
  cd ~/Projects/"$1" || echo "Directory ~/Projects/$1 does not exist."
}

# ------------------------------
# 5. History Configuration
# ------------------------------

# History settings to avoid duplicates and increase size.
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# History options
setopt append_history          # Append to history file, don't overwrite it
setopt inc_append_history      # Add commands to history file as they are typed
setopt share_history           # Share history across all sessions
setopt hist_ignore_dups        # Ignore duplicate entries
setopt hist_ignore_all_dups    # Remove all previous duplicates
setopt hist_reduce_blanks      # Remove superfluous blanks from each command
setopt hist_verify             # Show command with history expansion before executing

# ------------------------------
# 6. Autocompletion and Correction
# ------------------------------

# Enable command auto-correction.
ENABLE_CORRECTION="true"

# Make completion case-insensitive.
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# ------------------------------
# 7. Additional Plugins Configuration
# ------------------------------

# Load zsh-autosuggestions if installed.
if [[ -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Load zsh-syntax-highlighting if installed.
if [[ -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ------------------------------
# 8. PATH Configuration
# ------------------------------

# Add personal bin directories to PATH.
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Add Homebrew or other package managers' bin directories.
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# ------------------------------
# 9. Version Managers Configuration (Optional)
# ------------------------------

# Load NVM (Node Version Manager) if installed.
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
fi

# Load RVM (Ruby Version Manager) if installed.
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
  source "$HOME/.rvm/scripts/rvm"
fi

# Load pyenv (Python Version Manager) if installed.
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# ------------------------------
# 10. Load Custom Configurations
# ------------------------------

# Load custom aliases and functions from the custom folder.
for file in $ZSH_CUSTOM/*.zsh; do
  if [[ -f $file ]]; then
    source "$file"
  fi
done

# ------------------------------
# 11. Additional Options
# ------------------------------

# Enable Vi key bindings.
bindkey -v

# Enable colored output for `ls`.
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# ------------------------------
# 12. Powerlevel10k Configuration
# ------------------------------

# Load Powerlevel10k configuration if it exists.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# =============================================================================
# End of Configuration
# =============================================================================