/*
 * Address-level reconstructions of the background-map/object helpers around
 * 0x08005768 and 0x0800D00C-0x0800D238.
 *
 * The 0x0200F800/0x02010000/0x02010800 buffers and 0x800-byte stride strongly
 * suggest GBA background screen-map buffers. The names below describe observed
 * behavior; the exact meaning of every field is still being identified.
 */
#include <stdint.h>

#define REG8(address)  (*(volatile uint8_t *)(uintptr_t)(address))
#define REG16(address) (*(volatile uint16_t *)(uintptr_t)(address))
#define REG32(address) (*(volatile uint32_t *)(uintptr_t)(address))

#define MAP_OBJECT_RECORDS 0x030034C0u
#define MAP_BUFFER_POINTERS 0x0300387Cu
#define MAP_OBJECT_LINKS 0x030036F0u
#define MAP_HALFWORD_ROWS 0x030038C0u
#define MAP_OBJECT_RECORD_SIZE 0x1Cu

static volatile uint8_t *map_object_record(uint8_t object_index) {
    return (volatile uint8_t *)(uintptr_t)(
        MAP_OBJECT_RECORDS + (uint32_t)object_index * MAP_OBJECT_RECORD_SIZE);
}

static uint16_t make_map_entry(uint32_t low, uint32_t high) {
    return (uint16_t)((((uint16_t)high & 0x000Fu) << 12) | (uint16_t)low);
}

/* ROM 0x08005768 writes the same packed halfword across two rows. */
void fill_two_row_map_strip_08005768(
    volatile uint16_t *destination,
    uint32_t width,
    uint32_t low_attribute,
    uint32_t high_attribute
) {
    uint16_t count = (uint16_t)width;
    uint16_t value = make_map_entry(low_attribute, high_attribute);

    for (uint32_t row = 0; row < 2; ++row) {
        for (uint32_t column = 0; column < count; ++column) {
            destination[row * 32u + column] = value;
        }
    }
}

/*
 * ROM 0x0800D00C selects a 17-halfword row from the selector's 0x22-byte
 * record, clears it, then copies source values through the first zero.
 */
void copy_terminated_map_halfwords_0800D00C(
    uint32_t packed_selector,
    const volatile uint16_t *source
) {
    uint32_t selector = ((uint16_t)packed_selector >> 8) & 0x0Fu;
    volatile uint16_t *destination =
        (volatile uint16_t *)(uintptr_t)(MAP_HALFWORD_ROWS + selector * 0x22u);

    for (uint32_t i = 0; i < 17; ++i) {
        destination[i] = 0;
    }

    for (uint32_t i = 0; i < 17; ++i) {
        uint16_t value = source[i];
        destination[i] = value;
        if (value == 0) {
            break;
        }
    }
}

uint8_t get_map_object_status_0800D0AC(const volatile uint8_t *object) {
    uint8_t object_index = object[0];
    if (*(const volatile uint16_t *)(const volatile void *)object == 0) {
        return 0;
    }
    return map_object_record(object_index)[0];
}

uint8_t get_map_object_x_0800D0D0(const volatile uint8_t *object) {
    return map_object_record(object[0])[6];
}

uint8_t get_map_object_y_0800D0E4(const volatile uint8_t *object) {
    return map_object_record(object[0])[7];
}

void set_map_object_xy_0800D0F8(
    const volatile uint8_t *object,
    uint32_t x,
    uint32_t y
) {
    volatile uint8_t *record = map_object_record(object[0]);
    record[6] = (uint8_t)x;
    record[7] = (uint8_t)y;
}

void set_runtime_flag_03003A70_0800D110(void) {
    REG16(0x03003A70u) = 1;
}

void promote_map_object_state_2_to_3_0800D11C(
    const volatile uint8_t *object
) {
    volatile uint8_t *status = map_object_record(object[0]);
    if (status[0] == 2) {
        status[0] = 3;
    }
}

void demote_map_object_state_3_to_2_0800D13C(
    const volatile uint8_t *object
) {
    volatile uint8_t *status = map_object_record(object[0]);
    if (status[0] == 3) {
        status[0] = 2;
    }
}

void set_map_object_field_0D_0800D15C(
    const volatile uint8_t *object,
    uint32_t value
) {
    map_object_record(object[0])[0x0D] = (uint8_t)value;
}

/* ROM 0x0800D170 draws the record's two-row strip into its selected map buffer. */
void draw_map_object_strip_0800D170(const volatile uint8_t *object) {
    volatile uint8_t *record = map_object_record(object[0]);
    uint32_t buffer_index = record[8];
    uintptr_t buffer = (uintptr_t)REG32(
        MAP_BUFFER_POINTERS + buffer_index * sizeof(uint32_t));
    uint32_t tile_offset = (uint32_t)record[6] + (uint32_t)record[7] * 32u;
    volatile uint16_t *destination =
        (volatile uint16_t *)(buffer + tile_offset * sizeof(uint16_t));

    fill_two_row_map_strip_08005768(
        destination,
        record[3],
        REG16(0x03003892u),
        REG16(0x03003894u));
}

/*
 * ROM 0x0800D1B8 clears the object, replaces its map strip with the caller's
 * packed value, then releases the linked 8-byte records named by field +0x0B.
 */
void clear_map_object_strip_0800D1B8(
    volatile uint8_t *object,
    uint32_t low_attribute,
    uint32_t high_attribute
) {
    uint8_t object_index = object[0];
    volatile uint8_t *record = map_object_record(object_index);

    record[0] = 0;
    *(volatile uint16_t *)(volatile void *)object = 0;

    uint32_t buffer_index = record[8];
    uintptr_t buffer = (uintptr_t)REG32(
        MAP_BUFFER_POINTERS + buffer_index * sizeof(uint32_t));
    uint32_t tile_offset = (uint32_t)record[6] + (uint32_t)record[7] * 32u;
    volatile uint16_t *destination =
        (volatile uint16_t *)(buffer + tile_offset * sizeof(uint16_t));

    fill_two_row_map_strip_08005768(
        destination, record[3], low_attribute, high_attribute);

    uint32_t link_index = record[0x0B];
    volatile uint8_t *link = (volatile uint8_t *)(uintptr_t)(
        MAP_OBJECT_LINKS + link_index * 8u);
    link[0] = 0;
    uint16_t next = *(volatile uint16_t *)(volatile void *)(link + 4);
    while (next != 0xFFFFu) {
        link = (volatile uint8_t *)(uintptr_t)(MAP_OBJECT_LINKS + (uint32_t)next * 8u);
        link[0] = 0;
        next = *(volatile uint16_t *)(volatile void *)(link + 4);
    }
}

uint8_t read_runtime_map_mode_0800D238(void) {
    return REG8(0x03003A02u);
}
