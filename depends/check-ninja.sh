#!/bin/sh

ninja --version 1>/dev/null 2>&1 || { echo "ERROR: Install ninja before continuing."; exit 1; }
