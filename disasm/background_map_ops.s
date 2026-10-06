@ Runtime object/map operations. "Map object" is an evidence-based label:
@ entries select 0x800-stride buffers and helpers write two-row halfword strips.
        .thumb

        .org 0x5768
fill_two_row_map_strip_08005768:
        push    {r4, r5, lr}
        lsls    r1, r1, #16
        lsrs    r5, r1, #16
        lsls    r2, r2, #16
        lsls    r3, r3, #28
        orrs    r3, r2
        lsrs    r3, r3, #16              @ packed 16-bit map entry
        movs    r4, #0
        cmp     r4, r5
        bcs     0x080057D0
        adds    r2, r0, #0
        adds    r2, #0x40                @ second row is 32 halfwords later
        movs    r1, #3
        ands    r1, r5
        cmp     r5, #0
        ble     0x080057A8
        cmp     r1, #0
        beq     0x080057B6
        cmp     r1, #1
        ble     0x080057A8
        cmp     r1, #2
        ble     0x0800579E
        strh    r3, [r0]
        strh    r3, [r2]
        adds    r2, #2
        adds    r0, #2
        movs    r4, #1
0x0800579E:
        strh    r3, [r0]
        strh    r3, [r2]
        adds    r2, #2
        adds    r0, #2
        adds    r4, #1
0x080057A8:
        strh    r3, [r0]
        strh    r3, [r2]
        adds    r2, #2
        adds    r0, #2
        adds    r4, #1
        cmp     r4, r5
        bcs     0x080057D0
