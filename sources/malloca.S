	.text
	.even
| Only called internaly, so use fastcall arg-conventions, but store regs normally.
___init_small_chunks:
#ifndef __FASTCALL__
	move.l %d2,-(%sp)
#endif
	move.l #___real_alloc_small_chunks,___alloc_small_chunks
	moveq.l #0,%d2
#ifdef __mcoldfire__
	lea ___small_size_for_indexes-2(%pc),%a0
#else
	lea ___small_size_for_indexes(%pc),%a0
#endif
	lea ___small_index_for_size(%pc),%a1
.forloop1:
#ifdef __mcoldfire__
	cmp.l (%a0),%d2
#else
	cmp.w (%a0),%d2
#endif
	jle .noidxinc
    addq.l #4,%a0
#ifdef __mcoldfire__
	addq.l #4,%d0
.noidxinc:
	move.w %d0,(%a1)+
	addq.l #2,%d2
	cmp.l #1026,%d2
#else
	addq.w #4,%d0
.noidxinc:
	move.w %d0,(%a1)+
	addq.w #2,%d2
	cmp.w #1026,%d2
#endif
	jne .forloop1
	moveq #-2,%d0
#ifdef __mcoldfire__
    addq.l #1,%d0
	and.l d1,%d0
    lea ___small_mem_chunks(%pc),%a1
    lea ___small_index_for_size(%pc),%a0
	move.w (%a0,%d0.w),%a0
    move.l  %a0,%d0
	add.l %d0,%a1
#else
    addq.w #1,%d0
	and.w d1,%d0                          |  8
	lea ___small_mem_chunks(%pc),%a1      | 8
    lea ___small_index_for_size(%pc),%a0  | 8
    move.w (%a0,%d0.w),%d0                 | 16
    add.w  %d0,%a1
#endif
#ifndef __FASTCALL__
	move.l (%sp)+,%d2
#endif
|
| intentional fallthrough!
| Only called internaly, so use fastcall arg-conventions, but store regs normally.
___real_alloc_small_chunks:
#ifndef __FASTCALL__
    move.l  %d2,-(%sp)
    move.l  %a2,-(%sp)
#endif
	moveq.l #8,%d1     | d1=step
#ifdef __mcoldfire__
	lea ___small_size_for_indexes-2(%pc),%a0
    add.l (%a0,%d0.l),%d1
#else
	lea ___small_size_for_indexes(%pc),%a0
    add.w (%a0,%d0.w),%d1
#endif
	move.l #4096+32,%d2
	divs.w %d1,%d2    | d2=count
#ifdef __mcoldfire__
    lea -12(%sp),%sp
    movem.l %d0-%d2,(%sp)
#else
    movem.w %d0-%d2,-(%sp)
#endif
    mulu.w %d1,%d2
	movl	%d2,-(sp)
	movw	#72,-(sp)
	trap	#1
	addql	#6,%sp
    move.l  %d0,%a0   | a0=ptr
#ifdef __mcoldfire__
    movem.l (%sp),%d0-%d2
	lea  12(%sp),%sp
	cmp.l #0,%a0
#else
    movem.w (%sp)+,%d0-%d2
	cmp.w #0,%a0
#endif
	jeq .nomem
	lea ___small_mem_chunks(%pc),%a1
    ext.l %d0
	move.l %a0,(%a1,%d0.l)
#ifdef __mcoldfire__
    subq.l  #3,%d2
#else
    subq.w  #3,%d2
#endif
.forloop2:
#ifdef __mcoldfire__
    lea (%a0,%d1.l),%a1
#else
    lea (%a0,%d1.w),%a1
#endif
    move.l %a1,(%a0)+
    move.l %d0,(%a0)
    move.l %a1,%a0
#ifdef __mcoldfire__
    subq.l #1,d2
    jge .forloop2
#else
    dbra  %d2,.forloop2
#endif
#ifdef __mcoldfire__
    lea (%a0,%d1.l),%a1
#else
    lea (%a0,%d1.w),%a1
#endif
    clr.l (%a0)+
    move.l %d0,(%a0)
    move.l %a1,%a0
    clr.l (%a0)
    move.l %d0,4(%a0)
.nomem:
#ifndef __FASTCALL__
    move.l  (%sp)+,%a2
    move.l  (%sp)+,%d2
#endif
	rts
	.even
	.globl	_malloc
