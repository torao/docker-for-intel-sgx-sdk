#include "Enclave_u.h"
#include <sgx_urts.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void println(const char *msg) { printf(">> %s\n", msg); }

int main(int argc, char **argv) {

  // read launch token if exists
  const char *token_file = "launch-token";
  sgx_launch_token_t token = {0};
  FILE *f = fopen(token_file, "rb");
  if (f != NULL) {
    size_t len = fread(&token, 1, sizeof(sgx_launch_token_t), f);
    fclose(f);
    if (len != sizeof(sgx_launch_token_t)) {
      fprintf(stderr, "ERROR: invalid launch token: %s\n", token_file);
      return EXIT_FAILURE;
    }
  }

  // initialize enclave
  const char *enclave_name = "myenclave.signed.so";
  sgx_enclave_id_t eid = 0;
  int changed = 0;
  sgx_status_t status = sgx_create_enclave(enclave_name, SGX_DEBUG_FLAG, &token,
                                           &changed, &eid, NULL);
  if (status != SGX_SUCCESS) {
    fprintf(stderr, "ERROR: failed to initialize enclave (%d)\n", status);
    return EXIT_FAILURE;
  }

  // if the token needs to be updated, write it out to the file
  if (changed != 0) {
    FILE *f = fopen(token_file, "wb");
    if (f == NULL) {
      fprintf(stderr, "ERROR: failed to open file: %s\n", token_file);
      return EXIT_FAILURE;
    }
    size_t len = fwrite(&token, 1, sizeof(sgx_launch_token_t), f);
    fclose(f);
    if (len != sizeof(sgx_launch_token_t)) {
      fprintf(stderr, "ERROR: failed to write token to file: %s\n", token_file);
      return EXIT_FAILURE;
    }
  }

  // call the function in Enclave
  char buffer[1024];
  strcpy(buffer, "hello, ");
  int ret = EXIT_FAILURE;
  status = print_name(eid, &ret, buffer, sizeof(buffer));
  if (status != SGX_SUCCESS) {
    fprintf(stderr, "ERROR: failed to call the function in Enclave\n");
    return EXIT_FAILURE;
  }
  if (ret != EXIT_SUCCESS) {
    fprintf(stderr, "ERROR: the function in Enclave returned error response\n");
    return EXIT_FAILURE;
  }
  printf("<< %s\n", buffer);

  // destroy the Enclave
  sgx_destroy_enclave(eid);

  return EXIT_SUCCESS;
}
