# Initial ROM analysis

## Identification

| Field | Value |
| --- | --- |
| Target | North American GBA release |
| Header title | `SWORDCRAFT2` |
| Game code | `BSKE` |
| Revision | `0` |
| Image size | `16,777,216` bytes (16 MiB) |
| SHA-256 | `E267F052A3F138534F198BD33992D640568F80BF807E322C85C7B4CF6DD504AC` |
| Header complement checksum | Stored `0x74`; calculated `0x74` |
| Reset vector | `EA00002E` at file offset `0x0` |
| Branch target | File offset `0xC0`, GBA bus address `0x080000C0` |

The GBA entry instruction is ARM state. The branch target is computed from ARM PC semantics: `PC = 0x08000008`, displacement `0x2E * 4`, destination `0x080000C0`.

These checks establish that the header fields and complement checksum agree; they do not prove every ROM region is intact.

## Method and limits

A ROM stores ARM/Thumb machine instructions and data rather than the original C project. Decompiled C can therefore be equivalent and well annotated, but original symbols, comments, and exact source structure cannot generally be recovered from the binary alone.

The initial local copy was inspected without copying the ROM into this repository. The repository contains only analysis tools and notes. Local ROM SHA-256 was `E267F052A3F138534F198BD33992D640568F80BF807E322C85C7B4CF6DD504AC`.

## Next investigation steps

1. Disassemble the reset target and follow initialization/control flow while marking code versus literal pools and data.
2. Find interrupt handlers, BIOS calls, and writes to GBA memory-mapped registers.
3. Map decompression routines and asset/script tables.
4. Label routines and data in a machine-readable map; convert routines to C incrementally.
5. Validate any reconstructed build against the target image when an ARM7TDMI toolchain and linker layout are established.

## References

- [Community Korean localization repository](https://github.com/TeamLimRyan/SUMMON_NIGHT_CRAFT_SWORD_MONOGATARI_2_KOREAN_LOCALIZATION_RELEASE)
- [GBAtemp discussion of text and compression formats in the series](https://gbatemp.net/threads/summon-night-craft-sword-monogatari.227224/)
- [Summon Night: Swordcraft Story 2 deconstruction wiki](https://deconstruction.fandom.com/wiki/Summon_Night%3A_Swordcraft_Story_2)
