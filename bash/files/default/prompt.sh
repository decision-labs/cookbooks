__ps1_git() {
	local g="$(git rev-parse --git-dir 2>/dev/null)";
	if [ -n "$g" ]; then
		if [ -e "$g/../.promptignore" ]; then
			return
		fi
		local r;
		local b;
		if [ -f "$g/rebase-merge/interactive" ]; then
			r="|REBASE-i";
			b="$(cat "$g/rebase-merge/head-name")";
		else
			if [ -d "$g/rebase-merge" ]; then
				r="|REBASE-m";
				b="$(cat "$g/rebase-merge/head-name")";
			else
				if [ -d "$g/rebase-apply" ]; then
					if [ -f "$g/rebase-apply/rebasing" ]; then
						r="|REBASE";
					else
						if [ -f "$g/rebase-apply/applying" ]; then
							r="|AM";
						else
							r="|AM/REBASE";
						fi;
					fi;
				else
					if [ -f "$g/MERGE_HEAD" ]; then
						r="|MERGING";
					else
						if [ -f "$g/BISECT_LOG" ]; then
							r="|BISECTING";
						fi;
					fi;
				fi;
				b="$(git symbolic-ref HEAD 2>/dev/null)" || {
				b="$(
				case "${GIT_PS1_DESCRIBE_STYLE-}" in
					(contains)
					git describe --contains HEAD ;;
					(branch)
					git describe --contains --all HEAD ;;
					(describe)
					git describe HEAD ;;
					(* | default)
					git describe --exact-match HEAD ;;
				esac 2>/dev/null)" || b="$(cut -c1-7 "$g/HEAD" 2>/dev/null)..." || b="unknown";
				b="($b)"
			};
		fi;
	fi;
	local w;
	local i;
	local s;
	local u;
	local c;
	if [ "true" = "$(git rev-parse --is-inside-git-dir 2>/dev/null)" ]; then
		if [ "true" = "$(git rev-parse --is-bare-repository 2>/dev/null)" ]; then
			c="BARE:";
		else
			b="GIT_DIR!";
		fi;
	else
		if [ "true" = "$(git rev-parse --is-inside-work-tree 2>/dev/null)" ]; then
			#if [ -n "${GIT_PS1_SHOWDIRTYSTATE-}" ]; then
				if [ "$(git config --bool bash.showDirtyState)" != "false" ]; then
					git diff --no-ext-diff --ignore-submodules --quiet --exit-code || w="*";
					if git rev-parse --quiet --verify HEAD > /dev/null; then
						git diff-index --cached --quiet --ignore-submodules HEAD -- || i="+";
					else
						i="#";
					fi;
				fi;
			#fi;
			#if [ -n "${GIT_PS1_SHOWSTASHSTATE-}" ]; then
				git rev-parse --verify refs/stash > /dev/null 2>&1 && s="\\$";
			#fi;
			#if [ -n "${GIT_PS1_SHOWUNTRACKEDFILES-}" ]; then
				if [ -n "$(git ls-files --others --exclude-standard)" ]; then
					u="?";
				fi;
			#fi;
		fi;
	fi;

	local lb=$(git symbolic-ref HEAD)
	lb=${lb#refs/heads/}

	local ro=$(git config --get branch.${lb}.remote || echo "origin")
	local rb=$(git config --get branch.${lb}.merge)
	rb=${rb#refs/heads/}

	local ab=
	if [ "" != "${rb}" ]; then
		ab="(+$(git log --pretty=format:%H ${ro}/${rb}..${lb} | wc -w))"
		if [ "(+0)" = "${ab}" ]; then
			ab="(-$(git log --pretty=format:%H ${lb}..${ro}/${rb} | wc -w))"
		fi
		if [ "(-0)" = "${ab}" ]; then
			ab=""
		fi
	fi

	echo -e "${PCOL_red}${c}${PCOL_yellow}${b##refs/heads/}${PCOL_brown}${ab}${PCOL_red}${w}${i}${s}${u}${PCOL_green}${r}${PCOL_none}"
fi
}

__ps1_rc() {
	if [[ ${1:-0} -eq 0 ]]; then
		echo -en "${PCOL_lgreen}0${PCOL_none}"
	else
		echo -en "${PCOL_red}${1}${PCOL_none}"
	fi
}

PS1="${COL_lred}\u${COL_yellow}@${COL_lgreen}${_NODENAME}${COL_lgray}.${_DOMAINNAME}${COL_none}"
PS1="${PS1} ${COL_lgray}[${COL_none}\$(__ps1_rc \$?)${COL_lgray}]${COL_none}"
PS1="${PS1} ${COL_lcyan}\t${COL_none}"
PS1="${PS1} ${COL_lblue}\w${COL_none}"
PS1="${PS1} \$(__ps1_git)"
PS1="${PS1}\n${COL_lred}# ${COL_none}"

# screen/tmux title magic
set_screen_title() {
	echo -ne "\ek${USER}@${HOSTNAME}:${BASH_COMMAND/ *}\e\\"
}

if [[ "${TERM/-256color}" == "screen" ]]; then
	PROMPT_COMMAND='echo -ne "\ek${USER}@${HOSTNAME}\e\\"'
	trap set_screen_title DEBUG
fi
