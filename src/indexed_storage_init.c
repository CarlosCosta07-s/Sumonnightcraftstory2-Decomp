/*
 * Behavior-level reconstruction of ROM 0x0802660C.
 * The SVC #0x0B wrapper and its register arguments are preserved as raw
 * parameters; the full memory-transfer semantics are not reconstructed here.
 */
#include <stdint.h>

#define REG32(address) (*(volatile uint32_t *)(uintptr_t)(address))
extern void bios_swi_0B(uintptr_t source, uintptr_t destination, uint32_t control);

void initialize_indexed_storage_0802660C(void) {
    uint16_t zero_halfword = 0;
    bios_swi_0B((uintptr_t)&zero_halfword, 0x030065B0u, 0x0100010Cu);

    REG32(0x030067D0u) = 0x02000000u;
    REG32(0x0300659Cu) = 0x02000100u;
    REG32(0x030065A4u) = 0x02000380u;
    REG32(0x030067CCu) = 0x02000540u;
    REG32(0x03006590u) = 0x02000580u;
    REG32(0x030067C8u) = 0x02000680u;

    uint32_t zero_word_a = 0;
    bios_swi_0B((uintptr_t)&zero_word_a, 0x02000000u, 0x02000150u);
    uint32_t zero_word_b = 0;
    bios_swi_0B((uintptr_t)&zero_word_b, 0x02000540u, 0x050000B0u);
}
