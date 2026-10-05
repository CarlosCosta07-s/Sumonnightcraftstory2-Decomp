# Startup runtime routines

These findings follow the reset path in [boot-notes.md](boot-notes.md). Disassembly is in [startup_runtime.s](../disasm/startup_runtime.s); addresses refer to this ROM's GBA address space.

## State accessors

Three Thumb routines access the word at IWRAM address `0x030028EC`:

- `0x08000290` sign-extends its low 16-bit argument and stores the result.
- `0x080002A0` returns the word.
- `0x080002AC` stores `1`.

Equivalent behavior, with the address still provisional as a semantic name:

```c
#define STARTUP_STATE (*(volatile int32_t *)0x030028EC)

void set_startup_state(int16_t value) { STARTUP_STATE = value; }
int32_t get_startup_state(void) { return STARTUP_STATE; }
void set_startup_state_one(void) { STARTUP_STATE = 1; }
```

The startup loop at `0x08000418` calls `0x080001D0`, sets this word to `1`, then enters the polling routine at `0x080003C4`.

## Hardware and memory initialization

Routine `0x080002B8` writes `0x4014` to WAITCNT (`0x04000204`) and configures DMA3 (`0x040000D4`) with control word `0x8501` for transfers to these starting addresses:

| Destination | Source pattern placed on the stack |
| --- | --- |
| `0x02000000` EWRAM | `0x55555555` |
| `0x03000000` IWRAM | `0x55555555` |
| `0x06000000` VRAM | `0x00000000` |
| `0x07000000` OAM | `0x000000A0` |
| `0x05000000` palette RAM | `0x00000000` |

The DMA source mode is fixed and destination mode increments; `0x8501` enables an immediate 32-bit transfer. The count field is programmed as zero; its effective transfer length depends on DMA3's hardware semantics, so no byte count is claimed here. The exact DMA setup is preserved in the annotated listing.

After those fills, the routine calls `0x08003960` to install interrupts (see [irq-install.md](irq-install.md)), then `0x08003DA8`. The latter stores five constants into RAM at `0x03002FF0` through `0x03003000`; the purpose of that structure is not identified.

## Polling and scanline sample

Routine `0x080003C4` repeatedly reads the word at `0x030028E8`. While nonzero, it calls `0x08000358`, `0x08025E28`, `0x08010438`, `0x08000398`, and `0x0808CFA8`, then checks the word again.

The helper at `0x08000358` reads VCOUNT (`0x04000006`) and stores that halfword at `0x03002900`, among other calls. A cautious label for `0x03002900` is therefore “last sampled VCOUNT”; the game-level purpose is still unknown.

The `0x030028E8` polling word and `0x030028EC` startup state are distinct globals. Their relationship and the behavior of the five polling callees remain open questions.
