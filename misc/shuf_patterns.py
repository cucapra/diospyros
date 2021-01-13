import sys
import re

IMMEDIATE_PATTERN = r'<tr><td>\s*(\d+)\s*</td><td>\s*(PDX_[^<]+)\s*</td>' \
    r'<td>\s*([\d,\s]+)\s*</td></tr>'
BIT_WIDTH = 32


def get_immediates(infile):
    for line in infile:
        m = re.match(IMMEDIATE_PATTERN, line)
        if m:
            idx, name, indices_s = m.groups()
            indices = [int(s.strip()) for s in indices_s.split(',')]
            yield idx, name, indices


def coarsen_indices(byte_indices, size):
    for i in range(0, len(byte_indices), size):
        byte_chunk = byte_indices[i:i + size]
        assert byte_chunk[0] % size == 0
        start = byte_chunk[0] // size
        assert tuple(byte_chunk) == \
            tuple(range(start * size, start * size + size))
        yield start


def extract(infile):
    for idx, name, byte_indices in get_immediates(infile):
        if '{}B'.format(BIT_WIDTH) in name:
            word_indices = list(coarsen_indices(byte_indices, BIT_WIDTH // 8))
            print(name, word_indices)


if __name__ == '__main__':
    extract(sys.stdin)
