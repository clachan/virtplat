#!/bin/bash

podman run -it --rm --privileged -v $PWD:/virtplat:z --name my_virtplat virtplat
