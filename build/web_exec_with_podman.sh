#!/bin/bash
podman run --rm -it \
-e MYDATA_SOURCE_DIR='static' \
-e MYTEMPLATE_SOURCE_DIR='templates' \
-p 8080:8080 $MYREGISTRY/$MYREGISTRYACCT/$MYWEB_REPO:latest

