#include <string.h>

#define toupper(c) (((c) >= 'a' && (c) <= 'z') ? ((c) - 'a' - 'A') : (c))

int stricmp(const char *s1, const char *s2)
{
	int c1, c2;
	do
	{

		c1 = toupper(*s1);
		c2 = toupper(*s2);

		if (c1 != c2)
			return c2 - c1;
	} while (*s1++ && *s2++);

	return c2 - c1;
}


