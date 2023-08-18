FROM ubuntu:latest

# buildroot required packages
RUN apt update && DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends \
  bc \
  build-essential \
  cpio \
  file \
  git \
  ncurses-dev \
  rsync \
  unzip \
  wget \
  && rm -rf /var/lib/apt/lists/*
