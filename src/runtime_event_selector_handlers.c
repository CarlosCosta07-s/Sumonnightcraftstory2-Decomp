/*
 * Source-like reconstruction of event-command table entries 94 and 95.
 * Their exact game-level purpose is not identified.
 */
#include <stdint.h>

#define RUNTIME_BLOCK_ROOT   0x03006894u
#define EVENT_RUNTIME_ROOT    0x03006598u

extern uint32_t process_event_stream_08025F4C(void);
extern void set_indexed_value_080268B4(uint16_t index, int32_t value);

/*
 * ROM 0x08073AE0, selected by command-table entry 94 at 0x084CAD24.
 * The ROM keeps the low byte of the stream processor result.
 */
uint32_t event_command_94_08073AE0(void)
{
    uint8_t value = (uint8_t)process_event_stream_08025F4C();
    uintptr_t block = *(volatile uint32_t *)(uintptr_t)RUNTIME_BLOCK_ROOT;

    *(volatile uint8_t *)(block + 0x00u) = value;
    set_indexed_value_080268B4(64u, value);

    uintptr_t event_state =
        *(volatile uint32_t *)(uintptr_t)EVENT_RUNTIME_ROOT;
    *(volatile uint8_t *)(event_state + 1u) = 1;
    return 0;
}

/*
 * ROM 0x08073B10, selected by command-table entry 95 at 0x084CAD28.
 */
uint32_t event_command_95_08073B10(void)
{
    uint8_t value = (uint8_t)process_event_stream_08025F4C();
    uintptr_t block = *(volatile uint32_t *)(uintptr_t)RUNTIME_BLOCK_ROOT;

    *(volatile uint8_t *)(block + 0x54u) = value;
    set_indexed_value_080268B4(65u, value);

    uintptr_t event_state =
        *(volatile uint32_t *)(uintptr_t)EVENT_RUNTIME_ROOT;
    *(volatile uint8_t *)(event_state + 1u) = 1;
    return 0;
}
