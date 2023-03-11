if [[ ! -z $LM_MAC_ENABLE_P10K ]]; then
  # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
  # Initialization code that may require console input (password prompts, [y/n]
  # confirmations, etc.) must go above this block; everything else may go below.
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi

  source ${HOMEBREW_PREFIX}/opt/powerlevel10k/powerlevel10k.zsh-theme

  # To customize prompt, run -p10k configure- or edit ~/.p10k.zsh.
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi


# PATHS 
export NVM_DIR=~/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

export JAVA_HOME=$(/usr/libexec/java_home)
source $HOME/.zshenv
eval "$(rbenv init - zsh)"

# Setup ZScaler certs
export REQUESTS_CA_BUNDLE=/Users/Shared/.certificates/zscaler.pem
export CURL_CA_BUNDLE=/Users/Shared/.certificates/zscaler.pem
export NODE_EXTRA_CA_CERTS=/Users/Shared/.certificates/zscaler.pem
export SSL_CERT_FILE=/Users/Shared/.certificates/zscaler.pem
export AWS_CA_BUNDLE=/Users/Shared/.certificates/zscaler.crt

# Setup brew package cmd completion
if type brew &>/dev/null
then
  FPATH="${HOMEBREW_PREFIX}/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit
fi

# Path to your oh-my-zsh installation.
export ZSH="/Users/conorshirren/.oh-my-zsh"

# suggested ohmyzsh plugins - (will only work if you have installed ohmyzsh)
plugins=(
  emoji # might help brighten up your shell scripts https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/emoji
  git # check out the available aliases https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh#L52
  web-search # search from the command line, e.g. "google cryptic error message"
  nvm # https://github.com/lukechilds/zsh-nvm
  zsh-autosuggestions # autofills potential commands:
  zsh-syntax-highlighting # syntax highlighting
  dirhistory # shortcuts for directory navigation
)

# Load Aliases
. ~/.zsh_aliases

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="cloud"
# eastwood
# apple
# cloud
# frontcube
# fletcherm

source $ZSH/oh-my-zsh.sh


# Setup zsh options
setopt CORRECT
#setopt CORRECT_ALL
setopt AUTO_CD

source ~/.zsh/zsh-dircolors-solarized/zsh-dircolors-solarized.zsh
source ~/.alias
export PATH="${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin:$PATH"
export GROOVY_HOME=${HOMEBREW_PREFIX}/opt/groovy/libexec
export JAVA_HOME=$(/usr/libexec/java_home)
export NVM_DIR="$HOME/.nvm"
  [ -s "${HOMEBREW_PREFIX}/opt/nvm/nvm.sh" ] && \. "${HOMEBREW_PREFIX}/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "${HOMEBREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm" ] && \. "${HOMEBREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion


export PATH="${HOMEBREW_PREFIX}/opt/mongodb-community@4.4/bin:$PATH"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/conorshirren/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/conorshirren/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/conorshirren/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/conorshirren/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"


########################################################################

# Custom Functions

# Function to format commit msg with ticket number from branch name
# Branch Name must follow format: feature/QP-1010-description-of-change
gitc() {:
  branch=$(git symbolic-ref --short HEAD)
  if [ "$branch" = "master" ]; then
     echo You are currently on Master. Please checkout feature branch and try again.
     return 0
  fi
  ticket=$(echo "${branch}" | grep -Eo '[A-Z]+?-[0-9]+')
  read -r "CONF?Confirm Jira Ticket ($ticket): [Y/n] "
  if [[ "$CONF" =~ ^(no|n|N|NO|No)$ ]] then
      read -r "ticket?Enter Jira Ticket (e.g. QP-1234): "
  fi
  read -r "type?Commit Type: "
  read -r "msg?Commit Message: "
  echo Generating Commit Message for $ticket ..
  commitcommand=$(git commit -m "${type}: ${ticket} $msg")
  echo "${commitcommand}"
}
# Function to open Bitbucket from source directory of project
repo() {
  # output=$(git config --get remote.origin.url)
  output=$(git remote get-url origin)
  echo "${output}"
  open "${output}" # use system default browser
}

bb() {
    st=$(basename "`pwd`")
    upperstr=$(echo $st | tr '[:lower:]' '[:upper:]')
    slug=$(echo $upperstr | tr -d '-')
    bamboo_url="https://forge.lmig.com/builds/browse/QP-"$slug
    echo $bamboo_url
    open  "${bamboo_url}"
}

function openpr() {
  github_url=`git remote -v | awk '/fetch/{print $2}' | sed -Ee 's#(git@|git://)#https://#' -e 's@com:@com/@' -e 's%\.git$%%' | awk '/github/'`;
  branch_name=`git symbolic-ref HEAD | cut -d"/" -f 3,4`;
  pr_url=$github_url"/compare/main..."$branch_name
  open $pr_url;
}


blast() {
  echo "Removing Node Modules..."
  rm -rf node_modules
  echo "Installing project dependencies"
  yarn install
}
