/*
 * Reconstructed indexed value accessors at ROM 0x080268B4/0x08026908.
 * The ranges and signed loads follow the Thumb instructions; field meanings
 * and the pointer initializers remain under analysis.
 */
#include <stdint.h>

#define GLOBAL_WORD_BASE_PTR (*(volatile uint32_t *)(uintptr_t)0x030067D0u)
#define GLOBAL_HALF_BASE_PTR (*(volatile uint32_t *)(uintptr_t)0x0300659Cu)
#define GLOBAL_BYTE_BASE_PTR (*(volatile uint32_t *)(uintptr_t)0x030065A4u)

int32_t get_indexed_value_08026908(uint16_t index) {
    if (index <= 0x3Fu) {
        uintptr_t base = GLOBAL_WORD_BASE_PTR;
        return *(volatile int32_t *)(base + 4u * index);
    }
    if (index <= 0x17Fu) {
        uintptr_t base = GLOBAL_HALF_BASE_PTR;
        return *(volatile int16_t *)(base + 2u * index - 0x80u);
    }
    uintptr_t base = GLOBAL_BYTE_BASE_PTR;
    return *(volatile int8_t *)(base + index - 0x180u);
}

void set_indexed_value_080268B4(uint16_t index, uint32_t value) {
    if (index <= 0x3Fu) {
        uintptr_t base = GLOBAL_WORD_BASE_PTR;
        *(volatile uint32_t *)(base + 4u * index) = value;
        return;
    }
    if (index <= 0x17Fu) {
        uintptr_t base = GLOBAL_HALF_BASE_PTR;
        *(volatile uint16_t *)(base + 2u * index - 0x80u) = (uint16_t)value;
        return;
    }
    uintptr_t base = GLOBAL_BYTE_BASE_PTR;
    *(volatile uint8_t *)(base + index - 0x180u) = (uint8_t)value;
}
