/*
 * Source-like reconstruction of command-table entry 175 at 0x08023EA8.
 * The evaluator's result is discarded; its purpose and the flag's meaning
 * remain unknown.
 */
#include <stdint.h>

#define EVENT_FLAG_ROOT 0x03006598u

extern uint32_t process_event_stream_08025F4C(void);

int32_t event_command_175_08023EA8(void)
{
    (void)process_event_stream_08025F4C();

    uint32_t flag_base =
        *(volatile uint32_t *)(uintptr_t)EVENT_FLAG_ROOT;
    *(volatile uint8_t *)(uintptr_t)(flag_base + 1u) = 1u;
    return 0;
}
