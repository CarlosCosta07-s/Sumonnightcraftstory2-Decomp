@ Clears the scanline updater's state and installs it as HBlank handler.
@ Thumb code; .org values are ROM file offsets.
        .thumb
        .org 0x3704
install_hblank_scanline_handler:
        push    {r4, r5, r6, r7, lr}
        mov     r7, r8
        push    {r7}
        ldr     r1, [pc, #0x64]          @ 0x03002DA0
        movs    r0, #0
        strh    r0, [r1]
        ldr     r0, [pc, #0x60]          @ 0x03002D80
        movs    r1, #0
        str     r1, [r0]
        ldr     r3, [pc, #0x60]          @ 0x03002FE0
        ldr     r4, [pc, #0x60]          @ 0x03002EB0
        ldr     r0, [pc, #0x64]          @ 0x03002DB1 (Thumb entry)
        mov     r8, r0
        ldr     r5, [pc, #0x64]          @ IRQ handler table 0x03002D00
        ldr     r6, [pc, #0x64]          @ 0x03002EC0
        mov     ip, r6
        ldr     r7, [pc, #0x64]          @ 0x03002D90
        str     r1, [r6]
        str     r1, [r6, #4]
        str     r1, [r7]
        str     r1, [r7, #4]
        adds    r2, r7, #0
        adds    r2, #8
        mov     r0, ip
        adds    r0, #8
        str     r1, [r6, #8]
        str     r1, [r0, #4]
        str     r1, [r7, #8]
        str     r1, [r2, #4]
        str     r1, [r3]
        str     r1, [r3, #4]
        str     r1, [r4]
        str     r1, [r4, #4]
        mov     r0, r8
        str     r0, [r5, #4]             @ IRQ table slot 1 = HBlank handler
        ldr     r3, [pc, #0x44]          @ IME 0x04000208
        strh    r1, [r3]                 @ temporarily disable master IRQs
        ldr     r2, [pc, #0x44]          @ IE 0x04000200
        ldrh    r0, [r2]
        movs    r1, #2
        orrs    r0, r1
        strh    r0, [r2]                 @ enable IRQ bit 1 (HBlank)
        ldr     r2, [pc, #0x3C]          @ DISPSTAT 0x04000004
        ldrh    r0, [r2]
        movs    r1, #0x10
        orrs    r0, r1
        strh    r0, [r2]                 @ enable HBlank IRQ generation
        movs    r0, #1
        strh    r0, [r3]                 @ re-enable master IRQs
        pop     {r3}
        mov     r8, r3
        pop     {r4, r5, r6, r7}
        pop     {r0}
        bx      r0

        .org 0x3770
        .word   0x03002DA0
        .word   0x03002D80
        .word   0x03002FE0
        .word   0x03002EB0
        .word   0x03002DB1
        .word   0x03002D00
        .word   0x03002EC0
        .word   0x03002D90
        .word   0x04000208
        .word   0x04000200
        .word   0x04000004

@ Confirmed callers include 0x08018D0A, 0x080191FE, 0x0807C5FA, and 0x0807C69C.
