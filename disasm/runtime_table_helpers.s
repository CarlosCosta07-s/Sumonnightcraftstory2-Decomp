@ Helpers for table bytes based at the address constant 0x030034C0.
@ The game-level meaning of these fields remains unknown.
@ .org values are ROM file offsets.
        .thumb
        .org 0xCF48
write_runtime_table_byte_0800CF48:
        lsls    r0, r0, #16
        lsrs    r0, r0, #16              @ zero-extend low 16 bits
        ldr     r2, [pc, #0x0C]          @ address constant 0x030034C0
        movs    r3, #0xF3
        lsls    r3, r3, #2               @ 0x3CC
        adds    r2, r2, r3
        adds    r0, r0, r2
        strb    r1, [r0]                 @ [0x0300388C + index] = low byte of r1
        bx      lr
        .org 0xCF5A
        .hword  0x0000                   @ alignment padding
        .org 0xCF5C
        .word   0x030034C0

        .org 0xCF60
set_runtime_subflag_0800CF60:
        lsls    r0, r0, #16
        lsrs    r0, r0, #16              @ zero-extend low 16 bits
        ldr     r1, [pc, #0x0C]          @ address constant 0x030034C0
        movs    r2, #0xEE
        lsls    r2, r2, #2               @ 0x3B8
        adds    r1, r1, r2
        adds    r0, r0, r1
        movs    r1, #1
        strb    r1, [r0]                 @ [0x03003878 + index] = 1
        bx      lr
        .org 0xCF74
        .word   0x030034C0

@ Four more Thumb helpers operate on data near 0x03003874.
@ The higher-level meaning of these arrays is not yet known.
@ .org values are ROM file offsets.
        .thumb
        .org 0xCF78
clear_runtime_subflag_0800CF78:
        lsls    r0, r0, #16
        lsrs    r0, r0, #16              @ zero-extend low 16 bits
        ldr     r1, [pc, #0x0C]          @ address constant 0x030034C0
        movs    r2, #0xEE
        lsls    r2, r2, #2               @ 0x3B8
        adds    r1, r1, r2
        adds    r0, r0, r1
        movs    r1, #0
        strb    r1, [r0]                 @ [0x03003878 + index] = 0
        bx      lr

        .org 0xCF8C
        .word   0x030034C0

        .org 0xCF90
write_runtime_table_halfwords_0800CF90:
        push    {r4, lr}
        ldr     r2, [pc, #0x14]          @ address constant 0x030034C0
        ldr     r4, [pc, #0x14]          @ offset 0x3D2
        adds    r3, r2, r4
        strh    r0, [r3]                 @ [0x03003892] = low halfword of r0
        movs    r0, #0xF5
        lsls    r0, r0, #2               @ 0x3D4
        adds    r2, r2, r0
        strh    r1, [r2]                 @ [0x03003894] = low halfword of r1
        pop     {r4}
        pop     {r0}
        bx      r0

        .org 0xCFA8
        .word   0x030034C0
        .word   0x000003D2

        .org 0xCFB0
clear_runtime_table_entry_0800CFB0:
        push    {r4, lr}
        ldr     r3, [pc, #0x1C]          @ address constant 0x030034C0
        lsls    r1, r0, #2
        movs    r4, #0xEF
        lsls    r4, r4, #2               @ 0x3BC
        adds    r2, r3, r4
        adds    r1, r1, r2
        movs    r2, #0
        str     r2, [r1]                 @ [0x0300387C + 4 * index] = 0
        subs    r4, #8                   @ 0x3B4
        adds    r1, r3, r4
        adds    r0, r0, r1
        strb    r2, [r0]                 @ [0x03003874 + index] = 0
        pop     {r4}
        pop     {r0}
        bx      r0

        .org 0xCFD0
        .word   0x030034C0

        .org 0xCFD4
set_runtime_table_entry_0800CFD4:
        ldr     r2, [pc, #0x1C]          @ address constant 0x030034C0
        mov     ip, r2
        lsls    r2, r0, #2
        movs    r3, #0xEF
        lsls    r3, r3, #2               @ 0x3BC
        add     r3, ip
        adds    r2, r2, r3
        str     r1, [r2]                 @ [0x0300387C + 4 * index] = value
        movs    r1, #0xED
        lsls    r1, r1, #2               @ 0x3B4
        add     r1, ip
        adds    r0, r0, r1
        movs    r1, #1
        strb    r1, [r0]                 @ [0x03003874 + index] = 1
        bx      lr

        .org 0xCFF2
        .hword  0x0000                   @ alignment padding
        .org 0xCFF4
        .word   0x030034C0
