@ Reads a signed state halfword at *(u32 *)0x03006884 + 6.
@ Dispatches states 1, 4, 8, and 12 to address-identified helpers.
@ Thumb state; .org values are ROM file offsets.
        .thumb
        .org 0x692A8
dispatch_state_080692A8:
        push    {r4, lr}
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
        b       .Lreturn_state

        .org 0x692C0
        .word   0x03006884

        .org 0x692C4
.Lstate_above_4:
        cmp     r0, #8
        beq     .Lstate_8
        cmp     r0, #12
        beq     .Lstate_12
        b       .Lreturn_state
.Lstate_1:
        bl      0x08069594
        lsls    r0, r0, #16
        asrs    r0, r0, #16
        cmp     r0, #0
        bne     .Lreturn_state
        strh    r0, [r4, #6]
        b       .Lreturn_state
.Lstate_4:
        bl      0x080695A4
        b       .Lreturn_state
.Lstate_8:
        bl      0x08066540
        b       .Lreturn_state
.Lstate_12:
        bl      0x080695E8
.Lreturn_state:
        movs    r1, #6
        ldrsh   r0, [r4, r1]
        pop     {r4}
        pop     {r1}
        bx      r1
