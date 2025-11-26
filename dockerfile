# Dockerfile
FROM vllm/vllm-openai:v0.10.2

ARG VLLM_VERSION=0.10.2

USER root

# Whisper/transcription braucht in der Praxis sehr oft ffmpeg.
# libsndfile1 ist häufig für Audio-IO hilfreich (je nach Stack).
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg libsndfile1 && \
    rm -rf /var/lib/apt/lists/*
    mkdir -p /cache/huggingface /tmp && \
    chgrp -R 0 /cache /tmp && \
    chmod -R g=u /cache /tmp \
    pip install --no-cache-dir "vllm[audio]==${VLLM_VERSION}"
    

# Installiere vLLM mit Audio-Extras (kein Runtime-Pip mehr)

# OpenShift: random UID + Gruppe 0 -> Verzeichnisse müssen grp-writable sein.
ENV HF_HOME=/cache/huggingface \
    HF_HUB_CACHE=/cache/huggingface/hub \
    TRANSFORMERS_CACHE=/cache/huggingface/transformers \
    XDG_CACHE_HOME=/cache \
    HOME=/tmp

# vLLM Server als EntryPoint, damit du im Deployment nur args mitgibst.
ENTRYPOINT ["python3", "-m", "vllm.entrypoints.openai.api_server"]
CMD ["--help"]
