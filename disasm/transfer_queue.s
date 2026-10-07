@ Request queue used by the runtime transfer/object path.
@ Addresses in .org are ROM offsets; GBA addresses are shown in comments.
        .thumb

        .org 0x139C4
drain_transfer_requests_080139C4:
        push    {r4, r5, lr}
        ldr     r0, [pc, #0x4C]         @ 0x03006160: queue count
        ldrh    r0, [r0]
        subs    r3, r0, #1              @ begin at count-1
        lsls    r0, r3, #1
        adds    r0, r0, r3
        lsls    r0, r0, #2              @ entry index * 12
        ldr     r1, [pc, #0x44]         @ 0x03006170: queue entries
        adds    r2, r0, r1
        cmp     r3, #0
        blt     0x08013A0C
        ldr     r4, [pc, #0x40]         @ 0x040000D4: DMA3 registers
        movs    r5, #132
        lsls    r5, r5, #24             @ 0x84000000: enable + 32-bit mode
0x080139E0:
        ldr     r1, [r2, #8]            @ byte count
        ldr     r0, [r2, #0]            @ source
        str     r0, [r4, #0]
        ldr     r0, [r2, #4]            @ destination
        str     r0, [r4, #4]
        lsrs    r1, r1, #2              @ byte count -> 32-bit words
        orrs    r1, r5
        str     r1, [r4, #8]            @ start DMA3 immediately
        ldr     r0, [r4, #8]
        ldr     r0, [r4, #8]
        movs    r1, #128
        lsls    r1, r1, #24             @ 0x80000000: DMA enable bit
        subs    r3, #1
        subs    r2, #12                 @ next entry, backwards
        cmp     r0, #0
        bge     0x08013A08
0x08013A00:
        ldr     r0, [r4, #8]
        ands    r0, r1
        cmp     r0, #0
        bne     0x08013A00              @ wait until DMA3 clears enable
0x08013A08:
        cmp     r3, #0
        bge     0x080139E0
0x08013A0C:
        pop     {r4, r5}
        pop     {r0}
        bx      r0
        .org 0x13A12
        .hword  0x0000                  @ alignment
        .org 0x13A14
        .word   0x03006160
        .word   0x03006170
        .word   0x040000D4

        .org 0x13A20
enqueue_transfer_request_08013A20:
        push    {r4, r5, r6, lr}
        adds    r4, r0, #0              @ source
        adds    r5, r1, #0              @ destination
        adds    r6, r2, #0              @ length (caller value)
        ldr     r3, [pc, #0x20]         @ 0x03006160: halfword count
        ldrh    r0, [r3]
        lsls    r1, r0, #1
        adds    r1, r1, r0
        lsls    r1, r1, #2              @ index * 12 bytes
        ldr     r2, [pc, #0x1C]         @ 0x03006170: records
        adds    r1, r1, r2
        cmp     r0, #79
        bhi     0x08013A46              @ silently discard if count > 79
        str     r4, [r1]
        str     r5, [r1, #4]
        str     r6, [r1, #8]
        ldrh    r0, [r3]
        adds    r0, #1
        strh    r0, [r3]
        pop     {r4, r5, r6}
        pop     {r0}
        bx      r0
        .org 0x13A4A
        .hword  0x0000                  @ alignment
        .org 0x13A4C
        .word   0x03006160
        .word   0x03006170

        .org 0x13A54
reset_transfer_request_count_08013A54:
        ldr     r1, [pc, #4]            @ 0x03006160
        movs    r0, #0
        strh    r0, [r1]
        bx      lr
        .org 0x13A5C
        .word   0x03006160

        .org 0x13A60
clear_transfer_request_queue_08013A60:
        push    {lr}
        sub     sp, #4
        movs    r0, #0
        str     r0, [sp]                @ zero fill source
        ldr     r1, [pc, #0x0C]         @ 0x03006170
        ldr     r2, [pc, #0x10]         @ 0x050000F0
        mov     r0, sp
        bl      0x0808CF70              @ BIOS CpuSet wrapper (SWI 0x0B)
        add     sp, #4
        pop     {r0}
        bx      r0
        .org 0x13A78
        .word   0x03006170
        .word   0x050000F0              @ fill + 32-bit + 240 words = 0x3C0 bytes
