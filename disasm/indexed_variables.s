@ Indexed word/halfword/byte accessors used by the frame dispatcher.
@ Thumb state; literal pools and offsets are annotated from ROM.
        .thumb
        .org 0x268B4
set_indexed_value_080268B4:
        push    {lr}
        adds    r3, r1, #0               @ preserve value
        lsls    r0, r0, #16
        lsrs    r2, r0, #16              @ unsigned 16-bit index
        adds    r1, r2, #0
        cmp     r2, #0x3F
        bhi     set_indexed_value_nonword
        ldr     r0, [pc, #0x0C]          @ pointer global 0x030067D0
        ldr     r1, [r0]
        lsls    r0, r2, #2
        adds    r0, r0, r1
        str     r3, [r0]
        b       set_indexed_value_done
        .org 0x268D0
        .word   0x030067D0
        .org 0x268D4
set_indexed_value_nonword:
        ldr     r0, [pc, #0x10]          @ threshold 0x17F
        cmp     r2, r0
        bhi     set_indexed_value_byte
        ldr     r0, [pc, #0x10]          @ pointer global 0x0300659C
        ldr     r1, [r0]
        lsls    r0, r2, #1
        adds    r0, r0, r1
        subs    r0, #0x80               @ halfword index starts at 0x40
        strh    r3, [r0]
        b       set_indexed_value_done
        .org 0x268E8
        .word   0x0000017F
        .word   0x0300659C
        .org 0x268F0
set_indexed_value_byte:
        ldr     r0, [pc, #0x0C]          @ pointer global 0x030065A4
        ldr     r0, [r0]
        adds    r0, r2, r0
        ldr     r1, [pc, #0x0C]          @ -0x180
        adds    r0, r0, r1
        strb    r3, [r0]
set_indexed_value_done:
        pop     {r0}
        bx      r0
        .org 0x26900
        .word   0x030065A4
        .word   0xFFFFFE80

        .org 0x26908
get_indexed_value_08026908:
        push    {lr}
        lsls    r0, r0, #16
        lsrs    r2, r0, #16
        adds    r3, r2, #0               @ preserve index
        cmp     r2, #0x3F
        bhi     get_indexed_value_nonword
        ldr     r0, [pc, #8]             @ pointer global 0x030067D0
        ldr     r1, [r0]
        lsls    r0, r2, #2
        adds    r0, r0, r1
        ldr     r0, [r0]
        b       get_indexed_value_done
        .org 0x26920
        .word   0x030067D0
        .org 0x26924
get_indexed_value_nonword:
        ldr     r0, [pc, #0x14]          @ threshold 0x17F
        cmp     r2, r0
        bls     get_indexed_value_halfword
        ldr     r0, [pc, #0x14]          @ pointer global 0x030065A4
        ldr     r0, [r0]
        adds    r0, r2, r0
        ldr     r1, [pc, #0x10]          @ -0x180
        adds    r0, r0, r1
        ldrb    r0, [r0]
        lsls    r0, r0, #24
        asrs    r0, r0, #24              @ sign-extend byte
        b       get_indexed_value_done
        .org 0x2693C
        .word   0x0000017F
        .word   0x030065A4
        .word   0xFFFFFE80
        .org 0x26948
get_indexed_value_halfword:
        ldr     r0, [pc, #0x10]          @ pointer global 0x0300659C
        ldr     r1, [r0]
        lsls    r0, r3, #1
        adds    r0, r0, r1
        subs    r0, #0x80
        movs    r1, #0
        ldrsh   r0, [r0, r1]             @ sign-extend halfword
get_indexed_value_done:
        pop     {r1}
        bx      r1
        .org 0x2695A
        .hword  0x0000                  @ alignment
        .org 0x2695C
        .word   0x0300659C
