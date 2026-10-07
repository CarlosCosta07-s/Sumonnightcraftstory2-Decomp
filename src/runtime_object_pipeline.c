/*
 * Evidence-based C reconstruction of the object setup and transfer-queue path.
 * Names describe observed data flow; descriptor-marker meanings and the
 * exact asset domain remain unresolved.
 */
#include <stdint.h>

#define REG8(address)  (*(volatile uint8_t *)(uintptr_t)(address))
#define REG16(address) (*(volatile uint16_t *)(uintptr_t)(address))
#define REG32(address) (*(volatile uint32_t *)(uintptr_t)(address))

#define OBJECT_RECORDS       0x030034C0u
#define OBJECT_RECORD_SIZE   0x1Cu
#define CONFIG_VRAM_BASE     0x03003860u
#define CONFIG_STAGE_BASE    0x03003868u
#define STAGE_CURSOR         0x03003870u
#define REBUILD_GATE         0x03003A70u
#define TRANSFER_QUEUE_COUNT 0x03006160u
#define TRANSFER_QUEUE       0x03006170u
#define TRANSFER_QUEUE_CAP   80u

/* Results are used by 0x0800A380 as a count of 64-byte units. */
extern uint16_t scan_object_words_0800A304(const uint16_t *words);
extern uint16_t prepare_object_data_08004144(
    uintptr_t destination,
    const uint16_t *source_words,
    volatile uint16_t *record_words_10,
    const uint16_t *command_words,
    uint32_t fill_value);
extern void apply_object_commands_080042D0(
    uintptr_t destination,
    const uint16_t *command_words);
extern void allocate_object_transfer_nodes_0800A7E0(uint16_t object_index);

/*
 * ROM 0x08013A20 stores three words per accepted request:
 * source, destination, and a zero-extended 16-bit size. Count 80 is full.
 * The ROM routine silently ignores requests after the capacity check fails.
 */
void enqueue_transfer_request_08013A20(
    uintptr_t source, uintptr_t destination, uint32_t byte_count)
{
    volatile uint16_t *count =
        (volatile uint16_t *)(uintptr_t)TRANSFER_QUEUE_COUNT;

    if (*count >= TRANSFER_QUEUE_CAP) {
        return;
    }

    volatile uint32_t *entry = (volatile uint32_t *)(uintptr_t)(
        TRANSFER_QUEUE + (uint32_t)(*count) * 12u);
    entry[0] = (uint32_t)source;
    entry[1] = (uint32_t)destination;
    entry[2] = (uint16_t)byte_count;
    *count = (uint16_t)(*count + 1u);
}

/*
 * ROM 0x080139C4 drains requests from the highest queued index to zero.
 * Each request programs DMA3 in immediate, 32-bit mode and waits for its
 * enable bit to clear before processing the preceding entry. The routine
 * leaves the queue count unchanged.
 */
void drain_transfer_requests_080139C4(void)
{
    int32_t index = (int32_t)REG16(TRANSFER_QUEUE_COUNT) - 1;
    volatile uint32_t *entry = (volatile uint32_t *)(uintptr_t)(
        TRANSFER_QUEUE + (uint32_t)index * 12u);
    volatile uint32_t *dma3 = (volatile uint32_t *)(uintptr_t)0x040000D4u;

    if (index < 0) {
        return;
    }

    do {
        dma3[0] = entry[0];
        dma3[1] = entry[1];
        dma3[2] = (entry[2] >> 2) | 0x84000000u;

        while ((dma3[2] & 0x80000000u) != 0) {
            /* DMA3 clears bit 31 when the transfer completes. */
        }

        --index;
        entry -= 3;
    } while (index >= 0);
}

void reset_transfer_request_count_08013A54(void)
{
    REG16(TRANSFER_QUEUE_COUNT) = 0;
}

/*
 * ROM 0x08013A60 calls BIOS CpuSet in fill+word mode for 240 words
 * (0x3C0 bytes), clearing the 80 twelve-byte queue entries.
 */
extern void bios_CpuSet_fill32(uint32_t value, uintptr_t destination,
                               uint32_t word_count);
void clear_transfer_request_queue_08013A60(void)
{
    bios_CpuSet_fill32(0, TRANSFER_QUEUE, 240u);
}

/*
 * Address-level model of ROM 0x0800A380.
 *
 * Argument mapping is kept positional where the original routine only exposes
 * register/stack values. The direct field writes are shown below; no stronger
 * domain names are assigned to those fields.
 */
void initialize_runtime_object_0800A380(
    volatile uint16_t *output_handle,
    uint32_t record_byte_08,
    const uint16_t *source_words,
    uint32_t x,
    uint32_t y,
    uint32_t fill_value,
    uint32_t duplicate_record_byte_09_0A,
    const uint16_t *command_words,
    uint32_t count)
{
    uint16_t object_index = 0;

    /* The ROM tests status bytes for indices 0 through 19. */
    while (object_index <= 19u &&
           REG8(OBJECT_RECORDS +
                (uint32_t)object_index * OBJECT_RECORD_SIZE) != 0) {
        ++object_index;
    }

    /*
     * No separate exhausted-pool return is present: if all 20 status bytes
     * are occupied, the observed code proceeds with index 20.
     */
    *output_handle = (uint16_t)(0x0200u | object_index);

    volatile uint8_t *record = (volatile uint8_t *)(uintptr_t)(
        OBJECT_RECORDS + (uint32_t)object_index * OBJECT_RECORD_SIZE);
    volatile uint16_t *record_words_10 =
        (volatile uint16_t *)(uintptr_t)(record + 0x10u);

    record_words_10[0] = 0;
    record_words_10[1] = 0;
    record_words_10[2] = 0;
    record_words_10[3] = 0;

    /* A zero first halfword selects the pointer stored at ROM 0x084C7880. */
    if (source_words[0] == 0) {
        source_words = (const uint16_t *)(uintptr_t)REG32(0x084C7880u);
    }

    uintptr_t stage_base = REG32(CONFIG_STAGE_BASE);
    uint32_t cursor = REG32(STAGE_CURSOR) & ~3u;
    uintptr_t destination = stage_base + cursor;

    uint16_t size_units_64 = prepare_object_data_08004144(
        destination, source_words, record_words_10, command_words, fill_value);
    uint16_t descriptor_count = scan_object_words_0800A304(source_words);

    if (REG16(REBUILD_GATE) == 1u) {
        apply_object_commands_080042D0(destination, command_words);
    }

    record[0x02] = (uint8_t)descriptor_count;
    record[0x03] = (uint8_t)size_units_64;
    record[0x04] = 0;
    record[0x05] = 0;
    record[0x0D] = (uint8_t)count;
    record[0x0E] = count != 0 ? (uint8_t)(count - 1u) : 0;

    record[0x00] = 2;
    record[0x01] = 0;
    record[0x06] = (uint8_t)x;
    record[0x07] = (uint8_t)y;
    record[0x08] = (uint8_t)record_byte_08;
    record[0x09] = (uint8_t)duplicate_record_byte_09_0A;
    record[0x0A] = (uint8_t)duplicate_record_byte_09_0A;
    record[0x18] = 0;

    allocate_object_transfer_nodes_0800A7E0(object_index);

    REG32(STAGE_CURSOR) += (uint32_t)size_units_64 << 6;
    REG16(REBUILD_GATE) = 0;
}
