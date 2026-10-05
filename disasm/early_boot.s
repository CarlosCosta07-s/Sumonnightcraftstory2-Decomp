@ Early ARM7TDMI reset/interrupt setup for the USA ROM (BSKE).
@ Generated with Capstone 5.0.9 from the user's local ROM.
@ File offsets equal GBA bus addresses minus 0x08000000.
@ Literal words at 0xF4, 0xF8 and 0x1C4-0x1CC are data, not instructions.

        .arm
        .org 0x00C0
        mov     r0, #0x12
        msr     CPSR_fc, r0             @ IRQ mode; prepare IRQ stack
        ldr     sp, [pc, #0x24]         @ literal 0x080000F4
        mov     r0, #0x1F
        msr     CPSR_fc, r0             @ System mode; prepare system stack
        ldr     sp, [pc, #0x1C]         @ literal 0x080000F8
        ldr     r1, [pc, #0xE4]         @ -> literal at 0x080001C4 = 0x03007FFC
        add     r0, pc, #0x18           @ 0x080000FC, IRQ dispatcher
        str     r0, [r1]                @ install BIOS IRQ vector
        ldr     r1, [pc, #0xDC]         @ -> literal at 0x080001C8 = 0x0800040D
        mov     lr, pc
        bx      r1                      @ enter Thumb at 0x0800040C
        b       0x080000C0              @ if startup returns, restart

        .org 0x00F4
stack_irq:      .word 0x03007FA0        @ IRQ stack top
stack_system:   .word 0x03007E00        @ System stack top

        .org 0x00FC
irq_dispatch:
        mov     r3, #0x04000000
        add     r3, r3, #0x200          @ IE and IF at 0x04000200/202
        ldr     r2, [r3]                @ packed IF:IE on 16-bit GBA bus
        and     r1, r2, r2, lsr #16     @ pending AND enabled interrupts
        ands    r0, r1, #0x2000         @ VBlank? (high interrupt bit check)
        strbne  r0, [r3, #-0x17C]       @ acknowledge selected request at 0x04000084
        bne     0x08000114              @ spin while that request remains set
        mov     r2, #0
        @ The following repeated tests find the lowest pending/enabled IRQ bit.
        @ Each no-match path advances r2 by four bytes in the handler table.
        ands    r0, r1, #0x0001
        bne     irq_dispatch_table
        add     r2, r2, #4
        ands    r0, r1, #0x0002
        bne     irq_dispatch_table
        add     r2, r2, #4
        ands    r0, r1, #0x0004
        bne     irq_dispatch_table
        add     r2, r2, #4
        ands    r0, r1, #0x0008
        bne     irq_dispatch_table
        add     r2, r2, #4
        ands    r0, r1, #0x0010
        bne     irq_dispatch_table
        add     r2, r2, #4
        ands    r0, r1, #0x0020
        bne     irq_dispatch_table
        add     r2, r2, #4
        ands    r0, r1, #0x0040
        bne     irq_dispatch_table
        add     r2, r2, #4
        ands    r0, r1, #0x0080
        bne     irq_dispatch_table
        add     r2, r2, #4
        ands    r0, r1, #0x0100
        bne     irq_dispatch_table
        add     r2, r2, #4
        ands    r0, r1, #0x0200
        bne     irq_dispatch_table
        add     r2, r2, #4
        ands    r0, r1, #0x0400
        bne     irq_dispatch_table
        add     r2, r2, #4
        ands    r0, r1, #0x0800
        bne     irq_dispatch_table
        add     r2, r2, #4
        ands    r0, r1, #0x1000
irq_dispatch_table:
        strh    r0, [r3, #2]            @ acknowledge selected IF bit
        ldr     r1, [pc, #0x10]          @ -> literal at 0x080001CC
        add     r1, r1, r2              @ handler table base + IRQ index
        ldr     r0, [r1]
        bx      r0

        .org 0x01C4
        .word   0x03007FFC              @ BIOS IRQ vector address
        .word   0x0800040D              @ Thumb startup entry (bit 0 set)
        .word   0x03002D00              @ IRQ handler table base
