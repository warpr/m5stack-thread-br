# Builds the M5Stack Thread Border Router firmware.
#
# This mirrors the `build_examples_m5stack` job in .gitlab-ci.yml:
# it installs the pinned ESP-IDF release used by this example
# (see examples/m5stack_thread_border_router/README.md), builds the
# ESP32-H2 RCP firmware (which gets packed into the BR image), then
# builds the M5Stack Thread Border Router example for ESP32-S3.
#
# Usage:
#   docker build -t m5stack-thread-br .
#   docker run --rm -v "$PWD/out":/out m5stack-thread-br \
#       cp -r examples/m5stack_thread_border_router/build /out
#
# Add a .dockerignore excluding .git and any local build/ directories
# to keep the build context small.

FROM ubuntu:22.04

ARG IDF_BRANCH=release/v5.5
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        git wget flex bison gperf python3 python3-pip python3-venv \
        cmake ninja-build ccache libffi-dev libssl-dev dfu-util \
        libusb-1.0-0 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV IDF_PATH=/opt/esp-idf
ENV IDF_TOOLS_PATH=/opt/esp-idf-tools

# Pinned ESP-IDF release required by the m5stack example (v5.5.4).
RUN git clone --depth=1 --branch "${IDF_BRANCH}" --recursive \
        https://github.com/espressif/esp-idf.git "${IDF_PATH}" \
    && "${IDF_PATH}/install.sh" esp32s3,esp32h2

SHELL ["/bin/bash", "-c"]

WORKDIR /workspace/esp-thread-br
COPY . .
RUN git submodule update --init --recursive

# Build the ESP32-H2 RCP firmware; idf.py automatically packs the
# resulting image into the border router firmware below.
RUN source "${IDF_PATH}/export.sh" \
    && cd "${IDF_PATH}/examples/openthread/ot_rcp" \
    && idf.py set-target esp32h2 \
    && idf.py build

RUN source "${IDF_PATH}/export.sh" \
    && cd examples/m5stack_thread_border_router \
    && idf.py set-target esp32s3 \
    && idf.py build

CMD ["/bin/bash"]
