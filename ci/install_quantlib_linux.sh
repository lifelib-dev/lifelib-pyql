#!/usr/bin/env bash
# Install QuantLib (shared library) inside the manylinux_2_28 container.
# Called by cibuildwheel via CIBW_BEFORE_ALL_LINUX.
set -euo pipefail

QUANTLIB_VERSION="${QUANTLIB_VERSION:-1.41}"

echo "==> Installing build tools"
yum install -y cmake gcc-c++ wget boost-devel

echo "==> Downloading QuantLib ${QUANTLIB_VERSION}"
cd /tmp
wget -q "https://github.com/lballabio/QuantLib/releases/download/v${QUANTLIB_VERSION}/QuantLib-${QUANTLIB_VERSION}.tar.gz"
tar xzf "QuantLib-${QUANTLIB_VERSION}.tar.gz"

echo "==> Building QuantLib ${QUANTLIB_VERSION} (shared library)"
cd "QuantLib-${QUANTLIB_VERSION}"
mkdir -p build && cd build
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DQL_BUILD_BENCHMARK=OFF \
    -DQL_BUILD_EXAMPLES=OFF \
    -DQL_BUILD_TEST_SUITE=OFF
cmake --build . -j"$(nproc)"
cmake --install .

echo "==> Updating ldconfig"
ldconfig

echo "==> QuantLib installed successfully"
ls -la /usr/local/lib/libQuantLib*
