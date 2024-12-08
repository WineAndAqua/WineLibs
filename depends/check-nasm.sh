#!/bin/sh

nasm --version 1>/dev/null 2>&1 || { echo "ERROR: Install nasm before continuing."; exit 1; }
