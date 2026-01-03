# ----------------------------------------------------------------------------
# Image for Paperspace Notebook (GPU) - Stable Diffusion Forge Neo Suite
# - Base: NVIDIA CUDA 12.4.1 (Ubuntu 22.04)
# - Package Manager: micromamba (conda-compatible) + uv
# - Optimization: FlashAttention-2, SageAttention
# ----------------------------------------------------------------------------
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

LABEL maintainer="YourName <your@email.com>"

# ------------------------------
# 1. Build-time and runtime settings
# ------------------------------
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    SHELL=/bin/bash \
    MAMBA_ROOT_PREFIX=/opt/conda \
    # Forge Neo Speed Optimizations (A4000 = Ampere 8.6)
    CUDA_HOME=/usr/local/cuda \
    TORCH_CUDA_ARCH_LIST="8.6" \
    FORCE_CUDA="1" \
    PIP_NO_CACHE_DIR=1

# ------------------------------
# 2. System packages
# ------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget git nano vim zip unzip tzdata build-essential \
    libgl1 libglib2.0-0 libgoogle-perftools4 \
    ffmpeg bzip2 pkg-config \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------
# 3. Micromamba & Python 3.11 environment
# ------------------------------
RUN set -ex; \
    arch=$(uname -m); \
    if [ "$arch" = "x86_64" ]; then arch="linux-64"; fi; \
    if [ "$arch" = "aarch64" ]; then arch="linux-aarch64"; fi; \
    curl -Ls "https://micro.mamba.pm/api/micromamba/${arch}/latest" -o /tmp/micromamba.tar.bz2; \
    tar -xj -C /usr/local/bin/ --strip-components=1 -f /tmp/micromamba.tar.bz2 bin/micromamba; \
    rm /tmp/micromamba.tar.bz2; \
    \
    # Create management root
    mkdir -p $MAMBA_ROOT_PREFIX; \
    export MAMBA_ROOT_PREFIX=$MAMBA_ROOT_PREFIX; \
    micromamba shell init -s bash; \
    \
    # Create isolated Python environment (pyenv)
    micromamba create -y -n pyenv -c conda-forge python=3.11; \
    micromamba clean -a -y

# ------------------------------
# 4. Environment path settings
# ------------------------------
# Ensure 'pyenv' is the primary Python environment
ENV PATH=$MAMBA_ROOT_PREFIX/envs/pyenv/bin:$PATH

# ------------------------------
# 5. Core ML libraries & Jupyter
# ------------------------------
# PyTorch (Matching Forge Neo recommendation)
RUN micromamba run -n pyenv pip install \
    torch==2.4.1+cu124 torchvision==0.19.1+cu124 torchaudio==2.4.1+cu124 \
    --index-url https://download.pytorch.org/whl/cu124

# JupyterLab and Proxy extensions
RUN micromamba run -n pyenv pip install \
    jupyterlab notebook jupyter-server-proxy \
    xformers==0.0.28.post1 \
    ninja

# ------------------------------
# 6. Forge Neo specialized tools
# ------------------------------
# Install 'uv' for faster package management
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /usr/local/bin/uv

# Install Optimization Libs
# Note: FlashAttention build might fail on GitHub Actions free tier (7GB RAM limit)
RUN micromamba run -n pyenv pip install flash-attn --no-build-isolation
RUN micromamba run -n pyenv pip install sageattention

# ------------------------------
# 7. Application & Proxy Configuration
# ------------------------------
# Configure Jupyter Server Proxy for Forge Neo
COPY jupyter_server_config.py /etc/jupyter/jupyter_server_config.py

# ------------------------------
# 8. Entrypoint & Workspace setup
# ------------------------------
WORKDIR /notebooks
COPY scripts/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose Jupyter port
EXPOSE 8888

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default: Launch JupyterLab
CMD ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--ServerApp.token=", "--ServerApp.password="]
