#!/bin/bash
set -e

UBUNTU_VERSION=${1:-24.04}
CUDA_TAG=${2:-}
BASE_IMAGE="ubuntu:${UBUNTU_VERSION}"

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
DOCKERFILE_DIR="${SCRIPT_DIR}/ubuntu-desktop/${UBUNTU_VERSION}"

if [ ! -d "$DOCKERFILE_DIR" ]; then
    echo "Error: unsupported Ubuntu version ${UBUNTU_VERSION}"
    exit 1
fi

BUILD_ARGS="--build-arg BASE_IMAGE=${BASE_IMAGE}"

if [ -n "$CUDA_TAG" ]; then
    CUDA_BASE="nvidia/cuda:${CUDA_TAG}-runtime-ubuntu${UBUNTU_VERSION}"
    BUILD_ARGS="${BUILD_ARGS} --build-arg CUDA_BASE=${CUDA_BASE}"
fi

IMAGE_NAME="ubuntu-desktop:${UBUNTU_VERSION}"
[ -n "$CUDA_TAG" ] && IMAGE_NAME="${IMAGE_NAME}-cuda-${CUDA_TAG}"

DOCKER_BUILDKIT=1 docker build \
    -t "${IMAGE_NAME}" \
    -f "${DOCKERFILE_DIR}/Dockerfile" \
    ${BUILD_ARGS} \
    "${SCRIPT_DIR}"
