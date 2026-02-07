#!/usr/bin/env bash

dir="$HOME/.config/rofi/launcher/type-1/"
theme='style-5'

## Run
rofi \
    -show drun \
    -theme ${dir}/${theme}.rasi
