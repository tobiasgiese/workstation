# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/tobias/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
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

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

HISTSIZE=999999999
SAVEHIST=$HISTSIZE

# zstyle :omz:plugins:ssh-agent identities id_rsa id_rsa_dhcsvc
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

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

# eval $(keychain --systemd id_rsa id_rsa_dhcsvc)
# export TERM=linux
# export PYENV_ROOT="$HOME/.pyenv"
# export PATH="$PATH:$PYENV_ROOT/bin:$HOME/bin:$HOME/go/bin:/snap/bin/:/usr/local/kubebuilder/bin:$HOME/.local/bin"
export PATH="$PATH:$HOME/bin:/usr/local/go/bin:/snap/bin/:/usr/local/kubebuilder/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/.npm-global/bin"
export EDITOR=vim
export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
export LESS=' -R '

alias ip="ip -c"

# if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)"; fi
# eval "$(pyenv virtualenv-init -)"

autoload bashcompinit
bashcompinit
source <(kubectl completion zsh)

x-bash-backward-kill-word(){
WORDCHARS='*?_-[]~\!#$%^(){}<>|`@#$%^*()+:?' zle backward-kill-word
}
zle -N x-bash-backward-kill-word
bindkey '^W' x-bash-backward-kill-word

autoload -U +X bashcompinit && bashcompinit

# fzf setup
export FZF_DEFAULT_COMMAND='rg --files --hidden'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# From: /usr/share/doc/fzf/README.Debian
source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh
# load fzf
source /home/tobias/projects/github.com/fzf-tab/fzf-tab.plugin.zsh
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'
#To save every command before it is executed (this is different from bash's history -a solution):
setopt inc_append_history
#To retrieve the history file everytime history is called upon.
setopt share_history

# k8s aliases
alias kk="kubectl -n kube-system"
alias k=kubectl

alias i3edit="vim ~/.config/i3/config"

export LC_ALL=en_US.UTF-8
# Enable DOCKER_REPO_CACHE for bazel container_pull rules
export DOCKER_REPO_CACHE=$HOME/.cache/bazel/docker-repo-cache
mkdir -p $DOCKER_REPO_CACHE

alias fixlr='stty onlcr; stty sane'

fpath[1,0]=~/.zsh/completion/

# bazel run fzf completion
function bazel_completion() {
    label=$(bazel query "..." | fzf)
    currentShell="$(ps -hp $$ | awk '{print $5}')"
    if [[ "$currentShell" =~ bash ]]; then
        bind '"\e[0n": "bazel $1 $label"'
        printf '\e[5n'
    elif [[ "$currentShell" =~ zsh ]]; then
        print -z bazel $1 "$label"
    fi
}
# only for zsh:
alias br='bazel_completion run' 
alias bb='bazel_completion build'
