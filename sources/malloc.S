#NO_APP
	.text
	.even
___real_alloc_small_chunks:
	movem.l #6168,-(%sp)
	move.w %d0,%a3
	lea ___small_size_for_indexes,%a0
	move.w (%a0,%a3.l),%d3
	addq.w #8,%d3
	move.w #4096,%d4
	ext.l %d4
	divs.w %d3,%d4
	subq.w #1,%d4
	move.w %d3,%d0
	muls.w %d4,%d0
	move.w %d0,%a4
#APP
| 53 "malloc.c" 1
	movl	%a4,sp@-
	movw	#72,sp@-
	trap	#1
	addql	#6,sp
| 0 "" 2
#NO_APP
	move.l %d0,%a0
	tst.l %d0
	jeq .L2
	lea ___small_mem_chunks,%a1
	move.l %d0,(%a1,%a3.l)
	clr.w %d0
	move.w %d3,%a1
	jra .L3
.L4:
	move.l %a0,%d1
	add.l %a1,%d1
	move.l %d1,(%a0)
	addq.w #1,%d0
	move.l %d1,%a0
.L3:
	move.l %a3,4(%a0)
	cmp.w %d0,%d4
	jgt .L4
	clr.l (%a0)
.L2:
	movem.l (%sp)+,#6168
	rts
	.even
___init_small_chunks:
	move.l %d3,-(%sp)
	move.l #___real_alloc_small_chunks,___alloc_small_chunks
	clr.w %d2
	lea ___small_size_for_indexes,%a2
	lea ___small_index_for_size,%a1
.L7:
	cmp.w (%a2,%d0.w),%d2
	jle .L6
	addq.w #4,%d0
.L6:
	move.w %d2,%d3
	asr.w #1,%d3
	move.w %d3,%a0
	add.l %a0,%a0
	move.w %d0,(%a0,%a1.l)
	addq.w #2,%d2
	cmp.w #1026,%d2
	jne .L7
	moveq #-2,%d0
	and.l %d1,%d0
	lea ___small_index_for_size,%a0
	move.w (%a0,%d0.l),%d0
	move.l (%sp)+,%d3
	jra ___real_alloc_small_chunks
	.even
___large_malloc:
	move.l %d3,-(%sp)
	move.l %d0,%d3
	moveq #23,%d0
	add.l %d3,%d0
	moveq #-16,%d1
	and.l %d1,%d0
#APP
| 101 "malloc.c" 1
	movl	%d0,sp@-
	movw	#72,sp@-
	trap	#1
	addql	#6,sp
| 0 "" 2
#NO_APP
	move.l %d0,%a0
	tst.l %d0
	jeq .L10
	move.l %d3,4(%a0)
.L10:
	move.l (%sp)+,%d3
	rts
	.even
___large_free:
	move.l %a0,%d0
	subq.l #8,%d0
#APP
| 137 "malloc.c" 1
	movl	%d0,sp@-
	movw	#73,sp@-
	trap	#1
	addql	#6,sp
| 0 "" 2
#NO_APP
	rts
	.even
	.globl	_malloc
_malloc:
#ifndef __FASTCALL__
    move.l 4(sp),d0                             ; 12
	jeq .iszero                                 ; 8/12
    move.l d0,d1                                ; 4
#else
	move.l %d0,%d1                              ;  4
	jeq .iszero                                 ; 8/12
#endif
	cmp.l #1024,%d0                             ; 16
	jhi .islarge                                ; 8/12
#ifdef __mcoldfire__
	and.l #-2,%d0
	move.w ___small_index_for_size(pc,d0.w),%a1
	lea ___small_mem_chunks(pc,a1.l),%a1
#else
	and.w #-2,%d0                               ;  8
	move.w ___small_index_for_size(pc,d0.w),%d0 ; 16
	lea ___small_mem_chunks(pc,d0.w),%a1        ; 16
#endif
	move.l (%a1),%d2                            ;  8
	jeq .nosmallfree                            ; 8/12
    move.l d2,a0                                ;  4
	move.l (%a0),(%a1)                          ; 20
    moveq.l #0,d0                               ;  4
	move.l d0,(%a0)                             ; 12
	addq.l #8,%a0                               ;  8
	rts                                         ; 16 = 156clc
.nosmallfree:
	move.l ___alloc_small_chunks,%a0
	jsr (%a0)
	jra .testsuccess
.islarge:
	jsr ___large_malloc
.testsuccess:
#ifdef __mcoldfire__
	cmp.l #0,%a0
#else
	cmp.w #0,%a0
#endif
	jeq .iserror
    rts
.iserror:
	move.w #39,_errno
.iszero:
#ifndef __FASTCALL__
    moveq.l #0,d0
#else
	sub.l %a0,%a0
#endif
	rts
	.even
	.globl	_free
_free:
#ifndef __FASTCALL__
    move.l 4(sp),a0
#endif
#ifdef __mcoldfire__
	cmp.l #0,%a0
#else
	cmp.w #0,%a0                            ; 12
#endif
	jeq .isnull                             ; 8/12
	move.l -(%a0),%d0                       ; 16
	moveq #47,%d1                           ;  4
	cmp.l %d0,%d1                           ;  8
	jcs .islarge                            ; 8/12
	move.l ___small_mem_chunks(pc,d0.w),%a1 ; 20
	move.l (%a1),-(%a0)                     ; 20
	move.l %a0,(%a1)                        ; 12
	rts                                     ; 16 = 124clk
.islarge:
    addq.l  #4,a0
	jra ___large_free
.isnull:
	rts
	.even
	.globl	_malloc_size
_malloc_size:
#ifndef __FASTCALL__
    move.l 4(sp),a0
#endif
#ifdef __mcoldfire__
	cmp.l #0,%a0
#else
	cmp.w #0,%a0                                  ; 12
#endif
	jeq .isnull                                   ; 8/16
	move.l -(%a0),%d0                             ; 16
	moveq #47,%d1                                 ;  4
	cmp.l %d0,%d1                                 ;  8
	jcs .islarge                                  ; 8/16
	move.w ___small_size_for_indexes(pc,d0.l),%d0 ; 16
	ext.l %d0                                     ;  4
	rts                                           ; 16 = 92clk
.isnull:
	moveq #0,%d0
.islarge:
	rts
.lcomm ___small_index_for_size,1026
.lcomm ___small_mem_chunks,48
	.data
	.even
___alloc_small_chunks:
	.long	___init_small_chunks
	.text
	.even
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
