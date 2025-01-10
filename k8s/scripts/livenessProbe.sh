#!/bin/bash

# This liveness probe validates if now - .livenessProbe is smaller than 10

if [ -e ".livenessProbe" ]; then
    lastModified=$(stat -c %Y ".livenessProbe")
    currentTime=$(date +%s)
    dif=$((currentTime - lastModified))

    if [ "$dif" -lt "10" ]; then
        exit 0
    else
        exit 1
    fi
else
    exit 1
fi
