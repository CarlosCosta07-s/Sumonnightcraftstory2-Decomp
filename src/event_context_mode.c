/* Source-like reconstruction of the adjacent routine at 0x080261B8. */
#include <stdint.h>

#define SCRIPT_CONTEXT_ROOT 0x03006594u

void set_event_context_mode_from_tag_080261B8(void)
{
    volatile uint32_t *context_root =
        (volatile uint32_t *)(uintptr_t)SCRIPT_CONTEXT_ROOT;
    uintptr_t context = *context_root;
    uint16_t tag = *(volatile uint16_t *)(context + 2u);
    uint16_t family = tag & 0xFF00u;
    uint8_t mode = 2u;

    switch (family) {
    case 0x4000u: mode = 3u; break;
    case 0x8000u: mode = 4u; break;
    case 0xC000u: mode = 5u; break;
    case 0x1000u: mode = 6u; break;
    default: break;
    }

    *(volatile uint8_t *)context = mode;
}
