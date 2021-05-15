#!/bin/bash

podman build -v $PWD:/virtplat:z --tag virtplat --jobs $(getconf _NPROCESSORS_ONLN) .
