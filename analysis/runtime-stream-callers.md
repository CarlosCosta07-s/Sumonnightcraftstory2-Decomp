# Callers and ROM sources for the runtime halfword streams

This note extends [runtime-data-block-02001000.md](runtime-data-block-02001000.md) with direct call sites and the ROM pointer values they pass. Addresses and conditions below come from the matching USA ROM, SHA-256 `E267F052A3F138534F198BD33992D640568F80BF807E322C85C7B4CF6DD504AC`.

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

Entries 10 and 11 are zero. The first selected targets contain zero-terminated halfword sequences; for example, `0x0808F420` begins `0x8264, 0x8284, 0x8287, 0x8281, 0x8292, 0`, while `0x0808F414` begins `0x8260, 0x8285, 0x8292, 0x8281, 0`. The codes are not yet decoded or assigned a semantic domain.

## Context-provided streams

At `0x08014C4C`, code reads a byte at offset `+0x0C` from the structure pointed to by `0x03006554`. Value `0` copies the halfword stream at that structure's offset `+0x2C` to selector row 0 and runtime block offset `+4`; value `1` uses selector row 1 and block offset `+0x56`. Both branches call `0x0800D00C` before the matching copy routine.

A related path at `0x08014C98` repeats the indexed-value/table selection described above. These call sites show that the block's streams can be refreshed from either ROM-selected pointers or a context structure.

## Initial setup sources

The caller at `0x08060456` invokes `0x08070650` when the halfword at offset `+0x0A` of the structure rooted at `0x03006848` is not `20`. That initializer loads a pointer from ROM slot `0x084FCA2C`; the slot contains `0x08092608`. It passes the pointed-to zero-terminated sequence to `0x080726E4`.

A second caller at `0x080707CC` loads a pointer from `0x084FCA34`, whose value is `0x08092638`, then passes it to `0x0807292C`. The sequence at `0x08092608` starts `0x8264, 0x8284, 0x8287, 0x8281, 0x8292, 0`; the sequence at `0x08092638` starts `0x8264, 0x8277, 0x8285, 0x826B, 0x8263, 0`.

The values `64`, `65`, `240`, and the state halfword compared with `20` have only been identified as indexed values or fields. Their game-level meanings are not established. Likewise, the halfword codes have not been proven to be text, glyph IDs, or another resource format.
