FROM gleamlang/gleam:0.9.0-rc1

RUN apt-get update && apt-get install -y inotify-tools

WORKDIR /opt/app

COPY . .

# Done so generated files are available to heroku run bash
RUN rebar3 upgrade && rebar3 release
CMD ["_build/default/rel/app/bin/app","foreground"]
