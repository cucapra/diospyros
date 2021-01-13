"""Extract immediate shuffle patterns from Xtensa documentation.

Given an HTML file from the documentation for an Xtensa `SHFLI` or
`SELI` instruction, emit information about the available patterns for a
given bit width (currently 32).
"""
import sys
import re

IMMEDIATE_PATTERN = r'<tr><td>\s*(\d+)\s*</td><td>\s*(PDX_[^<]+)\s*</td>' \
    r'<td>\s*([\d,\s]+)\s*</td></tr>'
BIT_WIDTH = 32


def get_immediates(infile):
    """Parse an HTML documentation file and emit patterns.

    For each pattern, produce the index (the underlying "magic number"
    for the pattern), the name (the C constant in the header file), and
    a list of byte indices (indicating the exact byte-level immediate
    shuffle pattern).
    """
    for line in infile:
        m = re.match(IMMEDIATE_PATTERN, line)
        if m:
            idx, name, indices_s = m.groups()
            indices = [int(s.strip()) for s in indices_s.split(',')]
            yield idx, name, indices


def coarsen_indices(byte_indices, size):
    """Convert a byte-level shuffle pattern to a coarser one.

    Given `size`, which is a number of bytes, convert an `N`-length
    shuffle pattern list to an `N/size`-length one that describes the
    pattern at the level of those "words."

    If the pattern is not aligned to `size`, return None instead.
    """
    out = []
    for i in range(0, len(byte_indices), size):
        byte_chunk = byte_indices[i:i + size]
        if byte_chunk[0] % size:
            # Unaligned start point.
            return None
        start = byte_chunk[0] // size
        if tuple(byte_chunk) != \
           tuple(range(start * size, start * size + size)):
            # Chunk is not a whole word.
            return None
        out.append(start)
    return out


def extract(infile):
    """Extract all the patterns from the documentation and print.
    """
    for idx, name, byte_indices in get_immediates(infile):
        word_indices = coarsen_indices(byte_indices, BIT_WIDTH // 8)
        if word_indices:
            print(name, word_indices)


if __name__ == '__main__':
    extract(sys.stdin)
