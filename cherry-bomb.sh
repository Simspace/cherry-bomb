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

failures=""

if [ -n "${r}" ] &&  [ -n "${c}" ]
then
  dir=$(mktemp -d)
  trap 'rm -rf -- "$dir"' EXIT
  git clone "${r}" "${dir}"
  git reset --hard origin/dev
  cd "${dir}" || exit
  for branch_name in $(hub pr list -s open -f "%H "); do
    git checkout "${branch_name}"
    # This checks the status code of the previous command.
    # git cherry-pick returns a 1 on conflict and a 0 on merge success
    if git cherry-pick "${c}";
    then
      git push
    else
      git cherry-pick --abort
      failures="${failures}${branch_name}\n"
    fi
    git checkout dev
    git reset --hard origin/dev
  done
  failures="These branches failed to cherry-pick:\n"
  printf '%s' "${failures}"
  rm -rf "${dir}"
else
  echo "Usage: cherry-bomb [-c commit-hash]" >&2
fi
