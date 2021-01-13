#!/usr/bin/env bash

git_has_remote() {
	local REMOTE
	REMOTE=$(git remote)
	if [ "$REMOTE" = "" ]; then
		return 1
	fi
	return 0
}

case "$1" in
	"must_run" )
		if [ -r ".git" ]; then
			return 0
		fi
		return 1
		;;
	"is_content" )
		if [ "$2" = ".git" ]; then
			return 1
		fi
		if [ -r ".git" ]; then
			if git check-ignore "$2" >/dev/null ; then
				return 1;
			fi
		fi
		return 0
		;;

	"diff" | "config" | "add" | "commit" | "remote" )
		git "$@"
		;;
	"pull" )
		if ! git_has_remote ; then
			echo "No remote - skipping"
		else
			git pull --all --prune --autostash --rebase



			if ! git pull --all --prune; then
				echo "!! Remote branch has dissapear, looking for a new one..."

				ORIGIN=$(git branch --remotes --merged "HEAD" | grep -v HEAD)
				if [ -z "$ORIGIN" ]; then
					echo "!! !! No new branch found !! !!"
				else
					BRANCH="${ORIGIN/origin\/}"
					BRANCH="${BRANCH// /}"

					echo "!! New branch: '$BRANCH'"

					echo "Going on the new branch: $BRANCH"
					git checkout "$BRANCH"
					git pull --all --prune --autostash --rebase

					echo "On new branch: $BRANCH"
				fi
			fi
		fi
		;;
	"push" )
		if ! git_has_remote ; then
			echo "No remote - skipping"
		else
			if git status | grep "ahead"; then
				echo "No local changes, skipping..."
			else
				git "$@"
			fi
		fi
		;;
	"status" )
		git status -s -b --ahead-behind \
			| grep -v '^## [^\[]*$' \
			|| true
			# | grep -v '## master...origin/master$' \
			# | grep -v '## master$' \
		;;
	"status-full" )
		git status \
			| grep -v "no changes added to commit" \
			| grep -v "On branch master"  \
			| grep -v "Your branch is up to date" \
			| grep -v "nothing to commit, working tree clean" \
			|| true
		;;
esac

return 0
