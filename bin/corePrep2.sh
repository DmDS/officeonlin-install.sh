#!/bin/bash
# shellcheck disable=SC2154,SC2034
# this script contains:
## Download & install LibreOffice Engine Assets (Monorepo architecture)

if [ -d "${lo_dir}/instdir" ]; then
  echo "LibreOffice Engine assets already exist in ${lo_dir}/instdir. Skipping download."
  chown -R cool:cool ${lo_dir}
  return 0
fi

echo "Engine assets not found or incomplete. Preparing to download..."
set -e
rm -rf ${lo_dir}

echo
echo "Downloading LibreOffice Engine assets (414 MB, this might take a while) ..."
mkdir -p ${lo_dir}
cd ${lo_dir}

ENGINE_ASSET="engine-main-assets.tar.gz"
ASSET_URL="https://github.com/CollaboraOnline/online/releases/download/for-code-assets/${ENGINE_ASSET}"

wget "${ASSET_URL}" -q --show-progress --progress=bar:force

if [ ! -f "${ENGINE_ASSET}" ]; then
  echo "ERROR: Failed to download ${ENGINE_ASSET}."
  return 1
fi

chown -R cool:cool ${lo_dir}
echo
echo "Unpacking ..."
tar xf ${ENGINE_ASSET}
rm ${ENGINE_ASSET}
set +e
