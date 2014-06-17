/*
 * malltest.c
 *
 *  Created on: 01.06.2013
 *      Author: mfro
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <osbind.h>
#include <mint/basepage.h>

void recursive_alloc(int depth)
{
	char *ptr;

	printf("allocating 512 kBytes. Adress: ");

	ptr = calloc(1, 512 * 1024L);

	printf("%p\r\n", ptr);

	if (depth > 0)
	{
		recursive_alloc(--depth);
	}
	if (ptr != NULL)
	{
		printf("free %p\r\n", ptr);
		free(ptr);
	}
}

int main(int argc, char *argv[], char *envp[])
{
	char *ptr1, *ptr2, *ptr3;

	while (Cconis()) Cconin();

	printf("Allocating 256 kBytes:");
	ptr1 = malloc(256 * 1024L);
	printf(" ptr = %p\r\n", ptr1);

	printf("Allocating 32 kBytes:");
	ptr1 = malloc(32768);
	printf(" ptr = %p\r\n", ptr1);

	printf("Allocating 16 kBytes");
	ptr2 = malloc(16384);
	printf(" ptr = %p\r\n", ptr2);

	printf("Allocating 8 kBytes");
	ptr3 = malloc(8192);
	printf(" ptr = %p\r\n", ptr3);


	free(ptr2);
	free(ptr1);
	free(ptr3);

	(void) Cconws("press any key to continue\r\n");
	Cconin();
	recursive_alloc(50);

	(void) Cconws("press a key to return to desktop\r\n");
	Cconin();

	return 0;
}
