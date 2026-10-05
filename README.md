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

The startup path, memory initialization, IRQ dispatcher and handler table are mapped. The scanline updater's HBlank installation and the top-level frame-update dispatcher are identified. The indexed value accessors and their storage initialization, two adjacent conditional runtime initializers, and the probable VBlank sound-engine path are documented. Equivalent C excerpts are in [`src/early_runtime.c`](src/early_runtime.c), [`src/scanline_update.c`](src/scanline_update.c), [`src/scanline_irq_setup.c`](src/scanline_irq_setup.c), [`src/indexed_variables.c`](src/indexed_variables.c), [`src/indexed_storage_init.c`](src/indexed_storage_init.c), [`src/runtime_pointer_init.c`](src/runtime_pointer_init.c), [`src/secondary_runtime_init.c`](src/secondary_runtime_init.c), [`src/state_dispatch_080692A8.c`](src/state_dispatch_080692A8.c), [`src/state_poll_080693E4.c`](src/state_poll_080693E4.c), [`src/main_update.c`](src/main_update.c), and [`src/vblank_helpers.c`](src/vblank_helpers.c). Annotated assembly and evidence are in [`disasm/`](disasm/) and [`analysis/`](analysis/).

Most callees of the frame update dispatcher, several DMA setup helpers, the sound engine's deeper control flow, HBlank activation conditions, and most game systems remain to be analyzed. Symbol names are descriptive where original names are unavailable, and the reconstructed C excerpts are not yet part of a matching full build. No complete decompilation for this edition was found during the initial research.

See [`docs/initial-analysis.md`](docs/initial-analysis.md) for ROM identification and community references.

