@ VBlank support helpers for USA revision BSKE.
@ .org values are ROM file offsets; all code is Thumb.
@ Mode/flag semantics are descriptive and provisional.

        .thumb
        .org 0x7730
set_vcount_update_flag:
        ldr     r1, [pc, #4]             @ 0x03003040
        strb    r0, [r1]
        bx      lr
        .org 0x7738
        .word   0x03003040

        .org 0x773C
get_vcount_update_flag:
        ldr     r0, [pc, #8]             @ 0x03003040
        ldrb    r0, [r0]
        lsls    r0, r0, #24
        asrs    r0, r0, #24              @ sign-extend the byte
        bx      lr
        .org 0x7748
        .word   0x03003040

        .org 0x774C
vcount_delta_mode_one:
        push    {r4, r5, lr}
        ldr     r0, [pc, #0x40]          @ 0x03003050
        ldrb    r0, [r0, #2]             @ signed mode byte at 0x03003052
        lsls    r0, r0, #24
        asrs    r0, r0, #24
        cmp     r0, #1
        bne     vcount_delta_mode_one_done
        ldr     r0, [pc, #0x38]          @ 0x03003040
        ldrb    r0, [r0]
        lsls    r0, r0, #24
        asrs    r0, r0, #24
        cmp     r0, #0
        bne     vcount_delta_mode_one_done
        ldr     r4, [pc, #0x30]          @ 0x04000006 (VCOUNT)
        ldrh    r0, [r4]
        adds    r5, r0, #0               @ sample before sound-engine update
        bl      0x0808BB38               @ wrapper to 0x0808AE94
        ldr     r1, [pc, #0x28]          @ 0x0300303C
        ldrh    r4, [r4]
        strh    r4, [r1]                 @ store raw after-sample
        lsls    r0, r4, #16
        lsrs    r0, r0, #16
        cmp     r0, r5
        bhs     vcount_delta_mode_one_subtract
        adds    r0, r4, #0
        adds    r0, #0xE3
        strh    r0, [r1]
vcount_delta_mode_one_subtract:
        ldrh    r0, [r1]
        subs    r0, r0, r5
        strh    r0, [r1]
vcount_delta_mode_one_done:
        pop     {r4, r5}
        pop     {r0}
        bx      r0

        .org 0x7790
        .word   0x03003050
        .word   0x03003040
        .word   0x04000006
        .word   0x0300303C

        .org 0x77A0
vcount_delta_mode_zero:
        push    {r4, r5, lr}
        ldr     r0, [pc, #0x34]          @ 0x03003050
        ldrb    r0, [r0, #2]             @ signed mode byte at 0x03003052
        lsls    r0, r0, #24
        asrs    r0, r0, #24
        cmp     r0, #0
        bne     vcount_delta_mode_zero_done
        ldr     r4, [pc, #0x2C]          @ 0x04000006 (VCOUNT)
        ldrh    r0, [r4]
        adds    r5, r0, #0
        bl      0x0808BB38               @ wrapper to 0x0808AE94
        ldr     r1, [pc, #0x24]          @ 0x0300303C
        ldrh    r4, [r4]
        strh    r4, [r1]
        lsls    r0, r4, #16
        lsrs    r0, r0, #16
        cmp     r0, r5
        bhs     vcount_delta_mode_zero_subtract
        adds    r0, r4, #0
        adds    r0, #0xE3
        strh    r0, [r1]
vcount_delta_mode_zero_subtract:
        ldrh    r0, [r1]
        subs    r0, r0, r5
        strh    r0, [r1]
vcount_delta_mode_zero_done:
        pop     {r4, r5}
        pop     {r0}
        bx      r0

        .org 0x77D8
        .word   0x03003050
        .word   0x04000006
        .word   0x0300303C

        .org 0x77E4
vblank_sound_service_wrapper:
        push    {lr}
        bl      0x0808B474               @ sound-engine VBlank service candidate
        pop     {r0}
        bx      r0

        .org 0x77F0
get_byte_03003050:
        ldr     r0, [pc, #4]             @ 0x03003050
        ldrb    r0, [r0]
        bx      lr
        .org 0x77F8
        .word   0x03003050
