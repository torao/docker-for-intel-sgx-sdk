# App/     - Application's *.c and *.h files
# Enclave/ - Enclave's *.c and *.h files
# Include/ - Common header files for application and enclave
#
# $ cd samples/hello-world
# $ docker run -it --rm --name sgxskd -v `pwd`:/opt/local torao/sgxsdk
# # make run
# 
SGX_SDK ?= /opt/intel/sgxsdk
SGX_MODE ?= SIM
SGX_DEBUG ?= 1

APP_NAME := hello-sgx
ENCLAVE_NAME := myenclave.so
SIGNED_ENCLAVE_NAME := myenclave.signed.so
ENCLAVE_CONFIG_FILE := Enclave/Enclave.config.xml
SIGN_PRIVATE_KEY := Enclave/Enclave.private.pem

ifeq ($(shell getconf LONG_BIT), 32)
	SGX_ARCH := x86
else ifeq ($(findstring -m32, $(CXXFLAGS)), -m32)
	SGX_ARCH := x86
else
	SGX_ARCH := x64
endif

ifeq ($(SGX_ARCH), x86)
	SGX_CFLAGS := -m32
	SGX_LIBRARY_PATH := $(SGX_SDK)/lib
else
	SGX_CFLAGS := -m64
	SGX_LIBRARY_PATH := $(SGX_SDK)/lib64
endif
SGX_ENCLAVE_SIGNER := $(SGX_SDK)/bin/$(SGX_ARCH)/sgx_sign
SGX_EDGER8R := $(SGX_SDK)/bin/$(SGX_ARCH)/sgx_edger8r

ifneq ($(SGX_DEBUG), 0)
	SGX_CFLAGS += -O0 -g
else
	SGX_CFLAGS += -O2
endif

ifeq ($(SGX_MODE), HW)
	ifeq ($(SGX_DEBUG), 0)
		HW_RELEASE := 1
	endif
endif

ifeq ($(SGX_MODE), SIM)
	SIM_SUFFIX := _sim
endif

.PHONY: all run clean

all: $(SIGNED_ENCLAVE_NAME) $(APP_NAME)
ifeq ($(HW_RELEASE), 1)
	@echo "The project has been built in release hardware mode."
	@echo "Please sign the $(ENCLAVE_NAME) first with your signing key before you run the $(APP_NAME) to launch and access the enclave."
	@echo "To sign the enclave use the command:"
	@echo "   $(SGX_ENCLAVE_SIGNER) sign -key <your key> -enclave $(ENCLAVE_NAME) -out <$(SIGNED_ENCLAVE_NAME)> -config $(ENCLAVE_CONFIG_FILE)"
	@echo "You can also sign the enclave using an external signing tool. See User's Guide for more details."
	@echo "To build the project in simulation mode set SGX_MODE=SIM. To build the project in prerelease mode set SGX_PRERELEASE=1 and SGX_MODE=HW."
endif

run: all
ifneq ($(HW_RELEASE), 1)
	@$(CURDIR)/$(APP_NAME)
	@echo "RUN  =>  $(APP_NAME) [$(SGX_MODE)|$(SGX_ARCH), OK]"
endif

# ==== Build Enclave ====

ENCLAVE_SRC := $(wildcard Enclave/*.c)
ENCLAVE_OBJ := $(ENCLAVE_SRC:.c=.o)
ENCLAVE_INCLUDE := -IInclude -IEnclave -I$(SGX_SDK)/include -I$(SGX_SDK)/include/tlibc -I$(SGX_SDK)/include/stlport
ENCLAVE_CFLAGS := $(SGX_CFLAGS) -nostdinc -fvisibility=hidden -fpie -fstack-protector $(ENCLAVE_INCLUDE)
ENCLAVE_LFLAGS := $(SGX_CFLAGS) -Wl,--no-undefined -nostdlib -nodefaultlibs -nostartfiles -L$(SGX_LIBRARY_PATH) \
	-Wl,--whole-archive -lsgx_trts$(SIM_SUFFIX) -Wl,--no-whole-archive \
	-Wl,--start-group -lsgx_tstdc -lsgx_tcrypto -lsgx_tservice$(SIM_SUFFIX) -Wl,--end-group \
	-Wl,-Bstatic -Wl,-Bsymbolic -Wl,--no-undefined \
	-Wl,-pie,-eenclave_entry -Wl,--export-dynamic  \
	-Wl,--defsym,__ImageBase=0

Enclave/Enclave_t.c: $(SGX_EDGER8R) Enclave/Enclave.edl
	@cd Enclave/ && $(SGX_EDGER8R) --trusted Enclave.edl --search-path . --search-path $(SGX_SDK)/include
	@echo "GEN  =>  $@"

Enclave/%.o: Enclave/%.c
	@$(CC) $(ENCLAVE_CFLAGS) -c $< -o $@
	@echo "CC  <=  $<"

$(ENCLAVE_NAME): Enclave/Enclave_t.o $(ENCLAVE_OBJ)
	@$(CC) $^ -o $@ $(ENCLAVE_LFLAGS)
	@echo "LINK =>  $@"

$(SIGNED_ENCLAVE_NAME): $(ENCLAVE_NAME) $(SIGN_PRIVATE_KEY)
	@$(SGX_ENCLAVE_SIGNER) sign -key $(SIGN_PRIVATE_KEY) -enclave $(ENCLAVE_NAME) -out $@ -config $(ENCLAVE_CONFIG_FILE)
	@echo "SIGN =>  $@"

$(SIGN_PRIVATE_KEY):
	@openssl genrsa -3 3072 > $(SIGN_PRIVATE_KEY)

# ==== Build Application ====

APP_SRC := $(wildcard App/*.c)
APP_OBJ := $(APP_SRC:.c=.o)
APP_INCLUDE := -IInclude -IApp -I$(SGX_SDK)/include
APP_CFLAGS := $(SGX_CFLAGS) -fPIC -Wno-attributes $(APP_INCLUDE)
APP_LFLAGS := $(SGX_CFLAGS) -L$(SGX_LIBRARY_PATH) \
	-lpthread -lsgx_urts$(SIM_SUFFIX) -lsgx_uae_service$(SIM_SUFFIX)

ifneq ($(SGX_DEBUG), 0)
	APP_CFLAGS += -DDEBUG -UNDEBUG -UEDEBUG
else
	APP_CFLAGS += -DNDEBUG -UEDEBUG -UDEBUG
endif

App/Enclave_u.c: $(SGX_EDGER8R) Enclave/Enclave.edl
	@cd App/ && $(SGX_EDGER8R) --untrusted ../Enclave/Enclave.edl --search-path ../Enclave --search-path $(SGX_SDK)/include
	@echo "GEN  =>  $@"

App/%.o: App/%.c
	@$(CC) $(APP_CFLAGS) -c $< -o $@
	@echo "CC  <=  $<"

$(APP_NAME): App/Enclave_u.o $(APP_OBJ)
	@$(CC) $^ -o $@ $(APP_LFLAGS)
	@echo "LINK =>  $@"
