# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian
# instead of Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye-20230612-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: hexpm/elixir:1.15.2-erlang-26.0.2-debian-bullseye-20230612-slim
#

# ARG SPA_DIR="assets/spa"


########
ARG SPA_DIR="assets/spa"
ARG ELIXIR_VERSION=1.15.2
ARG OTP_VERSION=26.0.2
ARG DEBIAN_VERSION=bullseye-20230612-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

#######<--- Build the fullpage SPA
# pre-stage for fullpage SPA
FROM node:20-bullseye-slim as node-deps
RUN npm install -g pnpm
WORKDIR /front
COPY front/package.json front/pnpm-lock.yaml ./
RUN pnpm install

##### build stage of fullpage SPA: assets are build in /front/dist folder
FROM node-deps as asset-builder
ENV NODE_ENV prod
WORKDIR /front
COPY front .
RUN pnpm build
RUN pnpm prune --prod
#####--> end fullpage SPA

#####--> Phoenix build stage
# install node, npm and pnpm to build assets and compile Taliwind
FROM ${BUILDER_IMAGE} as builder

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git nodejs npm curl \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*
RUN curl -fsSL https://deb.nodesource.com/setup_18.x bullseye| bash - \
  && apt-get install -y nodejs

RUN npm install -g pnpm

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv
COPY --from=asset-builder /front/dist /app/priv/static/spa

COPY lib lib
COPY assets assets
# COPY front front

# compile assets
# RUN mix assets.deploy
ENV NODE_ENV prod
RUN  cd assets && pnpm install && node build.js --deploy

WORKDIR /app
RUN mix tailwind default --minify

# Compile the release
RUN mix do compile, phx.digest

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release && rm -rf /app/deps

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app
EXPOSE 4369
# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/phx_solid ./

USER nobody

CMD ["/app/bin/server"]
