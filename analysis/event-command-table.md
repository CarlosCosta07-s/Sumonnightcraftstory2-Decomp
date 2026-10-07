# Event command table sweep

The event dispatcher at `0x08026B14` reads an 8-bit command number and indexes a 32-bit pointer table. The table starts at ROM offset `0x004CABAC` (`0x084CABAC`) and contains 256 entries, ending at `0x004CAFAC`. This lies within the first 5 MiB of the ROM. The table has 69 null entries and 187 non-null entries. Entry 94 and 95 were previously confirmed as handlers `0x08073AE0` and `0x08073B10`.

A pointer-pattern sweep over aligned words in file offsets `0x000000`–`0x4FFFFF` produced 18,524 pointer-like values. Most cannot be treated as function references without context; the dispatcher's command-byte indexing and the coherent Thumb entry points provide the evidence for this table. The table and the handlers below are mapped in [rom_map.json](rom_map.json).

## Additional non-null entries 169–255

| Command | Thumb handler |
| ---: | --- |
| 169 | `0x08023DCC` |
| 170 | `0x08023DE4` |
| 171 | `0x08023E2C` |
| 172 | `0x08023E84` |
| 173 | `0x08022924` |
| 174 | `0x08022978` |
| 175 | `0x08023EA8` |
| 176 | `0x080229D8` |
| 185 | `0x08023EC0` |
| 186 | `0x08023EF0` |
| 187 | `0x08022A44` |
| 188 | `0x08022A90` |
| 189 | `0x08022AF4` |
| 190 | `0x08022B50` |
| 191 | `0x08023F2C` |
| 192 | `0x08022BAC` |
| 197 | `0x08022C38` |
| 198 | `0x08022C84` |
| 199 | `0x08023F84` |
| 200 | `0x08023FB4` |
| 201 | `0x08023FF4` |
| 202 | `0x08024030` |
| 203 | `0x08024070` |
| 204 | `0x08022CF0` |
| 209 | `0x080240B0` |
| 210 | `0x080240DC` |
| 211 | `0x080240F4` |
| 212 | `0x08022D4C` |
| 213 | `0x08022DC0` |
| 214 | `0x08024144` |
| 215 | `0x08024174` |
| 221 | `0x080241C8` |
| 222 | `0x08024204` |
| 223 | `0x08024224` |
| 224 | `0x08024254` |
| 225 | `0x08024284` |
| 226 | `0x080242F8` |
| 227 | `0x08024318` |
| 228 | `0x08024348` |
| 229 | `0x08022E38` |
| 230 | `0x08024378` |
| 233 | `0x080243C4` |
| 234 | `0x08022EE4` |
| 235 | `0x080243F4` |
| 237 | `0x0802440C` |
| 238 | `0x08024470` |
| 239 | `0x08024490` |
| 245 | `0x080244CC` |
| 246 | `0x080244FC` |
| 247 | `0x0802456C` |
| 248 | `0x080245B4` |
| 249 | `0x080245D4` |
| 250 | `0x08024604` |
| 251 | `0x08024640` |
| 252 | `0x08024660` |
| 253 | `0x08024698` |
| 254 | `0x080247D8` |
| 255 | `0x08022FE4` |

All listed targets have Thumb entry alignment (`pointer & ~1`) and visible function prologues/returns. The newly identified handler bodies occupy two dense code clusters: file offsets `0x00022924`–`0x000230B0` and `0x00023DCC`–`0x00024828`. Their code, observed literal pools, and unclassified gaps are now separated in the ROM map.

## Reconstructed handler example: command 173

Handler 173 calls `0x08026878` to obtain an index-like value, sign-extends its low halfword, and uses a 16-byte stride into the structure rooted at `0x03006558`, with base offset `0x1EDC`. If the record's signed halfword at `+0` is zero, the handler evaluates the current expression stream, stores its low halfword at `+4`, and changes the `+0` halfword to one. If the phase is one, it decrements the signed `+4` halfword and resets the phase to zero when the result is nonpositive. It returns the phase halfword. A C reconstruction is in [`src/event_command_173.c`](../src/event_command_173.c).

The entry's observable state machine is established, but the purpose of command 173, the index returned by `0x08026878`, and the record's game-level meaning are not yet identified. The other handlers are mapped by table reference and function boundaries; their semantic names remain open.