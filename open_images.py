import numpy as np
import matplotlib.pyplot as plt
import mplcursors  # For interactive cursor

# Constants
IMG_LENGTH = 240  # Image height
IMG_WIDTH = 320   # Image width

# Function to read image data from a file
def read_image_data(file_name):
    image = np.zeros((IMG_LENGTH, IMG_WIDTH), dtype=np.uint16)
    with open(file_name, "r") as file:
        for i in range(IMG_LENGTH):
            for j in range(IMG_WIDTH):
                line = file.readline()
                if line:
                    image[i, j] = int(line.strip(), 2)  # Convert from binary string to integer
    return image

# Read input and output image data
input_image = read_image_data("input_image_data.txt")
output_image = read_image_data("output_image_data.txt")

# Create the figure and two subplots for input and output images
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10, 5))

# Display input image in the first subplot
cax1 = ax1.imshow(input_image, cmap='gray', vmin=0, vmax=0b111111111111)
ax1.set_title('Input Image')
ax1.set_xticks(np.arange(0, IMG_WIDTH+1, 20))
ax1.set_yticks(np.arange(0, IMG_LENGTH+1, 20))
ax1.set_xticklabels(np.arange(0, IMG_WIDTH+1, 20))
ax1.set_yticklabels(np.arange(0, IMG_LENGTH+1, 20))
ax1.grid(color='white', linestyle='--', linewidth=0.5)

# Display output image in the second subplot
cax2 = ax2.imshow(output_image, cmap='gray', vmin=0, vmax=0b111111111111)
ax2.set_title('Output Image')
ax2.set_xticks(np.arange(0, IMG_WIDTH+1, 20))
ax2.set_yticks(np.arange(0, IMG_LENGTH+1, 20))
ax2.set_xticklabels(np.arange(0, IMG_WIDTH+1, 20))
ax2.set_yticklabels(np.arange(0, IMG_LENGTH+1, 20))
ax2.grid(color='white', linestyle='--', linewidth=0.5)

# Create interactive cursors for both input and output images
cursor1 = mplcursors.cursor(cax1, hover=True)
cursor2 = mplcursors.cursor(cax2, hover=True)

# Add hover functionality to display cell information for the input image
@cursor1.connect("add")
def on_add_input(sel):
    x, y = int(sel.target[0]), int(sel.target[1])
    pixel_value = input_image[y, x]
    sel.annotation.set(text=f"Input Cell: ({x}, {y})\nValue: {pixel_value}")
    sel.annotation.set_fontsize(8)

# Add hover functionality to display cell information for the output image
@cursor2.connect("add")
def on_add_output(sel):
    x, y = int(sel.target[0]), int(sel.target[1])
    pixel_value = output_image[y, x]
    sel.annotation.set(text=f"Output Cell: ({x}, {y})\nValue: {pixel_value}")
    sel.annotation.set_fontsize(8)

# Display the plot with both subplots
plt.tight_layout()
plt.show()