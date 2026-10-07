/*
 * Source-like reconstruction of command-table entry 173 at 0x08022924.
 * The game-level meaning of the command and helper at 0x08026878 are unknown.
 */
#include <stdint.h>

#define EVENT_STORAGE_ROOT 0x03006558u

extern uint32_t unresolved_08026878(void);
extern uint32_t process_event_stream_08025F4C(void);

int32_t event_command_173_08022924(void)
{
    int32_t selector16 = (int16_t)(uint16_t)unresolved_08026878();
    uint32_t root = *(volatile uint32_t *)(uintptr_t)EVENT_STORAGE_ROOT;
    uint32_t record_address =
        root + 0x1EDCu + (uint32_t)(selector16 * 16);
    volatile int16_t *phase =
        (volatile int16_t *)(uintptr_t)record_address;
    volatile int16_t *remaining =
        (volatile int16_t *)(uintptr_t)(record_address + 4u);

    if (*phase == 0) {
        *remaining = (int16_t)(uint16_t)process_event_stream_08025F4C();
        *phase = (int16_t)((uint16_t)*phase + 1u);
    } else if (*phase == 1) {
        *remaining = (int16_t)((uint16_t)*remaining - 1u);
        if (*remaining <= 0)
            *phase = 0;
    }

    return *phase;
}
