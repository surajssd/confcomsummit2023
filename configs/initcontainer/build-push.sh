#!/bin/bash

set -euo pipefail

# Use the image name provided by the user or use the default one.
IMAGE_NAME="${IMAGE_NAME:-quay.io/surajd/inference-model-setup}"
TIMESTAMP=$(date '+%Y-%m-%d-%H-%M-%S')

docker build --push -t "${IMAGE_NAME}:latest" -t "${IMAGE_NAME}:${TIMESTAMP}" -f Dockerfile ..

echo "Image available at:"
echo "${IMAGE_NAME}:latest"
echo "${IMAGE_NAME}:${TIMESTAMP}"
