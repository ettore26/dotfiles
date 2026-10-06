# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"


# Set the number of commands to remember in memory (in-session)
HISTSIZE=100000

# Set the number of commands to save to the history file
SAVEHIST=100000

# Optional: ensure history file location is set correctly
HISTFILE=~/.zsh_history

# Optional: add other useful history options
setopt INC_APPEND_HISTORY # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY      # Share history between all sessions.
setopt EXTENDED_HISTORY   # Write the history file in the ":start:elapsed;command" format.

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"
HIST_STAMPS="%Y-%m-%dT%H:%M:%SZ"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  brew
  git
  docker
  vi-mode
  colored-man-pages
  mvn
  mix
  kubectl
  colorize
  rust
  rbenv
  direnv
  uv
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

################################################################################################################################################
# Aliases
################################################################################################################################################

alias vim=nvim
alias nvim-testing='nvim --clean -u ~/.config/nvim/testing_init.lua'
alias john=$HOME/.local/lib/john_the_ripper/john
alias grep="grep --color=always"
alias p81="p81-helper-daemon ctl"
alias claude-wm="CLAUDE_CONFIG_DIR=~/.claude-wm claude"
alias claude-br="CLAUDE_CONFIG_DIR=~/.claude-br claude"

################################################################################################################################################
# Export variables
################################################################################################################################################

# local binary path
export PATH="$HOME/.local/bin/:$PATH"
# xdg: freedesktop
export XDG_CONFIG_HOME="$HOME/.config"
# LaTeX PATH config
# https://tug.org/texlive/quickinstall.html
export PATH="/usr/local/texlive/2024/bin/x86_64-linux:$PATH"
# GoLang config
export GOPATH=$HOME/go
export PATH="$GOPATH/bin:$PATH"
# kubernetes helm config
export KUBECONFIG=~/.kube/config
# Bob: NVim version manager
export PATH="$HOME/.local/share/bob/nvim-bin/:$PATH"
# k9s: kubernetes cli
export K9S_CONFIG_DIR="$XDG_CONFIG_HOME/k9s"
export K9S_LOGS_DIR="$K9S_CONFIG_DIR/logs"
# Per-OS tool dirs: appended only when the directory exists, so the same list
# works on macOS and Linux
if [[ $OSTYPE == darwin* ]]; then
  _app_data="$HOME/Library/Application Support"
  _git_contrib="${HOMEBREW_PREFIX:-/opt/homebrew}/share/git-core/contrib/diff-highlight"
  _coursier="$_app_data/Coursier/bin"
else
  _app_data="${XDG_DATA_HOME:-$HOME/.local/share}"
  _git_contrib="/usr/share/git-core/contrib"
  _coursier="$_app_data/coursier/bin"
fi
_tool_dirs=(
  "$_git_contrib"                         # git: diff-highlight, the pager in .gitconfig
  "$_coursier"                            # coursier: Scala/JVM app installer
  "$_app_data/JetBrains/Toolbox/scripts"  # JetBrains Toolbox: IDE launcher scripts
  "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason/bin"  # Mason: nvim-managed LSPs, e.g. jdtls for Claude Code
)
for _dir in $_tool_dirs; do
  [[ -d $_dir ]] && path+=("$_dir")
done
unset _app_data _git_contrib _coursier _tool_dirs _dir

################################################################################################################################################
# Configuration
################################################################################################################################################

# neovim/nvim/vim Editor
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Tmuxinator Config
tmux() {
  if [ $# -eq 0 ]; then
    tmuxinator start _hm
  else
    command tmux "$@"
  fi
}

# git: gwtc [query] cds into a worktree picked with fzf
source ~/.config/scripts/git-worktree-cd.sh

# Claude Code: resume a session under the profile that owns it
source ~/.config/scripts/claude-resume.zsh

# FZF config
source <(fzf --zsh)
export FZF_DEFAULT_OPTS_FILE=~/.config/fzf/.fzfrc
source ~/.config/scripts/fzf-git-branches.zsh

# nvm: node version manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# bun: js runtime
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# pnpm: package manager
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# SDKMan config
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

################################################################################################################################################
# Completion
################################################################################################################################################

# bws completions
[ -s "$HOME/.config/bws/completion" ] && source "$HOME/.config/bws/completion"

