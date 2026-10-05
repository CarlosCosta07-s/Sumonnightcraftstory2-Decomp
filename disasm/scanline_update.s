@ Copied Thumb scanline updater at ROM 0x08003C58.
@ Startup copies 0x100 bytes beginning here to IWRAM 0x03002DB0.
@ Code ends at 0x08003D2E; literals remain inside the copied block.

        .thumb
        .org 0x3C58
scanline_update:
        ldr     r0, [pc, #0xD4]         @ VCOUNT 0x04000006
        ldrh    r3, [r0]
        movs    r1, #0xA0
        cmp     r3, r1
        bmi     scanline_active         @ continue while VCOUNT < 160
        bx      lr

scanline_active:
        push    {r4, r5, r6}
        adds    r4, r3, #0              @ current scanline
        ldr     r0, [pc, #0xC8]         @ active slot at 0x03002DA0
        ldrh    r6, [r0]
        ldr     r5, [pc, #0xC8]         @ destination pointer table 0x03002EC0
        lsls    r3, r6, #2
        adds    r0, r3, r5
        ldr     r2, [r0]
        cmp     r2, #0
        beq     scanline_second_stream
        ldr     r0, [pc, #0xC0]         @ source pointer table 0x03002D90
        adds    r0, r3, r0
        ldr     r1, [r0]
        lsls    r0, r4, #1
        adds    r0, r0, r1
        ldrh    r0, [r0]
        strh    r0, [r2]

scanline_second_stream:
        adds    r5, #8                  @ destination pointer table 0x03002EC8
        adds    r5, r5, r3
        ldr     r2, [r5]
        cmp     r2, #0
        beq     scanline_events
        ldr     r0, [pc, #0xAC]         @ source pointer table 0x03002D90
        adds    r0, #8                  @ second source table: 0x03002D98
        adds    r0, r0, r3
        ldr     r1, [r0]
        lsls    r0, r4, #1
        adds    r0, r0, r1
        ldrh    r0, [r0]
        strh    r0, [r2]

scanline_events:
        ldr     r5, [pc, #0xA0]         @ event table 0x03002D40
        lsls    r3, r6, #5              @ 0x20-byte record for active slot
        adds    r2, r3, r5
        ldrh    r0, [r2, #4]
        cmp     r0, r4
        bne     event_1
        ldr     r1, [r2]
        ldrh    r0, [r2, #6]
        strh    r0, [r1]
event_1:
        ldrh    r0, [r2, #0xC]
        cmp     r0, r4
        bne     event_2
        adds    r0, r5, #0
        adds    r0, #8
        adds    r0, r0, r3
        ldr     r1, [r0]
        ldrh    r0, [r2, #0xE]
        strh    r0, [r1]
event_2:
        ldrh    r0, [r2, #0x14]
        cmp     r0, r4
        bne     event_3
        adds    r0, r5, #0
        adds    r0, #0x10
        adds    r0, r0, r3
        ldr     r1, [r0]
        ldrh    r0, [r2, #0x16]
        strh    r0, [r1]
event_3:
        ldrh    r0, [r2, #0x1C]
        cmp     r0, r4
        bne     event_streams
        adds    r0, r5, #0
        adds    r0, #0x18
        adds    r0, r0, r3
        ldr     r1, [r0]
        ldrh    r0, [r2, #0x1E]
        strh    r0, [r1]

event_streams:
        ldr     r5, [pc, #0x5C]         @ pointer table 0x03002FE0
        lsls    r3, r6, #2
        adds    r2, r3, r5
        ldrh    r0, [r2]
        cmp     r0, #0
        beq     scanline_done
        lsls    r2, r6, #2
        adds    r0, r2, r5
        ldr     r0, [r0]                @ first per-line data stream
        lsls    r3, r4, #3
        adds    r1, r0, r3
        ldr     r0, [pc, #0x4C]         @ second pointer table 0x03002EB0
        adds    r0, r2, r0
        ldr     r2, [r0]
        adds    r2, r2, r3
        ldr     r3, [pc, #0x48]         @ hardware base 0x04000028
        ldrh    r0, [r1]
        strh    r0, [r3]
        ldrh    r0, [r1, #2]
        strh    r0, [r3, #2]
        ldrh    r0, [r1, #4]
        strh    r0, [r3, #4]
        ldrh    r0, [r1, #6]
        strh    r0, [r3, #6]
        ldr     r1, [pc, #0x38]         @ hardware base 0x04000020
        ldrh    r0, [r2]
        strh    r0, [r1]
        ldrh    r0, [r2, #2]
        strh    r0, [r1, #4]
        ldrh    r0, [r2, #4]
        strh    r0, [r1, #6]
        ldrh    r0, [r2, #6]
        strh    r0, [r1, #0xA]
scanline_done:
        pop     {r4, r5, r6}
        bx      lr

        .org 0x3D30
        .word   0x04000006              @ VCOUNT
        .word   0x03002DA0              @ active slot index
        .word   0x03002EC0              @ first destination pointer table
        .word   0x03002D90              @ source pointer table
        .word   0x03002D90              @ second source table is +8
        .word   0x03002D40              @ per-slot event records
        .word   0x03002FE0              @ first per-line stream pointers
        .word   0x03002EB0              @ second per-line stream pointers
        .word   0x04000028              @ IO register base A
        .word   0x04000020              @ IO register base B
