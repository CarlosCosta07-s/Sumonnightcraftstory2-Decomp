/*
 * Behavior-level reconstruction of ROM 0x080726C4.
 * The destination globals are preserved as address-based names because the
 * pointed-to structures have not yet been identified.
 */
#include <stdint.h>

#define REG32(address) (*(volatile uint32_t *)(uintptr_t)(address))

void initialize_runtime_pointer_roots_080726C4(void) {
    REG32(0x03006894u) = 0x02001000u;
    REG32(0x0300689Cu) = 0x084F3284u;
}
