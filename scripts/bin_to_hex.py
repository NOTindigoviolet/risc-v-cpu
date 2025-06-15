import sys

def bin_to_hex(input_file, output_file):
    with open(input_file, 'rb') as f_in:
        binary_data = f_in.read()

    with open(output_file, 'w') as f_out:
        # Iterate through the binary data 4 bytes at a time (32-bit instructions)
        for i in range(0, len(binary_data), 4):
            # Ensure we have a full 4 bytes (handle potential padding at end if not exact multiple)
            instruction_bytes = binary_data[i : i + 4]
            if len(instruction_bytes) == 4:
                # Interpret as big-endian (most significant byte first)
                # For RISC-V, usually little-endian in memory, but for $readmemh,
                # the order of bytes in the hex string is often big-endian for visual clarity
                # and corresponds to the instruction bits [31:0]
                # So, if bytes are b0 b1 b2 b3, hex will be b3b2b1b0
                hex_instruction = instruction_bytes[::-1].hex() # Reverse to get little-endian byte order as expected for hex representation of a single instruction word
                f_out.write(hex_instruction + '\n')
            else:
                # Pad with zeros if it's the last incomplete instruction
                padded_bytes = instruction_bytes + b'\x00' * (4 - len(instruction_bytes))
                hex_instruction = padded_bytes[::-1].hex()
                f_out.write(hex_instruction + '\n')


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: python bin_to_hex.py <input_bin_file> <output_hex_file>")
        sys.exit(1)
    bin_to_hex(sys.argv[1], sys.argv[2])