# Check if Docker is rootless.
# If so, run the container with root user to avoid permission issues with mounted volumes.
if docker info -f "{{println .SecurityOptions}}" | grep -q rootless; then
    echo "Docker running in rootless mode"
    docker run --rm --net=host -u 0:0 -v $(pwd)/output:/output -it humaneval /bin/bash -c "python eval.py"
else
    docker run --rm --net=host -v $(pwd)/output:/output -it humaneval /bin/bash -c "python eval.py"
fi