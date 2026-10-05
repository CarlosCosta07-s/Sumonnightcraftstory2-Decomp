@ Initial Thumb startup at the reset stub's BX target.
@ Generated from USA ROM BSKE with Capstone 5.0.9.
@ Offsets are ROM file offsets; addresses are in the 0x08000000 ROM window.

        .thumb
        .org 0x040C
startup_entry:
        push    {lr}
        bl      0x080002B8
        ldr     r1, [pc, #0x14]         @ literal at 0x08000428
        movs    r0, #0
        str     r0, [r1]                @ target 0x030028EC
startup_loop:
        bl      0x080001D0
        movs    r0, #1
        bl      0x08000290
        bl      0x080003C4
        b       startup_loop

        .org 0x0428
startup_ram_pointer:
        .word   0x030028EC              @ loaded at 0x08000412

        .org 0x042C
next_function:
        @ Function prologue begins here; not yet fully classified.
