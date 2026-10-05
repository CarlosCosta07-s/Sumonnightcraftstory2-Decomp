@ IRQ table helpers and VBlank handler for the USA ROM (BSKE).
@ Thumb state; addresses are GBA addresses.

        .thumb
        .org 0x3A08
set_irq_handler:
        lsls    r0, r0, #16
        ldr     r2, [pc, #8]             @ 0x03002D00
        lsrs    r0, r0, #14             @ low 16-bit index * 4
        adds    r0, r0, r2
        str     r1, [r0]                 @ r1 is function pointer
        bx      lr

        .org 0x3A14
irq_handler_table:
        .word   0x03002D00

        .org 0x3A18
get_irq_handler:
        lsls    r0, r0, #16
        ldr     r1, [pc, #8]             @ 0x03002D00
        lsrs    r0, r0, #14
        adds    r0, r0, r1
        ldr     r0, [r0]
        bx      lr

        .org 0x3A24
        .word   0x03002D00

        .org 0x3A28
default_irq_handler:
        bx      lr                       @ no-op handler for unused IRQs

        .org 0x3A2C
vblank_irq_handler:
        push    {lr}
        bl      0x080077E4
        ldr     r1, [pc, #0x14]          @ 0x03002ED4
        ldr     r0, [r1]
        adds    r0, #1
        str     r0, [r1]
        bl      0x0800774C
        ldr     r1, [pc, #0x0C]          @ 0x03007FF8
        movs    r0, #1
        strh    r0, [r1]
        pop     {r0}
        bx      r0

        .org 0x3A48
        .word   0x03002ED4              @ VBlank counter
        .word   0x03007FF8              @ BIOS work RAM flag
