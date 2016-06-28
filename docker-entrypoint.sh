#!/bin/bash
set -e

# Run as user "tusd" if the command is "tusd"
if [ "$1" = 'tusd' ]; then
	set -- gosu tusd tini -- "$@"
fi

exec "$@"
