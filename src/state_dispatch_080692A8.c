/*
 * Behavior-level reconstruction of ROM 0x080692A8.
 * The state object's base is loaded through 0x03006884. Its relationship
 * to other runtime roots is not established.
 */
#include <stdint.h>

#define REG32(address) (*(volatile uint32_t *)(uintptr_t)(address))
#define REG16(address) (*(volatile int16_t *)(uintptr_t)(address))

extern int32_t sub_08069594(void);
extern void sub_080695A4(void);
extern void sub_08066540(void);
extern void sub_080695E8(void);

int16_t dispatch_state_080692A8(void) {
    uintptr_t state_base = REG32(0x03006884u);
    int16_t state = REG16(state_base + 6u);

    switch (state) {
    case 1:
        if ((int16_t)sub_08069594() == 0) {
            REG16(state_base + 6u) = 0;
        }
        break;
    case 4:
        sub_080695A4();
        break;
    case 8:
        sub_08066540();
        break;
    case 12:
        sub_080695E8();
        break;
    default:
        break;
    }

    return REG16(state_base + 6u);
}
