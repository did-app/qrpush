FROM gleamlang/gleam:0.9.0

# NOTE the WORKDIR should not be the users home dir as the will copy container cookie into host machine
WORKDIR /opt/app
RUN mix local.hex --force && mix local.rebar --force

# TODO mount volumes including gen
COPY . .
RUN mix deps.get
# RUN mix compile mix_gleam
RUN mix compile
RUN mix test

CMD ["./bin/start"]
