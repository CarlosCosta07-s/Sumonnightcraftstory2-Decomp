# Event expression stream processor

`0x08025F4C` is a Thumb evaluator for a halfword stream. Its handlers are event-table entries 94 and 95, described in [runtime-stream-callers.md](runtime-stream-callers.md). A source-like C reconstruction is in [`src/event_expression_processor.c`](../src/event_expression_processor.c); the signed arithmetic helper semantics are in [`src/signed_arithmetic_helpers.c`](../src/signed_arithmetic_helpers.c). This analysis targets the USA revision-0 ROM identified by SHA-256 `E267F052A3F138534F198BD33992D640568F80BF807E322C85C7B4CF6DD504AC`.

## Stream and stack

- The current script context pointer is loaded from `*(u32 *)0x03006594`.
- Its halfword stream cursor is the word at context offset `+4`. Each consumed halfword advances that cursor by two bytes, including opcode operands.
- The evaluator resets the word at `0x03002088` to zero. Expression values are pushed as 32-bit words beginning at `0x03002008`.
- Opcode `0` terminates the stream; the function returns stack word zero. It does not verify that there is exactly one result.
- The apparent stack capacity is 32 words (`0x80` bytes), adjacent to the depth word. The routine has no explicit capacity, underflow, or stream-length checks. Malformed input can therefore access outside the intended stack or source data.

## Operand opcodes

| Opcode | Observed behavior |
| ---: | --- |
| `0x0001` | Consume a second halfword, sign-extend it from 16 bits, and push it. |
| `0x0002` | Consume an index and load a value from the indexed word/halfword/byte stores. |
| `0x0003` | Consume an index and load a signed halfword, signed byte, or packed bit from a second typed store. |
| `0x0004`–`0x007F` | Consume the opcode without pushing a value. No further semantics assigned. |

For opcode `0x0002`, indices `0x00`–`0x3F` select signed 32-bit words through the pointer stored at `0x030067D0`; `0x40`–`0x17F` select signed halfwords through `0x0300659C` with byte offset `2*index - 0x80`; `0x180`–`0xFFFF` select signed bytes through `0x030065A4` with offset `index - 0x180`.

For opcode `0x0003`, indices `0`–`31` select signed halfwords through `0x030067CC`; `32`–`255` select signed bytes through `0x03006590` at offset `index - 32`; indices `256` and above select bit `(index & 7)` from the byte array rooted at `0x030067C8`, at offset `(index - 256) >> 3`. The selected bit is pushed as zero or one.

## Operator opcodes

Operators consume operands from the stack and push one result. Binary operators use the second-to-top item as the left operand and the top item as the right operand.

| Opcode | Operation | Result |
| ---: | --- | --- |
| `0x0080` | Logical NOT | `1` if operand is zero, otherwise `0` |
| `0x0081` | Bitwise complement | `~operand` |
| `0x0082` | Multiply | signed 32-bit result |
| `0x0083` | Signed divide | zero divisor yields `0` |
| `0x0084` | Signed remainder | zero divisor yields `0` |
| `0x0085` | Add | 32-bit result |
| `0x0086` | Subtract | left minus right |
| `0x0087`–`0x008C` | Signed `<`, `<=`, `>`, `>=`, `==`, `!=` | `0` or `1` |
| `0x008D`–`0x008F` | Bitwise AND, XOR, OR | 32-bit result |
| `0x0090`–`0x0091` | Logical AND, OR | `0` or `1` |
| `0x0092` and above | The 16-entry jump-table range check is skipped; observed path pushes the left operand unchanged. | left operand |

The operator dispatch table at file offset `0x000260E0` holds 16 Thumb destinations for opcodes `0x82`–`0x91`. Comparison handlers normalize their result to zero or one. The signed division and remainder routines at `0x0808D370` and `0x0808D408` use iterative long division and return zero for a zero divisor.

## Adjacent tag-to-mode routine

`0x080261B8` is a separate routine immediately following the evaluator. It reads the halfword at context offset `+2`, masks it with `0xFF00`, then writes a mode byte at context offset `+0`: family `0x4000` maps to `3`, `0x8000` to `4`, `0xC000` to `5`, `0x1000` to `6`, and every other family to `2`. The name `set_event_context_mode_from_tag_080261B8` in the C excerpt describes only these observed operations.

## Evidence and remaining unknowns

Event commands 94 and 95 invoke the evaluator, keep only its low byte, and store it at runtime block offsets `+0` and `+0x54` (also indexed values 64 and 65). Their game-level purpose and the meaning of individual indexed values remain unknown. The format has no in-stream length in this routine; valid streams are expected to terminate with opcode zero and satisfy the stack discipline, but the constraints that guarantee this have not yet been traced.

The map now separates the evaluator's code, literal pools, operator jump table, the adjacent tag routine, and the two arithmetic helper bodies in [`rom_map.json`](rom_map.json).