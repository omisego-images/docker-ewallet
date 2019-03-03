ARG PREFIX="ewallet-builder"

# Workaround for COPY not expanding variables.
FROM $PREFIX-erlang AS ewallet-builder-erlang
FROM $PREFIX-elixir AS ewallet-builder-elixir
FROM $PREFIX-node AS ewallet-builder-node
FROM $PREFIX-python3 AS ewallet-builder-python3

FROM $PREFIX-base

LABEL maintainer="OmiseGO Team <omg@omise.co>"
LABEL description="Builder image for OmiseGO eWallet"

ARG USER=ewallet
ARG GROUP=ewallet
ARG UID=10000
ARG GID=10000

COPY --from=ewallet-builder-erlang /usr/local/otp /usr/local/otp
COPY --from=ewallet-builder-erlang /usr/local/rebar3 /usr/local/rebar3
COPY --from=ewallet-builder-elixir /usr/local/elixir /usr/local/elixir
COPY --from=ewallet-builder-node /usr/local/node /usr/local/node
COPY --from=ewallet-builder-python3 /usr/local/python3 /usr/local/python3

ENV LD_LIBRARY_PATH=/usr/local/otp/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/local/elixir/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/local/node/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/local/python3/lib:$LD_LIBRARY_PATH
ENV PATH=/usr/local/otp/bin:$PATH
ENV PATH=/usr/local/rebar3/bin:$PATH
ENV PATH=/usr/local/elixir/bin:$PATH
ENV PATH=/usr/local/node/bin:$PATH
ENV PATH=/usr/local/python3/bin:$PATH

ENV HOME /home/${USER}
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

ARG DOCKER_COMPOSE_VERSION="1.23.2"
ARG PIPENV_VERSION="2018.11.26"
ARG KAPITAN_VERSION="0.22.3"

RUN set -xe \
 && apk add --update --no-cache --virtual .utils \
        bash \
        build-base \
        cmake \
        docker \
        findutils \
        git \
        gnupg \
        imagemagick \
        libressl \
        openssh \
 && apk add --no-cache --virtual .libsecp256k1-build \
        autoconf \
        automake \
        gmp \
        gmp-dev \
        libtool \
 && apk add --no-cache --virtual .python3-pip-build \
        build-base \
        libffi-dev \
        libressl-dev \
 && mkdir -p /usr/local/python3-venv \
 && virtualenv /usr/local/python3-venv/docker \
 && virtualenv /usr/local/python3-venv/pipenv \
 && virtualenv /usr/local/python3-venv/kapitan \
 && /usr/local/python3-venv/docker/bin/pip3 install "docker-compose==$DOCKER_COMPOSE_VERSION" \
 && /usr/local/python3-venv/pipenv/bin/pip3 install "pipenv==$PIPENV_VERSION" \
 && /usr/local/python3-venv/kapitan/bin/pip3 install "kapitan==$KAPITAN_VERSION" \
 && ln -s /usr/local/python3-venv/docker/bin/docker-compose /usr/local/bin/docker-compose \
 && ln -s /usr/local/python3-venv/pipenv/bin/pipenv /usr/local/bin/pipenv \
 && ln -s /usr/local/python3-venv/kapitan/bin/kapitan /usr/local/bin/kapitan \
 && find /usr/local/python3 -depth \( \
            \( -type d -a \( -name test -o -name tests \) \) \
            -o \
            \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
        \) -exec rm -rf \{\} \; \
 && find /usr/local/python3-venv -depth \( \
            \( -type d -a \( -name test -o -name tests \) \) \
            -o \
            \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
        \) -exec rm -rf \{\} \; \
 && rm -rf "$HOME/.cache" \
 && RUN_DEPS="$( \
        find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec \
            scanelf --needed --nobanner --format '%n#p' '{}' ';' \
            | tr ',' '\n' \
            | sort -u \
            | awk '! /^$/ && system("test -z $(find /usr/local -iname " $1 ")") == 0 { print "so:" $1 }' \
    )" \
 && apk add --update --no-cache --virtual .run-deps \
        $RUN_DEPS \
        ca-certificates \
        libressl-dev \
        lksctp-tools \
 && apk del .python3-pip-build \
 && addgroup -g ${GID} ${GROUP} \
 && adduser -D -h ${HOME} -u ${UID} -G ${GROUP} -H ${USER} \
 && mkdir -p "${HOME}" \
 && chown -R "${UID}:${GID}" "${HOME}"

USER ${USER}

RUN set -xe \
 && mix do local.hex --force, local.rebar --force
