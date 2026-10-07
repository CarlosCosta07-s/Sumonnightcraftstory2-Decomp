/*
 * Source-like reconstruction of command-table entry 169 at 0x08023DCC.
 * Helper 0x08015BAC and the purpose of the byte flag remain unknown.
 */
#include <stdint.h>

#define EVENT_FLAG_ROOT 0x03006598u

extern void unresolved_08015BAC(uint32_t incoming_r0);

int32_t event_command_169_08023DCC(uint32_t incoming_r0)
{
    unresolved_08015BAC(incoming_r0);

    uint32_t flag_base =
        *(volatile uint32_t *)(uintptr_t)EVENT_FLAG_ROOT;
    *(volatile uint8_t *)(uintptr_t)(flag_base + 1u) = 1u;
    return 0;
}
