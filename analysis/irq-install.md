# IRQ installation during startup

The memory-init routine calls `0x08003960`; that function turns the provisional IRQ setup into the active system. Its annotated instruction sequence is in [irq_install.s](../disasm/irq_install.s).

## Handler table and copied dispatcher

The function first clears the counter at `0x03002ED4`, calls state-reset routines at `0x08003C00` and `0x080036A8`, then fills thirteen entries at `0x03002D00 + 4*i` (`i = 0..12`) with `0x08003A29`. That pointer enters the Thumb no-op at `0x08003A28`.

It then uses DMA3 to copy `0x100` bytes from ROM `0x080000FC` to IWRAM `0x03002EE0`. The copied code includes its literal pool, so the ARM dispatcher’s PC-relative references remain together. The BIOS vector slot `0x03007FFC` is changed to `0x03002EE0`.

The function copies another 0x100-byte block from ROM `0x08003C58` to `0x03002DB0`. The block is a scanline graphics updater; it reads VCOUNT, processes per-slot line/event tables, and writes halfwords to graphics IO registers. See [scanline-update.md](scanline-update.md) for the recovered behavior. The copied updater's caller is not yet identified.

## VBlank handler and IRQ enable

The routine replaces handler-table slot 0 (VBlank) with `0x08003A2D`, targeting Thumb code at `0x08003A2C`. It then writes:

- `IE = 0x2001` at `0x04000200` (interrupt bits 0 and 13);
- `DISPSTAT = 0x0008` at `0x04000004` (VBlank IRQ enable);
- `IME = 1` at `0x04000208` (master enable).

The VBlank handler at `0x08003A2C` calls `0x080077E4`, increments the word at `0x03002ED4`, calls `0x0800774C`, and writes halfword `1` to `0x03007FF8`. The first helper forwards to `0x0808B474`, which validates a sound-engine state block and accesses DMA/audio-related hardware registers; it is likely the engine's VBlank sound service. The second helper calls `0x0808BB38` (a wrapper around `0x0808AE94`) under RAM-flag conditions and records a VCOUNT delta at `0x0300303C`. See [vblank-audio.md](vblank-audio.md) for the instruction evidence and confidence limits.

The state-reset helpers, scanline updater, and VBlank support routines are annotated in [early_state_init.s](../disasm/early_state_init.s), [scanline_update.s](../disasm/scanline_update.s), and [vblank_helpers.s](../disasm/vblank_helpers.s). The ROM pointer data installed at `0x03002FF0` and the callers that configure these timing flags still need analysis.
