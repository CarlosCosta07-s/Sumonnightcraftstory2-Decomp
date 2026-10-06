@ Duplicate state poller found at 0x08069474.
@ It uses the same root pointer and state handlers as 0x080693E4,
@ then calls 0x0800CF78 for indices 0-3 when the state is zero.
@ Thumb state; .org values are ROM file offsets.
        .thumb
        .org 0x69474
state_poll_duplicate_08069474:
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

        .org 0x6948E
        .hword  0x0000                   @ alignment padding

        .org 0x69490
        .word   0x03006884

        .org 0x69494
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
