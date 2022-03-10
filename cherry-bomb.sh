#!/bin/bash

set -e

unset PATH

while getopts 'p:c:' OPTION; do
    case "$OPTION" in
        p)
            p="$OPTARG"
            ;;
        c)
            c="$OPTARG"
            ;;
        *)  exit 0
            ;;
    esac
done

if [ -n "${p}" ] &&  [ -n "${c}" ]
then
  cd "${p}" || exit
  pwd
  $hub pr list -s open -f "%B%H%n"
else
  echo "Usage: cherry-bomb [-p path] [-c commit-hash]" >&2
fi
