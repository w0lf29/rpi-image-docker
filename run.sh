#!/bin/bash

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed. Please install it before proceeding."
    exit 1
fi

# Define variables for service and commands
SERVICE_NAME="rpi-imagegen"
BUILD_COMMAND="./build.sh -D ./parameters/slim/ -c pi5-slim -o ./parameters/slim/my.options"
RSYNC_COMMAND="rsync -a /home/imagegen/rpi-image-gen/work/deb12-slim/deploy/deb12-slim.img /home/imagegen/rpi-image-gen/output"

# Ensure the Docker Compose service exists
if ! docker-compose config --services | grep -q "^${SERVICE_NAME}$"; then
    echo "Error: Service '${SERVICE_NAME}' not found in Docker Compose configuration."
    exit 1
fi

echo "Running service ${SERVICE_NAME} with Docker Compose..."
docker-compose run --rm -it "${SERVICE_NAME}" bash -c "
    echo 'Running build.sh command...';
    ${BUILD_COMMAND} || { echo 'Build command failed.'; exit 1; };
    echo 'Running rsync command...';
    ${RSYNC_COMMAND} || { echo 'Rsync command failed.'; exit 1; };
    echo 'All commands executed successfully.';
"
"