#!/bin/bash
# Demyx
# https://demyx.sh
# 0 0 * * *

# Rotate demyx log
/usr/local/bin/demyx log --rotate=demyx
# Rotate stack log
/usr/local/bin/demyx log --rotate=stack
# Rotate WordPress log
/usr/local/bin/demyx log --rotate=wp
