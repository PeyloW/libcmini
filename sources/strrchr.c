#include <string.h>

char *strrchr(const char *s, int c)
{
	const char *cp = s + strlen(s) + 1;

	do
	{
		if (*cp == (char) c)
			return (char*)cp;
	} while (cp-- > s);

	return NULL;
}

char *rindex(const char *s, int c) __attribute__((alias("strrchr")));
