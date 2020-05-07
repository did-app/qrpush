#!/bin/sh

rebar3 release
_build/default/rel/app/bin/app start

inotifywait -r -m -e modify -e create -e delete src |
   while read path _ file; do
       rebar3 release
       _build/default/rel/app/bin/app restart
   done
