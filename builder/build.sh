#!/bin/sh
## Builder script for omisegoimages/ewallet-builder.
## This script is being used instead of multi-stage build to leverage layer
## caching of builder images via `docker load` and `docker save`.

BASE_DIR=$(cd "$(dirname "$0")/" || exit; pwd -P)
BASE_IMAGES="base erlang elixir node python3"
CACHE_FILENAME="docker-layers.tar"

## We require the IMAGE_NAME is passed as arguments to the shell script.
## The name of base builder images will be derived from this name.

IMAGE_NAME="$1"

if [ -z "$IMAGE_NAME" ]; then
    printf "Usage: %s image_name [cache_dir]\\n" "$0"
    exit 1
fi

## If cache directory is also provided, make sure we make use of it.
## Ignore if layer cache could not be loaded as we will recreate the
## cache upon successful build. (Although this require full rebuild)

CACHE_DIR="$2"

if [ -n "$CACHE_DIR" ] && [ -d "$CACHE_DIR" ]; then
    docker load -i "$CACHE_DIR/$CACHE_FILENAME" || true
fi

## Build base images in order they're defined; sometimes base image
## has dependencies on each other.

BASE_IMAGE_NAMES=""

for i in $BASE_IMAGES; do
    BASE_IMAGE_NAMES="$IMAGE_NAME-$i $BASE_IMAGE_NAMES"
    if ! docker build \
           --cache-from "$IMAGE_NAME-$i" \
           --build-arg "PREFIX=$IMAGE_NAME" \
           -t "$IMAGE_NAME-$i" \
           -f "$BASE_DIR/Dockerfile.$i" \
           "$BASE_DIR/"; then
        printf "Build failed!\\n"
        exit 1
    fi
done

## Build the actual image.
## Exit immediately if the build failed.

if ! docker build \
       --cache-from "$IMAGE_NAME" \
       --build-arg "PREFIX=$IMAGE_NAME" \
       -t "$IMAGE_NAME" \
       -f "$BASE_DIR/Dockerfile" \
       "$BASE_DIR/"; then
   printf "Build failed!\\n"
   exit 1
fi

## If cache directory is also provided, make sure to save the resulting
## artifacts into cache. Need to disable SC2086 here because we need
## argument splitting.

# shellcheck disable=SC2086
if [ -n "$CACHE_DIR" ] && [ -d "$CACHE_DIR" ]; then
    docker save \
      -o "$CACHE_DIR/$CACHE_FILENAME" \
      $IMAGE_NAME \
      $BASE_IMAGE_NAMES
fi
