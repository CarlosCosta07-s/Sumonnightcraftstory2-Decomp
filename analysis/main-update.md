# Main per-frame update dispatcher

The startup loop at `0x08000418` calls `0x080001D0` on each iteration. The routine is a top-level update dispatcher: it calls a fixed series of subsystem routines, checks indexed value `8` before three more calls, then writes shared state and invokes two final helpers. The exact order is preserved in [main_update.s](../disasm/main_update.s), with a behavior-level reconstruction in [main_update.c](../src/main_update.c).

## Update order

1. Unconditional calls: `0x080011F8`, `0x080063FC`, `0x0800D8A8`, `0x08007D10`, `0x080139AC`, `0x08001964`, `0x080126E8`, `0x08013710`, and `0x0801053C`.
2. Read indexed value `8` using `0x08026908`. If it is not `1`, call `0x0802660C` (`initialize_indexed_storage_0802660C`).
3. Unconditional calls: `0x0800D908`, `0x080069D8`, `0x08005540`, `0x0800A154`, `0x08012058`, `0x08009CDC`, and `0x080548CC`.
4. Read indexed value `8` again; call `0x080726C4` (`initialize_runtime_pointer_roots_080726C4`) unless the value is `1`. Read it a third time; call `0x08069270` (`initialize_secondary_runtime_block_08069270`) unless it is `1`.
5. Call `0x0807CB8C` and `0x0808ACCC`; store `0x02003200` in record slot 0 via `0x080266DC`; set indexed values 0-3 to `0x55555555`; pass indexed value 4 to `0x080266F8`; and call `0x08026728` with three zero arguments.

The repeated reads show that indexed value 8 gates three separate update paths. Their game-level names and whether their state can change between reads remain unknown.

## Indexed value accessors

`0x080268B4` writes an indexed value and `0x08026908` reads one. Both truncate the input index to 16 bits and select a storage format by range:

| Index | Storage | Address calculation | Read behavior |
| --- | --- | --- | --- |
| `0x0000-0x003F` | 32-bit word | `base = *(u32 *)0x030067D0`; then `base + 4 * index` | return word |
| `0x0040-0x017F` | 16-bit halfword | `base = *(u32 *)0x0300659C`; then `base + 2 * index - 0x80` | sign-extend halfword |
| `0x0180-0xFFFF` | byte | `base = *(u32 *)0x030065A4`; then `base + index - 0x180` | sign-extend byte |

The initializer at `0x0802660C` sets the three indexed-storage base pointers to `0x02000000`, `0x02000100`, and `0x02000380`, matching the accessor address calculations above. It also installs three additional pointer roots at `0x030067CC`, `0x03006590`, and `0x030067C8`, targeting `0x02000540`, `0x02000580`, and `0x02000680`. The source reconstruction is in [indexed_variables.c](../src/indexed_variables.c), and both accessors are annotated in [indexed_variables.s](../disasm/indexed_variables.s). The initializer is listed in [indexed_storage_init.s](../disasm/indexed_storage_init.s) and reconstructed in [indexed_storage_init.c](../src/indexed_storage_init.c).

## Other gated initialization paths\n\nThe dispatcher’s second gated path, at `0x080726C4`, writes `0x02001000` through the pointer global at `0x03006894` and writes ROM address `0x084F3284` through `0x0300689C`. Its address-based reconstruction is in [runtime_pointer_init.s](../disasm/runtime_pointer_init.s) and [runtime_pointer_init.c](../src/runtime_pointer_init.c).\n\nThe third gated path, at `0x08069270`, sets `*(u32 *)0x03006860` to `0x02002800`, calls the `0x0808CF70` SVC #0x0B wrapper with a zero halfword on the stack, destination `0x02002800`, and control argument `0x010000D6`, then writes zero to `0x020029A8` (`base + 0x1A8`). See [secondary_runtime_init.s](../disasm/secondary_runtime_init.s) and [secondary_runtime_init.c](../src/secondary_runtime_init.c). The SVC wrapper is confirmed; its full transfer semantics and these pointed-to structures’ game-level roles remain unknown.\n\nA nearby routine at `0x080692A8` reads a signed state at offset `+6` through the pointer global `0x03006884`. It dispatches states `1`, `4`, `8`, and `12` to `0x08069594`, `0x080695A4`, `0x08066540`, and `0x080695E8`; for state `1`, a zero return from `0x08069594` clears the state. Although it sits near the initializer at `0x08069270`, it uses a different pointer global, so the relationship between the two structures remains unconfirmed. Its listing and C reconstruction are in [state_dispatch_080692A8.s](../disasm/state_dispatch_080692A8.s) and [state_dispatch_080692A8.c](../src/state_dispatch_080692A8.c). Callers and helper semantics are not yet identified.\n\nThe state poller at `0x080693E4` uses the same pointer global `0x03006884` and state offset `+6`. It dispatches states `1`, `4`, `8`, and `12` through the same four helpers; when the state is zero afterward, it calls `0x0800CF78` with arguments `0` through `3` and returns `0`. It returns `1` for nonzero states. The helper's role is unknown; see [state_poll_080693E4.s](../disasm/state_poll_080693E4.s) and [state_poll_080693E4.c](../src/state_poll_080693E4.c).\n\n## Confidence and next work

The call order, branch conditions, literal values, and index thresholds come directly from the matching ROM. The names in the C source are descriptive. Next, analyze the repeated callees and trace where indexed values 4 and 8 are written.

