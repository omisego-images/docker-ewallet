FROM alpine:3.7

LABEL maintainer="OmiseGO Team <omg@omise.co>"
LABEL description="Builder image for OmiseGO eWallet"

ENV LANG=C.UTF-8

RUN set -xe && \
    apk add --no-cache --virtual .fetch-deps \
        curl \
        ca-certificates

# ------------------------------------------------------------------------------
# Erlang
# ------------------------------------------------------------------------------

ENV OTP_VERSION="20.3.8"

RUN set -xe && \
    OTP_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${OTP_VERSION}.tar.gz" && \
    OTP_DOWNLOAD_SHA256="a7e59c531605fbd19ceac0568ae81c89ec690449e861da6e3598399f9c4b747f" && \
    apk add --update --no-cache --virtual .erlang-build \
        dpkg-dev dpkg \
        gcc \
        g++ \
        libc-dev \
        linux-headers \
        make \
        autoconf \
        ncurses-dev \
        libressl-dev \
        unixodbc-dev \
        lksctp-tools-dev \
        tar && \
    curl -fsL -o otp-src.tar.gz "${OTP_DOWNLOAD_URL}" && \
    echo "${OTP_DOWNLOAD_SHA256}  otp-src.tar.gz" |sha256sum -c - && \
    mkdir -vp /usr/local/src/otp && \
    tar -xzC /usr/local/src/otp --strip-components=1 -f otp-src.tar.gz && \
    rm otp-src.tar.gz && \
    ( \
        cd /usr/local/src/otp && \
        ./otp_build autoconf && \
        ./configure --prefix=/usr/local/otp --build="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" && \
        make -j$(nproc) && \
        make install \
    ) && \
    rm -rf /usr/local/src/otp && \
    find /usr/local/otp -regex '/usr/local/otp/lib/erlang/\(lib/\|erts-\).*/\(man\|doc\|obj\|c_src\|emacs\|info\|examples\)' | xargs rm -rf && \
    find /usr/local/otp -name src | xargs -r find | grep -v '\.hrl$' | xargs rm -v || true && \
    find /usr/local/otp -name src | xargs -r find | xargs rmdir -vp || true && \
    scanelf --nobanner -E ET_EXEC -BF '%F' --recursive /usr/local/otp | xargs -r strip --strip-all && \
    scanelf --nobanner -E ET_DYN -BF '%F' --recursive /usr/local/otp | xargs -r strip --strip-unneeded && \
    OTP_RUN_DEPS="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/otp \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/otp/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" && \
    apk add --update --no-cache --virtual .erlang-run \
        $OTP_RUN_DEPS \
        lksctp-tools && \
    apk del .erlang-build && \
    rm -rf /usr/local/src

ENV PATH=/usr/local/otp/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/erlang/lib:$LD_LIBRARY_PATH

ENV REBAR3_VERSION="3.5.0"

RUN set -xe && \
    REBAR3_DOWNLOAD_URL="https://github.com/erlang/rebar3/archive/${REBAR3_VERSION}.tar.gz" && \
    REBAR3_DOWNLOAD_SHA256="e95e9d1f2ce219f548d4f49ad41409af02069190f19e2b6717585eef6ee77501" && \
    curl -fsL -o rebar3-src.tar.gz "${REBAR3_DOWNLOAD_URL}" && \
    echo "${REBAR3_DOWNLOAD_SHA256}  rebar3-src.tar.gz" |sha256sum -c - && \
    mkdir -p /usr/local/src/rebar3 && \
    tar -xzC /usr/local/src/rebar3 --strip-components=1 -f rebar3-src.tar.gz && \
    rm rebar3-src.tar.gz && \
    ( \
        cd /usr/local/src/rebar3 && \
        HOME=$PWD ./bootstrap && \
        mkdir -p /usr/local/rebar3/bin && \
        install -v ./rebar3 /usr/local/rebar3/bin/rebar3 \
    ) && \
    rm -rf /usr/local/src/rebar3 && \
    rm -rf /usr/local/src

ENV PATH=/usr/local/rebar3/bin:$PATH

# ------------------------------------------------------------------------------
# Elixir
# ------------------------------------------------------------------------------

ENV ELIXIR_VERSION="1.6.5"

RUN set -xe && \
    apk add --update --no-cache --virtual .elixir-build \
        make \
        tar && \
    ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/v${ELIXIR_VERSION}.tar.gz" && \
    ELIXIR_DOWNLOAD_SHA256="defe2bed953ee729addf1121db3fa42a618ef1d6c57a1f489da03b0e7a626e89" && \
    curl -fsL -o elixir-src.tar.gz "${ELIXIR_DOWNLOAD_URL}" && \
    echo "${ELIXIR_DOWNLOAD_SHA256}  elixir-src.tar.gz" |sha256sum -c - && \
    mkdir -p /usr/local/src/elixir && \
    tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz && \
    rm elixir-src.tar.gz && \
    ( \
        cd /usr/local/src/elixir && \
        make -j$(nproc) && \
        PREFIX=/usr/local/elixir make install \
    ) && \
    rm -rf /usr/local/src/elixir && \
    apk del .elixir-build && \
    rm -rf /usr/local/src

ENV PATH=/usr/local/elixir/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/elixir/lib:$LD_LIBRARY_PATH

# ------------------------------------------------------------------------------
# S6
# ------------------------------------------------------------------------------

ENV S6_VERSION="1.21.4.0"

RUN set -xe && \
    apk add --update --no-cache --virtual .fetch-deps \
        curl \
        ca-certificates && \
    S6_DOWNLOAD_URL="https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz" && \
    S6_DOWNLOAD_SHA256="e903f138dea67e75afc0f61e79eba529212b311dc83accc1e18a449d58a2b10c" && \
    curl -fsL -o s6-overlay.tar.gz "${S6_DOWNLOAD_URL}" && \
    echo "${S6_DOWNLOAD_SHA256}  s6-overlay.tar.gz" |sha256sum -c - && \
    tar -xzC / -f s6-overlay.tar.gz && \
    rm s6-overlay.tar.gz && \
    apk del .fetch-deps

# ------------------------------------------------------------------------------
# Application
# ------------------------------------------------------------------------------

RUN apk add --update --no-cache --virtual .ewallet-runtime \
        bash \
        imagemagick

ARG user=ewallet
ARG group=ewallet
ARG uid=10000
ARG gid=10000

RUN set -xe && \
    addgroup -g ${gid} ${group} && \
    adduser -D -h /app -u ${uid} -G ${group} ${user} && \
    chown "${uid}:${gid}" "/app"

RUN mix do local.hex --force, local.rebar --force

ENTRYPOINT ["/init"]