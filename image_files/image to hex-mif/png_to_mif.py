# Utility to convert png files to Quartus' MIF memory initialisation file format
# Also: Converts 8-bit colour to 3-bit colour.
from PIL import Image

def png_to_mif(png_file, mif_file):
    # Open the image file
    img = Image.open(png_file)
    img = img.convert('RGB')
    
    # Get image dimensions
    width, height = img.size
    
    # Open the MIF file for writing
    with open(mif_file, 'w') as f:
        # Write MIF header
        f.write(f"WIDTH=12;\nDEPTH={width * height};\n\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\n\nCONTENT BEGIN\n")
        
        # Process each pixel
        address = 0
        for y in range(height):
            for x in range(width):
                r, g, b = img.getpixel((x, y))
                
                # Convert to 12-bit RGB (4 bits per channel)
                r_12 = (r >> 4) & 0xF
                g_12 = (g >> 4) & 0xF
                b_12 = (b >> 4) & 0xF
                
                # Combine into a single 12-bit value
                rgb_12 = (r_12 << 8) | (g_12 << 4) | b_12
                
                # Write to MIF file
                f.write(f"{address:04X} : {rgb_12:03X};\n")
                address += 1
        
        # Write MIF footer
        f.write("END;\n")

# Example usage # add in this later
png_to_mif('./Linear-Gradient.png', './output.mif')
