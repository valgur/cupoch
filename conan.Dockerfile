FROM nvidia/cuda:11.4.0-devel-ubuntu20.04

WORKDIR /work/cupoch

ENV DEBIAN_FRONTEND noninteractive
ENV TZ Asia/Tokyo
RUN apt-get update && apt-get install -y --no-install-recommends \
         curl \
         build-essential \
         libxinerama-dev \
         libxcursor-dev \
         libglu1-mesa-dev \
         xorg-dev \
         cmake \
         tzdata \
         python3-dev \
         python3-setuptools \
         python3-pip && \
     rm -rf /var/lib/apt/lists/*

ENV PATH $PATH:/root/.local/bin

RUN python3 -m pip install -U wheel conan cmake

COPY . .
RUN conan create . -c tools.system.package_manager:mode=install
