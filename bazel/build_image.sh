#!/usr/bin/env bash
set -euo pipefail

cd "${BUILD_WORKSPACE_DIRECTORY:?missing BUILD_WORKSPACE_DIRECTORY}"

IMAGE_REPO="${IMAGE_REPO:-ghcr.io/carverauto/codeline}"
IMAGE_TAG="${IMAGE_TAG:-dev}"
IMAGE_PLATFORM="${IMAGE_PLATFORM:-linux/amd64}"

./bazel/build_release.sh

docker build \
  --platform "${IMAGE_PLATFORM}" \
  -f docker/Dockerfile \
  -t "${IMAGE_REPO}:${IMAGE_TAG}" \
  .

echo "Built image ${IMAGE_REPO}:${IMAGE_TAG}"
