/*
 * Equivalent C reconstruction of the copied Thumb routine at ROM 0x08003C58.
 * Startup copies its 0x100-byte code/literal block to IWRAM at 0x03002DB0.
 * The RAM table names and the overall graphics role are provisional.
 */

#include <stdint.h>

#define GBA_PTR(type, address) ((type *)(uintptr_t)(address))

typedef struct {
    uint32_t destination;
    uint16_t scanline;
    uint16_t value;
} scanline_event_t;

void scanline_update_recovered(void)
{
    const uint16_t line = *GBA_PTR(volatile uint16_t, 0x04000006); /* VCOUNT */
    if (line >= 160)
        return;

    const uint16_t slot = *GBA_PTR(volatile uint16_t, 0x03002DA0);

    volatile uint32_t *const line_destinations_a =
        GBA_PTR(volatile uint32_t, 0x03002EC0);
    const uint32_t line_destination_a = line_destinations_a[slot];
    if (line_destination_a != 0) {
        const volatile uint32_t *const line_sources_a =
            GBA_PTR(volatile uint32_t, 0x03002D90);
        const uint16_t *const source =
            (const uint16_t *)(uintptr_t)line_sources_a[slot];
        *GBA_PTR(volatile uint16_t, line_destination_a) = source[line];
    }

    volatile uint32_t *const line_destinations_b =
        GBA_PTR(volatile uint32_t, 0x03002EC8);
    const uint32_t line_destination_b = line_destinations_b[slot];
    if (line_destination_b != 0) {
        const volatile uint32_t *const line_sources_b =
            GBA_PTR(volatile uint32_t, 0x03002D98);
        const uint16_t *const source =
            (const uint16_t *)(uintptr_t)line_sources_b[slot];
        *GBA_PTR(volatile uint16_t, line_destination_b) = source[line];
    }

    volatile scanline_event_t *const events =
        GBA_PTR(volatile scanline_event_t, 0x03002D40) + slot * 4;
    for (unsigned i = 0; i < 4; ++i) {
        if (events[i].scanline == line) {
            volatile uint16_t *const destination =
                (volatile uint16_t *)(uintptr_t)events[i].destination;
            *destination = events[i].value;
        }
    }

    volatile uint32_t *const stream_a_pointers =
        GBA_PTR(volatile uint32_t, 0x03002FE0);
    /* The ROM tests the low halfword of this pointer, not the full word. */
    if ((uint16_t)stream_a_pointers[slot] == 0)
        return;

    const uint16_t *const stream_a =
        (const uint16_t *)(uintptr_t)stream_a_pointers[slot];
    volatile uint32_t *const stream_b_pointers =
        GBA_PTR(volatile uint32_t, 0x03002EB0);
    const uint16_t *const stream_b =
        (const uint16_t *)(uintptr_t)stream_b_pointers[slot];

    const uint16_t *const row_a = stream_a + (size_t)line * 4;
    const uint16_t *const row_b = stream_b + (size_t)line * 4;
    volatile uint16_t *const io_a =
        GBA_PTR(volatile uint16_t, 0x04000028);
    volatile uint16_t *const io_b =
        GBA_PTR(volatile uint16_t, 0x04000020);

    io_a[0] = row_a[0];
    io_a[1] = row_a[1];
    io_a[2] = row_a[2];
    io_a[3] = row_a[3];

    io_b[0] = row_b[0];
    io_b[2] = row_b[1];
    io_b[3] = row_b[2];
    io_b[5] = row_b[3];
}
