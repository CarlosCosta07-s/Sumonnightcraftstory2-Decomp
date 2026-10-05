@ Early state reset routines called by IRQ initialization.
@ Thumb disassembly from ROM BSKE. RAM structure names are provisional.

        .thumb
        .org 0x36A8
initialize_irq_state_tables:
        push    {r4, r5, r6, r7, lr}
        ldr     r1, [pc, #0x48]         @ 0x03002DA0
        movs    r0, #0
        strh    r0, [r1]
        ldr     r1, [pc, #0x44]         @ 0x03002D80
        movs    r0, #0
        str     r0, [r1]
        movs    r1, #0
        ldr     r7, [pc, #0x40]         @ 0x03002ED0
        ldr     r5, [pc, #0x44]         @ 0x03002D40
        movs    r3, #0
        movs    r4, #0xFF
init_four_entries:
        adds    r6, r5, #0
        adds    r6, #0x20              @ second table base 0x03002D60
        lsls    r0, r1, #16
        asrs    r0, r0, #16
        lsls    r2, r0, #3
        adds    r1, r2, r5
        str     r3, [r1]
        strh    r4, [r1, #4]
        strh    r3, [r1, #6]
        adds    r2, r2, r6
        str     r3, [r2]
        strh    r4, [r1, #0x24]
        strh    r3, [r1, #0x26]
        adds    r0, #1
        lsls    r0, r0, #16
        lsrs    r1, r0, #16
        asrs    r0, r0, #16
        cmp     r0, #3
        ble     init_four_entries
        movs    r0, #0
        strh    r0, [r7]
        strh    r0, [r7, #2]
        pop     {r4, r5, r6, r7}
        pop     {r0}
        bx      r0

        .org 0x36F4
        .word   0x03002DA0
        .word   0x03002D80
        .word   0x03002ED0
        .word   0x03002D40

        .org 0x3C00
clear_irq_runtime_state:
        push    {r4, r5, r6, lr}
        ldr     r1, [pc, #0x3C]         @ 0x03002DA0
        movs    r0, #0
        strh    r0, [r1]
        ldr     r1, [pc, #0x38]         @ 0x03002D80
        movs    r0, #0
        str     r0, [r1]
        ldr     r3, [pc, #0x38]         @ 0x03002FE0
        ldr     r4, [pc, #0x38]         @ 0x03002EB0
        ldr     r1, [pc, #0x3C]         @ 0x03002EC0
        mov     ip, r1
        ldr     r5, [pc, #0x3C]         @ 0x03002D90
        str     r0, [r1]
        str     r0, [r1, #4]
        str     r0, [r5]
        str     r0, [r5, #4]
        adds    r2, r5, #0
        adds    r2, #8
        adds    r1, #8
        mov     r6, ip
        str     r0, [r6, #8]
        str     r0, [r1, #4]
        str     r0, [r5, #8]
        str     r0, [r2, #4]
        str     r0, [r3]
        str     r0, [r3, #4]
        str     r0, [r4]
        str     r0, [r4, #4]
        pop     {r4, r5, r6}
        pop     {r0}
        bx      r0

        .org 0x3C40
        .word   0x03002DA0
        .word   0x03002D80
        .word   0x03002FE0
        .word   0x03002EB0
        .word   0x03002EC0
        .word   0x03002D90

        .org 0x3DA8
install_rom_data_roots:
        ldr     r1, [pc, #0x14]         @ destination 0x03002FF0
        ldr     r0, [pc, #0x18]
        str     r0, [r1]
        ldr     r0, [pc, #0x18]
        str     r0, [r1, #4]
        ldr     r0, [pc, #0x18]
        str     r0, [r1, #8]
        ldr     r0, [pc, #0x18]
        str     r0, [r1, #0xC]
        ldr     r0, [pc, #0x18]
        str     r0, [r1, #0x10]
        bx      lr

        .org 0x3DC0
        .word   0x03002FF0              @ destination RAM structure
        .word   0x085015CC              @ ROM pointer 1 (file offset 0x5015CC)
        .word   0x08C7F5FC              @ ROM pointer 2 (file offset 0xC7F5FC)
        .word   0x08ABA81C              @ ROM pointer 3 (file offset 0xABA81C)
        .word   0x089436FC              @ ROM pointer 4 (file offset 0x9436FC)
        .word   0x08FB6DEC              @ ROM pointer 5 (file offset 0xFB6DEC)
