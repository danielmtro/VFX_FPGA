from PIL import Image

def convert_to_12bit_rgb(input_png, output_png):
    # Open the image file
    img = Image.open(input_png)
    img = img.convert('RGB')  # Ensure image is in RGB format

    # Create a new image with the same size
    new_img = Image.new('RGB', img.size)

    width, height = img.size

    for y in range(height):
        for x in range(width):
            r, g, b = img.getpixel((x, y))

            # Convert 8-bit RGB to 4-bit RGB
            r_4bit = r >> 4
            g_4bit = g >> 4
            b_4bit = b >> 4

            # Convert back to 8-bit RGB for saving
            r_8bit = r_4bit << 4
            g_8bit = g_4bit << 4
            b_8bit = b_4bit << 4

            new_img.putpixel((x, y), (r_8bit, g_8bit, b_8bit))

    # Save the new image
    new_img.save(output_png)

# Example usage
convert_to_12bit_rgb('./chad-ho-640x480.png', './chad_ho_12_bit_rgb.png')
