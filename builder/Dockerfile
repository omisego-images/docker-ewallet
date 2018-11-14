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

ENV HOME /home/${USER}
ENV LANG=C.UTF-8

RUN set -xe \
 && apk add --update --no-cache --virtual .utils \
        build-base \
        cmake \
        docker \
        findutils \
        git \
        imagemagick \
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
        libressl \
        libressl-dev \
        lksctp-tools \
 && addgroup -g ${GID} ${GROUP} \
 && adduser -D -h ${HOME} -u ${UID} -G ${GROUP} -H ${USER} \
 && mkdir -p "${HOME}" \
 && chown "${UID}:${GID}" "${HOME}"

USER ${USER}

ENV LD_LIBRARY_PATH=/usr/local/otp/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/local/elixir/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/local/node/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/local/python3/lib:$LD_LIBRARY_PATH
ENV PATH=/usr/local/otp/bin:$PATH
ENV PATH=/usr/local/rebar3/bin:$PATH
ENV PATH=/usr/local/elixir/bin:$PATH
ENV PATH=/usr/local/node/bin:$PATH
ENV PATH=/usr/local/python3/bin:$PATH

RUN set -xe \
 && mix do local.hex --force, local.rebar --force
