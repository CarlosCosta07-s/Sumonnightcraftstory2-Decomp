# Summon Night: Swordcraft Story 2 (USA) decompilation

A progressive reverse-engineering project for the North American Game Boy Advance release (`BSKE`). The aim is to document the ROM, disassemble ARM7TDMI code, identify data formats, and gradually reconstruct equivalent C code.

## Target ROM

- Header title: `SWORDCRAFT2`
- Game code: `BSKE`
- Revision: `0`
- Expected size: `16,777,216` bytes (16 MiB)
- SHA-256: `E267F052A3F138534F198BD33992D640568F80BF807E322C85C7B4CF6DD504AC`
- Header checksum: `0x74` (verified)
- Entry instruction: ARM branch `EA00002E` at file offset `0x00000000`, targeting file offset `0x000000C0` / GBA address `0x080000C0`

The ROM itself is intentionally not stored in this repository. Keep a legally obtained local copy and pass its path to the tools.

## Quick start

Requires Python 3.10+.

```sh
python tools/inspect_rom.py "/path/to/Summon Night - Swordcraft Story 2 (USA).gba"
python -m pip install -r requirements.txt
python tools/disassemble.py "/path/to/rom.gba" --start 0xC0 --size 0x200 --mode arm
python tools/disassemble.py "/path/to/rom.gba" --start 0x40C --size 0x100 --mode thumb
```

Use `--mode thumb` for Thumb-code ranges and `--mode arm` for ARM-code ranges. GBA ROM addresses start at `0x08000000`; tool offsets are file offsets unless otherwise stated. Disassembly is mechanical; literal pools and embedded data must be marked manually.

## Project status

The startup path, memory-fill setup, IRQ dispatcher installation, handler table, and VBlank handler are mapped. Initial equivalent C for state accessors and IRQ setup is in [`src/early_runtime.c`](src/early_runtime.c). Evidence and annotated assembly are in [`analysis/`](analysis/) and [`disasm/`](disasm/).

The copied code blob at `0x08003C58`, several DMA setup callees, the large update routine at `0x080001D0`, and most of the game remain to be analyzed. No complete decompilation for this edition was found during the initial research.

See [`docs/initial-analysis.md`](docs/initial-analysis.md) for ROM identification and community references.
