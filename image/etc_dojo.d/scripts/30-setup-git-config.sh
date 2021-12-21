#!/bin/bash -e

if [ -n ${GIT_USER_NAME} ] ; then
  git config --system user.name ${GIT_USER_NAME}
fi

if [ -n ${GIT_USER_EMAIL} ] ; then
  git config --system user.email ${GIT_USER_EMAIL}
fi

git config --system alias.st status
git config --system alias.ci commit
git config --system alias.pu push
git config --system alias.co checkout
git config --system alias.br branch
