#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/workspace/dlang"
INSTALL_SH="${INSTALL_DIR}/install.sh"

mkdir -p "${INSTALL_DIR}"

if command -v curl >/dev/null 2>&1; then
    curl -fsSL https://dlang.org/install.sh -o "${INSTALL_SH}"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "${INSTALL_SH}" https://dlang.org/install.sh
else
    echo "Error: Please install curl or wget." >&2
    exit 1
fi

chmod +x "${INSTALL_SH}"

"${INSTALL_SH}" install dmd,dub

ACTIVATE_PATH="$("${INSTALL_SH}" dmd -a)"

RCFILE="${HOME}/.bashrc"
if ! grep -Fxq "source ${ACTIVATE_PATH}" "${RCFILE}"; then
    echo '' >> "${RCFILE}"
    echo "# Auto-activate D environment" >> "${RCFILE}"
    echo "source ${ACTIVATE_PATH}" >> "${RCFILE}"
fi

source "${ACTIVATE_PATH}"

echo "DMD version: $(dmd --version)"
echo "DUB version: $(dub --version)"
echo "Installation and setup complete."