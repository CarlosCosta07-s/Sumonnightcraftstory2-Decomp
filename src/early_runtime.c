/*
 * Reconstructed C equivalents for early startup routines in ROM BSKE.
 *
 * This is an analysis source file, not yet part of a matching full ROM build.
 * See analysis/startup-runtime.md and analysis/irq-install.md for evidence.
 */

#include <stdint.h>
#include <string.h>

typedef void (*irq_handler_t)(void);

/* Provisional labels for fixed IWRAM/BIOS work RAM addresses. */
#define STARTUP_STATE (*(volatile int32_t *)(uintptr_t)0x030028EC)
#define VBLANK_COUNT  (*(volatile uint32_t *)(uintptr_t)0x03002ED4)
#define IRQ_TABLE     ((irq_handler_t volatile *)(uintptr_t)0x03002D00)
#define BIOS_IRQ_VECTOR (*(irq_handler_t volatile *)(uintptr_t)0x03007FFC)
#define BIOS_IRQ_FLAG (*(volatile uint16_t *)(uintptr_t)0x03007FF8)

#define REG_IE       (*(volatile uint16_t *)(uintptr_t)0x04000200)
#define REG_DISPSTAT (*(volatile uint16_t *)(uintptr_t)0x04000004)
#define REG_IME      (*(volatile uint16_t *)(uintptr_t)0x04000208)

extern void sub_08003C00(void);
extern void sub_080036A8(void);
extern void sub_080077E4(void);
extern void sub_0800774C(void);

void set_startup_state(int16_t value)
{
    STARTUP_STATE = value;
}

int32_t get_startup_state(void)
{
    return STARTUP_STATE;
}

void set_startup_state_one(void)
{
    STARTUP_STATE = 1;
}

static void default_irq_handler(void)
{
    /* ROM handler at 0x08003A28 is BX LR. */
}

static void vblank_irq_handler(void)
{
    sub_080077E4();
    ++VBLANK_COUNT;
    sub_0800774C();
    BIOS_IRQ_FLAG = 1;
}

static void set_irq_handler(uint16_t index, irq_handler_t handler)
{
    IRQ_TABLE[index] = handler;
}

/*
 * Equivalent memory effects of ROM routine 0x08003960.
 * DMA3 is replaced here by byte copies; transfer timing is not reproduced.
 */
void install_irq_system(void)
{
    VBLANK_COUNT = 0;
    sub_08003C00();
    sub_080036A8();

    for (uint16_t i = 0; i < 13; ++i)
        set_irq_handler(i, default_irq_handler);

    memcpy((void *)(uintptr_t)0x03002EE0,
           (const void *)(uintptr_t)0x080000FC, 0x100);
    BIOS_IRQ_VECTOR = (irq_handler_t)(uintptr_t)0x03002EE0;

    memcpy((void *)(uintptr_t)0x03002DB0,
           (const void *)(uintptr_t)0x08003C58, 0x100);

    set_irq_handler(0, vblank_irq_handler);
    REG_IE = 0x2001;
    REG_DISPSTAT = 0x0008;
    REG_IME = 1;
}
