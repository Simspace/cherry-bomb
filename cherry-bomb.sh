#!/bin/bash

set -e

while getopts 'c:' OPTION; do
    case "$OPTION" in
        c)
            c="$OPTARG"
            ;;
        *)  exit 0
            ;;
    esac
done

if [ -n "${p}" ] &&  [ -n "${c}" ]
then
  dir=$(mktemp -d)
  git clone git@github.com:Simspace/portal-suite.git "${dir}"
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
