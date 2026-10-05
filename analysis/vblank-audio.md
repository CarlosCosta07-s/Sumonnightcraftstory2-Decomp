# VBlank sound and VCOUNT helpers

The VBlank handler at `0x08003A2C` calls `0x080077E4`, increments `0x03002ED4`, calls `0x0800774C`, and sets a halfword at `0x03007FF8`. This page records the two helper paths and their observable effects. Annotated Thumb is in [vblank_helpers.s](../disasm/vblank_helpers.s); a behavior-level C reconstruction is in [vblank_helpers.c](../src/vblank_helpers.c).

## Sound-engine evidence

`0x080077E4` is a four-instruction wrapper around `0x0808B474`. That callee loads a state pointer through `0x03007FF0`, compares the first word with `0x68736D53`, updates byte counters in that state, and accesses memory-mapped registers beginning at `0x040000BC`, including halfword writes at `0x040000C6`. These state and hardware accesses point to the sound subsystem. The descriptive label `vblank_sound_service_wrapper` is provisional; the original symbol is not recovered.

`0x0800774C` and `0x080077A0` both call `0x0808BB38`, which is a wrapper around `0x0808AE94`. The latter validates the same state signature through the global at `0x03007FF0` and continues into a larger state-processing routine. This is strong evidence that these calls service the sound engine, though the complete engine control flow has not been reconstructed.

## VCOUNT delta routines

`0x0800774C` proceeds only when the signed byte at `0x03003052` equals `1` and the signed byte at `0x03003040` equals `0`. `0x080077A0` proceeds when the byte at `0x03003052` equals `0`; it does not test `0x03003040`.

Both routines sample `VCOUNT` (`0x04000006`), call `0x0808BB38`, sample VCOUNT again, and store an elapsed-line value at `0x0300303C`. If the second sample is lower than the first, the code adds `0xE3` before subtracting the first sample. The use of `0xE3` is confirmed; the intended wrap convention and the meaning of the stored delta are not yet established.

The helpers at `0x08007730` and `0x0800773C` write and read the signed byte at `0x03003040`. A separate byte getter at `0x080077F0` reads `0x03003050`. Their callers and the meaning of the mode/flag fields remain unknown.

## Next analysis

Trace writes to `0x03003040`, `0x03003050`, and `0x03003052` to identify who configures these branches. Continue mapping the sound engine around `0x0808AE94` and `0x0808B474`; keep the current names as analysis labels until callers or data structures confirm more specific roles.
