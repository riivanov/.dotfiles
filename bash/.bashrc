#
# ~/.bashrc
#

#unalias md
md () {
echo "$@"
 md2html "$@" | lynx -stdin
}

export TERM=rxvt-unicode-256color
# ask for master password once; never quit
export LPASS_AGENT_TIMEOUT=0
export DOTNET_CLI_TELEMETRY_OPTOUT=1
# Add .NET Core SDK tools
export PATH="$PATH:/home/rivanov/.dotnet/tools"
# Source NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
source ~/.rvm/scripts/rvm 

# Infinite history
HISTSIZE=-1
HISTFILESIZE=-1
# Avoid duplicates
HISTCONTROL=ignoredups:erasedups
# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

source ~/.bash_aliases

xdg-user-dirs-update --set DOWNLOAD /home/rivanov/dwl
xdg-user-dirs-update --set DOCUMENTS /home/rivanov/doc
xdg-user-dirs-update --set MUSIC /home/rivanov/dwl/music
xdg-user-dirs-update --set PICTURES /home/rivanov/dwl/pic
xdg-user-dirs-update --set VIDEOS /home/rivanov/dwl/vid

deleteNonXDGDirs() {
  DIRS=('Downloads' 'Library');

  for DIR in ${DIRS[@]}; do
    #if directory exists
    if [[ -d $DIR ]]; then
      #delete it
      rm -rf $DIR
    fi
  done
}

deleteNonXDGDirs

[[ $- != *i* ]] && return

colors() {
	local fgc bgc vals seq0

	printf "Color escapes are %s\n" '\e[${value};...;${value}m'
	printf "Values 30..37 are \e[33mforeground colors\e[m\n"
	printf "Values 40..47 are \e[43mbackground colors\e[m\n"
	printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

	# foreground colors
	for fgc in {30..37}; do
		# background colors
		for bgc in {40..47}; do
			fgc=${fgc#37} # white
			bgc=${bgc#40} # black

			vals="${fgc:+$fgc;}${bgc}"
			vals=${vals%%;}

			seq0="${vals:+\e[${vals}m}"
			printf "  %-9s" "${seq0:-(default)}"
			printf " ${seq0}TEXT\e[m"
			printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
		done
		echo; echo
	done
}

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Change the window title of X terminals
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
esac

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	if [[ ${EUID} == 0 ]] ; then
		PS1='[`date +%a-%T`]\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
	else
		PS1='[`date +%a-%T`]\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
	fi

	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
	alias egrep='egrep --colour=auto'
	alias fgrep='fgrep --colour=auto'
else
	if [[ ${EUID} == 0 ]] ; then
		# show root@ when we don't have colors
		PS1='[`date +%a-%T`]\u@\h \W \$ '
	else
		PS1='[`date +%a-%T`]\u@\h \w \$ '
	fi
fi

unset use_color safe_term match_lhs sh

#alias cp="cp -i"                          # confirm before overwriting something
#alias df='df -h'                          # human-readable sizes
#alias free='free -m'                      # show sizes in MB
#alias np='nano -w PKGBUILD'
#alias more=less

xhost +local:root > /dev/null 2>&1

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

shopt -s expand_aliases

# export QT_SELECT=4

#
# # ex - archive extractor
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}


keys=`ls ~/.ssh | grep "[a-z]*_ed25519" | grep -v "pub" | sed -e "s#^#/home/rivanov/.ssh/#"`
# Only prompt once for password protected SSH keys
if [[ $- == *i* ]]; then # is this an interactive shell?
    if [[ -x /usr/bin/keychain ]]; then # set up ssh key server
        eval $(keychain --eval --ignore-missing "$keys")
    fi
fi


# Track time spent in BASH
source ~/code/sh/bash-wakatime/bash-wakatime.sh
# Load Angular CLI autocompletion.
source <(ng completion script)
source "$HOME/.cargo/env"
source ~/.dotnet-suggest-shim.bash


# Enable correct interpretation of left |\ key
xmodmap -e 'keycode 94 = 0x5c 0x7c'

cd ~/code/
#cd ~/code/ts/riivanov.github.io

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Share one history among all bash terminals
# After each command, append to the history file and reread it
# leave at end of ~/.bashrc; otherwise is overwritten
PROMPT_COMMAND="history -a; history -c; history -r; ${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}"
#clear
