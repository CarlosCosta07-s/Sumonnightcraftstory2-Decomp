# Scanline update routine copied to IWRAM

Startup's IRQ initializer copies 0x100 bytes from ROM `0x08003C58` to IWRAM `0x03002DB0`. Routine `0x08003704` later installs the copied code at `0x03002DB1` (Thumb entry) in IRQ table slot 1, which is HBlank, and enables HBlank IRQ generation. That resolves the updater's caller. The code reads VCOUNT and uses per-slot tables to update values during visible scanlines. It ends at ROM offset `0x3D2E`; its literals are in `0x3D30-0x3D57`. Annotated assembly and C are in [scanline_update.s](../disasm/scanline_update.s), [scanline_update.c](../src/scanline_update.c), [scanline_irq_setup.s](../disasm/scanline_irq_setup.s), and [scanline_irq_setup.c](../src/scanline_irq_setup.c).

## Recovered behavior

1. Read VCOUNT (`0x04000006`). Return when the scanline is 160 or greater.
2. Read the active slot index from `0x03002DA0`.
3. If the slot has destinations at `0x03002EC0` or `0x03002EC8`, copy one halfword from the corresponding per-line source streams at `0x03002D90` or `0x03002D98` to each destination.
4. Inspect the slot's 0x20-byte record at `0x03002D40 + 0x20 * slot`. It contains four 8-byte events of the form `{destination pointer, scanline, halfword value}`. For each event whose scanline equals VCOUNT, write its value to its destination.
5. If the low halfword of the stream pointer at `0x03002FE0 + 4 * slot` is nonzero, load four halfwords for this scanline from each of two per-line streams (`0x03002FE0` and `0x03002EB0`) and write them to graphics IO addresses `0x04000028-0x0400002E` and `0x04000020`, `0x04000024`, `0x04000026`, and `0x0400002A`.

The IO writes and scanline-indexed tables strongly indicate raster/affine graphics updates. The routine's caller and the semantic names of its table slots remain unknown; the current name is descriptive, not an original symbol.

## HBlank installation

[early_state_init.s](../disasm/early_state_init.s) records routines that clear the pointer tables and initialize four groups of event records. The event record stride and field offsets match the accesses above. A separate helper at `0x08003DA8` writes five ROM pointers into a RAM block beginning at `0x03002FF0`; their individual data formats still need identification.

