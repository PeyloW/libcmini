/*
 * lib.h
 *
 *  Created on: 08.06.2013
 *      Author: mfro
 */

#ifndef LIB_H_
#define LIB_H_

/* definitions needed for stack stuff */

#define MINFREE	(8L * 1024L)		/* free at least this much mem on top */
#define MINKEEP (64L * 1024L)		/* keep at least this much mem on stack */
void _setstack(char *);

/* definitions needed in FILE related functions (fopen, fseek etc.) */

#ifdef __MINTLIB_COMAPTIBLE
#	define FILE_SET_HANDLE(fp, H) fp->__cookie = (void*)H
#	define FILE_GET_HANDLE(fp) ((long)fp->__cookie)
#else
#	define FILE_SET_HANDLE(fp, H) fp->Handle = H
#	define FILE_GET_HANDLE(fp) (fp->Handle)
#endif

typedef void (*ExitFn)(void);
extern char **environ;

#endif /* LIB_H_ */
