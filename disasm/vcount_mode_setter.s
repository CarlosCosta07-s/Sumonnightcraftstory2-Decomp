@ Setter for the signed mode byte read by VCOUNT timing helpers.
@ Thumb code; .org values are ROM file offsets.
        .thumb
        .org 0x7534
set_vcount_mode_03003052:
        ldr     r1, [pc, #4]             @ 0x03003050
        strb    r0, [r1, #2]             @ write mode byte at 0x03003052
        bx      lr
        .org 0x753A
        .hword  0x0000                  @ alignment/padding
        .org 0x753C
        .word   0x03003050

@ Observed callers:
@ 0x08018D06, 0x080191FA, 0x0807C5F6, 0x0807C698 pass 0.
@ 0x0801A9C8 and 0x0801A9E0 pass 1.
@ The callers' high-level meaning remains under investigation.
