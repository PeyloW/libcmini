#include <stddef.h>	/* for size_t */
#include <stdlib.h>	/* for malloc()/free() */
#include <string.h>
#include <ext.h>	/* for malloc_size() */

#define __MIN_REALLOC_SIZE   128

__attribute__ ((always_inline))
static size_t __realloc_needed(void* ptr, size_t size) {
  register size_t oldsize = malloc_size(ptr);
  if (size != oldsize) {
    if (oldsize < size) {
      return oldsize;
    }
    else if ((oldsize - size) > __MIN_REALLOC_SIZE) {
      return size;
    }
  }
  return 0;
}

void *_realloc(void* ptr, size_t size) {
  if (ptr) {
    if (size) {
      size_t cz = __realloc_needed(ptr, size);
      if (cz) {
        void *new = malloc(size);
        if (new) {
          memcpy(new, ptr, cz);
        }
        free(ptr);
        ptr = new;
      }
    }
    else { /* size==0 */
      free(ptr);
      ptr = NULL;
    }
  }
  else { /* ptr==0 */
    if (size) {
      ptr = malloc(size);
    }
  }
  return ptr;
}
