# Runtime data block rooted at `0x03006894`

This note describes only fields and data movement that can be read directly from the USA revision 0 ROM. It does not assign game-level names to the block. The two stream-copy routines have a source-like reconstruction in [runtime_stream_copy.c](../src/runtime_stream_copy.c). Their direct callers and confirmed ROM sources are mapped in [runtime-stream-callers.md](runtime-stream-callers.md).

## Root and copied streams

`0x080726C4` initializes two pointer globals:

- `*(u32 *)0x03006894 = 0x02001000`
- `*(u32 *)0x0300689C = 0x084F3284`

The code at `0x080726E4` receives a source pointer and copies halfwords, including the first one, to `*(u32 *)0x03006894 + 4`. It stops after copying the first zero halfword. The destination advances by two bytes per element. There is no length argument or bound check visible in this routine.

The duplicate-shaped routine at `0x0807292C` performs the same zero-terminated halfword copy to base offset `+0x56`. It also has no visible explicit bound. These are the sources previously observed for selector rows 0 and 1 respectively: the setup path passes `base+4` and `base+0x56` to `0x0800D00C`, which copies each stream into a 17-halfword selector row. This establishes the memory relationship, but not the data's semantic role.

## Directly observed fields

The accessors in the surrounding range show these write locations relative to the root pointer:

| Offset | Width | Observed write behavior |
| --- | --- | --- |
| `+0` | byte | `0x0807271C` stores its argument's low byte and writes that value through indexed setter `0x080268B4` at index 64 |
| `+1`, `+2` | byte | separate low-byte setters at `0x08072738` and `0x08072742` |
| `+0x1E` | halfword | setter at `0x0807274C` |
| `+0x20` | halfword | `0x0807275C` clamps its argument to the halfword at `+0x1E`, then stores it here |
| `+0x22+2*i`, `+0x2C+2*i`, `+0x36+2*i` | halfword | indexed setters at `0x080727BC`, `0x080727D0`, and `0x080727E4` |
| `+0x40+i`, `+0x43`, `+0x49` | byte | indexed or fixed byte setters at `0x08072806`, `0x0807281C`, and `0x0807282A` |
| `+0x4C`, `+0x50` | word | setters clamp values to `0x0098967F` before storing |
| `+0x54 | byte | `0x08072968` stores its argument's low byte and writes the value through indexed setter at index 65 |
| `+0x56` | halfword stream | zero-terminated copy destination of `0x0807292C` |
| `+0xC0+24*i+6`, `+0xC0+24*i+7` | bytes | setters at `0x08072D74` and `0x08072D90` write two per-entry byte fields |

The indexed setter at `0x080268B4` maps index 64 into the halfword-backed indexed-variable range; index 65 is adjacent in that same range. That is direct evidence of shared data flow, not proof that these fields control the object-preparation path.

## Remaining unknowns

- The game-level meanings of indexed values 64, 65, and 240 and the state halfword checked by one initialization caller.
- Why selectors 0 and 1 can be refreshed from either a ROM pointer table or a context structure, while selectors 5–7 use other indexed ROM pointer tables.
- The meanings of the remaining fields and the 24-byte records beginning at `+0xC0`.
- Whether callers guarantee correctly terminated source streams; no local bounds check is present in the copy routines.

