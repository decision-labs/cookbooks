#!/bin/bash

GIT_REPO=$1
OWNER=${2:-$(id -u)}
GROUP=${3:-$(id -g)}
TMPDIR=$(mktemp -d)

umask 027

mkdir -p $GIT_REPO
pushd $GIT_REPO
git init --bare
popd

pushd $TMPDIR
git init
touch .keep
git add .keep
git commit -m "initial commit"
git remote add origin file://$GIT_REPO
git push origin master
popd

rm -rf $TMPDIR

chown $OWNER:$GROUP -R $GIT_REPO
