/*
 * stdlib.h
 *
 *  Created on: 31.05.2013
 *      Author: mfro
 */

#ifndef _STDLIB_H_
#define _STDLIB_H_

typedef unsigned long size_t;

extern int atoi(const char *c);
extern long atol(const char *c);
extern void *malloc(size_t size);
extern void *calloc(size_t nmemb, size_t size);
extern void *realloc(void *ptr, size_t size);
extern void free(void *ptr);

extern char *ltoa(long value, char *buffer, int radix);
#define _ltoa(a, b, c) ltoa((a), (b), (c))

extern char *getenv(const char *name);

int atexit(void (*func)(void));
extern void exit(int status);
extern void abort(void);

extern void srand48(long int seedval);

extern long strtol(const char*, char**, int);
extern unsigned long strtoul(const char*, char**, int);
extern long long strtoll(const char*, char**, int);
extern unsigned long long strtoull(const char*, char**, int);


#define NULL	((void *) 0)
#endif /* _STDLIB_H_ */
