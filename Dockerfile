# syntax=docker/dockerfile:1
ARG CUDA_VERSION=12.4.1
FROM nvidia/cuda:${CUDA_VERSION}-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# ------------------------------
# OS packages (minimal + practical)
# ------------------------------
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates curl git wget unzip \
      ffmpeg \
      python3.11 python3.11-venv python3.11-distutils \
      python3-pip \
      tini \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    python3.11 -m pip install --no-cache-dir -U pip setuptools wheel

# ------------------------------
# JupyterLab + proxy (environment only; notebooks are user-managed)
# ------------------------------
RUN set -eux; \
    python3.11 -m pip install --no-cache-dir \
      jupyterlab==4.* \
      jupyter-server==2.* \
      jupyter-server-proxy==4.* \
      jupyterlab-git==0.* \
      uv==0.* \
      notebook==7.* \
      jupyter-server-terminals==0.* \
    ;

# Jupyter config: keep it minimal; only proxy menu item is configured here.
COPY jupyter_server_config.py /etc/jupyter/jupyter_server_config.py

# Helper scripts
COPY scripts/start-jupyter.sh /usr/local/bin/start-jupyter
COPY scripts/start-forge-neo.sh /usr/local/bin/start-forge-neo
RUN chmod +x /usr/local/bin/start-jupyter /usr/local/bin/start-forge-neo

# Paperspace expects /notebooks to exist (mounted volume)
RUN mkdir -p /notebooks /workspace
WORKDIR /notebooks

EXPOSE 8888 7860

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["start-jupyter"]
