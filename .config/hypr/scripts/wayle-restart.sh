#!/usr/bin/env bash
# Restart the wayle panel (or start it if it isn't running).
pkill -x wayle
exec wayle panel start
