#!/bin/sh
set -eu

REPO="tooppoo/git-kura"
INSTALLER_URL="https://raw.githubusercontent.com/${REPO}/main/install.sh"

GIT_KURA_VERSION="${VERSION:-latest}"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
REQUIRE_SIGNATURE="${REQUIRE_SIGNATURE:-false}"

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

normalize_git_kura_version() {
    version="$1"

    case "${version}" in
        latest)
            printf '%s\n' "latest"
            return 0
            ;;
    esac

    if printf '%s' "${version}" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$'; then
        printf '%s\n' "${version}"
        return 0
    fi

    if printf '%s' "${version}" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
        printf 'v%s\n' "${version}"
        return 0
    fi

    echo_stderr "Invalid git-kura version: ${version}."
    echo_stderr "Use 'latest', a release tag such as 'v0.0.6', or a bare semantic version such as '0.0.6'."
    exit 1
}

run_installer() {
    normalized_version="$(normalize_git_kura_version "${GIT_KURA_VERSION}")"

    set -- --install-dir "${INSTALL_DIR}"

    if [ "${normalized_version}" != "latest" ]; then
        set -- "$@" --version "${normalized_version}"
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
    # This Feature normalizes user-facing version input before delegating.
    curl -fsSL "${INSTALLER_URL}" | sh -s -- "$@"
}

main
