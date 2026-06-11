#!/bin/sh
set -eu

REPO="tooppoo/git-kura"
INSTALLER_URL="https://raw.githubusercontent.com/${REPO}/main/install.sh"

GIT_KURA_VERSION="${VERSION:-latest}"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
REQUIRE_SIGNATURE="${REQUIRE_SIGNATURE:-false}"

echo_stderr() {
    echo "$@" >&2
}

check_supported_distribution() {
    if [ ! -r /etc/os-release ]; then
        echo_stderr "Unsupported distribution: /etc/os-release was not found."
        exit 1
    fi

    # shellcheck disable=SC1091
    . /etc/os-release

    distribution="${ID:-}"
    distribution_like="${ID_LIKE:-}"

    case "${distribution} ${distribution_like}" in
        *debian*|*ubuntu*) ;;
        *)
            echo_stderr "Unsupported distribution: git-kura Feature v0 supports Debian/Ubuntu based images only."
            echo_stderr "Detected ID='${distribution}' ID_LIKE='${distribution_like}'."
            exit 1
            ;;
    esac
}

install_packages() {
    if ! command -v apt-get >/dev/null 2>&1; then
        echo_stderr "Unsupported distribution: apt-get is required for git-kura Feature v0."
        exit 1
    fi

    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends ca-certificates curl git tar
    rm -rf /var/lib/apt/lists/*
}

run_installer() {
    set -- --install-dir "${INSTALL_DIR}"

    if [ "${GIT_KURA_VERSION}" != "latest" ]; then
        set -- "$@" --version "${GIT_KURA_VERSION}"
    fi

    case "${REQUIRE_SIGNATURE}" in
        true|1|yes)
            set -- "$@" --require-signature
            ;;
        false|0|no)
            ;;
        *)
            echo_stderr "Invalid require_signature value: ${REQUIRE_SIGNATURE}. Use true or false."
            exit 1
            ;;
    esac

    echo "Installing git-kura from ${INSTALLER_URL}"
    # Intentionally calls the upstream installer so release resolution,
    # checksums, and optional signature verification stay owned by git-kura.
    curl -fsSL "${INSTALLER_URL}" | sh -s -- "$@"
}

check_supported_distribution
install_packages
run_installer
