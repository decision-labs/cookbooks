if [ -n "${BASH_VERSION}" ] ; then
	PS1="\[\033[01;32m\]\u@$(hostname -f)\[\033[01;34m\] \w\n\$\[\033[00m\] "
fi
