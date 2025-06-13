git submodule update --init --recursive
docker build -f vllm/docker/Dockerfile.cpu --tag vllm-cpu-env --target vllm-openai ./vllm

# Launch VLLM server
docker run --rm \
             --privileged=true \
             --shm-size=4g \
             -p 8000:8000 \
             -e VLLM_CPU_KVCACHE_SPACE=2 \
             -e VLLM_CPU_OMP_THREADS_BIND=16 \
             vllm-cpu-env \
             --model=Qwen/Qwen2.5-Coder-0.5B-Instruct \
             --dtype=bfloat16