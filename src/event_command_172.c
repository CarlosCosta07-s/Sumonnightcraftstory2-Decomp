/*
 * Source-like reconstruction of command-table entry 172 at 0x08023E84.
 * Helper 0x0801F2FC and the meaning of the state bits remain unknown.
 */
#include <stdint.h>

#define EVENT_STATE_ROOT 0x03006558u

extern void unresolved_0801F2FC(uint32_t updated_flags);

int32_t event_command_172_08023E84(void)
{
    uint32_t state_base =
        *(volatile uint32_t *)(uintptr_t)EVENT_STATE_ROOT;
    volatile uint16_t *flags =
        (volatile uint16_t *)(uintptr_t)state_base;

    uint16_t updated = (uint16_t)((*flags & 0xFFFBu) | 1u);
    *flags = updated;
    unresolved_0801F2FC(updated);
    return 0;
}
