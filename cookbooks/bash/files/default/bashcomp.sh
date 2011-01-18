# bash completion

_bashcomp_debian() {
	bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}

	if [ -n "$PS1" ]; then
		if [ $bmajor -eq 2 -a $bminor '>' 04 ] || [ $bmajor -gt 2 ]; then
			if [ -r /etc/bash_completion ]; then
				. /etc/bash_completion
			fi
		fi
	fi

	unset bash bminor bmajor
}

_bashcomp_gentoo() {
	# ensure that wanted completions are loaded if available
	CHANGED=0
	for w in $(<${_BASHRC_DIR}/bashcomp-modules); do
		if [[ -e /etc/bash_completion.d/${w} || -e ~/.bash_completion.d/${w} ]]; then
			continue
		fi

		if [[ -e /usr/share/bash-completion/${w} ]]; then
			if hash eselect 2>/dev/null; then
				eselect bashcomp enable ${w}
				CHANGED=1
			fi
		fi
	done

	# ensure to reload bash if bash completion has changed
	if [[ ${CHANGED} -eq 1 ]]; then
		unset CHANGED
		exec ${SHELL}
	fi

	unset CHANGED

	# this is for backwards-compatibility only, gentoo has bash completion enabled
	# by default nowadays.
	[[ -f /etc/profile.d/bash-completion.sh ]] && source /etc/profile.d/bash-completion.sh
}

_bashcomp_unknown() {
	:
}

_bashcomp_${_DISTNAME}

export COMP_WORDBREAKS=${COMP_WORDBREAKS/:/}
export FIGNORE=".o:~"
