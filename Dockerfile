FROM gleamlang/gleam:0.9.0-rc1 as build

FROM elixir:1.10.3

COPY --from=build /bin/gleam /bin
RUN gleam --version

RUN mix local.hex --force && mix local.rebar --force

# NOTE the WORKDIR should not be the users home dir as the will copy container cookie into host machine
WORKDIR /opt/app

# TODO mount volumes including gen
COPY . .
RUN mix deps.get
# RUN mix compile mix_gleam
RUN mix compile
RUN mix test

CMD ["./bin/start"]
