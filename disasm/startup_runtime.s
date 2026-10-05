@ Startup runtime helpers, locally disassembled from ROM BSKE.
@ Thumb state unless otherwise noted; addresses are GBA addresses.
@ Literal words are labeled separately from instructions.

        .thumb
        .org 0x0290
set_startup_state:
        ldr     r1, [pc, #8]             @ literal 0x0800029C = 0x030028EC
        lsls    r0, r0, #16
        asrs    r0, r0, #16             @ sign-extend low 16-bit argument
        str     r0, [r1]
        bx      lr

        .org 0x02A0
get_startup_state:
        ldr     r0, [pc, #4]             @ literal 0x080002A8 = 0x030028EC
        ldr     r0, [r0]
        bx      lr

        .org 0x02AC
set_startup_state_one:
        ldr     r1, [pc, #4]             @ literal 0x080002B4 = 0x030028EC
        movs    r0, #1
        str     r0, [r1]
        bx      lr

        .org 0x02B8
memory_and_hardware_init:
        push    {lr}
        sub     sp, #8
        ldr     r1, [pc, #0x74]         @ 0x04000204 WAITCNT
        ldr     r2, [pc, #0x78]         @ 0x00004014
        mov     r0, r2
        strh    r0, [r1]                @ WAITCNT = 0x4014

        @ DMA3 fill descriptors: source is a stack word held fixed;
        @ destination is incrementing; transfer is 32-bit/immediate.
        ldr     r2, [pc, #0x74]         @ 0x55555555
        str     r2, [sp]
        ldr     r0, [pc, #0x74]         @ DMA3 base 0x040000D4
        mov     r1, sp
        str     r1, [r0]                @ DMA3 source
        movs    r1, #0x80
        lsls    r1, r1, #0x12           @ destination 0x02000000
        str     r1, [r0, #4]
        ldr     r1, [pc, #0x6C]         @ count/control 0x85010000
        str     r1, [r0, #8]
        ldr     r1, [r0, #8]

        mov     r2, sp
        movs    r1, #0xC0
        lsls    r1, r1, #0x12           @ destination 0x03000000
        str     r1, [r0, #4]
        ldr     r1, [pc, #0x60]
        str     r1, [r0, #8]
        ldr     r1, [r0, #8]

        movs    r2, #0
        str     r2, [sp]
        mov     r1, sp
        str     r1, [r0]
        movs    r1, #0xC0
        lsls    r1, r1, #0x13           @ destination 0x06000000
        str     r1, [r0, #4]
        ldr     r1, [pc, #0x50]
        str     r1, [r0, #8]
        ldr     r1, [r0, #8]

        movs    r1, #0xA0
        str     r1, [sp]
        mov     r1, sp
        str     r1, [r0]
        movs    r1, #0xE0
        lsls    r1, r1, #0x13           @ destination 0x07000000
        str     r1, [r0, #4]
        ldr     r1, [pc, #0x40]
        str     r1, [r0, #8]
        ldr     r1, [r0, #8]

        add     r1, sp, #4
        strh    r2, [r1]                @ zero fill word at sp+4
        str     r1, [r0]
        movs    r1, #0xA0
        lsls    r1, r1, #0x13           @ destination 0x05000000
        str     r1, [r0, #4]
        ldr     r1, [pc, #0x30]
        str     r1, [r0, #8]
        ldr     r0, [r0, #8]

        bl      0x08003960
        bl      0x08003DA8
        add     sp, #8
        pop     {r0}
        bx      r0

        .org 0x0334
        .word   0x04000204              @ WAITCNT
        .word   0x00004014              @ WAITCNT value
        .word   0x55555555              @ fill pattern
        .word   0x040000D4              @ DMA3 source register
        .word   0x85010000              @ DMA3 count/control
        .word   0x85010000
        .word   0x85010000
        .word   0x85010000
        .word   0x85010000              @ literal pool ends at 0x08000358
