FROM ubuntu:20.04 AS sgxsdk
LABEL maintainer="TAKAMI Torao <koiroha@gmail.com>"

# Install develpment tools and libraries.
RUN apt update -y && apt upgrade -y && \
    apt install -y tzdata && \
    apt install -y build-essential ocaml ocamlbuild automake autoconf libtool wget \
    python-is-python3 libssl-dev git cmake perl \
    git unzip

# Build and install Intel SGX SDK.
RUN git clone https://github.com/intel/linux-sgx.git && \
    cd linux-sgx && \
    make preparation && \
    cp external/toolset/ubuntu20.04/* /usr/local/bin && \
    make sdk_install_pkg && \
    ./linux/installer/bin/sgx_linux_x64_sdk_*.bin --prefix=/opt/intel && \
    echo "source /opt/intel/sgxsdk/environment" >> ~/.bashrc && \
    cd .. && \
    rm -rf linux-sgx

WORKDIR /opt/local
CMD [ "bash" ]

# ================================================================
FROM sgxsdk AS sgxpsw
LABEL maintainer="TAKAMI Torao <koiroha@gmail.com>"

# Install develpment tools and libraries.
RUN apt update -y && apt upgrade -y && \
    apt install -y tzdata && \
    apt install -y libssl-dev libcurl4-openssl-dev protobuf-compiler libprotobuf-dev \
    debhelper cmake reprepro unzip wget python-is-python3 \
    git lsb-release

# Build and install Intel SGX SDK.
RUN git clone https://github.com/intel/linux-sgx.git && \
    cd linux-sgx && \
    make preparation && \
    cp external/toolset/ubuntu20.04/* /usr/local/bin && \
    make deb_psw_pkg && \
    make deb_local_repo && \
    echo "deb [trusted=yes arch=amd64] file:/opt/local/linux-sgx/linux/installer/deb/sgx_debian_local_repo focal main" > /etc/apt/sources.list.d/intel-sgx.list && \
    apt update -y && \
    apt install -y libssl-dev libcurl4-openssl-dev libprotobuf-dev \
    libsgx-launch libsgx-urts
ENV LD_LIBRARY_PATH /opt/intel/sgxsdk/lib64:$LD_LIBRARY_PATH

WORKDIR /opt/local
CMD [ "bash" ]