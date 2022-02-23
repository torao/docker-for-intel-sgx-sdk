#include "Enclave_t.h"
#include <sgx_trts.h>
#include <stdlib.h>
#include <string.h>

#define max(a, b) ((a) > (b) ? (a) : (b))

int print_name(char *buffer, size_t capacity) {
  const char *message = "I'm Voldo";
  size_t len = max(0, capacity - strlen(buffer) - 1);
  strncat(buffer, message, len);
  sgx_status_t state = println(buffer);
  if (state != SGX_SUCCESS) {
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}
