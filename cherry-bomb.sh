#!/bin/bash
#bloop
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

failures=""

if [ -n "${r}" ] &&  [ -n "${c}" ]
then
  dir=$(mktemp -d)
  git clone "${r}" "${dir}"
  git reset --hard origin/dev
  cd "${dir}" || exit
  for branch_name in $(hub pr list -s open -f "%H "); do
    git checkout "${branch_name}"
    git cherry-pick "${c}"
    # This checks the status code of the previous command.
    # git cherry-pick returns a 1 on conflict and a 0 on merge success
    res=$(echo "$?")
    if [ ${res} -eq 1 ]
    then
      git cherry-pick --abort
      failures="${failures}${branch_name}\n"
    else
      git push
    fi
    git checkout dev
    git reset --hard origin/dev
  done
  failures="These branches failed to cherry-pick:\n"
  printf ${failures}
  rm -rf "${dir}"
else
  echo "Usage: cherry-bomb [-c commit-hash]" >&2
fi
