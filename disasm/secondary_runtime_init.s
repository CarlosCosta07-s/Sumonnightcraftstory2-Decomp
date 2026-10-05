@ Called by frame_update_dispatcher when indexed value 8 != 1.
@ Sets a RAM base, issues BIOS SVC #0x0B with recorded arguments,
@ then clears the word at base + 0x1A8.
@ Thumb state; .org values are ROM file offsets.
        .thumb
        .org 0x69270
initialize_secondary_runtime_block_08069270:
        push    {r4, lr}
        sub     sp, #4
        ldr     r4, [pc, #0x24]          @ global 0x03006860
        ldr     r1, [pc, #0x28]          @ base 0x02002800
        str     r1, [r4]
        mov     r2, sp
        movs    r0, #0
        strh    r0, [r2]
        ldr     r2, [pc, #0x20]          @ SVC argument 0x010000D6
        mov     r0, sp
        bl      0x0808CF70               @ BIOS SVC #0x0B wrapper
        ldr     r0, [r4]
        movs    r1, #0xD4
        lsls    r1, r1, #1               @ 0x1A8
        adds    r0, r0, r1
        movs    r1, #0
        str     r1, [r0]
        add     sp, #4
        pop     {r4}
        pop     {r0}
        bx      r0

        .org 0x6929C
        .word   0x03006860
        .word   0x02002800
        .word   0x010000D6
