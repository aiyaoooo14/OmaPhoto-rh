# A supported Rocky, 10 unless named; EPEL, RPM Fusion, and CRB.
ARG RELEASE=10
# el10 builds on the system GCC 14. The official library stops at 9.3; Rocky's
# own org namespace carries 10, and quay.io rate-limits runner IPs.
FROM rockylinux/rockylinux:10.2 AS el10
RUN dnf -y install epel-release curl \
    && dnf -y install https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-10.noarch.rpm \
    && dnf -y --enablerepo=crb install gcc-c++ cmake ninja-build pkgconf \
        qt6-qtbase-devel qt6-qtsvg-devel qt6-qtimageformats-devel \
        libheif-devel libheif-freeworld LibRaw-devel fontconfig-devel \
        shared-mime-info hicolor-icon-theme dejavu-sans-fonts \
        dejavu-serif-fonts dejavu-sans-mono-fonts rpm-build \
    && dnf clean all
# el9: the GCC 14 toolset, put on PATH through ENV.
FROM rockylinux:9 AS el9
RUN dnf install -y --enablerepo=crb epel-release curl \
    && dnf install -y --enablerepo=crb cmake ninja-build gcc-c++ gcc-toolset-14 gcc-toolset-14-gcc-c++ \
        qt6-qtbase-devel qt6-qtsvg-devel qt6-qtimageformats libheif-devel LibRaw-devel fontconfig-devel rpm-build \
    && dnf clean all
FROM el${RELEASE}
# The ONNX Runtime the packages carry: Microsoft's own build.
RUN curl -fsSL -o /tmp/ort.tgz \
        https://github.com/microsoft/onnxruntime/releases/download/v1.21.0/onnxruntime-linux-x64-1.21.0.tgz \
    && echo "7485c7e7aac6501b27e353dcbe068e45c61ab51fbaf598d13970dfae669d20bf  /tmp/ort.tgz" | sha256sum -c - \
    && mkdir -p /tmp/ort /usr/local/include/onnxruntime /usr/local/lib64 \
    && tar -xzf /tmp/ort.tgz -C /tmp/ort --strip-components=1 \
    && cp -r /tmp/ort/include/. /usr/local/include/onnxruntime/ \
    && mkdir -p /usr/local/lib/cmake && mv /tmp/ort/lib/cmake/onnxruntime /usr/local/lib/cmake/ \
    && cp -a /tmp/ort/lib/. /usr/local/lib64/ \
    && mkdir -p /usr/local/share/doc/onnxruntime \
    && cp /tmp/ort/LICENSE /tmp/ort/ThirdPartyNotices.txt /usr/local/share/doc/onnxruntime/ \
    && echo /usr/local/lib64 > /etc/ld.so.conf.d/onnxruntime.conf && ldconfig \
    && rm -rf /tmp/ort /tmp/ort.tgz
# U²-Net (Apache-2.0), as rembg converted it (MIT), for Remove Background.
RUN mkdir -p /usr/local/share/omaphoto \
    && curl -fsSL -o /usr/local/share/omaphoto/u2net.onnx \
        https://github.com/danielgatis/rembg/releases/download/v0.0.0/u2net.onnx \
    && echo "8d10d2f3bb75ae3b6d527c77944fc5e7dcd94b29809d47a739a7a728a912b491  /usr/local/share/omaphoto/u2net.onnx" | sha256sum -c -
