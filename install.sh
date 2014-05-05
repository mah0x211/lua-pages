#!/bin/bash

set -e
set -x

LUAROCKS=`which luarocks`
$LUAROCKS install https://raw.githubusercontent.com/mah0x211/tsukuyomi/master/tsukuyomi-scm-1.rockspec
