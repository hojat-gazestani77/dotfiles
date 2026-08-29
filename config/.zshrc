GH_TOKEN=$VAR_GH_TOKEN

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""
#ZSH_THEME="robbyrussell"
#ZSH_THEME="powerlevel10k/powerlevel10k"

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

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
#plugins=(git)
plugins=(macos vi-mode ansible git you-should-use docker kubectl zsh-autosuggestions zsh-completions zsh-syntax-highlighting sublime)


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
alias py="python3"
alias k="kubectl"
alias kkk="k9s"
alias t='tldr'
alias nv="nvim"
alias bat="batcat"
# Detect OS and set 'ls' alias appropriately
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux (GNU ls)
    alias ls='ls -l --color=auto -h --group-directories-first'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS (requires 'coreutils' for GNU ls)
    if command -v gls &> /dev/null; then
        alias ls='gls -l --color=auto -h --group-directories-first'
    else
        echo "⚠️ Install 'coreutils' for better 'ls' on macOS: brew install coreutils"
        alias ls='ls -G -h'  # Fallback to BSD ls (no --group-directories-first)
    fi
fi

g-ckeckout-commit() { git log --oneline --decorate | fzf --preview 'git diff main..$(echo {} | awk "{print \$1}") | delta --features line-numbers decorations' | awk "{print \$1}" | xargs git checkout; }
gcmp() { gc -am "$1" && gp; }

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
___MY_VMOPTIONS_SHELL_FILE="${HOME}/.jetbrains.vmoptions.sh"; if [ -f "${___MY_VMOPTIONS_SHELL_FILE}" ]; then . "${___MY_VMOPTIONS_SHELL_FILE}"; fi

export PATH="/usr/local/go/bin:$PATH"
PATH=~/.console-ninja/.bin:$PATH
# Created by `pipx` on 2024-07-06 08:56:01
export PATH="$PATH:/Users/hojat/.local/bin"
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

eval "$(starship init zsh)"

export LESS="--chop-long-lines --HILITE-UNREAD --ignore-case --incsearch --jump-target=4 --LONG-PROMPT --no-init --quit-if-one-screen --RAW-CONTROL-CHARS --use-color --window=-4"
export RIPGREP_CONFIG_PATH=~/.config/ripgreprc

function rg() {
	command rg --json $@ | delta;
}

function start_ssh_agent() {
    echo "Please your ssh key pass phrase for this session: "
    # Check if SSH agent is already running
    if ! pgrep -u "$USER" ssh-agent > /dev/null; then
        # Start the SSH agent if it's not running
        eval "$(ssh-agent -s)"
    fi
    # Add the SSH key to the agent
    ssh-add ~/.ssh/id_ed25519
}

start_ssh_agent
echo "Exporting Orca kubernetes config file"
export KUBECONFIG=~/.kube/config

zstyle ':completion:*:ssh:*' hosts $(awk '/^Host / {print $2}' ~/.ssh/config)
export DJANGO_SECRET_KEY='r6@8mwjhf@@=+2^!_^lz!9z$x2aj-*5^cy9aw05pff!t^3ga(#'

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/hojat/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/hojat/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/hojat/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/hojat/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export PATH="/usr/local/kerio/vpnclient:/opt/nvim/bin:$PATH"

#kubecolor() {
#    command kubecolor "$@"
#}
#compdef kubecolor=kubectl
eval "$(uv generate-shell-completion zsh)"
set -a; [ -f ~/.env ] && source ~/.env; set +a
export PATH="$HOME/.local/bin:$PATH"

# opencode
export PATH=/home/hojat/.opencode/bin:$PATH
