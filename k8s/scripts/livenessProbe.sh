#!/bin/bash

if [ -e ".livenessProbe" ]; then
    lastModified=$(stat -c %Y ".livenessProbe")
    currentTime=$(date +%s)
    dif=$((currentTime - lastModified))

    if [ "$dif" -gt "10" ]; then
        exit 0
    else
        exit 1
    fi
else
    exit 1
fi