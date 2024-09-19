`timescale 1ns / 1ps

module blurring_filter (
    input logic clk,
    input logic [2:0] freq_flag,  // Pitch input: 0 for 1x1, 1 for 3x3, 2 for 5x5
    input logic [12-1:0] data_in,
    output logic [12-1:0] data_out
);

    // Kernel sizes
    localparam KERNEL_SIZE_1x1 = 1;
    localparam KERNEL_SIZE_3x3 = 3;
    localparam KERNEL_SIZE_5x5 = 5;

    // Maximum kernel size (7x7)
    localparam MAX_KERNEL_SIZE = KERNEL_SIZE_5x5;

    // Image buffer (maximum size for 7x7 kernel)
    logic [12-1:0] image_buffer [0:MAX_KERNEL_SIZE-1][0:MAX_KERNEL_SIZE-1];
    logic [12-1:0] kernel [0:MAX_KERNEL_SIZE-1][0:MAX_KERNEL_SIZE-1];
    logic signed [2*12-1:0] conv_result;  // Double-width for intermediate result

    // Define the kernel weights based on freq_flag (Pitch input)
    always_comb begin
        case (freq_flag)
            3'b000: begin // 1x1 kernel
                kernel[0][0] = 12'h000001;
            end
            3'b001: begin // 3x3 kernel
                kernel[0][0] = 12'h000001;
                kernel[0][1] = 12'h000001;
                kernel[0][2] = 12'h000001;
                kernel[1][0] = 12'h000001;
                kernel[1][1] = 12'h000002;
                kernel[1][2] = 12'h000001;
                kernel[2][0] = 12'h000001;
                kernel[2][1] = 12'h000001;
                kernel[2][2] = 12'h000001;
            end
            3'b010: begin // 5x5 kernel
                kernel[0][0] = 12'h000001;
                kernel[0][1] = 12'h000001;
                kernel[0][2] = 12'h000001;
                kernel[0][3] = 12'h000001;
                kernel[0][4] = 12'h000001;
                kernel[1][0] = 12'h000001;
                kernel[1][1] = 12'h000002;
                kernel[1][2] = 12'h000002;
                kernel[1][3] = 12'h000002;
                kernel[1][4] = 12'h000001;
                kernel[2][0] = 12'h000001;
                kernel[2][1] = 12'h000002;
                kernel[2][2] = 12'h000003;
                kernel[2][3] = 12'h000002;
                kernel[2][4] = 12'h000001;
                kernel[3][0] = 12'h000001;
                kernel[3][1] = 12'h000002;
                kernel[3][2] = 12'h000002;
                kernel[3][3] = 12'h000002;
                kernel[3][4] = 12'h000001;
                kernel[4][0] = 12'h000001;
                kernel[4][1] = 12'h000001;
                kernel[4][2] = 12'h000001;
                kernel[4][3] = 12'h000001;
                kernel[4][4] = 12'h000001;
            end
            default: begin // Default to 1x1 kernel
                kernel[0][0] = 12'h000001;
            end
        endcase
    end

    // Shift incoming data into the image buffer
    always_ff @(posedge clk) begin
        // Shift the image buffer rows
        for (int i = MAX_KERNEL_SIZE-1; i > 0; i--) begin
            for (int j = 0; j < MAX_KERNEL_SIZE; j++) begin
                image_buffer[i][j] <= image_buffer[i-1][j];
            end
        end
        
        // Insert new pixel data into the first row of the buffer
        image_buffer[0][0] <= data_in;
    end

    // Convolution operation
    always_ff @(posedge clk) begin
        conv_result = 0;
        // Apply convolution only if freq_flag matches the kernel size
        for (int i = 0; i < MAX_KERNEL_SIZE; i++) begin
            for (int j = 0; j < MAX_KERNEL_SIZE; j++) begin
					 conv_result += image_buffer[i][j] * kernel[i][j];
            end
        end
        // Truncate the result to the output width
        data_out <= conv_result[12-1:0];
    end

endmodule