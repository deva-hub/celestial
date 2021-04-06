FROM hexpm/elixir:1.11.3-erlang-23.2.2-alpine-3.12.1 AS base

WORKDIR /workspace

# Install build tools
RUN --mount=type=cache,id=apk,sharing=locked,target=/var/cache/apk \
  apk add make gcc libc-dev

# Install Mix depedencies
RUN mix do local.rebar --force, local.hex --force

FROM base AS deps

# Define production build env
ENV MIX_ENV=prod

# Copy root Mix project
COPY mix.exs mix.lock ./

# Copy umbrella Mix projects
COPY apps/celestial/mix.exs apps/celestial/
COPY apps/celestial_gateway/mix.exs apps/celestial_gateway/
COPY apps/celestial_portal/mix.exs apps/celestial_portal/
COPY apps/celestial_web/mix.exs apps/celestial_web/
COPY apps/celestial_protocol/mix.exs apps/celestial_protocol/
COPY apps/celestial_network/mix.exs apps/celestial_network/

# Pull config
COPY config config

# Pull depedencies
RUN --mount=id=hex-cache,type=cache,target=/root/.hex \
  mix do deps.get, deps.compile

FROM deps AS source

# Copy source
COPY apps apps
COPY rel rel

FROM source AS release

# Assemble release
RUN mix release

FROM alpine:3.11.3

# Install Erlang Runtime dependencies
RUN --mount=type=cache,id=apk,sharing=locked,target=/var/cache/apk \
  apk add openssl ncurses-libs

WORKDIR /celestial

# Create application user
RUN adduser \
  --disabled-password \
  --gecos "Celestial" \
  --shell "/sbin/nologin" \
  --no-create-home \
  celestial
USER celestial

# Set tmp directory
ENV RELEASE_TMP=/tmp/celestial

# Copy release assembly
COPY --from=release --chown=celestial /workspace/_build/prod/rel/celestial .

# Set entrypoint
ENTRYPOINT [ "/celestial/bin/celestial" ]
CMD [ "start" ]
