libcmini
========

This is a patched version of libcmini from [Atari Forge](http://www.atariforge.org/gf/project/libcmini/) 
to support the [patched GCC 4.6.4](https://github.com/PeyloW/gcc-4.6.4) with -mfastcall support.

libcmini is a simple and lightweight C library for GCC allowing to code applications with small footprint.

Functionality comparable to PURE C meant as mintlib replacement for situations where you don't need all the standards stuff.

Changes from main
-----------------
* Patched .S assembly files to support __FASCALL__ calling convention.
* Patched make files to make Coldfire and fastcall binarioes optional.
* Rewritten malloc with buckets.
	 - Small mem chunks are constant time and fast, over 40k mallocs/sec on 8MHz ST.
	 - 1k+ chunks use TOS/MiNT directly.
* Implemented missing time functions.
* Added benchmark test.

Fastcall?
---------
GCC passes all arguments on the stack by default. The Atari ST, and even the Falcon 030, have a slow 16 bit wide memory bus.
As a result memory operations are very expensive. Most functions take only a few arguments that can be passed in registers.

-mfastcall uses d0-2/a0-1/fp0-2 for passing integer and pointer arguments when possible, and always return pointers in a0.
a2 is not used for passing arguments, but is considered clobbered, this allows a2 to be used as call target function pointer.

The result is faster code execution, and slightly smaller memory footprint. Especially when used in combination with -mshort to 
avoid library calls for most integer operations.

With -mfastcall libcmini itself is 3% smaller binary, and the tests/bench test executes 20% faster. 
