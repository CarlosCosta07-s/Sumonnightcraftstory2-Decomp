# RAM state reset and data pointer setup

See the annotated instructions in [early_state_init.s](../disasm/early_state_init.s).

## State reset helpers

Routine `0x08003C00`, called during IRQ installation, writes zeros to fields at `0x03002DA0`, `0x03002D80`, `0x03002EC0-0x03002ECC`, `0x03002D90-0x03002D9C`, `0x03002FE0-0x03002FE4`, and `0x03002EB0-0x03002EB4`. This matches the pointer and selector tables consumed by the copied scanline updater, plus additional state fields whose use is not yet known.

Routine `0x080036A8` clears a halfword at `0x03002DA0` and a word at `0x03002D80`. It initializes four records at each of `0x03002D40` and `0x03002D60`, with an eight-byte stride: a zero word, halfword `0x00FF`, then halfword zero. It also clears halfwords at `0x03002ED0` and `0x03002ED2`. These match the four event slots read by [scanline_update](scanline-update.md).

The data shapes suggest per-slot scanline callbacks and tables, but their higher-level purpose is still being traced.

## ROM data roots

Routine `0x08003DA8` writes five 32-bit ROM pointers to a block beginning at IWRAM `0x03002FF0`:

| RAM field | ROM pointer | ROM file offset |
| --- | --- | --- |
| `0x03002FF0` | `0x085015CC` | `0x5015CC` |
| `0x03002FF4` | `0x08C7F5FC` | `0xC7F5FC` |
| `0x03002FF8` | `0x08ABA81C` | `0xABA81C` |
| `0x03002FFC` | `0x089436FC` | `0x9436FC` |
| `0x03003000` | `0x08FB6DEC` | `0xFB6DEC` |

The pointer values are directly confirmed; the five targets' formats and roles are not yet identified.
