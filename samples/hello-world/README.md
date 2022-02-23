# Sample Program for Intel SGX

```
$ cd samples/hello-world
$ docker run -it --rm --name sgxsdk -v `pwd`:/opt/local torao/sgxsdk bash

root@e7bcf3905105:/opt/local# make run
>> hello, I'm Voldo
<< hello, I'm Voldo
RUN  =>  hello-sgx [SIM|x64, OK]
```
