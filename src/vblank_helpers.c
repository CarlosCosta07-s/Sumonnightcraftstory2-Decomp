/*
 * Behavior-level reconstruction of selected VBlank support routines.
 * Addresses and branch conditions come from the annotated Thumb listing.
 * Function names are descriptive; no matching full-game build exists yet.
 */
#include <stdint.h>

#define REG_VCOUNT (*(volatile uint16_t *)(uintptr_t)0x04000006u)
#define VCOUNT_DELTA (*(volatile uint16_t *)(uintptr_t)0x0300303Cu)
#define VCOUNT_UPDATE_FLAG (*(volatile int8_t *)(uintptr_t)0x03003040u)
#define VCOUNT_MODE (*(volatile int8_t *)(uintptr_t)0x03003052u)

/* 0x0808BB38 is a wrapper around 0x0808AE94, which checks the sound-engine
 * state signature and advances its state. The exact original symbol is unknown.
 */
extern void sound_engine_service_0808BB38(void);

void set_vcount_update_flag(int8_t value) {
    VCOUNT_UPDATE_FLAG = value;
}

int8_t get_vcount_update_flag(void) {
    return VCOUNT_UPDATE_FLAG;
}

static void record_vcount_delta(uint16_t before) {
    uint16_t after = REG_VCOUNT;
    VCOUNT_DELTA = after;
    if (after < before) {
        VCOUNT_DELTA = (uint16_t)(after + 0xE3u);
    }
    VCOUNT_DELTA = (uint16_t)(VCOUNT_DELTA - before);
}

/* ROM 0x0800774C: requires mode == 1 and update flag == 0. */
void vcount_delta_mode_one(void) {
    if (VCOUNT_MODE != 1 || VCOUNT_UPDATE_FLAG != 0) {
        return;
    }
    uint16_t before = REG_VCOUNT;
    sound_engine_service_0808BB38();
    record_vcount_delta(before);
}

/* ROM 0x080077A0: requires mode == 0; it does not test the update flag. */
void vcount_delta_mode_zero(void) {
    if (VCOUNT_MODE != 0) {
        return;
    }
    uint16_t before = REG_VCOUNT;
    sound_engine_service_0808BB38();
    record_vcount_delta(before);
}

/* ROM 0x080077E4 forwards to 0x0808B474, likely the sound engine's VBlank
 * service because the callee validates its state block and accesses audio/DMA I/O.
 */
extern void sound_vblank_service_0808B474(void);
void vblank_sound_service_wrapper(void) {
    sound_vblank_service_0808B474();
}

/* ROM 0x080077F0 reads the byte at 0x03003050. */
uint8_t get_byte_03003050(void) {
    return *(volatile uint8_t *)(uintptr_t)0x03003050u;
}
