#!/bin/bash

buildah bud -t ocp4-exp01-web . && \
podman tag localhost/ocp4-exp01-web quay.io/worsco/ocp4-exp01-web:latest && \
podman push quay.io/worsco/ocp4-exp01-web:latest

