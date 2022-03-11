#!/bin/bash

set -e

while getopts 'r:c:' OPTION; do
    case "$OPTION" in
        r)
            r="$OPTARG"
            ;;
        c)
            c="$OPTARG"
            ;;
        *)  exit 0
            ;;
    esac
done

if [ -n "${r}" ] &&  [ -n "${c}" ]
then
  dir=$(mktemp -d)
  git clone "${r}" "${dir}"
  git reset --hard origin/dev
  cd "${dir}" || exit
  for branch_name in $(hub pr list -s open -f "%H "); do
    git checkout "${branch_name}"
    git cherry-pick "${c}"
    git push
    git checkout dev
    git reset --hard origin/dev
  done
else
  echo "Usage: cherry-bomb [-c commit-hash]" >&2
fi
