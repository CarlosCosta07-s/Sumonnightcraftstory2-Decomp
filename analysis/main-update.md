# Main per-frame update dispatcher

The startup loop at `0x08000418` calls `0x080001D0` on each iteration. The routine is a top-level update dispatcher: it calls a fixed series of subsystem routines, checks indexed value `8` before three more calls, then writes shared state and invokes two final helpers. The exact order is preserved in [main_update.s](../disasm/main_update.s), with a behavior-level reconstruction in [main_update.c](../src/main_update.c).

## Update order

1. Unconditional calls: `0x080011F8`, `0x080063FC`, `0x0800D8A8`, `0x08007D10`, `0x080139AC`, `0x08001964`, `0x080126E8`, `0x08013710`, and `0x0801053C`.
2. Read indexed value `8` using `0x08026908`. If it is not `1`, call `0x08026660C`.
3. Unconditional calls: `0x0800D908`, `0x080069D8`, `0x08005540`, `0x0800A154`, `0x08012058`, `0x08009CDC`, and `0x080548CC`.
4. Read indexed value `8` again; call `0x080726C4` unless the value is `1`. Read it a third time; call `0x08069270` unless it is `1`.
5. Call `0x0807CB8C` and `0x0808ACCC`; store `0x02003200` in record slot 0 via `0x080266DC`; set indexed values 0-3 to `0x55555555`; pass indexed value 4 to `0x080266F8`; and call `0x08026728` with three zero arguments.

The repeated reads show that indexed value 8 gates three separate update paths. Their game-level names and whether their state can change between reads remain unknown.

## Indexed value accessors

`0x080268B4` writes an indexed value and `0x08026908` reads one. Both truncate the input index to 16 bits and select a storage format by range:

| Index | Storage | Address calculation | Read behavior |
| --- | --- | --- | --- |
| `0x0000-0x003F` | 32-bit word | `*(u32 *)0x030067D0 + 4 * index` | return word |
| `0x0040-0x017F` | 16-bit halfword | `*(u32 *)0x0300659C + 2 * index - 0x80` | sign-extend halfword |
| `0x0180-0xFFFF` | byte | `*(u32 *)0x030065A4 + index - 0x180` | sign-extend byte |

The three globals hold base pointers; their initialization and the meaning of individual indices are still being traced. The source reconstruction is in [indexed_variables.c](../src/indexed_variables.c), and both accessors are annotated in [indexed_variables.s](../disasm/indexed_variables.s).

## Confidence and next work

The call order, branch conditions, literal values, and index thresholds come directly from the matching ROM. The names in the C source are descriptive. Next, analyze the repeated callees and trace where indexed values 4 and 8 are written.

