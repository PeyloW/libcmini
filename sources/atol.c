/*
 * atoi.c
 *
 *  Created on: 29.05.2013
 *      Author: mfro
 */

#include <string.h>
#ifdef MINTLIB_COMAPTIBLE
#	include <ctype.h>
#else
#	include "../include/ctype.h"
#endif

long atol(const char *c)
{
	long value = 0;
	while (isdigit(*c))
	{
		value *= 10;
		value += (long) (*c - '0');
		c++;
	}
	return value;
}
