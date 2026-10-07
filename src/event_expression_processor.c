/*
 * Source-like reconstruction of the expression stream evaluator at
 * 0x08025F4C. Opcode names below describe observed operations only.
 * The ROM performs no stack-depth or stream-length checks.
 */
#include <stdint.h>

#define SCRIPT_CONTEXT_ROOT 0x03006594u
#define EXPRESSION_STACK    0x03002008u
#define EXPRESSION_DEPTH    0x03002088u

extern int32_t signed_divide_0808D370(int32_t dividend, int32_t divisor);
extern int32_t signed_remainder_0808D408(int32_t dividend, int32_t divisor);

static uint16_t read_expression_halfword(uintptr_t script_context)
{
    volatile uint32_t *cursor =
        (volatile uint32_t *)(script_context + 4u);
    const volatile uint16_t *source =
        (const volatile uint16_t *)(uintptr_t)*cursor;
    uint16_t value = *source;
    *cursor += 2u;
    return value;
}

static void push_expression_result(int32_t value)
{
    volatile uint32_t *depth =
        (volatile uint32_t *)(uintptr_t)EXPRESSION_DEPTH;
    volatile int32_t *stack =
        (volatile int32_t *)(uintptr_t)EXPRESSION_STACK;

    stack[*depth] = value;
    *depth = *depth + 1u;
}

static int32_t load_indexed_expression_value(uint16_t index)
{
    if (index <= 0x3Fu) {
        uintptr_t base = *(volatile uint32_t *)(uintptr_t)0x030067D0u;
        return *(volatile int32_t *)(base + (uint32_t)index * 4u);
    }

    if (index <= 0x17Fu) {
        uintptr_t base = *(volatile uint32_t *)(uintptr_t)0x0300659Cu;
        uintptr_t address = base + (uint32_t)index * 2u - 0x80u;
        return *(volatile int16_t *)address;
    }

    uintptr_t base = *(volatile uint32_t *)(uintptr_t)0x030065A4u;
    uintptr_t address = base + (uint32_t)index - 0x180u;
    return *(volatile int8_t *)address;
}

static int32_t load_typed_expression_value(uint16_t index)
{
    if (index <= 31u) {
        uintptr_t base = *(volatile uint32_t *)(uintptr_t)0x030067CCu;
        return *(volatile int16_t *)(base + (uint32_t)index * 2u);
    }

    if (index <= 255u) {
        uintptr_t base = *(volatile uint32_t *)(uintptr_t)0x03006590u;
        return *(volatile int8_t *)(base + (uint32_t)index - 32u);
    }

    uintptr_t base = *(volatile uint32_t *)(uintptr_t)0x030067C8u;
    uint32_t bit = index & 7u;
    uintptr_t address = base + ((uint32_t)index - 0x100u) / 8u;
    uint8_t packed = (uint8_t)*(volatile int8_t *)address;
    return (packed >> bit) & 1u;
}

static int32_t apply_expression_operator(uint16_t opcode,
                                         int32_t left,
                                         int32_t right)
{
    switch (opcode) {
    case 0x82: return left * right;
    case 0x83: return signed_divide_0808D370(left, right);
    case 0x84: return signed_remainder_0808D408(left, right);
    case 0x85: return left + right;
    case 0x86: return left - right;
    case 0x87: return left < right;
    case 0x88: return left <= right;
    case 0x89: return left > right;
    case 0x8A: return left >= right;
    case 0x8B: return left == right;
    case 0x8C: return left != right;
    case 0x8D: return left & right;
    case 0x8E: return left ^ right;
    case 0x8F: return left | right;
    case 0x90: return left != 0 && right != 0;
    case 0x91: return left != 0 || right != 0;
    default:   return left;
    }
}

/*
 * The stream is read through *(u32 *)0x03006594 + 4. Opcode zero terminates
 * the expression. On termination the ROM returns stack slot zero, even if
 * malformed input left an unexpected depth.
 */
uint32_t process_event_stream_08025F4C(void)
{
    uintptr_t script_context =
        *(volatile uint32_t *)(uintptr_t)SCRIPT_CONTEXT_ROOT;
    volatile uint32_t *depth =
        (volatile uint32_t *)(uintptr_t)EXPRESSION_DEPTH;
    volatile int32_t *stack =
        (volatile int32_t *)(uintptr_t)EXPRESSION_STACK;

    *depth = 0;

    for (;;) {
        uint16_t opcode = read_expression_halfword(script_context);

        if (opcode == 0) {
            break;
        }

        if (opcode == 1u) {
            push_expression_result((int16_t)read_expression_halfword(
                script_context));
            continue;
        }

        if (opcode == 2u) {
            uint16_t index = read_expression_halfword(script_context);
            push_expression_result(load_indexed_expression_value(index));
            continue;
        }

        if (opcode == 3u) {
            uint16_t index = read_expression_halfword(script_context);
            push_expression_result(load_typed_expression_value(index));
            continue;
        }

        if (opcode < 0x80u) {
            /* Other low opcodes are consumed without pushing a result. */
            continue;
        }

        if (opcode <= 0x81u) {
            *depth = *depth - 1u;
            int32_t value = stack[*depth];
            push_expression_result(opcode == 0x80u
                                       ? (value == 0)
                                       : ~value);
            continue;
        }

        *depth = *depth - 1u;
        int32_t right = stack[*depth];
        *depth = *depth - 1u;
        int32_t left = stack[*depth];
        push_expression_result(
            apply_expression_operator(opcode, left, right));
    }

    return (uint32_t)stack[0];
}
