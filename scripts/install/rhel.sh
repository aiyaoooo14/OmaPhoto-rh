#!/usr/bin/env bash
# Installs OmaPhoto's latest RPM on EL9 and EL10.
set -euo pipefail
base=https://github.com/aiyaoooo14/OmaPhoto-rh/releases/latest/download
. /etc/os-release
# Rebuilds name their base in ID_LIKE.
case " ${ID:-} ${ID_LIKE:-} " in
*" rhel "* | *" rocky "* | *" almalinux "* | *" centos "*) ;;
*)
    echo "This script is for RHEL, Rocky Linux, AlmaLinux or CentOS; this system is ${PRETTY_NAME:-unknown}." >&2
    exit 1
    ;;
esac
if [ "$(uname -m)" != x86_64 ]; then
    echo "OmaPhoto's packages are built for x86_64 alone." >&2
    exit 1
fi
# Each major release names its own RPM.
major=${VERSION_ID:-}
major=${major%%.*}
case "$major" in
9) package=omaphoto-el9.x86_64.rpm ;;
10) package=omaphoto-el10.x86_64.rpm ;;
*)
    echo "This script is for EL9 and EL10; this system is ${PRETTY_NAME:-unknown}." >&2
    exit 1
    ;;
esac
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
fetch() {
    if command -v curl >/dev/null 2>&1; then
        curl -fL --proto '=https' -o "$2" "$1"
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$2" "$1"
    else
        echo "This script needs curl or wget to download the package." >&2
        exit 1
    fi
}
fetch "$base/$package" "$work/$package"
fetch "$base/SHA256SUMS" "$work/SHA256SUMS"
# The package must match the checksum published beside it.
(cd "$work" && grep " $package\$" SHA256SUMS | sha256sum -c -)
# Dependencies come from the base repos and EPEL; CRB needs a nudge.
if ! sudo dnf install -y "$work/$package"; then
    echo "dnf could not resolve the dependencies; enable EPEL and CRB, then rerun:" >&2
    echo "  sudo dnf install epel-release"
    if [ "$major" = 9 ]; then
        # EL9's dnf4 spells the switch with dashes.
        if [ "${ID:-}" = rhel ]; then
            # RHEL itself reaches CRB through subscription-manager.
            echo "  sudo subscription-manager repos --enable codeready-builder-for-rhel-9-x86_64-rpms"
        else
            echo "  sudo dnf config-manager --set-enabled crb"
        fi
    else
        # EL10's dnf5 drops the dashes.
        echo "  sudo dnf config-manager set-enabled crb"
    fi
    exit 1
fi
# EL's own libheif decodes no HEVC; RPM Fusion's does (the same name on EL9 and EL10).
if ! rpm -q libheif-freeworld >/dev/null 2>&1; then
    echo "HEIC import needs RPM Fusion's libheif-freeworld: https://rpmfusion.org/Configuration, then sudo dnf install libheif-freeworld"
fi
