/*
 * Address-level reconstruction of the two zero-terminated halfword stream
 * copies rooted at 0x03006894. No explicit source-length check is present
 * in either ROM routine.
 */
#include <stdint.h>

#define RUNTIME_BLOCK_ROOT 0x03006894u

static volatile uint8_t *runtime_block(void)
{
    return (volatile uint8_t *)(uintptr_t)
        (*(volatile uint32_t *)(uintptr_t)RUNTIME_BLOCK_ROOT);
}

/* ROM 0x080726E4: source in r0, destination at runtime block + 4. */
void copy_stream_to_runtime_block_080726E4(const uint16_t *source)
{
    volatile uint16_t *destination =
        (volatile uint16_t *)(runtime_block() + 4);

    uint16_t value;
    do {
        value = *source++;
        *destination++ = value;
    } while (value != 0);
}

/* ROM 0x0807292C: source in r0, destination at runtime block + 0x56. */
void copy_stream_to_runtime_block_0807292C(const uint16_t *source)
{
    volatile uint16_t *destination =
        (volatile uint16_t *)(runtime_block() + 0x56);

    uint16_t value;
    do {
        value = *source++;
        *destination++ = value;
    } while (value != 0);
}
