.section	__TEXT,__text,regular,pure_instructions
.build_version macos, 13, 0	sdk_version 14, 0
.globl	_print_array 
.p2align	2

_print_array:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32] ; 16-byte Folded Spill
	add	x29, sp, #32
	stur wzr, [x29, #-4]
	stur w0, [x29, #-8]
	str	wzr, [sp, #12]
	b LOOP_HEADER_PA

    LOOP_HEADER_PA:
        ldr	w8, [sp, #12] ; i
        subs w8, w8, #10
        cset w8, ge
        tbnz w8, #0, LOOP_END_PA
        b LOOP_BODY_PA

    LOOP_BODY_PA:
        adrp	 x10, _array@PAGE
        add	x10, x10, _array@PAGEOFF

        ldr	w9, [sp, #12] ; i
        ldr	w9, [x10, x9, lsl #2]  ; array[i]
        str	x9, [sp]

        adrp	x0, l_.str@PAGE
        add	x0, x0, l_.str@PAGEOFF
        bl	_printf

        ldr	w8, [sp, #12] ; i
        add	w8, w8, #1    ; i += 1
        str	w8, [sp, #12]
        b LOOP_HEADER_PA
    LOOP_END_PA:

    ; printf("\n")
    adrp	x0, l_.str.end@PAGE
    add	x0, x0, l_.str.end@PAGEOFF
    bl	_printf

	ldp	x29, x30, [sp, #32] ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
;} end _print_array

.section	__TEXT,__text,regular,pure_instructions
.globl	_mergesort 
.p2align	2

; void mergesort(int lo, int hi) : expects args (lo, hi) => (w0, w1)
_mergesort:
	sub	sp, sp, #96
	stp	x29, x30, [sp, #80] ; 16-byte Folded Spill
	add	x29, sp, #80
	stur wzr, [x29, #-4]
	stur w0, [x29, #-8]

    ; if lo == hi: return
    subs w8, w1, w0
    cset w8, eq
    tbnz w8, #0, RETURN

    ; mid = (lo+hi) // 2
    add w2, w0, w1      
    lsr w2, w2, #1 

	str	w0, [sp]      ; lo
	str	w1, [sp, #4]  ; hi
	str	w2, [sp, #8]  ; mid

    ; mergesort (lo, mid)
    ldr	w0, [sp]      ; lo = lo
    ldr w1, [sp, #8]  ; hi = mid
    bl _mergesort

    ; mergesort (mid+1, hi)
    ldr	w2, [sp, #8]
    add w0, w2, #1    ; lo = mid+1
    ldr	w1, [sp, #4]  ; hi = hi
    bl _mergesort

    ldr	w0, [sp]      ; lo
	ldr	w1, [sp, #4]  ; hi
	ldr	w2, [sp, #8]  ; mid
    add w3, w2, #1    ; mid+1
    sub w4, w1, w0  
    add w4, w4, #1    ; hi-lo+1;

	str	w0, [sp, #12]  ; i
	str	w3, [sp, #16]  ; j
	str	wzr, [sp, #20] ; k
	str	w4, [sp, #24]  ; sz
	b MERGE_LOOP_HEADER

    MERGE_LOOP_HEADER:
        ldr	w8, [sp, #20] ; k
        ldr	w4, [sp, #24] ; sz
        subs w8, w8, w4
        cset w8, ge
        tbnz w8, #0, MERGE_LOOP_END
        b MERGE_LOOP_BODY

    MERGE_LOOP_BODY:
    	ldr	w1, [sp, #4]   ; hi
	    ldr	w2, [sp, #8]   ; mid
        ldr	w5, [sp, #12]  ; i
        ldr	w6, [sp, #16]  ; j

        adrp	 x10, _array@PAGE
        add	x10, x10, _array@PAGEOFF
        add x13, sp, #28 ; swap base offest

        ; if (i > mid)
        subs w8, w5, w2
        cset w8, gt
        tbnz w8, #0, INCR_J

        ; else if (j > hi)
        subs w8, w6, w1
        cset w8, gt
        tbnz w8, #0, INCR_I

        ; else if (array[i] < array[j])
        ldr	w11, [x10, x5, lsl #2]  ; array[i]
        ldr	w12, [x10, x6, lsl #2]  ; array[j]
        subs w8, w11, w12
        cset w8, lt
        tbnz w8, #0, INCR_I
        b INCR_J

        INCR_J:
            ldr	w8, [sp, #20]           ; k
            ldr	w12, [x10, x6, lsl #2]  ; array[j]
            str w12, [x13, x8, lsl #2]  ; swap[k] = array[j];
            add w6, w6, #1              ; j += 1
            str	w6, [sp, #16]
            b INCR_K

        INCR_I:
            ldr	w8, [sp, #20]           ; k
            ldr	w12, [x10, x5, lsl #2]  ; array[i]
            str w12, [x13, x8, lsl #2]  ; swap[k] = array[i];
            add w5, w5, #1              ; i += 1
            str	w5, [sp, #12]
            b INCR_K

        INCR_K:
            ldr	w8, [sp, #20]          ; k
            add	w8, w8, #1             ; k += 1
            str	w8, [sp, #20]
            b MERGE_LOOP_HEADER
    MERGE_LOOP_END:

	str	wzr, [sp, #20]    ; k = 0
    COPY_LOOP_HEADER:
        ldr	w8, [sp, #20] ; k
        ldr	w4, [sp, #24] ; sz
        subs w8, w8, w4
        cset w8, ge
        tbnz w8, #0, COPY_LOOP_END
        b COPY_LOOP_BODY

    COPY_LOOP_BODY:
        adrp	 x10, _array@PAGE
        add	x10, x10, _array@PAGEOFF
        add x13, sp, #28 ; swap offest

        ldr	w0, [sp]                ; lo
        ldr	w8, [sp, #20]           ; k
        add	w7, w0, w8              ; lo+k
        ldr	w12, [x13, x8, lsl #2]  ; swap[k]
        str w12, [x10, x7, lsl #2]  ; array[lo+k] = swap[k];

        add	w8, w8, #1              ; k += 1
        str	w8, [sp, #20]
        b COPY_LOOP_HEADER
    COPY_LOOP_END:
    b RETURN

    RETURN:
	ldp	x29, x30, [sp, #80] ; 16-byte Folded Reload
	add	sp, sp, #96
	ret
;} end _mergesort

.section	__TEXT,__text,regular,pure_instructions
.globl	_main 
.p2align	2

_main:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32] ; 16-byte Folded Spill
	add	x29, sp, #32
	stur wzr, [x29, #-4]
	stur w0, [x29, #-8]
	str	x1, [sp, #16]

    bl _print_array  ; array before sort
    mov w0, #0       ; lo = 0
    mov w1, #9       ; hi = len(array)-1
    bl _mergesort    ; sort array
    bl _print_array  ; array after sort

    mov	w0, #0
	ldp	x29, x30, [sp, #32] ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
;} end _main


.section	__DATA,__data
.globl	_array                          ; @array
.p2align	2, 0x0

_array:
	.long	12                              ; 0xc
	.long	33                              ; 0x21
	.long	18                              ; 0x12
	.long	32                              ; 0x20
	.long	55                              ; 0x37
	.long	78                              ; 0x4e
	.long	15                              ; 0xf
	.long	42                              ; 0x2a
	.long	7                               ; 0x7
	.long	99                              ; 0x63

.section	__TEXT,__cstring,cstring_literals

l_.str:                                 ; @.str
	.asciz	"%d,"

l_.str.end:                             ; @.str.end
	.asciz	"\n"
