#!/bin/bash
# Auto open VORTEX thick-border menu in interactive console only.
# Banner connect /etc/dropbear_banner tidak disentuh.

if [[ $- == *i* ]]; then
  menu
fi
