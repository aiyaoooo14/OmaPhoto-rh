#!/usr/bin/env bash
# Installs OmaPhoto's latest RPM on RHEL 10 and rebuilds.
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
major=${VERSION_ID:-}
major=${major%%.*}
case "$major" in
10) package=omaphoto-el10.x86_64.rpm ;;
9)
    echo "EL9 is not supported yet; the OmaPhoto RHEL package targets EL10 for now." >&2
    exit 1
    ;;
*)
    echo "This script supports EL10 alone; this system is ${PRETTY_NAME:-unknown}." >&2
    exit 1
    ;;
esac
if [ "$(uname -m)" != x86_64 ]; then
    echo "OmaPhoto's packages are built for x86_64 alone." >&2
    exit 1
fi
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
# Dependencies come from the base repos and EPEL.
if ! sudo dnf install -y "$work/$package"; then
    echo "dnf could not resolve the dependencies; confirm EPEL is enabled: sudo dnf install epel-release" >&2
    exit 1
fi
# EL's own libheif decodes no HEVC; RPM Fusion's does.
if ! rpm -q libheif-freeworld >/dev/null 2>&1; then
    echo "HEIC import needs RPM Fusion's libheif-freeworld: https://rpmfusion.org/Configuration, then sudo dnf install libheif-freeworld"
fi
