/*
 * Behavior-level reconstructions of the runtime table helpers around ROM
 * 0x0800CEF8-0x0800CFF8. Their consumers include background-map code, but
 * several fields' exact game-level roles remain under investigation.
 */
#include <stdint.h>

#define REG8(address)  (*(volatile uint8_t *)(uintptr_t)(address))
#define REG16(address) (*(volatile uint16_t *)(uintptr_t)(address))
#define REG32(address) (*(volatile uint32_t *)(uintptr_t)(address))

#define RUNTIME_TABLE_ADDRESS 0x030034C0u
#define RUNTIME_CONFIG_PAIR_A_OFFSET 0x3A0u
#define RUNTIME_CONFIG_PAIR_B_OFFSET 0x3A8u
#define RUNTIME_ENTRY_BYTE_OFFSET 0x3B4u
#define RUNTIME_ENTRY_WORD_OFFSET 0x3BCu
#define RUNTIME_SUBFLAG_OFFSET 0x3B8u
#define RUNTIME_OTHER_BYTE_OFFSET 0x3CCu
#define RUNTIME_MODE_BYTE_OFFSET 0x3D0u

void write_runtime_config_pair_a_0800CEF8(uint32_t first, uint32_t second) {
    REG32(RUNTIME_TABLE_ADDRESS + RUNTIME_CONFIG_PAIR_A_OFFSET) = first;
    REG32(RUNTIME_TABLE_ADDRESS + RUNTIME_CONFIG_PAIR_A_OFFSET + 4u) = second;
}

void write_runtime_config_pair_b_0800CF18(uint32_t first, uint32_t second) {
    REG32(RUNTIME_TABLE_ADDRESS + RUNTIME_CONFIG_PAIR_B_OFFSET) = first;
    REG32(RUNTIME_TABLE_ADDRESS + RUNTIME_CONFIG_PAIR_B_OFFSET + 4u) = second;
}

void write_runtime_config_byte_0800CF38(uint32_t value) {
    REG8(RUNTIME_TABLE_ADDRESS + RUNTIME_MODE_BYTE_OFFSET) = (uint8_t)value;
}

void write_runtime_table_byte_0800CF48(uint32_t index, uint32_t value) {
    uint32_t narrowed_index = (uint16_t)index;
    REG8(RUNTIME_TABLE_ADDRESS + RUNTIME_OTHER_BYTE_OFFSET + narrowed_index) = (uint8_t)value;
}

void set_runtime_subflag_0800CF60(uint32_t index) {
    uint32_t narrowed_index = (uint16_t)index;
    REG8(RUNTIME_TABLE_ADDRESS + RUNTIME_SUBFLAG_OFFSET + narrowed_index) = 1;
}

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

uint32_t read_runtime_table_entry_0800CFF8(uint32_t index) {
    return REG32(RUNTIME_TABLE_ADDRESS + RUNTIME_ENTRY_WORD_OFFSET + (index << 2));
}
