#include <string.h>

#define toupper(c) (((c) >= 'a' && (c) <= 'z') ? ((c) - 'a' - 'A') : (c))

int strnicmp(const char *s1, const char *s2, size_t n)
{
	do
	{
		if (toupper(*s1) != toupper(*s2))
			return *s2 - *s1;
		n--;
	} while (*s1++ && *s2++ && n);

	return *s2 - *s1;
}


