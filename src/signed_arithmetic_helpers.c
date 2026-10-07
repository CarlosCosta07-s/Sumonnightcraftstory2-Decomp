/*
 * Semantic C reconstruction of the ARM7TDMI helpers at 0x0808D370 and
 * 0x0808D408. The ROM implements long division in Thumb assembly.
 */
#include <stdint.h>

int32_t signed_divide_0808D370(int32_t dividend, int32_t divisor)
{
    if (divisor == 0)
        return 0;

    /* Two's-complement wrap matches the ROM's negation-based algorithm. */
    if (dividend == INT32_MIN && divisor == -1)
        return INT32_MIN;

    return dividend / divisor;
}

int32_t signed_remainder_0808D408(int32_t dividend, int32_t divisor)
{
    if (divisor == 0)
        return 0;

    if (dividend == INT32_MIN && divisor == -1)
        return 0;

    return dividend % divisor;
}
