@ Setup reached by frame_update_dispatcher when indexed value 8 != 1.
@ Initializes indexed-memory base pointers and performs three SVC #0x0B calls.
@ Thumb state; .org values are ROM file offsets.
        .thumb
        .org 0x2660C
initialize_indexed_storage_0802660C:
        push    {r4, r5, lr}
        sub     sp, #0x0C
        mov     r1, sp
        movs    r0, #0
        strh    r0, [r1]                 @ first SVC source word
        ldr     r1, [pc, #0x50]          @ 0x030065B0
        ldr     r2, [pc, #0x50]          @ 0x0100010C
        mov     r0, sp
        bl      0x0808CF70               @ BIOS SVC #0x0B wrapper
        ldr     r0, [pc, #0x4C]          @ pointer global 0x030067D0
        movs    r1, #0x80
        lsls    r1, r1, #18              @ 0x02000000
        str     r1, [r0]
        ldr     r2, [pc, #0x48]          @ pointer global 0x0300659C
        ldr     r0, [pc, #0x4C]          @ 0x02000100
        str     r0, [r2]
        ldr     r2, [pc, #0x4C]          @ pointer global 0x030065A4
        ldr     r0, [pc, #0x4C]          @ 0x02000380
        str     r0, [r2]
        ldr     r0, [pc, #0x4C]          @ pointer global 0x030067CC
        ldr     r5, [pc, #0x50]          @ 0x02000540
        str     r5, [r0]
        ldr     r2, [pc, #0x50]          @ pointer global 0x03006590
        ldr     r0, [pc, #0x50]          @ 0x02000580
        str     r0, [r2]
        ldr     r2, [pc, #0x50]          @ pointer global 0x030067C8
        ldr     r0, [pc, #0x54]          @ 0x02000680
        str     r0, [r2]
        movs    r4, #0
        str     r4, [sp, #4]
        add     r0, sp, #4
        ldr     r2, [pc, #0x4C]          @ SVC argument 0x02000150
        bl      0x0808CF70
        str     r4, [sp, #8]
        add     r0, sp, #8
        ldr     r2, [pc, #0x48]          @ SVC argument 0x050000B0
        adds    r1, r5, #0               @ 0x02000540
        bl      0x0808CF70
        add     sp, #0x0C
        pop     {r4, r5}
        pop     {r0}
        bx      r0

        .org 0x26668
        .word   0x030065B0
        .word   0x0100010C
        .word   0x030067D0
        .word   0x0300659C
        .word   0x02000100
        .word   0x030065A4
        .word   0x02000380
        .word   0x030067CC
        .word   0x02000540
        .word   0x03006590
        .word   0x02000580
        .word   0x030067C8
        .word   0x02000680
        .word   0x02000150
        .word   0x050000B0
