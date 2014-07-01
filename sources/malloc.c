/*
 * malloc.c
 *
 *  Created on: 17.06.2014
 *      Author: peylow
 *
 *  Use fast path for allocating blocks of 1024 bytes or less, otherwise trust
 *  the OS to be reasonable.
 */
#include <stddef.h> /* for size_t */
#include <osbind.h> /* for Malloc/Mfree on target */
#include <stdlib.h> /* for NULL */
#include <errno.h>  /* for errno and ENOMEM */

typedef struct {
  void*  next;
  size_t size;
} __mem_chunk;

#define __BLOCK_START(b)	(((void*)(b))-sizeof(__mem_chunk))
#define __BLOCK_RET(b)	(((void*)(b))+sizeof(__mem_chunk))
#define __MEM_ALIGN_SIZE	  16
#define __MEM_ALIGN(s)	(((s)+__MEM_ALIGN_SIZE-1)&(unsigned long)(~(__MEM_ALIGN_SIZE-1)))

#ifndef __DEV_MALLOC__

void *large_malloc(size_t size) {
  register __mem_chunk* ptr;
  register size_t need = __MEM_ALIGN(size+sizeof(__mem_chunk));
  ptr = (void *)Malloc(need);
  if (ptr) {
    ptr->size = size;
  } 
  else {
    errno = ENOMEM;
  }
  return __BLOCK_RET(ptr);
}

void large_free(void* ptr) {
  __mem_chunk* tmp = __BLOCK_START(ptr);
  Mfree(tmp);
}

#else

extern void *large_malloc(size_t size);
void large_free(void* ptr);

/*
 * Defines for fast path blocks for allocs of 1024 bytes and less. Uses block
 * sizes so that at most 127 bytes can be "wasted".
 */
#define __MAX_INDEX (12 * 4)
#define __MEM_BLOCK_SIZE	4096
#define __MIN_SMALL_SIZE	   8
#define __MAX_SMALL_SIZE	1024
static const short __small_size_for_indexes[__MAX_INDEX / 2] = {8,0,16,0,32,0,64,0,128,0,256,0,384,0,512,0,640,0,768,0,896,0,1024,0};
static short __small_index_for_size[(__MAX_SMALL_SIZE / 2) + 1];
static __mem_chunk* __small_mem_chunks[__MAX_INDEX / 4]; /* first free chunk for 8, 16, 32... blocks. */

// Use function pointer that is replaced for init small mem chunks, to do lazy init.
static void* __init_small_chunks(short idx, size_t size);
static void* (*__alloc_small_chunks)(short idx, size_t size) = &__init_small_chunks;

#define __SMALL_SIZE_FOR_INDEX(idx) (*((short*)(((char *)__small_size_for_indexes)+idx)))
#define __SMALL_CHUNK_FOR_INDEX(idx) (*((__mem_chunk**)(((char *)__small_mem_chunks)+idx)))

__attribute__ ((noinline))
static void*  __real_alloc_small_chunks(short idx, size_t size) {
  register short step = __SMALL_SIZE_FOR_INDEX(idx)+sizeof(__mem_chunk);
  register short count = (__MEM_BLOCK_SIZE / ((short)step));
  register __mem_chunk *ptr;
  
  ptr = (void*)Malloc(step * count);
  if (!ptr) return NULL;
  
  __SMALL_CHUNK_FOR_INDEX(idx) = ptr;
  
  while (count--) {
    ptr->size = idx;
    ptr = ptr->next = (((void*)ptr)+step);
  }
  ptr->size = idx;
  ptr->next = NULL;
  
  return ptr;
}

__attribute__ ((noinline))
static void*  __init_small_chunks(short idx, size_t size) {
  short sz;
  __alloc_small_chunks = &__real_alloc_small_chunks;
  for (sz = 0; sz <= __MAX_SMALL_SIZE; sz += 2) {
    if (__SMALL_SIZE_FOR_INDEX(idx) < sz) {
      idx += 4;
    }
    __small_index_for_size[sz / 2] = idx;
  }
  idx = __small_index_for_size[size / 2];
  return __real_alloc_small_chunks(idx, size);
}

__attribute__ ((always_inline))
static void* __small_malloc(size_t size) {
  register short idx = __small_index_for_size[size / 2];
  register __mem_chunk *ptr = __SMALL_CHUNK_FOR_INDEX(idx);
  if (ptr)  {	/* no free blocks ? */
    /* get a free block */
    __SMALL_CHUNK_FOR_INDEX(idx) = ptr->next;
    ptr->next = NULL;
    return ptr;
  }
  else {
    return __alloc_small_chunks(idx, size);
  }  
}

__attribute__ ((always_inline))
static void __small_free(void* ptr) {
  __mem_chunk* tmp = __BLOCK_START(ptr);
  short idx = tmp->size;
  tmp->next = __SMALL_CHUNK_FOR_INDEX(idx);
  __SMALL_CHUNK_FOR_INDEX(idx) = tmp;
}

void free(void *ptr) {
  if (ptr) {
    register __mem_chunk* tmp = __BLOCK_START(ptr);
    if (tmp->size < __MAX_INDEX) {
      __small_free(ptr);
    }
    else {
      large_free(ptr);
    }
  }
}

void* malloc(size_t size) {
  register __mem_chunk* ptr;
  if (size) {
    if (size <= __MAX_SMALL_SIZE) {
      ptr = __small_malloc(size);
    }
    else {
      return large_malloc(size);
    }
    if (ptr) {
      return __BLOCK_RET(ptr);
    }
    errno = ENOMEM;
  }
  return NULL;
}

size_t malloc_size(const void *ptr) {
  if (ptr) {
    register __mem_chunk* tmp = __BLOCK_START(ptr);
    size_t size = tmp->size;
    if (size < __MAX_INDEX) {
      size = __SMALL_SIZE_FOR_INDEX(size);
    }
    return size;
  }
  return 0;
}

#endif