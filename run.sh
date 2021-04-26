#!/bin/bash

podman run -it --rm --privileged -v $PWD:/host --name my_virtplat virtplat
