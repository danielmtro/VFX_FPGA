# Utility to convert png files to hex memory initialisation files for Verilog's $readmemh() function.
# Also: Converts 8-bit colour to 12-bit colour.

from PIL import Image

def png_to_hex(png_file, hex_file):
    # Open the image file
    img = Image.open(png_file)
    img = img.convert('RGB')
    
    # Get image dimensions
    width, height = img.size
    
    # Open the HEX file for writing
    with open(hex_file, 'w') as f:
        # Process each pixel
        for y in range(height):
            for x in range(width):
                r, g, b = img.getpixel((x, y))
                
                # Convert to 12-bit RGB (4 bits per channel)
                r_12 = (r >> 4) & 0xF
                g_12 = (g >> 4) & 0xF
                b_12 = (b >> 4) & 0xF
                
                # Combine into a single 12-bit value
                rgb_12 = (r_12 << 8) | (g_12 << 4) | b_12
                
                # Write to HEX file
                f.write(f"{rgb_12:03X}\n")

# Example usage


# Usage example:
png_to_hex('./chad-ho-320x240.png', './chad-ho-320x240.hex')

