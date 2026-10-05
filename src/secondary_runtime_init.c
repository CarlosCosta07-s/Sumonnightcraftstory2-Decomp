/*
 * Behavior-level reconstruction of ROM 0x08069270.
 * The SVC #0x0B call is recorded with raw arguments; its data-transfer
 * semantics are not inferred in this source excerpt.
 */
#include <stdint.h>

#define REG32(address) (*(volatile uint32_t *)(uintptr_t)(address))
extern void bios_swi_0B(uintptr_t source, uintptr_t destination, uint32_t control);

void initialize_secondary_runtime_block_08069270(void) {
    uint16_t zero_halfword = 0;
    REG32(0x03006860u) = 0x02002800u;

    bios_swi_0B((uintptr_t)&zero_halfword, 0x02002800u, 0x010000D6u);
    REG32(0x02002800u + 0x1A8u) = 0;
}
