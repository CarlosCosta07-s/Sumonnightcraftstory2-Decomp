# Background-map object and buffer helpers

This note records the evidence around the runtime table at `0x030034C0`. The source-like reconstructions and annotated listings are in [background_map_ops.c](../src/background_map_ops.c), [background_map_ops.s](../disasm/background_map_ops.s), and [runtime_table_helpers.c](../src/runtime_table_helpers.c).

## What the ROM directly establishes

Several helpers use the same base and fixed offsets:

| Address | Observed access |
| --- | --- |
| `0x03003860`, `0x03003864` | Two 32-bit values written by `0x0800CEF8` |
| `0x03003868`, `0x0300386C` | Two 32-bit values written by `0x0800CF18` |
| `0x03003874 + i` | Per-index byte set to 1 by `0x0800CFD4`, cleared by `0x0800CFB0` |
| `0x03003878 + i` | Per-index byte set to 1 by `0x0800CF60`, cleared by `0x0800CF78` |
| `0x0300387C + 4*i` | Pointer-sized entry set by `0x0800CFD4`, cleared by `0x0800CFB0`, and read by `0x0800CFF8` |
| `0x0300388C + i` | Byte written by `0x0800CF48` |
| `0x03003890` | Byte written by `0x0800CF38` |
| `0x03003892`, `0x03003894` | Halfwords written by `0x0800CF90` |
| `0x030038C0 + 0x22*s` | A 17-halfword row selected by bits 8-11 of the argument to `0x0800D00C` |

The callers use indices 0-3 for the pointer and byte arrays. The code has no bounds checks in the helpers, so this documents observed use rather than a proven maximum.

`0x0800D170` derives an object-record address as `0x030034C0 + id*0x1C`. It reads the strip width at `+3`, X at `+6`, Y at `+7`, and a pointer-table index at `+8`. It reads the selected buffer pointer from `0x0300387C + 4*index`, computes `2*(X + 32*Y)`, and calls `0x08005768` with the width and the halfwords at `0x03003892`/`0x03003894`.

`0x08005768` packs the low 16 bits of its third argument together with the low four bits of its fourth argument, then writes that halfword `width` times to each of two rows. The rows are 0x40 bytes apart (32 halfwords). This establishes a two-row map-strip writer.

`0x0800D1B8` clears the record's byte at `+0`, clears the caller's first halfword, writes a replacement strip using its two value arguments, then clears an 8-byte linked-record chain. Each chain entry's active byte at `+0` is set to zero; the next index is the halfword at `+4`, with `0xFFFF` as terminator.

Other accesses confirm additional record fields: `0x0800D0AC` returns the record byte at `+0` only when the caller's first halfword is nonzero; `0x0800D0D0` and `0x0800D0E4` read bytes `+6` and `+7`; `0x0800D0F8` writes them; `0x0800D11C` changes state 2 to 3; `0x0800D13C` changes 3 to 2; and `0x0800D15C` writes byte `+0x0D`. The complete record format and meanings of the state values are not yet known.

## Why these look like background-map buffers

Initialization at `0x08074088` writes `0x06001C00` and `0x4C00` into the first config pair, then `0x0200E000` and `0x1800` into the second. It assigns tags 13, 14, and 15 to indices 0-2 and stores pointers `0x0200F800`, `0x02010000`, and `0x02010800` in the corresponding pointer-table entries. The next setup at `0x080742C0` repeats those values. Another caller at `0x0805CD8A` writes `0x06002800`/`0x2800` and `0x02018000`/`0x1800`, then associates tag 4 with pointer `0x0200E800`.

The three first pointer values are spaced by exactly `0x800` bytes, and the called writer addresses the buffers as 32-halfword rows. Together with the tag values 13-15 and destinations in the `0x06000000` region, this strongly suggests background screen-map buffers and a graphics-transfer/configuration system. That hardware-level interpretation is an inference; the exact consumer of every config field and the final transfer path still need to be traced.

`0x0800D00C` is a separate bounded-list operation: it clears 17 halfwords in one of 16 selector records at `0x030038C0`, then copies source halfwords up to the first zero (or the 17-entry limit). Its callers and purpose remain unidentified.

## Remaining unknowns

- The exact meaning of the active byte (`+0x3B4`) and subflag (`+0x3B8`) arrays.
- The meaning of the per-index byte tags and fixed fields at `+0x3D0`, `+0x3D2`, and `+0x3D4`.
- The full 0x1C-byte object-record format, especially fields `+0x0B` and `+0x0D`.
- Which routine consumes the two config pairs and performs the final hardware transfer.
- The selector-row records at `0x030038C0` and their callers.