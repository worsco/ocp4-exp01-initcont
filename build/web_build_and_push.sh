#!/bin/bash

if [[ -z "$MYWEB_REPO" ]] ; then
  echo "You must set the MYWEBCONT_REPO environment variable"
  exit 1
fi

if [[ -z "$MYREGISTRY" ]] ; then
  echo "You must set the MYREGISTRY environment variable"
  exit 1
fi

if [[ -z "$MYREGISTRYACCT" ]] ; then
  echo "You must set the MYREGISTRYACCT environment variable"
  exit 1
fi

cd webcontainer && \
buildah bud -t $MYREGISTRY/$MYREGISTRYACCT/$MYWEB_REPO:latest . && \
podman push $MYREGISTRY/$MYREGISTRYACCT/$MYWEB_REPO:latest

