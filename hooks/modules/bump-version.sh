#!/usr/bin/env bash

if [ -z "$VERSION" ]; then
    VERSION=$(echo $1 || echo "hotfix")
fi

VERSION=$($BASE_DIR/modules/semverbump.sh $VERSION)

if [ $? -ne 0 ]; then
    __print_fail "Unable to bump version."
    return 1
else
    return 0
fi
