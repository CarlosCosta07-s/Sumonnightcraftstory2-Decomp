#!/usr/bin/env python3
"""Disassemble an explicitly selected GBA ROM range with Capstone."""

from __future__ import annotations

import argparse
from pathlib import Path

from capstone import Cs, CS_ARCH_ARM, CS_MODE_ARM, CS_MODE_THUMB


ROM_BASE = 0x08000000


def number(value: str) -> int:
    return int(value, 0)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rom", type=Path, help="path to a local .gba image")
    parser.add_argument("--start", required=True, type=number, help="file offset, e.g. 0xC0")
    parser.add_argument("--size", required=True, type=number, help="number of bytes to decode")
    parser.add_argument("--mode", choices=("arm", "thumb"), required=True)
    args = parser.parse_args()

    if args.start < 0 or args.size <= 0:
        parser.error("--start must be nonnegative and --size must be positive")

    try:
        data = args.rom.read_bytes()
    except OSError as exc:
        parser.error(str(exc))

    end = args.start + args.size
    if end > len(data):
        parser.error(f"requested range ends at 0x{end:X}, past ROM size 0x{len(data):X}")

    mode = CS_MODE_ARM if args.mode == "arm" else CS_MODE_THUMB
    disassembler = Cs(CS_ARCH_ARM, mode)
    disassembler.detail = False
    chunk = data[args.start:end]
    bus_address = ROM_BASE + args.start

    print(f"; file offset 0x{args.start:X}..0x{end:X}, GBA address 0x{bus_address:08X}, {args.mode.upper()}")
    print("; Decoding is mechanical: confirm code/data boundaries before treating output as instructions.")
    for instruction in disassembler.disasm(chunk, bus_address):
        raw = instruction.bytes.hex(" ").upper()
        print(f"{instruction.address:08X}  {raw:<12} {instruction.mnemonic:<8} {instruction.op_str}")


if __name__ == "__main__":
    main()
