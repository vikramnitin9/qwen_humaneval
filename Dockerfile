FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt -y update
RUN apt install -y wget git

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add a non-root user with the same UID and GID as the host user
ARG USER_ID
ARG GROUP_ID
RUN if ! getent group ${GROUP_ID}; then \
    groupadd -g ${GROUP_ID} appuser; \
    fi && \
    useradd -m -u ${USER_ID} -g ${GROUP_ID} appuser

RUN mkdir -p /opt/miniconda3 && \
    chown -R ${USER_ID}:${GROUP_ID} /opt/miniconda3

# Set the non-root user as the owner of the /app directory
RUN mkdir -p /app && \
    chown -R ${USER_ID}:${GROUP_ID} /app

# Switch to the non-root user
USER appuser
WORKDIR /app

ENV PATH="/opt/miniconda3/bin:${PATH}"

# Install Miniconda on x86 or ARM platforms
RUN arch=$(uname -m) && \
    if [ "$arch" = "x86_64" ]; then \
    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"; \
    elif [ "$arch" = "aarch64" ]; then \
    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"; \
    else \
    echo "Unsupported architecture: $arch"; \
    exit 1; \
    fi && \
    wget $MINICONDA_URL -O miniconda.sh && \
    mkdir -p /opt/miniconda3 && \
    bash miniconda.sh -b -u -p /opt/miniconda3 && \
    rm -f miniconda.sh

RUN conda install -y python=3.10 pip

RUN git clone https://github.com/openai/human-eval
RUN pip install -e human-eval
RUN pip install requests

COPY --chown=${USER_ID}:${GROUP_ID} proj/ /app/proj/
COPY --chown=${USER_ID}:${GROUP_ID} eval.py /app/eval.py
COPY --chown=${USER_ID}:${GROUP_ID} inference.py /app/inference.py