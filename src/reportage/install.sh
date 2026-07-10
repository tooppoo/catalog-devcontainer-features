#!/bin/sh
set -eu

REPO="tooppoo/reportage"
INSTALLER_URL="https://raw.githubusercontent.com/${REPO}/main/install.sh"

REPORTAGE_VERSION="${VERSION:-latest}"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

main() {
    check_supported_distribution
    install_packages
    run_installer
}

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
            echo_stderr "Unsupported distribution: reportage Feature v0 supports Debian/Ubuntu based images only."
            echo_stderr "Detected ID='${distribution}' ID_LIKE='${distribution_like}'."
            exit 1
            ;;
    esac
}

install_packages() {
    if ! command -v apt-get >/dev/null 2>&1; then
        echo_stderr "Unsupported distribution: apt-get is required for reportage Feature v0."
        exit 1
    fi

    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends \
        ca-certificates \
        coreutils \
        curl \
        grep \
        gzip \
        mawk \
        tar
    rm -rf /var/lib/apt/lists/*
}

normalize_reportage_version() {
    version="$1"

    case "${version}" in
        "")
            echo_stderr "Invalid reportage version: version must not be empty."
            exit 1
            ;;
        latest)
            printf '%s\n' "latest"
            return 0
            ;;
    esac

    if printf '%s' "${version}" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+([-.+][0-9A-Za-z.-]+)?$'; then
        printf 'v%s\n' "${version}"
        return 0
    fi

    printf '%s\n' "${version}"
}

run_installer() {
    normalized_version="$(normalize_reportage_version "${REPORTAGE_VERSION}")"

    set -- --install-dir "${INSTALL_DIR}"

    if [ "${normalized_version}" != "latest" ]; then
        set -- "$@" --version "${normalized_version}"
    fi

    tmp_installer="$(mktemp)"
    cleanup() {
        rm -f "${tmp_installer}"
    }
    trap cleanup EXIT HUP INT TERM

    echo "Installing reportage from ${INSTALLER_URL}"
    # Intentionally delegates release resolution and checksum verification to
    # reportage's upstream installer. This Feature only normalizes user-facing
    # version input and prepares the Debian/Ubuntu runtime dependencies.
    curl -fsSL "${INSTALLER_URL}" -o "${tmp_installer}"
    sh "${tmp_installer}" "$@"
}

main
