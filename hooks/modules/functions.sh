#!/usr/bin/env bash

COLOR_RED=$(printf '\e[0;31m')
COLOR_DEFAULT=$(printf '\e[m')
ICON_CROSS=$(printf $COLOR_RED'✘'$COLOR_DEFAULT)

ROOT_DIR=$(git rev-parse --show-toplevel 2> /dev/null)
BASE_DIR=$(cd $(dirname $BASH_SOURCE[0])/..; pwd)

function warn {
    echo "$@" >&2
}

function __print_fail {
    echo -e "  $ICON_CROSS $1"
}

function __get_commit_files {
    echo $(git diff-index --name-only --diff-filter=ACM --cached HEAD --)
}

function __get_version_file {
    if [ -z "$VERSION_FILE" ]; then
        VERSION_FILE=$(git config --get gitflow.semver.filename || echo ".version")
    fi

    echo "$ROOT_DIR/$VERSION_FILE"
}

