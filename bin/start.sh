#!/usr/bin/env sh
set -eu

mix deps.get

elixir --sname app -S mix run --no-halt
