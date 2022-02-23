# Docker container for Intel SGX SDK

Docker container for Intel SGX SDK

## How to build docker image

```
$ git clone https://github.com/torao/docker-for-intel-sgx-sdk.git
$ cd docker-for-intel-sgx-sdk
$ docker build -t sgxsdk .
```

## How to build Intel SGX project

```
$ docker run -it --rm --name sgxsdk -v `pwd`:/opt/local sgxsdk bash

# make all
```