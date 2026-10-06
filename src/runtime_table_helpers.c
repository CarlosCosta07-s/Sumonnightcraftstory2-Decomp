/*
 * Behavior-level reconstructions of ROM 0x0800CF78, 0x0800CF90,
 * 0x0800CFB0, and 0x0800CFD4.
 * These routines access tables in IWRAM; the tables' game-level purpose
 * remains unidentified.
 */
#include <stdint.h>

#define REG8(address)  (*(volatile uint8_t *)(uintptr_t)(address))
#define REG16(address) (*(volatile uint16_t *)(uintptr_t)(address))
#define REG32(address) (*(volatile uint32_t *)(uintptr_t)(address))

#define RUNTIME_TABLE_ADDRESS 0x030034C0u
#define RUNTIME_ENTRY_BYTE_OFFSET 0x3B4u
#define RUNTIME_ENTRY_WORD_OFFSET 0x3BCu
#define RUNTIME_SUBFLAG_OFFSET 0x3B8u

void clear_runtime_subflag_0800CF78(uint32_t index) {
    uint32_t narrowed_index = (uint16_t)index;
    REG8(RUNTIME_TABLE_ADDRESS + RUNTIME_SUBFLAG_OFFSET + narrowed_index) = 0;
}

void write_runtime_table_halfwords_0800CF90(uint16_t first, uint16_t second) {
    REG16(RUNTIME_TABLE_ADDRESS + 0x3D2u) = first;
    REG16(RUNTIME_TABLE_ADDRESS + 0x3D4u) = second;
}

void clear_runtime_table_entry_0800CFB0(uint32_t index) {
    REG32(RUNTIME_TABLE_ADDRESS + RUNTIME_ENTRY_WORD_OFFSET + (index << 2)) = 0;
    REG8(RUNTIME_TABLE_ADDRESS + RUNTIME_ENTRY_BYTE_OFFSET + index) = 0;
}

void set_runtime_table_entry_0800CFD4(uint32_t index, uint32_t value) {
    REG32(RUNTIME_TABLE_ADDRESS + RUNTIME_ENTRY_WORD_OFFSET + (index << 2)) = value;
    REG8(RUNTIME_TABLE_ADDRESS + RUNTIME_ENTRY_BYTE_OFFSET + index) = 1;
}
