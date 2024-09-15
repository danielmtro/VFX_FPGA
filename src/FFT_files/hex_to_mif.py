def hex_to_mif(hex_file, mif_file, depth, width):
    with open(hex_file, 'r') as hex_f, open(mif_file, 'w') as mif_f:
        # Write the header for the MIF file
        mif_f.write(f"DEPTH = {depth};\n")
        mif_f.write(f"WIDTH = {width};\n")
        mif_f.write("ADDRESS_RADIX = HEX;\n")
        mif_f.write("DATA_RADIX = HEX;\n")
        mif_f.write("CONTENT BEGIN\n")

        # Read the hex file and write to the MIF file
        address = 0
        for line in hex_f:
            data = line.strip()
            mif_f.write(f"{address:04X} : {data};\n")
            address += 1

        # Write the footer for the MIF file
        mif_f.write("END;\n")

# Example usage
hex_file = "hex_recording.hex"
mif_file = "hex_recording.mif"
depth = 32768  # Adjust as needed
width = 16     # Adjust as needed

hex_to_mif(hex_file, mif_file, depth, width)
