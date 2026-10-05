# IRQ installation during startup

The memory-init routine calls `0x08003960`; that function turns the provisional IRQ setup into the active system. The annotated instruction sequence is in [irq_install.s](../disasm/irq_install.s).

## Handler table and copied dispatcher

The function first clears the counter at `0x03002ED4`, calls helpers at `0x08003C00` and `0x080036A8`, then fills thirteen entries at `0x03002D00 + 4*i` (`i = 0..12`) with `0x08003A29`. That pointer enters the Thumb no-op at `0x08003A28`.

It then uses DMA3 to copy `0x100` bytes from ROM `0x080000FC` to IWRAM `0x03002EE0`. The copied code includes its literal pool, so the ARM dispatcher’s PC-relative references remain together. The BIOS vector slot `0x03007FFC` is changed to `0x03002EE0`.

A second `0x100)-byte block is copied from ROM `0x08003C58` to `0x03002DB0`. Its use is not identified yet; the ROM pointer literal has bit 0 set for Thumb, while DMA copies the aligned halfword stream.

## VBlank handler and IRQ enable

The routine replaces handler-table slot 0 (VBlank) with `0x08003A2D`, targeting Thumb code at `0x08003A2C`. It then writes:

- `IE = 0x2001` at `0x04000200` (interrupt bits 0 and 13);
- `DISPSTAT = 0x0008` at `0x04000004` (VBlank IRQ enable);
- `IME = 1` at `0x04000208` (master enable).

The VBlank handler at `0x08003A2C` calls `0x080077E4`, increments the word at `0x03002ED4`, calls `0x0800774C`, and writes halfword `1` to `0x03007FF8`. That final address is in BIOS work RAM; its exact interaction with the BIOS is not yet documented here.

The source blob at `0x08003C58`, the two setup helpers, and the VBlank callees need further analysis. The handler-table initializer and interrupt register writes, however, are directly visible in the matching ROM.
