/*
 * snprintf.c
 *
 *  Created on: 29.05.2013
 *      Author: mfro
 */

#include <stdarg.h>
#include <stdio.h>

extern int doprnt(int (*)(int, void *), void *stream, const char *fmt, va_list va);

int snprintf(char *str, size_t size, const char *fmt, ...)
{
	int ret;

	va_list va;
	va_start(va, fmt);
	ret = vsnprintf(str, size, fmt, va);
	va_end(va);
	return ret;
}
