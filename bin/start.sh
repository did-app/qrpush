#!/usr/bin/env sh
set -eu

mix deps.get

(cd lib/qr_push/www ; npm install)

elixir --sname app -S mix run --no-halt

