# Reset path and interrupt dispatcher

ROM target: USA revision `BSKE`, identified by SHA-256 in the [initial analysis](../docs/initial-analysis.md).

## Reset stub (`0x080000C0`, ARM)

The reset entry performs these observable steps:

1. Sets CPSR mode to IRQ (`0x12`) and loads `sp` from a literal at `0x080000F4`; the literal is `0x03007FA0`.
2. Sets CPSR mode to System (`0x1F`) and loads `sp` from `0x080000F8`; the literal is `0x03007E00`.
3. Loads `0x03007FFC`, the BIOS IRQ vector slot, and stores `0x080000FC` there.
4. Loads the odd pointer `0x0800040D` and uses `bx`, entering Thumb code at `0x0800040C`.
5. If that call returns, execution branches back to the reset entry.

The literal pool at `0x080001C4-0x080001CF` contains the BIOS vector address, Thumb startup pointer, and handler-table base `0x03002D00`.

## IRQ dispatcher (`0x080000FC`, ARM)

The dispatcher reads adjacent interrupt-enable and interrupt-request registers at `0x04000200` and `0x04000202` as one word, then ANDs the request bits with the enable bits. It treats bit `0x2000` specially: a byte store is made to `0x04000084`, followed by a loop while that pending bit remains set. The purpose of this store is unresolved.

For bits `0x0001` through `0x1000`, the dispatcher checks the pending mask from low to high. Each absent bit advances an index by four bytes. It writes the selected bit to IF (`0x04000202`) to acknowledge it, loads a function pointer from `0x03002D00 + index`, and branches to that handler.

## IRQ installation during startup

The initializer at `0x08003960` fills table slots 0-12 at `0x03002D00` with a default Thumb no-op at `0x08003A28`. It copies the dispatcher and its literal pool (0x100 bytes) from ROM `0x080000FC` to IWRAM `0x03002EE0`, then changes the BIOS vector to that IWRAM copy.

It also copies a 0x100-byte ROM block from `0x08003C58` to `0x03002DB0`. The routine in the copied block reads VCOUNT, processes per-slot line/event tables, and writes values to graphics IO registers; its role as a scanline/raster updater is supported by its later installation as the HBlank handler at `0x08003704`. See [scanline-update.md](scanline-update.md), [scanline_irq_setup.s](../disasm/scanline_irq_setup.s), and the equivalent C in [scanline_update.c](../src/scanline_update.c).

Slot 0 (VBlank) is replaced with `0x08003A2D`, targeting the Thumb handler at `0x08003A2C`. The initializer then writes `IE=0x2001`, enables VBlank IRQ in DISPSTAT (`0x04000004 = 8`), and enables IME (`0x04000208 = 1`). Detailed instructions are in [irq-install.md](irq-install.md) and [irq_install.s](../disasm/irq_install.s).

The VBlank handler calls `0x080077E4`, increments the word at `0x03002ED4`, calls `0x0800774C`, and writes halfword `1` to `0x03007FF8`. `0x080077E4` forwards to a routine that validates a sound-engine state signature and touches sound/DMA-related registers. `0x0800774C` calls a sound-engine update wrapper when two RAM flags match, then stores a VCOUNT-derived delta at `0x0300303C`. The helper at `0x080077A0` applies the same calculation under the alternate mode flag. See [vblank-audio.md](vblank-audio.md).

## Thumb startup (`0x0800040C`)

At `0x0800040C`, the stub saves LR, calls `0x080002B8`, then loops through `0x080001D0`, the state setter at `0x08000290`, and polling routine `0x080003C4`. The literal loaded at `0x08000412` is at `0x08000428`; it should be marked as data, not Thumb instructions. Runtime findings are in [startup-runtime.md](startup-runtime.md).

## Confidence and next steps

Addresses, modes, literal values, and register operations come directly from disassembly of the matching ROM. The IRQ table setup and scanline updater's per-line accesses are mapped. Remaining work includes identifying the higher-level conditions that select the HBlank setup and configure VCOUNT timing flags, analyzing DMA helper callees and ROM pointer targets at `0x03002FF0`, and mapping the large update routine.

