# Runtime object preparation and transfer queue

This note follows the object setup path from `0x0800A380` through its staging buffer and transfer requests. Source-like reconstructions are in [runtime_object_pipeline.c](../src/runtime_object_pipeline.c), the queue listing is in [transfer_queue.s](../disasm/transfer_queue.s), and the related map-strip routines remain in [background_map_ops.c](../src/background_map_ops.c).

## Direct observations

### Object setup at `0x0800A380`

- The routine scans status byte `0` of records at `0x030034C0 + index*0x1C`, testing indices `0..19`.
- It writes `0x0200 | index` to the caller's halfword handle.
- If the supplied source's first halfword is zero, it loads a replacement pointer from the word stored at ROM address `0x084C7880`.
- It computes a staging destination as `*(0x03003868) + (*(0x03003870) & ~3)`.
- It calls `0x08004144` with that destination, the source words, the record's halfwords at `+0x10`, a command-word pointer, and a fill value.
- The return from `0x08004144` is stored in record byte `+3` and advances the cursor at `0x03003870` by `return << 6`. Thus the return is used as a count of 64-byte reservation units.
- It calls `0x0800A304` on the source and stores that return in record byte `+2`.
- When halfword `0x03003A70 == 1`, it calls `0x080042D0` with the same staging destination and command-word pointer, then clears the gate.
- Other direct record writes are: `+0=2`, `+1=0`, `+4=0`, `+5=0`, `+6=x`, `+7=y`, `+8=input byte`, `+9=input byte`, `+0x0A=same input byte`, `+0x0D=count`, `+0x0E=(count-1) or 0`, and `+0x18=0`. Four halfwords at `+0x10..+0x16` are cleared before preparation.
- It then calls `0x0800A7E0`, which attaches transfer-node records to the object.

There is no explicit “no free record” return in the observed control flow. After testing indices 0 through 19, the routine continues with index 20. Since `0x030034C0 + 20*0x1C = 0x030036F0`, that address is also the start of the 8-byte node pool used by `0x0800A7E0`. This is a potential boundary hazard; whether callers guarantee an available record is not yet established.

### Descriptor parsing and staging

- `0x0800A304` reads halfwords until zero. It masks values with `0xF0FF`; a value matching `0xC083` selects one of the 16 rows at `0x030038C0 + selector*0x22`, with selector in bits 8–11. The selected row is scanned through its zero terminator. The routine also compares against `0x7087`.
- `0x08004144` clears 480 words (1,920 bytes) at the scratch pointer `*(0x03003008)` using BIOS CpuFastSet, with the supplied fill value. It then interprets the source/command words, reads the same selector rows, and calls `0x080053AC`, `0x080061A4`, and `0x080057D8` on other entries. At the end it calls `0x08006330` to transfer the generated scratch data into the staging destination.
- `0x080042D0` also reads the command words and selector rows. It writes into the destination in 96-byte steps and calls `0x08005954` or `0x08005960`.

These behaviors are established from the instruction flow. The meanings of markers `0xC083` and `0x7087`, the row contents, the helper transforms, and the semantic name of the prepared asset remain open.

### VRAM transfer requests

- `0x0800A7E0` reads the VRAM base from `0x03003860`, the staging base from `0x03003868`, and the aligned staging cursor from `0x03003870`.
- It scans 46 eight-byte node slots at `0x030036F0 + index*8`. The first byte is treated as an occupied/free flag; the halfword at `+4` is followed as a linked-list index, with `0xFFFF` used as a terminator.
- For available slots, it calls `0x08013A20` with consecutive source/destination addresses and a size of `0x300` bytes. It records a per-node value of 12 units or the remaining unit count. The exact meaning of the node halfword at `+2` is not assigned here.
- `0x08013A20` stores source, destination, and a zero-extended 16-bit size in each 12-byte entry at `0x03006170 + count*12`. It accepts indices 0–79; if the count is already above 79, it returns without adding a request.
- `0x08013A54` resets the halfword count at `0x03006160`.
- `0x08013A60` clears 240 words at `0x03006170`, which is the 960-byte space for 80 queue entries.
- `0x080139C4` drains the queue from index `count-1` down to zero. For each entry it writes source, destination, and `(byte_count >> 2) | 0x84000000` to DMA3 registers at `0x040000D4`, then waits until DMA3 bit 31 clears. It does not reset the count.
- The direct caller of `0x080139C4` is `0x08000358`. That routine is called at `0x080003D0` inside the polling loop at `0x080003C4`, which repeats while the word at `0x030028E8` is nonzero. The queue drain is the first operation in `0x08000358`; later in that routine, `0x080139B8` resets the queue count. The frame dispatcher also calls the separate reset wrapper `0x080139AC`. The VBlank handler at `0x08003A2C` does not directly call this drain path.

### What remains unknown

The queue's producer, capacity, entry format, DMA3 drain, and direct call context are now established. The remaining questions are:

1. Resolve the roles of `0xC083` and `0x7087` by tracing their source tables and the helper transforms at `0x080053AC`, `0x080061A4`, `0x080057D8`, `0x08005954`, and `0x08005960`.
2. Identify the exact meaning and units of the node field at `+2`, and how it relates to configured VRAM range size `0x03003864`.
3. Confirm the caller invariant that prevents object index 20 from being used.
4. Explain why the queue drains in reverse order and how the polling-loop state at `0x030028E8` is entered/exited.
