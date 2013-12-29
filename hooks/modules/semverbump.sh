#!/usr/bin/env bash

. "$(dirname $0)/functions.sh"

function __print_usage {
    echo "Usage: $(basename $0) [major|minor|hotfix|<semver>][-<prerelease>][+<metadata>]"
    echo 
    echo "    major|minor|hotfix: Version will be bumped accordingly."
    echo "    <semver>:          Version won't be bumped."
    echo "    <prerelease>:      Some prerelease info (beta,alpha...)."
    echo "    <metadata>:        Some version metadata (build123)."
    echo 
    echo "Example: $(basename $0) major-beta+build123"
    echo 
    echo "    This will increase the major version by 1 and add some metadata to version."
    echo 
    exit 1
}

function __print_version {
    echo $VERSION_BUMPED
    exit 0
}

# determine sort command
if [ ! -z "$VERSION_SORT" ]; then
    if [ ! -f "/opt/local/bin/gsort" ]; then
        VERSION_SORT="/opt/local/bin/gsort -V"
    else
        VERSION_SORT="/usr/bin/sort -V"
    fi
fi

if [ $# -gt 2 ]; then
    __print_usage
fi

# Parse version argument --------------------------#
VERSION_ARG="$1"

if [[ "$VERSION_ARG" =~ ^(major|minor|hotfix)?(-[0-9A-Za-z-]+)?(\+[0-9A-Za-z-]+)?$ ]]; then
    VERSION_UPDATE_MODE=$(echo "${BASH_REMATCH[1]}" | tr '[:lower:]' '[:upper:]')
    VERSION_PREREL="${BASH_REMATCH[2]}"
    VERSION_METADATA="${BASH_REMATCH[3]}"

    if [ -z "$VERSION_UPDATE_MODE" ]; then
        VERSION_UPDATE_MODE="HOTFIX"
    fi
elif [[ "$VERSION_ARG" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z-]+)?(\+[0-9A-Za-z-]+)?$ ]]; then
    VERSION_BUMPED=$VERSION_ARG
    __print_version
else
    __print_usage
fi

# Extract current version from tags ---------------#
VERSION_PREFIX=$(git config --get gitflow.prefix.versiontag)
VERSION_TAG=$(git tag -l "$VERSION_PREFIX*" | $VERSION_SORT | tail -1)

if [ ! -z "$VERSION_TAG" ]; then
    if [ ! -z "$VERSION_PREFIX" ]; then
        VERSION_CURRENT=${VERSION_TAG#$VERSION_PREFIX}
    else
        VERSION_CURRENT=$VERSION_TAG
    fi
fi

# If no version tag found, try version file -------#
if [ -z "$VERSION_CURRENT" ]; then
    VERSION_FILE=$(__get_version_file)

    if [ -f "$VERSION_FILE" ]; then
        VERSION_CURRENT=$(cat $VERSION_FILE)
    fi
fi

# If no version found, start with 0.0.0 -----------#
if [ -z "$VERSION_CURRENT" ]; then
    VERSION_CURRENT="0.0.0"
fi

# Parse current version for MAJOR.MINOR.HOTFIX -----#
if [[ "$VERSION_CURRENT" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)(-[0-9A-Za-z-]+)?(\+[0-9A-Za-z-]+)?$ ]]; then
    VERSION_MAJOR=${BASH_REMATCH[1]}
    VERSION_MINOR=${BASH_REMATCH[2]}
    VERSION_HOTFIX=${BASH_REMATCH[3]}
else
    warn "WARN: Current version ($VERSION_CURRENT) doesn't match semantic version pattern."
    warn "Please try again manualy specifying your version."

    exit 1
fi

# Bump version ------------------------------------#
if [ "$VERSION_UPDATE_MODE" == "HOTFIX" ]; then
    VERSION_HOTFIX=$((VERSION_HOTFIX + 1))
elif [ "$VERSION_UPDATE_MODE" == "MINOR" ]; then
    VERSION_MINOR=$((VERSION_MINOR + 1))
    VERSION_HOTFIX=0
else
    VERSION_MAJOR=$((VERSION_MAJOR + 1))
    VERSION_MINOR=0
    VERSION_HOTFIX=0
fi

VERSION_BUMPED="${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_HOTFIX}${VERSION_PREREL}${VERSION_METADATA}"

__print_version
