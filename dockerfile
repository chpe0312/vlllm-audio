# Dockerfile
FROM vllm/vllm-openai:v0.10.2

ARG VLLM_VERSION=0.10.2

USER root


RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg libsndfile1 && \
    rm -rf /var/lib/apt/lists/*


RUN pip install --no-cache-dir "vllm[audio]==${VLLM_VERSION}"


ENV HF_HOME=/cache/huggingface \
    HF_HUB_CACHE=/cache/huggingface/hub \
    TRANSFORMERS_CACHE=/cache/huggingface/transformers \
    XDG_CACHE_HOME=/cache \
    HOME=/tmp

RUN mkdir -p /cache/huggingface /tmp && \
    chgrp -R 0 /cache /tmp && \
    chmod -R g=u /cache /tmp

ENTRYPOINT ["python3", "-m", "vllm.entrypoints.openai.api_server"]
CMD ["--help"]
