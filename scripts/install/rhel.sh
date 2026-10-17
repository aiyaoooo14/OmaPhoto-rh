#!/usr/bin/env bash
# Installs OmaPhoto's latest RPM on EL9 and EL10.
set -euo pipefail
base=https://github.com/aiyaoooo14/OmaPhoto-rh/releases/latest/download
. /etc/os-release
case " ${ID:-} ${ID_LIKE:-} " in
*" rhel "* | *" rocky "* | *" almalinux "* | *" centos "*) ;;
*)
    echo "This script is for RHEL, Rocky, AlmaLinux or CentOS; this system is ${PRETTY_NAME:-unknown}." >&2
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
curl -fL --proto '=https' -o "$work/$package" "$base/$package"
curl -fsSL --proto '=https' -o "$work/SHA256SUMS" "$base/SHA256SUMS"
# The package must match the checksum published beside it.
(cd "$work" && grep " $package\$" SHA256SUMS | sha256sum -c -)
sudo dnf install "$work/$package"
# EL's own libheif decodes no HEVC; RPM Fusion's does.
echo "HEIC import needs RPM Fusion free's libheif-freeworld (the same name on EL9 and EL10): enable RPM Fusion, then sudo dnf install libheif-freeworld"
# Missing dependencies come from EPEL and CRB.
echo "If dependencies are missing, enable EPEL and CRB, then rerun:"
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
