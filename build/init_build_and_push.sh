#!/bin/bash

if [[ -z "$MYINITCONT_REPO" ]] ; then
  echo "You must set the MYINITCONT_REPO environment variable"
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

cd initcontainer && \
buildah bud -t $MYINITCONT_REPO . && \
podman tag localhost/$MYINITCONT_REPO $MYREGISTRY/$MYREGISTRYACCT/$MYINITCONT_REPO:latest && \
podman push $MYREGISTRY/$MYREGISTRYACCT/$MYINITCONT_REPO:latest

