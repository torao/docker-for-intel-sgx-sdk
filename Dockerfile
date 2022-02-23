FROM ubuntu:20.04
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
    echo -e "no\n/opt/intel" | ./linux/installer/bin/sgx_linux_x64_sdk_*.bin && \
    echo "source /opt/intel/sgxsdk/environment" >> ~/.bashrc && \
    cd .. && \
    rm -rf linux-sgx

WORKDIR /opt/local
CMD [ "bash" ]