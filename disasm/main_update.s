@ Top-level per-frame update dispatcher at ROM 0x080001D0.
@ Thumb state. Callee names are preserved as addresses until identified.
        .thumb
        .org 0x01D0
frame_update_dispatcher:
        push    {r4, lr}
        bl      0x080011F8
        bl      0x080063FC
        bl      0x0800D8A8
        bl      0x08007D10
        bl      0x080139AC
        bl      0x08001964
        bl      0x080126E8
        bl      0x08013710
        bl      0x0801053C
        movs    r0, #8
        bl      0x08026908               @ read indexed value 8
        cmp     r0, #1
        beq     update_gate_1_done
        bl      0x0802660C
update_gate_1_done:
        bl      0x0800D908
        bl      0x080069D8
        bl      0x08005540
        bl      0x0800A154
        bl      0x08012058
        bl      0x08009CDC
        bl      0x080548CC
        movs    r0, #8
        bl      0x08026908
        cmp     r0, #1
        beq     update_gate_2_done
        bl      0x080726C4
update_gate_2_done:
        movs    r0, #8
        bl      0x08026908
        cmp     r0, #1
        beq     update_gate_3_done
        bl      0x08069270
update_gate_3_done:
        bl      0x0807CB8C
        bl      0x0808ACCC
        ldr     r1, [pc, #0x40]          @ 0x02003200
        movs    r0, #0
        bl      0x080266DC               @ store pointer in record slot 0
        movs    r0, #0
        bl      0x080268B4               @ indexed value[0] = 0x55555555
        movs    r0, #1
        adds    r1, r4, #0
        bl      0x080268B4
        movs    r0, #2
        adds    r1, r4, #0
        bl      0x080268B4
        movs    r0, #3
        adds    r1, r4, #0
        bl      0x080268B4
        movs    r0, #4
        bl      0x08026908               @ read indexed value[4]
        bl      0x080266F8               @ forward returned value
        movs    r0, #0
        movs    r1, #0
        movs    r2, #0
        bl      0x08026728
        pop     {r4}
        pop     {r0}
        bx      r0

        .org 0x0288
        .word   0x02003200
        .word   0x55555555
