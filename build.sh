#!/bin/bash

set -xeuo pipefail

cd $(dirname $0)
mkdir resource-types-tmp

GOLANG_DOCKER_IMAGE_TAG=1.17.8-alpine3.15
ALPINE_BASE_IMAGE_TAG=3.15.0

# Clone the resources we want to be build into the worker
git clone --depth 1 --branch v1.5.0 https://github.com/concourse/registry-image-resource.git resource-types-tmp/registry-image-resource
git clone --depth 1 --branch v1.6.2 https://github.com/concourse/docker-image-resource resource-types-tmp/docker-image-resource
git clone --depth 1 --branch v1.2.0 https://github.com/concourse/s3-resource.git resource-types-tmp/s3-resource

mkdir -p resource-types/{registry-image,docker-image,s3}

docker build -t registry-image-resource \
   --build-arg base-image=alpine:$ALPINE_BASE_IMAGE_TAG \
   --build-arg builder_image=golang:$GOLANG_DOCKER_IMAGE_TAG \
   -f resource-types-tmp/registry-image-resource/dockerfiles/alpine/Dockerfile \
   resource-types-tmp/registry-image-resource

docker build -t docker-image-resource \
   --build-arg base-image=alpine:$ALPINE_BASE_IMAGE_TAG \
   --build-arg builder_image=golang:$GOLANG_DOCKER_IMAGE_TAG \
   -f resource-types-tmp/docker-image-resource/dockerfiles/alpine/Dockerfile \
   resource-types-tmp/docker-image-resource

docker build -t s3-resource \
   --build-arg base-image=alpine:$ALPINE_BASE_IMAGE_TAG \
   --build-arg builder_image=golang:$GOLANG_DOCKER_IMAGE_TAG \
   -f resource-types-tmp/s3-resource/dockerfiles/alpine/Dockerfile \
   resource-types-tmp/s3-resource

docker export registry-image-resource | gzip \
  > resource-types/registry-image/rootfs.tgz
docker export docker-image-resource | gzip \
  > resource-types/docker-image/rootfs.tgz
docker export s3-resource | gzip \
  > resource-types/s3/rootfs.tgz

#docker build -t concourse-arm-worker .
