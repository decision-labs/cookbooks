# color detection magic
use_color=false

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

unset safe_term match_lhs


if ${use_color}; then
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	alias ls="ls --color=auto"
	alias grep="grep --color=auto"

	# this is a lot uglier than the old color() function, but should be more
	# efficient and easier to use in the prompt
	PCOL_black='\033[00;30m'
	PCOL_dgray='\033[01;30m'
	PCOL_red='\033[00;31m'
	PCOL_lred='\033[01;31m'
	PCOL_green='\033[00;32m'
	PCOL_lgreen='\033[01;32m'
	PCOL_brown='\033[00;33m'
	PCOL_yellow='\033[01;33m'
	PCOL_blue='\033[00;34m'
	PCOL_lblue='\033[01;34m'
	PCOL_purple='\033[00;35m'
	PCOL_lpurple='\033[01;35m'
	PCOL_cyan='\033[00;36m'
	PCOL_lcyan='\033[01;36m'
	PCOL_lgray='\033[00;37m'
	PCOL_white='\033[01;37m'
	PCOL_none='\033[00m'

	COL_black='\[\033[00;30m\]'
	COL_dgray='\[\033[01;30m\]'
	COL_red='\[\033[00;31m\]'
	COL_lred='\[\033[01;31m\]'
	COL_green='\[\033[00;32m\]'
	COL_lgreen='\[\033[01;32m\]'
	COL_brown='\[\033[00;33m\]'
	COL_yellow='\[\033[01;33m\]'
	COL_blue='\[\033[00;34m\]'
	COL_lblue='\[\033[01;34m\]'
	COL_purple='\[\033[00;35m\]'
	COL_lpurple='\[\033[01;35m\]'
	COL_cyan='\[\033[00;36m\]'
	COL_lcyan='\[\033[01;36m\]'
	COL_lgray='\[\033[00;37m\]'
	COL_white='\[\033[01;37m\]'
	COL_none='\[\033[00m\]'
else
	PCOL_black=''
	PCOL_dgray=''
	PCOL_red=''
	PCOL_lred=''
	PCOL_green=''
	PCOL_lgreen=''
	PCOL_brown=''
	PCOL_yellow=''
	PCOL_blue=''
	PCOL_lblue=''
	PCOL_purple=''
	PCOL_lpurple=''
	PCOL_cyan=''
	PCOL_lcyan=''
	PCOL_lgray=''
	PCOL_white=''
	PCOL_none=''

	COL_black=''
	COL_dgray=''
	COL_red=''
	COL_lred=''
	COL_green=''
	COL_lgreen=''
	COL_brown=''
	COL_yellow=''
	COL_blue=''
	COL_lblue=''
	COL_purple=''
	COL_lpurple=''
	COL_cyan=''
	COL_lcyan=''
	COL_lgray=''
	COL_white=''
	COL_none=''
fi
