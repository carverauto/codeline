#!/usr/bin/env bash
set -euo pipefail

cd "${BUILD_WORKSPACE_DIRECTORY:?missing BUILD_WORKSPACE_DIRECTORY}"

IMAGE_REPO="${IMAGE_REPO:-ghcr.io/carverauto/codeline}"
IMAGE_TAG="${IMAGE_TAG:-dev}"
IMAGE_PLATFORM="${IMAGE_PLATFORM:-linux/amd64}"

IMAGE_PLATFORM="${IMAGE_PLATFORM}" ./bazel/build_image.sh

docker push "${IMAGE_REPO}:${IMAGE_TAG}"

echo "Pushed image ${IMAGE_REPO}:${IMAGE_TAG}"
