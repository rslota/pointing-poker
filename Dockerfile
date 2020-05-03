FROM debian:stretch as builder

ARG ERLANG_VERSION=1:22.3.2-1
ARG ELIXIR_VERSION=1.10.1-1
ARG MIX_ENV=prod

ENV ERLANG_VERSION ${ERLANG_VERSION}
ENV ELIXIR_VERSION ${ELIXIR_VERSION}
ENV MIX_ENV ${MIX_ENV}

SHELL ["/bin/bash", "-c"]

# Handle locales
RUN apt-get update && \
        apt-get install --yes locales && \
        sed -i '/^#.* en_US.UTF-8 /s/^#//' /etc/locale.gen && \
        locale-gen

ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en"

# Install build utils
RUN apt-get install --yes \
        wget \
        unzip \
        build-essential \
        apt-transport-https \
        git \
        curl

# Install Erlang & Elixir
RUN echo "deb https://packages.erlang-solutions.com/debian stretch contrib" >> /etc/apt/sources.list && \
        cat /etc/apt/sources.list && \
        wget --quiet -O - https://packages.erlang-solutions.com/debian/erlang_solutions.asc | apt-key add - && \
        apt-get update && \
        apt-get install --yes \
        esl-erlang=$ERLANG_VERSION \
        elixir=$ELIXIR_VERSION

# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

WORKDIR /build

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

# build assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

COPY priv priv
COPY assets assets
RUN npm run --prefix ./assets deploy
RUN mix phx.digest

# compile and build release
COPY lib lib
COPY rel rel
RUN mix do compile, release

RUN mkdir /release && \
        cp -r _build/prod/rel/pointing_poker/* /release/


FROM debian:stretch-slim

# Handle locales
RUN apt-get update && \
        apt-get install --yes locales && \
        sed -i '/^#.* en_US.UTF-8 /s/^#//' /etc/locale.gen && \
        locale-gen
ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en"

# libcrypto.so is required by ERTS. curl for healthcheck.
RUN apt-get install --yes \
        libssl1.1 \
        curl

WORKDIR /app

COPY --from=builder /release/ .

RUN groupadd -r app && useradd -r -g app app
RUN chown -R app /app
USER app

EXPOSE 4000

HEALTHCHECK --interval=30s --timeout=30s --retries=3 --start-period=5s \
        CMD curl --silent localhost:4000/ || exit 1

CMD trap 'exit' INT; /app/bin/pointing_poker start
