# Reset path and interrupt dispatcher

ROM target: USA revision `BSKE`, identified by SHA-256 in the [initial analysis](../docs/initial-analysis.md).

## Reset stub (`0x080000C0`, ARM)

The reset entry performs these observable steps:

1. Sets CPSR mode to IRQ (`0x12`) and loads `sp` from a literal at `0x080000F4`; the literal is `0x03007FA0`.
2. Sets CPSR mode to System (`0x1F`) and loads `sp` from `0x080000F8`; the literal is `0x03007E00`.
3. Loads `0x03007FFC`, the BIOS IRQ vector slot, and stores `0x080000FC` there.
4. Loads the odd pointer `0x0800040D` and uses `bx`, entering Thumb code at `0x0800040C`.
5. If that call returns, execution branches back to the reset entry.

The vector at `0x080000FC` is the custom IRQ dispatcher annotated in [`disasm/early_boot.s`](../disasm/early_boot.s). The literal pool at `0x080001C4-0x080001CF` contains the BIOS vector address, Thumb startup pointer, and a handler-table base `0x03002D00`.

## IRQ dispatcher (`0x080000FC`, ARM)

The routine reads the adjacent GBA interrupt-enable and interrupt-request registers at `0x04000200` and `0x04000202` as one word, then ANDs the request bits with the enable bits. It treats bit `0x2000` specially: a byte store is made to `0x04000084`, followed by a loop while the pending bit remains set. The purpose of this store is unresolved and is intentionally not guessed in the disassembly comments.

For bits `0x0001` through `0x1000`, the dispatcher checks the pending mask from low to high. Each absent bit advances an index by four bytes. It writes the selected bit to IF (`0x04000202`) to acknowledge it, loads a function pointer from the table at `0x03002D00 + index`, and branches to that handler. The table contents and handler identities are not mapped yet.

## Thumb startup (`0x0800040C`)

At `0x0800040C`, the stub saves LR, calls helpers at `0x080002B8`, `0x080001D0`, `0x08000290`, and `0x080003C4`, and loops back to `0x08000418`. The literal loaded at `0x08000412` is at `0x08000428`; it should be marked as data, not Thumb instructions. The helper functions remain unlabeled pending control-flow and call-site analysis.

## Confidence and next steps

The addresses, modes, literal values, and register operations above come directly from disassembly of the matching local ROM. Hardware-register meaning is identified only where the address and instruction sequence support it. Next, map the IRQ table and inspect the four Thumb helper routines, then trace startup's RAM clearing and main-loop behavior.
