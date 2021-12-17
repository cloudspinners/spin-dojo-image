#!/bin/bash -e

if [ -n ${GIT_USER_NAME} ] ; then
  git config --global user.name ${GIT_USER_NAME}
else
  echo "No GIT_USER_NAME"
fi

if [ -n ${GIT_USER_EMAIL} ] ; then
  git config --global user.email ${GIT_USER_EMAIL}
else
  echo "No GIT_USER_EMAIL"
fi
