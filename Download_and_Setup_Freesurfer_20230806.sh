#!/bin/bash

# work log
# 11-09-2022: wrote the script
# 01-02-2023: tried installing freesurfer beta
# 06-08-2023: now the latest freesurfer version is 7.4.1.

set -euo pipefail

# prep
VERSION="7.4.1" # change here if you need to roll back or use some other versions
TARBALL="freesurfer-Linux-centos6_x86_64-stable-pub-v${VERSION}.tar.gz"
URL="https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/${VERSION}/${TARBALL}"
INSTALL_BASE="${HOME}"
INSTALL_DIR="${INSTALL_BASE}/freesurfer-${VERSION}"
SHELL_RC="${HOME}/.bashrc"

# where should the freesurfer folder go? i recommend /Users/username/
mkdir -p "${INSTALL_BASE}"

# check if it's already there
if [ ! -f "${INSTALL_BASE}/${TARBALL}" ]; then
  wget -c "${URL}" -O "${INSTALL_BASE}/${TARBALL}"
fi

# decomp
tar -xzf "${INSTALL_BASE}/${TARBALL}" -C "${INSTALL_BASE}"

# move to versioned directory
mv "${INSTALL_BASE}/freesurfer" "${INSTALL_DIR}"

# you need to have a license! register at the freesurfer website and get the license text file
if [ ! -f "${INSTALL_DIR}/license.txt" ]; then
  echo "copy your freesurfer license file to ${INSTALL_DIR}/license.txt"
fi

# Environment setup in .bashrc
if ! grep -q "FREESURFER_HOME" "${SHELL_RC}"; then
  {
    echo ""
    echo "# FreeSurfer ${VERSION} setup"
    echo "export FREESURFER_HOME=\"${INSTALL_DIR}\""
    echo "source \"\${FREESURFER_HOME}/setup.sh\""
  } >> "${SHELL_RC}"
  echo "environment variables added to ${SHELL_RC}"
fi

echo "freesurfer ${VERSION} installed in ${INSTALL_DIR}"
echo "restart your shell or run 'source ${SHELL_RC}' to activate"
