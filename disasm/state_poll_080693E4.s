@ Dispatches the same state values as 0x080692A8.
@ If the state is zero after dispatch, calls 0x0800CF78 with 0, 1, 2, and 3.
@ Returns 1 while the signed state at *(u32 *)0x03006884 + 6 is nonzero.
@ Thumb state; .org values are ROM file offsets.
        .thumb
        .org 0x693E4
state_poll_080693E4:
        push    {r4, r5, lr}
        movs    r5, #1
        ldr     r0, [pc, #0x14]          @ pointer global 0x03006884
        ldr     r4, [r0]
        movs    r1, #6
        ldrsh   r0, [r4, r1]
        cmp     r0, #4
        beq     .Lstate_4
        cmp     r0, #4
        bgt     .Lstate_above_4
        cmp     r0, #1
        beq     .Lstate_1
        b       .Lcheck_state

        .org 0x69400
        .word   0x03006884

        .org 0x69404
.Lstate_above_4:
        cmp     r0, #8
        beq     .Lstate_8
        cmp     r0, #12
        beq     .Lstate_12
        b       .Lcheck_state
.Lstate_1:
        bl      0x08069594
        lsls    r0, r0, #16
        asrs    r0, r0, #16
        cmp     r0, #0
        bne     .Lcheck_state
        strh    r0, [r4, #6]
        b       .Lcheck_state
.Lstate_4:
        bl      0x080695A4
        b       .Lcheck_state
.Lstate_8:
        bl      0x08066540
        b       .Lcheck_state
.Lstate_12:
        bl      0x080695E8
.Lcheck_state:
        movs    r1, #6
        ldrsh   r0, [r4, r1]
        cmp     r0, #0
        bne     .Lreturn_active
        movs    r0, #0
        bl      0x0800CF78
        movs    r0, #1
        bl      0x0800CF78
        movs    r0, #2
        bl      0x0800CF78
        movs    r0, #3
        bl      0x0800CF78
        movs    r5, #0
.Lreturn_active:
        adds    r0, r5, #0
        pop     {r4, r5}
        pop     {r1}
        bx      r1
