
FROM nvidia/cuda:11.4.0-devel-ubuntu20.04

WORKDIR /work/cupoch

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y tzdata
ENV TZ Asia/Tokyo

RUN apt-get update && apt-get install -y --no-install-recommends \
         curl \
         build-essential \
         libxinerama-dev \
         libxcursor-dev \
         libglu1-mesa-dev \
         xorg-dev \
         cmake \
         python3-dev \
         python3-setuptools && \
     rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://install.python-poetry.org | python3 -

ENV PATH $PATH:/root/.local/bin

COPY src/python src/python
RUN cd src/python \
    && poetry config virtualenvs.create false \
    && poetry run pip install -U pip wheel conan cmake \
    && poetry install

ENV PYTHONPATH $PYTHONPATH:/usr/lib/python3.8/site-packages

COPY conanfile.py conanfile.py
RUN mkdir build \
    && cd build \
    && conan install .. -of . -c tools.system.package_manager:mode=install

COPY . .
RUN cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
    && make install-pip-package
