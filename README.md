# Docker container for Intel SGX SDK

Docker container for Intel SGX SDK

## How to build docker image

```
$ git clone https://github.com/torao/sample.intel-sgx.git
$ cd sample.intel-sgx
$ docker build --target sgxsdk -t sgxsdk .
$ docker build --target sgxpsw -t sgxpsw .
```

## How to build Intel SGX project

```
$ docker run -it --rm --name sgxsdk -v `pwd`:/opt/local sgxsdk
```