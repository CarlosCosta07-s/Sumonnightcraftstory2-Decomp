/*
 * Behavior-level reconstruction of ROM 0x080693E4.
 * The helper at 0x0800CF78 is retained by address because its purpose
 * has not yet been identified.
 */
#include <stdint.h>

#define REG32(address) (*(volatile uint32_t *)(uintptr_t)(address))
#define REG16(address) (*(volatile int16_t *)(uintptr_t)(address))

extern int32_t sub_08069594(void);
extern void sub_080695A4(void);
extern void sub_08066540(void);
extern void sub_080695E8(void);
extern void sub_0800CF78(int32_t index);

int32_t state_poll_080693E4(void) {
    uintptr_t state_base = REG32(0x03006884u);
    volatile int16_t *state = (volatile int16_t *)(state_base + 6u);

    switch (*state) {
    case 1:
        if ((int16_t)sub_08069594() == 0) {
            *state = 0;
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

    if (*state == 0) {
        sub_0800CF78(0);
        sub_0800CF78(1);
        sub_0800CF78(2);
        sub_0800CF78(3);
        return 0;
    }

    return 1;
}
