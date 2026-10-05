@ Called by frame_update_dispatcher when indexed value 8 != 1.
@ Writes a RAM base and a ROM pointer to globals.
@ Thumb state; .org values are ROM file offsets.
        .thumb
        .org 0x726C4
initialize_runtime_pointer_roots_080726C4:
        ldr     r1, [pc, #0x0C]          @ 0x03006894
        ldr     r0, [pc, #0x10]          @ 0x02001000
        str     r0, [r1]
        ldr     r1, [pc, #0x10]          @ 0x0300689C
        ldr     r0, [pc, #0x10]          @ 0x084F3284
        str     r0, [r1]
        bx      lr
        .balign 4

        .org 0x726D4
        .word   0x03006894
        .word   0x02001000
        .word   0x0300689C
        .word   0x084F3284