0x080057B6:
        strh    r3, [r0]
        strh    r3, [r2]
        strh    r3, [r0, #2]
        strh    r3, [r2, #2]
        strh    r3, [r0, #4]
        strh    r3, [r2, #4]
        strh    r3, [r0, #6]
        strh    r3, [r2, #6]
        adds    r2, #8
        adds    r0, #8
        adds    r4, #4
        cmp     r4, r5
        bcc     0x080057B6
0x080057D0:
        pop     {r4, r5}
        pop     {r0}
        bx      r0
        .org 0x57D6
        .hword  0x0000                   @ alignment padding

        .org 0xD00C
copy_terminated_runtime_halfwords_0800D00C:
        push    {r4, r5, lr}
        adds    r5, r1, #0                @ source
        lsls    r0, r0, #16
        lsrs    r3, r0, #16
        ldr     r2, [pc, #0x90]          @ 0x030038C0
        movs    r0, #0xF0
        lsls    r0, r0, #4               @ 0xF00
        ands    r0, r3
        lsrs    r0, r0, #8               @ selector = (argument & 0xF00) >> 8
        lsls    r1, r0, #4
        adds    r1, r1, r0
        lsls    r1, r1, #1               @ 34 bytes per selector
        movs    r0, #0
        adds    r1, r1, r2
        strh    r0, [r1]
        adds    r1, #2
        movs    r4, #1
        cmp     r4, #16
        bhi     0x0800D042
0x0800D032:
        strh    r0, [r1]
        strh    r0, [r1, #2]
        strh    r0, [r1, #4]
        strh    r0, [r1, #6]
        adds    r1, #8
        adds    r4, #4
        cmp     r4, #16
        bls     0x0800D032
0x0800D042:
        movs    r4, #0
        ldr     r2, [pc, #0x60]          @ 0x030038C0
        movs    r1, #0xF0
        lsls    r1, r1, #4
        ands    r1, r3
        lsrs    r1, r1, #8
        adds    r3, r5, #0
        lsls    r0, r1, #4
        adds    r0, r0, r1
        lsls    r0, r0, #1
        adds    r1, r0, r2
        ldrh    r0, [r3]
        strh    r0, [r1]
        ldrh    r0, [r3]
        cmp     r0, #0
        beq     0x0800D0A0
        adds    r3, #2
        adds    r1, #2
        adds    r4, #1
        cmp     r4, #16
        bhi     0x0800D0A0
0x0800D06C:
        adds    r2, r4, #0
        ldrh    r0, [r3]
        strh    r0, [r1]
        ldrh    r0, [r3]
        cmp     r0, #0
        beq     0x0800D0A0
        ldrh    r0, [r3, #2]
        strh    r0, [r1, #2]
        ldrh    r0, [r3, #2]
        cmp     r0, #0
        beq     0x0800D0A0
        ldrh    r0, [r3, #4]
        strh    r0, [r1, #4]
        ldrh    r0, [r3, #4]
        cmp     r0, #0
        beq     0x0800D0A0
        ldrh    r0, [r3, #6]
        strh    r0, [r1, #6]
        ldrh    r0, [r3, #6]
        cmp     r0, #0
        beq     0x0800D0A0
        adds    r3, #8
        adds    r1, #8
        adds    r2, #4
        cmp     r2, #16
        bls     0x0800D06E
0x0800D0A0:
        pop     {r4, r5}
        pop     {r0}
        bx      r0
        .org 0xD0A6
        .hword  0x0000                   @ alignment padding
        .org 0xD0A8
        .word   0x030038C0

        .org 0xD0AC
get_map_object_status_0800D0AC:
        push    {lr}
        ldrb    r2, [r0]
        lsls    r1, r2, #3
        subs    r1, r1, r2
        lsls    r1, r1, #2               @ object index * 0x1C
        ldr     r2, [pc, #0x0C]          @ 0x030034C0
        adds    r1, r1, r2
        ldrh    r0, [r0]
        cmp     r0, #0
        beq     0x0800D0C8
        ldrb    r0, [r1]
        b       0x0800D0CA
        .org 0xD0C4
        .word   0x030034C0
        .org 0xD0C8
        movs    r0, #0
        pop     {r1}
        bx      r1
        .org 0xD0CE
        .hword  0x0000

        .org 0xD0D0
get_map_object_x_0800D0D0:
        ldrb    r1, [r0]
        lsls    r0, r1, #3
        subs    r0, r0, r1
        lsls    r0, r0, #2
        ldr     r1, [pc, #0x04]          @ 0x030034C0
        adds    r0, r0, r1
        ldrb    r0, [r0, #6]
        bx      lr
        .org 0xD0DE
        .hword  0x0000
        .org 0xD0E0
        .word   0x030034C0

        .org 0xD0E4
get_map_object_y_0800D0E4:
        ldrb    r1, [r0]
        lsls    r0, r1, #3
        subs    r0, r0, r1
        lsls    r0, r0, #2
        ldr     r1, [pc, #0x04]          @ 0x030034C0
        adds    r0, r0, r1
        ldrb    r0, [r0, #7]
        bx      lr
        .org 0xD0F2
        .hword  0x0000
        .org 0xD0F4
        .word   0x030034C0

        .org 0xD0F8
set_map_object_xy_0800D0F8:
        ldrb    r3, [r0]
        lsls    r0, r3, #3
        subs    r0, r0, r3
        lsls    r0, r0, #2
        ldr     r3, [pc, #0x08]          @ 0x030034C0
        adds    r0, r0, r3
        strb    r1, [r0, #6]
        strb    r2, [r0, #7]
        bx      lr
        .org 0xD10A
        .hword  0x0000
        .org 0xD10C
        .word   0x030034C0

        .org 0xD110
set_runtime_flag_03003A70_0800D110:
        ldr     r1, [pc, #0x04]          @ 0x03003A70
        movs    r0, #1
        strh    r0, [r1]
        bx      lr
        .org 0xD116
        .hword  0x0000
        .org 0xD118
        .word   0x03003A70

        .org 0xD11C
promote_map_object_state_2_to_3_0800D11C:
        push    {lr}
        ldrb    r1, [r0]
        lsls    r0, r1, #3
        subs    r0, r0, r1
        lsls    r0, r0, #2
        ldr     r1, [pc, #0x10]          @ 0x030034C0
        adds    r1, r0, r1
        ldrb    r0, [r1]
        cmp     r0, #2
        bne     0x0800D134
        movs    r0, #3
        strb    r0, [r1]
        pop     {r0}
        bx      r0
        .org 0xD138
        .word   0x030034C0

        .org 0xD13C
demote_map_object_state_3_to_2_0800D13C:
        push    {lr}
        ldrb    r1, [r0]
        lsls    r0, r1, #3
        subs    r0, r0, r1
        lsls    r0, r0, #2
        ldr     r1, [pc, #0x10]          @ 0x030034C0
        adds    r1, r0, r1
        ldrb    r0, [r1]
        cmp     r0, #3
        bne     0x0800D154
        movs    r0, #2
        strb    r0, [r1]
        pop     {r0}
        bx      r0
        .org 0xD158
        .word   0x030034C0

        .org 0xD15C
set_map_object_field_0D_0800D15C:
        ldrb    r2, [r0]
        lsls    r0, r2, #3
        subs    r0, r0, r2
        lsls    r0, r0, #2
        ldr     r2, [pc, #0x04]          @ 0x030034C0
        adds    r0, r0, r2
        strb    r1, [r0, #0x0D]
        bx      lr
        .org 0xD16A
        .hword  0x0000
        .org 0xD16C
        .word   0x030034C0

        .org 0xD170
draw_map_object_strip_0800D170:
        push    {r4, lr}
        ldrb    r0, [r0]
        lsls    r2, r0, #3
        subs    r2, r2, r0
        lsls    r2, r2, #2
        ldr     r4, [pc, #0x34]          @ 0x030034C0
        adds    r2, r2, r4
        ldrb    r3, [r2, #8]             @ selected map-buffer index
        lsls    r3, r3, #2
        movs    r1, #0xEF
        lsls    r1, r1, #2               @ pointer table offset 0x3BC
        adds    r0, r4, r1
        adds    r3, r3, r0
        ldrb    r1, [r2, #7]             @ y
        lsls    r1, r1, #5
        ldrb    r0, [r2, #6]             @ x
        adds    r1, r1, r0
        lsls    r1, r1, #1
        ldr     r0, [r3]                 @ map buffer pointer
        adds    r0, r0, r1
        ldrb    r1, [r2, #3]             @ strip width
        ldr     r3, [pc, #0x18]          @ config offset 0x3D2
        adds    r2, r4, r3
        ldrh    r2, [r2]                 @ low map-entry bits
        adds    r3, #2
        adds    r4, r4, r3
        ldrh    r3, [r4]                 @ high map-entry nibble
        bl      0x08005768
        pop     {r4}
        pop     {r0}
        bx      r0
        .org 0xD1B0
        .word   0x030034C0
        .word   0x000003D2

        .org 0xD1B8
clear_map_object_strip_0800D1B8:
        push    {r4, r5, r6, r7, lr}
        adds    r5, r1, #0
        adds    r3, r2, #0
        lsls    r5, r5, #16
        lsrs    r5, r5, #16
        lsls    r3, r3, #16
        lsrs    r3, r3, #16
        ldr     r7, [pc, #0x64]          @ 0x030036F0
        ldrb    r1, [r0]
        lsls    r4, r1, #3
        subs    r4, r4, r1
        lsls    r4, r4, #2
        ldr     r2, [pc, #0x5C]          @ -0x230
        adds    r1, r7, r2              @ 0x030034C0
        adds    r4, r4, r1
        movs    r1, #0
        strb    r1, [r4]
        movs    r6, #0
        strh    r1, [r0]
        ldrb    r2, [r4, #8]
        lsls    r2, r2, #2
        movs    r1, #198
        lsls    r1, r1, #1               @ 0x18C: pointer table minus link-table base
        adds    r0, r7, r1
        adds    r2, r2, r0
        ldrb    r1, [r4, #7]
        lsls    r1, r1, #5
        ldrb    r0, [r4, #6]
        adds    r1, r1, r0
        lsls    r1, r1, #1
        ldr     r0, [r2]
        adds    r0, r0, r1
        ldrb    r1, [r4, #3]
        adds    r2, r5, #0
        bl      0x08005768
        ldrb    r0, [r4, #0x0B]
        lsls    r0, r0, #3
        adds    r0, r0, r7
        strb    r6, [r0]
        ldrb    r0, [r4, #0x0B]
        lsls    r0, r0, #3
        adds    r0, r0, r7
        ldrh    r0, [r0, #4]
        ldr     r1, [pc, #0x20]          @ 0x0000FFFF
        cmp     r0, r1
        beq     0x0800D224
0x0800D216:
        movs    r2, #0
        lsls    r0, r0, #3
        adds    r0, r0, r7
        strb    r2, [r0]
        ldrh    r0, [r0, #4]
        cmp     r0, r1
        bne     0x0800D218
0x0800D224:
        pop     {r4, r5, r6, r7}
        pop     {r0}
        bx      r0
        .org 0xD22A
        .hword  0x0000                   @ alignment padding
        .org 0xD22C
        .word   0x030036F0
        .word   0xFFFFFDD0
        .word   0x0000FFFF

        .org 0xD238
read_runtime_byte_03003A02_0800D238:
        ldr     r0, [pc, #0x04]          @ 0x03003A00
        ldrb    r0, [r0, #2]
        bx      lr
        .org 0xD23E
        .hword  0x0000
        .org 0xD240
        .word   0x03003A00
