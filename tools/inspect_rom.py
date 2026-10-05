#!/usr/bin/env python3
"""Inspect the standard header of a Game Boy Advance ROM."""

from __future__ import annotations

import argparse
import hashlib
from pathlib import Path


def read_header(path: Path) -> tuple[bytes, bytes]:
    data = path.read_bytes()
    if len(data) < 0xC0:
        raise ValueError(f"{path} is too short to contain a GBA header")
    return data, data[0xA0:0xC0]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rom", type=Path, help="path to a local .gba image")
    args = parser.parse_args()

    try:
        data, header = read_header(args.rom)
    except (OSError, ValueError) as exc:
        parser.error(str(exc))

    checksum = (-sum(header[:0x1D]) - 0x19) & 0xFF
    title = header[:12].decode("ascii", errors="replace").rstrip("\x00")
    print(f"Size: {len(data)} bytes")
    print(f"SHA-256: {hashlib.sha256(data).hexdigest().upper()}")
    print(f"Title: {title}")
    print(f"Game code: {header[12:16].decode('ascii', errors='replace')}")
    print(f"Maker code: {header[16:18].decode('ascii', errors='replace')}")
    print(f"Revision: {header[28]}")
    print(f"Header checksum: stored=0x{header[29]:02X}, calculated=0x{checksum:02X}")
    print(f"Entry bytes: {data[:4].hex(' ').upper()}")


if __name__ == "__main__":
    main()
