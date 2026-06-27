#!/bin/bash
# shellcheck disable=SC2154,SC2034
set -e

if ! command -v cmake &> /dev/null; then
  echo "CMake is required to build modern Poco but not found. Installing..."
  apt-get install cmake -y
fi

POCO_BUILD_DIR="/opt/poco-1.15.3-all"

cd ${POCO_BUILD_DIR} || exit 1

echo "Configuring Poco with CMake..."
sudo -Hu cool bash -c "cd ${POCO_BUILD_DIR} && mkdir -p build && cd build && cmake .. \
  -DPOCO_ENABLE_SAMPLES=OFF \
  -DPOCO_ENABLE_TESTS=OFF \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local"

echo "Building Poco (this will take a few minutes)..."
sudo -Hu cool make -C ${POCO_BUILD_DIR}/build -j${cpu}

echo "Installing Poco..."
make -C ${POCO_BUILD_DIR}/build install
ldconfig

set +e
