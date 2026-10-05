/*
 * Behavior-level reconstruction of ROM routine 0x08003704.
 * This clears scanline callback tables and installs the copied Thumb routine
 * as IRQ handler-table slot 1 (HBlank).
 */
#include <stdint.h>

#define REG16(address) (*(volatile uint16_t *)(uintptr_t)(address))
#define REG32(address) (*(volatile uint32_t *)(uintptr_t)(address))

void install_hblank_scanline_handler(void) {
    REG16(0x03002DA0u) = 0;
    REG32(0x03002D80u) = 0;

    REG32(0x03002EC0u) = 0;
    REG32(0x03002EC4u) = 0;
    REG32(0x03002EC8u) = 0;
    REG32(0x03002ECCu) = 0;
    REG32(0x03002D90u) = 0;
    REG32(0x03002D94u) = 0;
    REG32(0x03002D98u) = 0;
    REG32(0x03002D9Cu) = 0;
    REG32(0x03002FE0u) = 0;
    REG32(0x03002FE4u) = 0;
    REG32(0x03002EB0u) = 0;
    REG32(0x03002EB4u) = 0;

    REG32(0x03002D04u) = 0x03002DB1u; /* slot 1, Thumb pointer */

    REG16(0x04000208u) = 0; /* IME off during IRQ configuration */
    REG16(0x04000200u) |= 0x0002u; /* IE: HBlank */
    REG16(0x04000004u) |= 0x0010u; /* DISPSTAT: request HBlank IRQ */
    REG16(0x04000208u) = 1; /* IME on */
}
