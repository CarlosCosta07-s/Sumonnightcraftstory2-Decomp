# Callers and ROM sources for the runtime halfword streams

This note extends [runtime-data-block-02001000.md](runtime-data-block-02001000.md) with direct call sites and the ROM pointer values they pass. Source-like C reconstructions of the two selector event handlers are in [runtime_event_selector_handlers.c](../src/runtime_event_selector_handlers.c). Addresses and conditions below come from the matching USA ROM, SHA-256 `E267F052A3F138534F198BD33992D640568F80BF807E322C85C7B4CF6DD504AC`.

## Direct caller inventory

A full halfword-aligned Thumb `BL` scan found these direct call sites:

| Copy routine | Call sites |
| --- | --- |
| `0x080726E4` → block offset `+4` | `0x08014BDA`, `0x08014C70`, `0x08014CCA`, `0x0807068A` |
| `0x0807292C` → block offset `+0x56` | `0x08014C04`, `0x08014C88`, `0x08014CF4`, `0x080707CC` |

This is a direct-call inventory, not proof that there are no ARM-state, indirect, or computed calls.

## Selectable source table

The routines around `0x08014BA8` and `0x08014C98` read indexed value `240` using `0x08026908`. In the observed branches:

- When the value is `0`, they read indexed value `64`, select a 32-bit pointer at `0x084C7B48 + 4*value64`, pass it with tag `0xC083` to `0x0800D00C`, then pass that same pointer to `0x080726E4`.
- When the value is `1`, they read indexed value `65`, select a pointer at `0x084C7B50 + 4*value65` (the same table with a two-entry offset), pass it with tag `0xC183` to `0x0800D00C`, then pass that pointer to `0x0807292C`.
- Other values take the return path in these routines; this does not establish whether other code handles them.

The first ten words at `0x084C7B48` are pointers:

| Table index | Pointer |
| ---: | --- |
| 0 | `0x0808F420` |
| 1 | `0x0808F414` |
| 2 | `0x0808F408` |
| 3 | `0x0808F3FC` |
| 4 | `0x0808F3F0` |
| 5 | `0x0808F3E4` |
| 6 | `0x0808F450` |
| 7 | `0x0808F444` |
| 8 | `0x0808F438` |
| 9 | `0x0808F42C` |

Entries 10 and 11 are zero. The first selected targets contain zero-terminated halfword sequences; for example, `0x0808F420` begins `0x8264, 0x8284, 0x8287, 0x8281, 0x8292, 0`, while `0x0808F414` begins `0x8260, 0x8285, 0x8292, 0x8281, 0`. The codes are not yet decoded or assigned a semantic domain. The observed selection code does not clamp values 64 or 65 before pointer arithmetic; whether the stored values are constrained upstream is unknown.

## Context-provided streams

At `0x08014C4C`, code reads a byte at offset `+0x0C` from the structure pointed to by `0x03006554`. Value `0` copies the halfword stream at that structure's offset `+0x2C` to selector row 0 and runtime block offset `+4`; value `1` uses selector row 1 and block offset `+0x56`. Both branches call `0x0800D00C` before the matching copy routine.

A related path at `0x08014C98` repeats the indexed-value/table selection described above. These call sites show that the block's streams can be refreshed from either ROM-selected pointers or a context structure.

## Initial setup sources

The caller at `0x08060456` invokes `0x08070650` when the halfword at offset `+0x0A` of the structure rooted at `0x03006848` is not `20`. That initializer loads a pointer from ROM slot `0x084FCA2C`; the slot contains `0x08092608`. It passes the pointed-to zero-terminated sequence to `0x080726E4`.

A second caller at `0x080707CC` loads a pointer from `0x084FCA34`, whose value is `0x08092638`, then passes it to `0x0807292C`. The sequence at `0x08092608` starts `0x8264, 0x8284, 0x8287, 0x8281, 0x8292, 0`; the sequence at `0x08092638` starts `0x8264, 0x8277, 0x8285, 0x826B, 0x8263, 0`.

The values `64`, `65`, `240`, and the state halfword compared with `20` have only been identified as indexed values or fields. Their game-level meanings are not established. The pointer-selection path has no local range check for values 64 or 65; table validity therefore depends on upstream constraints that have not yet been traced. Likewise, the halfword codes have not been proven to be text, glyph IDs, or another resource format.


## Writers of indexed values 64 and 65

The direct callers of the small setter wrappers add constraints to the source question:

- `0x0807271C` stores its byte argument in block offset `+0` and writes the same value to indexed value `64`. Its direct callers found in the halfword-aligned Thumb `BL` scan are `0x08064F2E` and `0x08070690`. The first passes the byte at offset `+0xD0` of the structure held in `r7`; the second passes zero during initialization.
- `0x08072968` stores its byte argument in block offset `+0x54` and writes it to indexed value `65`. Its only direct caller found in that scan is `0x080707D2`, which passes `0xFF` during initialization.
- Two additional routines, `0x08073AE0` and `0x08073B10`, call `0x08025F4C`, store its low-byte return at block offsets `+0` and `+0x54`, and write it to indexed values `64` and `65` respectively. No halfword-aligned Thumb `BL` callers to those two routines were found, so their activation path remains unidentified.

Thus these indexed values are not only table indices: at least some code paths write a context byte or a byte returned from a halfword-stream processor into them. The ROM-table selection code still performs no local range check. Whether the values are constrained to the ten nonzero pointer entries is unknown.


## Event-command dispatch for values 64 and 65

The indirect path is resolved through the ROM handler table:

- Dispatcher `0x08026B14` reads the command byte at `*(u32 *)0x03006594 + 2`, multiplies it by four, and loads a handler pointer from the table at `0x084CABAC`.
- It calls `0x0808D334`, which is a one-instruction `bx r0` tail-call trampoline.
- Table entry 94 at `0x084CAD24` contains Thumb pointer `0x08073AE1`; entry 95 at `0x084CAD28` contains `0x08073B11`.
- Handler `0x08073AE0` runs `0x08025F4C`, then stores its low-byte result at block offset `+0` and indexed value `64`.
- Handler `0x08073B10` does the same at block offset `+0x54` and indexed value `65`.
- Both handlers set byte `1` at `*(u32 *)0x03006598 + 1` and return zero.

This proves that the event-command dispatch table can refresh both selector indices using the result of `0x08025F4C`. The parser's output domain, the meaning of command IDs 94/95, and the constraints on values later used as pointer-table indices remain unresolved.
