# Dockerfile
FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    sshpass \
    git \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Ansible via pip
RUN pip install ansible

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Set working directory
WORKDIR /ansible

# (Optional) Copy your Ansible code into the image if you want a baked-in version
# COPY . /ansible

# Default command (for testing purposes)
CMD ["ansible-playbook", "--version"]

