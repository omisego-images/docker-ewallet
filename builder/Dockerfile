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
# Ruby
# ------------------------------------------------------------------------------

ENV RUBY_VERSION=2.5.1
ENV RUBY_DOWNLOAD_SHA256=886ac5eed41e3b5fc699be837b0087a6a5a3d10f464087560d2d21b3e71b754d

RUN set -xe && \
    apk add --update --no-cache --virtual .ruby-build \
        autoconf \
	bison \
	bzip2 \
	bzip2-dev \
	ca-certificates \
	coreutils \
	dpkg-dev dpkg \
	gcc \
	gdbm-dev \
	glib-dev \
	libc-dev \
	libffi-dev \
	libressl \
	libressl-dev \
	libxml2-dev \
	libxslt-dev \
	linux-headers \
	make \
	ncurses-dev \
	procps \
	readline-dev \
	ruby \
	tar \
	xz \
	yaml-dev \
        zlib-dev && \
    RUBY_DOWNLOAD_URL="https://cache.ruby-lang.org/pub/ruby/${RUBY_VERSION%.*}/ruby-${RUBY_VERSION}.tar.xz" && \
    RUBY_DOWNLOAD_SHA256="886ac5eed41e3b5fc699be837b0087a6a5a3d10f464087560d2d21b3e71b754d" && \
    curl -fsL -o ruby-src.tar.xz "${RUBY_DOWNLOAD_URL}" && \
    echo "${RUBY_DOWNLOAD_SHA256}  ruby-src.tar.xz" |sha256sum -c - && \
    mkdir -p /usr/local/src/ruby && \
    tar -xJC /usr/local/src/ruby --strip-components=1 -f ruby-src.tar.xz && \
    rm ruby-src.tar.xz && \
    ( \
        cd /usr/local/src/ruby && \
        { \
            echo '#define ENABLE_PATH_CHECK 0'; \
            echo; \
            cat file.c; \
        } > file.c.new && \
        mv file.c.new file.c && \
        autoconf && \
        export ac_cv_func_isnan=yes ac_cv_func_isinf=yes && \
        ./configure \
            --prefix=/usr/local/ruby \
            --build="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
            --disable-install-doc \
            --enable-shared && \
        make -j$(nproc) && \
        make install \
    ) && \
    rm -rf /usr/local/src/ruby && \
    scanelf --nobanner -E ET_EXEC -BF '%F' --recursive /usr/local/ruby | xargs -r strip --strip-all && \
    scanelf --nobanner -E ET_DYN -BF '%F' --recursive /usr/local/ruby | xargs -r strip --strip-unneeded && \
    RUBY_RUN_DEPS="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/ruby \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/ruby/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" && \
    apk add --update --no-cache --virtual .ruby-run \
        $RUBY_RUN_DEPS \
        bzip2 \
        ca-certificates \
        libffi-dev \
        libressl-dev \
        procps \
        yaml-dev \
        zlib-dev && \
    apk del .ruby-build && \
    rm -rf /usr/local/src

ENV PATH=/usr/local/ruby/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/ruby/lib:$LD_LIBRARY_PATH

ENV RUBYGEMS_VERSION="2.7.7"
ENV BUNDLER_VERSION="1.16.2"

ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME"
ENV BUNDLE_SILENCE_ROOT_WARNING=1
ENV BUNDLE_APP_CONFIG="$GEM_HOME"

RUN set -xe && \
    mkdir -p /usr/local/etc && \
    { \
        echo 'install: --no-document'; \
        echo 'update: --no-document'; \
    } >> /usr/local/etc/gemrc && \
    gem update --system "${RUBYGEMS_VERSION}" && \
    gem install bundler --version "${BUNDLER_VERSION}" --force && \
    mkdir -p "${GEM_HOME}" && \
    chmod 777 "${GEM_HOME}" && \
    rm -rf /root/.gem

ENV PATH=$GEM_HOME/bin:$BUNDLE_PATH/gems/bin:$PATH

# ------------------------------------------------------------------------------
# Node
# ------------------------------------------------------------------------------

ENV NODE_VERSION="9.11.2"

RUN set -xe && \
    apk add --update --no-cache --virtual .node-build \
        curl \
        make \
        gcc \
        g++ \
        python \
        linux-headers \
        binutils-gold \
        libstdc++ && \
    NODE_DOWNLOAD_URL="https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.xz" && \
    NODE_DOWNLOAD_SHA256="06484eac7f6b7c87e96983a039422347c0047284bc4d373d90884ae3966dc213" && \
    curl -fsL -o node-src.tar.xz "${NODE_DOWNLOAD_URL}" && \
    echo "${NODE_DOWNLOAD_SHA256}  node-src.tar.xz" |sha256sum -c - && \
    mkdir -p /usr/local/src/node && \
    tar -xJC /usr/local/src/node --strip-components=1 -f node-src.tar.xz && \
    rm node-src.tar.xz && \
    ( \
        cd /usr/local/src/node && \
        export ac_cv_func_isnan=yes ac_cv_func_isinf=yes && \
        ./configure \
            --prefix=/usr/local/node \
            --fully-static && \
        make -j$(nproc) && \
        make install \
    ) && \
    rm -rf /usr/local/src/node && \
    scanelf --nobanner -E ET_EXEC -BF '%F' --recursive /usr/local/node | xargs -r strip --strip-all && \
    scanelf --nobanner -E ET_DYN -BF '%F' --recursive /usr/local/node | xargs -r strip --strip-unneeded && \
    NODE_RUN_DEPS="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/node \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/node/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" && \
    apk add --update --no-cache --virtual .node-run \
        $NODE_RUN_DEPS \
        ca-certificates && \
    apk del .node-build && \
    rm -rf /usr/local/src

ENV PATH=/usr/local/node/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/node/lib:$LD_LIBRARY_PATH

ENV NPM_VERSION="6.1.0"
ENV YARN_VERSION="1.7.0"

RUN set -xe && \
    npm install -g npm@${NPM_VERSION} && \
    npm install -g yarn@${YARN_VERSION} && \
    find /usr/local/node/lib/node_modules/npm -name test -o -name .bin -type d -print0 | xargs -0 rm -rf && \
    find /usr/local/node/lib/node_modules/yarn -name test -o -name .bin -type d -print0 | xargs -0 rm -rf && \
    rm -rf /root/.npm

# ------------------------------------------------------------------------------
# Application
# ------------------------------------------------------------------------------

RUN apk add --update --no-cache --virtual .ewallet-runtime imagemagick && \
    apk add --update --no-cache --virtual .ewallet-build git build-base && \
    apk add --update --no-cache --virtual .ewallet-lint cmake libressl-dev && \
    gem install pronto pronto-dialyzer pronto-credo --no-document

ARG user=ewallet
ARG group=ewallet
ARG uid=10000
ARG gid=10000

ENV HOME /home/${user}

RUN set -xe && \
    addgroup -g ${gid} ${group} && \
    adduser -D -h ${HOME} -u ${uid} -G ${group} -H ${user} && \
    mkdir -p "${HOME}" && \
    chown "${uid}:${gid}" "${HOME}"

USER ${user}

RUN mix do local.hex --force, local.rebar --force