_malloc:
|    illegal
#ifndef __FASTCALL__
    move.l 4(%sp),%d0
#endif
	move.l %d0,%d1                              |  4
	jeq .iszero                                 | 8/12
	cmp.l #1024,%d0                             | 16
	jhi .islarge1                                | 8/12
#ifdef __mcoldfire__
    addq.l  #1,d0
	and.l #-2,%d0
    lea ___small_mem_chunks(%pc),%a1
    lea ___small_index_for_size(%pc),%a0
	move.w (%a0,%d0.w),%a0
    move.l %a0,%d0
	add.l %d0,%a1
#else
    addq.w  #1,d0                               | 4
	and.w #-2,%d0                               |  8
	lea ___small_mem_chunks(%pc),%a1      | 8
    lea ___small_index_for_size(%pc),%a0  | 8
    move.w (%a0,%d0.w),%d0                | 16
    add.w  %d0,%a1                        | 8
#endif
#ifndef __FASTCALL__
    move.l (%a1),%a0                            |  8
#ifdef __mcoldfire__
    cmp.l #0,%a0
#else
    cmp.w #0,%a0                                 | 12
#endif
	jeq .nosmallfree                            | 8/12
#else
	move.l (%a1),%d2                            |  8
	jeq .nosmallfree                            | 8/12
    move.l %d2,%a0                              |  4
#endif
	move.l (%a0),(%a1)                          | 20
    moveq.l #0,d0                               |  4
	move.l %d0,(%a0)                            | 12
	addq.l #8,%a0                               |  8
	rts                                         | 16 = 168clc
.nosmallfree:
	move.l ___alloc_small_chunks(%pc),%a0       | 16
	jsr (%a0)                                   | 16
#ifdef __mcoldfire__
	cmp.l #0,%a0
#else
	cmp.w #0,%a0
#endif
	jeq .iserror
	addq.l #8,%a0
    rts
.iserror:
	move.w #39,_errno
.iszero:
#ifndef __FASTCALL__
    moveq.l #0,%d0
#else
	sub.l %a0,%a0
#endif
	rts
.islarge1:
	jra _large_malloc
	.even
	.globl	_free
_free:
|    illegal
#ifndef __FASTCALL__
    move.l 4(%sp),a0
#endif
#ifdef __mcoldfire__
	cmp.l #0,%a0
#else
	cmp.w #0,%a0                            | 12
#endif
	jeq .isnull1                             | 8/12
	move.l -(%a0),%d0                       | 16
	moveq #47,%d1                           |  4
	cmp.l %d0,%d1                           |  8
	jcs .islarge2                            | 8/12
    lea ___small_mem_chunks(%pc),%a1        | 8
    move.l (%a1,d0.l),%a1                   | 20
	move.l (%a1),-(%a0)                     | 20
	move.l %a0,(%a1)                        | 12
	rts                                     | 16 = 132clk
.islarge2:
#ifdef __FASTCALL__
    addq.l  #4,%a0
#endif
	jra _large_free
.isnull1:
	rts
	.even
	.globl	_malloc_size
_malloc_size:
|    illegal
#ifndef __FASTCALL__
    move.l 4(%sp),a0
#endif
#ifdef __mcoldfire__
	cmp.l #0,%a0
#else
	cmp.w #0,%a0                                  | 12
#endif
	jeq .isnull2                                   | 8/16
	move.l -(%a0),%d0                             | 16
	moveq #47,%d1                                 |  4
	cmp.l %d0,%d1                                 |  8
	jcs .islarge3                                  | 8/16
    lea ___small_size_for_indexes(%pc),%a0        | 8
    move.w (%a0,%d0.l),d0                           | 16
	ext.l %d0                                     |  4
	rts                                           | 16 = 100clk
.isnull2:
	moveq #0,%d0
.islarge3:
	rts
.lcomm ___small_mem_chunks,48
.lcomm ___small_index_for_size,1026
	.even
___alloc_small_chunks:
	.long	___init_small_chunks
	.even
	.word	0
	.word	0
___small_size_for_indexes:
	.word	8
	.word	0
	.word	16
	.word	0
	.word	32
	.word	0
	.word	64
	.word	0
	.word	128
	.word	0
	.word	256
	.word	0
	.word	384
	.word	0
	.word	512
	.word	0
	.word	640
	.word	0
	.word	768
	.word	0
	.word	896
	.word	0
	.word	1024
	.word	0

