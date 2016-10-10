#!/usr/bin/env zsh

emulate -L zsh

apk_path=$1

mv ${apk_path%/}/usr/bin ${apk_path%/}/bin
