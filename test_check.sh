#!/bin/bash
set -e

if [[ -z $GITHUB_TOKEN ]]; then
    export CURL_AUTH=""
else
    export CURL_AUTH="Authorization: token ${GITHUB_TOKEN}"
fi

if [[ -z $TARGET ]]; then
    export TARGET=xenial_x64
fi

if [[ -z $REPOSLUG ]]; then
    export REPOSLUG=nugu-developers/nugu-linux
fi

if [[ -z $TRAVIS_REPO_SLUG ]]; then
    export TRAVIS_REPO_SLUG=nugulinux/test
fi

if [[ -z $SHA ]]; then
    export SHA=$(curl -s -H "${CURL_AUTH}" -X GET https://api.github.com/repos/${REPOSLUG}/commits/master | jq '.sha' -r)
    export SHORTSHA=$(echo ${SHA} | cut -c -7)
fi

./check.sh x
