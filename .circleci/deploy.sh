#!/bin/bash

set -e

git config --global user.email $(git log -n 1 --pretty='format:%aE')
git config --global user.name $(git log -n 1 --pretty='format:%aN')

cd crystax-ndk/sources/python
git init
git add .
git commit --quiet -m "Deploy to Github Pages [ci skip]"
git push --force "https://${GITHUB_TOKEN}@${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}.git" master:gh-pages