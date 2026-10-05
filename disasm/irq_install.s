@ IRQ subsystem install routine called from 0x080002B8.
@ Thumb, ROM BSKE. Literal pool begins at 0x080039CC.

        .thumb
        .org 0x3960
install_irq_system:
        push    {lr}
        ldr     r1, [pc, #0x68]         @ 0x03002ED4, reset VBlank counter
        movs    r0, #0
        str     r0, [r1]
        bl      0x08003C00
        bl      0x080036A8

        movs    r0, #0
        ldr     r3, [pc, #0x5C]         @ IRQ handler table 0x03002D00
        ldr     r2, [pc, #0x5C]         @ default Thumb handler 0x08003A29
set_default_handler:
        lsls    r1, r0, #16
        asrs    r1, r1, #16
        lsls    r0, r1, #2
        adds    r0, r0, r3
        str     r2, [r0]
        adds    r1, #1
        lsls    r1, r1, #16
        lsrs    r0, r1, #16
        asrs    r1, r1, #16
        cmp     r1, #12
        ble     set_default_handler     @ fill entries 0..12

        @ Copy ARM dispatcher plus its literal pool into IWRAM.
        ldr     r1, [pc, #0x48]         @ DMA3 source register 0x040000D4
        ldr     r0, [pc, #0x4C]         @ source 0x080000FC
        str     r0, [r1]
        ldr     r2, [pc, #0x4C]         @ destination 0x03002EE0
        str     r2, [r1, #4]
        ldr     r3, [pc, #0x4C]         @ count/control 0x80000080
        str     r3, [r1, #8]            @ 0x80 halfwords, immediate, 16-bit
        ldr     r0, [r1, #8]            @ synchronize with DMA completion

        @ Install copied IRQ entry at BIOS vector and copy a second ROM blob.
        ldr     r0, [pc, #0x48]         @ 0x03007FFC
        str     r2, [r0]
        ldr     r0, [pc, #0x48]         @ source 0x08003C59
        str     r0, [r1]
        ldr     r0, [pc, #0x48]         @ destination 0x03002DB0
        str     r0, [r1, #4]
        str     r3, [r1, #8]
        ldr     r0, [r1, #8]

        @ Set VBlank handler for table slot 0.
        ldr     r1, [pc, #0x44]         @ 0x08003A2D, Thumb handler 0x08003A2C
        movs    r0, #0
        bl      0x08003A08              @ set_irq_handler(index, function)

        ldr     r1, [pc, #0x40]         @ IE = 0x04000200
        ldr     r2, [pc, #0x44]         @ enabled mask 0x2001
        mov     r0, r2
        strh    r0, [r1]
        ldr     r1, [pc, #0x40]         @ DISPSTAT = 0x04000004
        movs    r0, #8                  @ enable VBlank IRQ
        strh    r0, [r1]
        ldr     r1, [pc, #0x40]         @ IME = 0x04000208
        movs    r0, #1                  @ global IRQ enable
        strh    r0, [r1]
        pop     {r0}
        bx      r0

        .org 0x39CC
        .word   0x03002ED4              @ VBlank counter
        .word   0x03002D00              @ handler table
        .word   0x08003A29              @ default no-op (Thumb bit set)
        .word   0x040000D4              @ DMA3 source register
        .word   0x080000FC              @ source: ARM dispatcher
        .word   0x03002EE0              @ destination: copied IRQ dispatcher
        .word   0x80000080              @ DMA3 count/control
        .word   0x03007FFC              @ BIOS IRQ vector slot
        .word   0x08003C59              @ source: copied ROM blob
        .word   0x03002DB0              @ destination: copied blob
        .word   0x08003A2D              @ VBlank handler (Thumb)
        .word   0x04000200              @ IE
        .word   0x00002001              @ IE mask: bits 0 and 13
        .word   0x04000004              @ DISPSTAT
        .word   0x04000208              @ IME
