#!/bin/bash
# shellcheck disable=SC2154,SC2034
# this script contains:
## Download FULL Monorepo (Online + Engine) & Prepare Structure

if ls /usr/local/lib/libPocoCrypto.so.* 1> /dev/null 2>&1; then
  cp /usr/local/lib/libPocoCrypto.so.* /usr/lib/
  cp /usr/local/lib/libPocoXML.so.* /usr/lib/
fi

set -e

# ПЕРЕХВАТ СТАРОГО РЕПОЗИТОРИЯ
if [[ -z "$cool_src_repo" || "$cool_src_repo" == *"CollaboraOnline/online.git"* ]]; then
  cool_src_repo="https://github.com/CollaboraOnline/online.mirror.git"
fi

if [ -d "${cool_dir}/wsd" ] && [ -d "${cool_dir}/engine/include" ]; then
  echo "Full monorepo already exists. Skipping download."
else
  echo "Preparing to download FULL monorepo..."
  echo "NOTE: If download interrupts, just re-run the script. It WILL RESUME!"

  if [ ! -d "${cool_dir}/.git" ]; then
    rm -rf ${cool_dir}
    mkdir -p ${cool_dir}
    cd ${cool_dir}
    git init
    git remote add origin "${cool_src_repo}"
    git config advice.detachedHead false
  else
    cd ${cool_dir}
  fi

  TARGET_REF="${cool_src_tag:-${cool_src_branch:-main}}"

  echo "Fetching '${TARGET_REF}'..."
  if ! git fetch --progress --depth=1 origin "${TARGET_REF}"; then
     echo "!!! DOWNLOAD INTERRUPTED !!! Run the script again to RESUME!"
     return 1
  fi

  echo "Extracting files..."
  git checkout FETCH_HEAD
  chown -R cool:cool ${cool_dir}
  echo "Full monorepo downloaded successfully!"
fi

if [ "${DIST}" = "Debian" ]; then
  if [ "${CODENAME}" = "bullseye" ] || [ "${CODENAME}" = "bookworm" ]; then
    apt-get install libssl-dev -y
  elif [ "${CODENAME}" = "buster" ]; then
    apt-get install libssl-dev -y
  else
    apt-get install nodejs-dev node-gyp libssl1.0-dev npm -y
  fi
else
  apt-get install nodejs libssl-dev -y
fi

set +e
if ! npm -g list jake >/dev/null; then
  npm install -g jake
fi

# Патч для AdminModel.hpp
if [ -f "${cool_dir}/wsd/AdminModel.hpp" ]; then
  if ! grep -q "^#include <list>" "${cool_dir}/wsd/AdminModel.hpp"; then
    sed -i '16a\#include <list>' "${cool_dir}/wsd/AdminModel.hpp"
  fi
fi

set -e
ENGINE_DIR="${cool_dir}/engine"
ENGINE_INSTDIR="${ENGINE_DIR}/instdir"

if [ ! -d "${ENGINE_INSTDIR}/program" ]; then
  if [ -d "${lo_dir}/instdir" ]; then
    echo "Moving pre-compiled engine binaries into the monorepo engine/ folder..."
    mv "${lo_dir}/instdir" "${ENGINE_DIR}/"
    chown -R cool:cool "${ENGINE_INSTDIR}"
    echo "Engine binaries successfully integrated."
  else
    echo "ERROR: Engine binaries not found at ${lo_dir}/instdir."
    return 1
  fi
else
  echo "Engine binaries already in place. Skipping."
fi

set +e
