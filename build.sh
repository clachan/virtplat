#!/bin/bash

podman build --tag virtplat --jobs $(getconf _NPROCESSORS_ONLN) .
