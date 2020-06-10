#!/bin/bash
# Demyx
# https://demyx.sh

if [[ ! -d "$DEMYX_APP" ]]; then
    cp -r "$DEMYX_CONFIG"/skel/. "$DEMYX"
fi

[[ ! -L "$DEMYX"/log ]] && ln -s "$DEMYX_LOG" "$DEMYX"/log
