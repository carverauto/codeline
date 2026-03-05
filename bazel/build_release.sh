#!/usr/bin/env bash
set -euo pipefail

cd "${BUILD_WORKSPACE_DIRECTORY:?missing BUILD_WORKSPACE_DIRECTORY}"

IMAGE_PLATFORM="${IMAGE_PLATFORM:-linux/amd64}"
ELIXIR_IMAGE="${ELIXIR_IMAGE:-hexpm/elixir:1.19.4-erlang-28.3-debian-bookworm-20251208-slim}"

docker run --rm \
  --platform "${IMAGE_PLATFORM}" \
  --user "$(id -u):$(id -g)" \
  -e MIX_ENV=prod \
  -e HOME=/tmp \
  -v "${PWD}:/workspace" \
  -w /workspace \
  "${ELIXIR_IMAGE}" \
  sh -lc '
    mix local.hex --force >/dev/null &&
    mix local.rebar --force >/dev/null &&
    mix deps.get &&
    rm -rf dist/release/codeline &&
    mix release --path dist/release/codeline
  '

echo "Built Elixir release at dist/release/codeline"
