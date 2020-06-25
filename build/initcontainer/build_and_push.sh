#!/bin/bash

buildah bud -t ocp4-exp01-initcont . && \
podman tag localhost/ocp4-exp01-initcont quay.io/worsco/ocp4-exp01-initcont:latest && \
podman push quay.io/worsco/ocp4-exp01-initcont:latest

