#!/bin/bash

set -euo pipefail

cd $(dirname $0)
mkdir -p resource-types-tmp

GOLANG_DOCKER_IMAGE_TAG=1.17.8-alpine3.15
ALPINE_BASE_IMAGE_TAG=3.15.0

# Clone the resources we want to be build into the worker
git clone --depth 1 --branch v1.5.0 https://github.com/concourse/registry-image-resource.git resource-types-tmp/registry-image-resource
git clone --depth 1 --branch v1.6.2 https://github.com/concourse/docker-image-resource resource-types-tmp/docker-image-resource
git clone --depth 1 --branch v1.2.0 https://github.com/concourse/s3-resource.git resource-types-tmp/s3-resource
git clone --depth 1 --branch v1.14.5  https://github.com/concourse/git-resource.git resource-types-tmp/git-resource

RESOURCES="registry-image docker-image s3 git"

for i in $RESOURCES; do

   # Clone the resources we want to be build into the worker
   mkdir -p resource-types/$i

   # Build the docker images
   docker build -t ${i}-resource \
      --build-arg base-image=alpine:$ALPINE_BASE_IMAGE_TAG \
      --build-arg builder-image=golang:$GOLANG_DOCKER_IMAGE_TAG \
      -f resource-types-tmp/${i}-resource/dockerfiles/alpine/Dockerfile \
      resource-types-tmp/${i}-resource

   # Create a container from the image
   docker create --name ${i} ${i}-resource
   docker export ${i} | gzip \
      > resource-types/${i}/rootfs.tgz
   docker rm -v ${i}

done

#rm -rf resource-types-tmp
#docker build -t concourse-arm-worker .
