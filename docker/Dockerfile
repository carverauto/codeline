FROM hexpm/elixir:1.19.4-erlang-28.3-debian-bookworm-20251208-slim AS build

WORKDIR /workspace
ENV MIX_ENV=prod
ENV ERL_FLAGS="+JMsingle true"
ENV ELIXIR_ERL_OPTIONS="+JMsingle true"

COPY mix.exs ./
COPY config ./config
COPY lib ./lib

RUN mix local.hex --force >/dev/null \
  && mix local.rebar --force >/dev/null \
  && mix deps.get \
  && mix release --path /opt/release/codeline

FROM debian:bookworm-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates openssl libstdc++6 \
  && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 10001 codeline \
  && useradd -m -u 10001 -g codeline -s /usr/sbin/nologin codeline

WORKDIR /opt/codeline
COPY --from=build /opt/release/codeline /opt/codeline

ENV HOME=/home/codeline
ENV LANG=C.UTF-8
ENV ELIXIR_ERL_OPTIONS=+fnu
EXPOSE 31337

USER codeline:codeline
ENTRYPOINT ["/opt/codeline/bin/codeline"]
CMD ["start"]
