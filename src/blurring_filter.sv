`timescale 1ns / 1ps

module blurring_filter (
    input logic clk,
    input logic ready_in,
    input logic valid_in,
    input logic startofpacket_in,
    input logic endofpacket_in,
    input logic is_underage,
    input logic [12-1:0] data_in,
    output logic ready_out,
    output logic valid_out,
    output logic startofpacket_out,
    output logic endofpacket_out,
    output logic [12-1:0] data_out
);

    // Pass through valid signal
    assign valid_out = valid_in;
    assign ready_out = ready_in;

    // Pass through the sop and eop signals
    assign startofpacket_out = startofpacket_in;
    assign endofpacket_out = endofpacket_in;

    // Extract RGB components from input data
    logic [3:0] red_in, green_in, blue_in;

    assign red_in   = data_in[11:8];  // Bits 11-8 for red
    assign green_in = data_in[7:4];   // Bits 7-4 for green
    assign blue_in  = data_in[3:0];   // Bits 3-0 for blue

    // 320 wide image
    localparam image_width = 9'b101000000;

    // Image buffer for RGB components
    logic [3:0] red_buffer [0:(image_width*4 + 6)];
    logic [3:0] green_buffer [0:(image_width*4 + 6)];
    logic [3:0] blue_buffer [0:(image_width*4 + 6)];

    logic [9:0] conv_result_r, conv_result_g, conv_result_b;  // Final convolution results for RGB

    // Define the bitshift kernel
    logic [3:0] kernel [0:34];

    always_comb begin
        kernel[0] = 15;
        kernel[1] = 15;
        kernel[2] = 0;
        kernel[3] = 0;
        kernel[4] = 0;
        kernel[5] = 1;
        kernel[6] = 1;

        kernel[7] = 15;
        kernel[8] = 0;
        kernel[9] = 0;
        kernel[10] = 0;
        kernel[11] = 1;
        kernel[12] = 1;
        kernel[13] = 1;

        kernel[14] = 0;
        kernel[15] = 0;
        kernel[16] = 0;
        kernel[17] = 1;
        kernel[18] = 1;
        kernel[19] = 1;
        kernel[20] = 2;

        kernel[21] = 0;
        kernel[22] = 0;
        kernel[23] = 1;
        kernel[24] = 1;
        kernel[25] = 1;
        kernel[26] = 2;
        kernel[27] = 2;

        kernel[28] = 0;
        kernel[29] = 1;
        kernel[30] = 1;
        kernel[31] = 1;
        kernel[32] = 2;
        kernel[33] = 2;
        kernel[34] = 2;

        /*
        Sum is 64
        Weights
        0 0 1 1 1 2 2
        0 1 1 1 2 2 2
        1 1 1 2 2 2 4
        1 1 2 2 2 4 4
        1 2 2 2 4 4 4
        */
    end

    // Shift incoming data into separate RGB buffers
    always_ff @(posedge clk) begin : Image_buffer
        if (startofpacket_in) begin
            for (int i = 0; i < (image_width*4 + 6); i++) begin
                red_buffer[i] <= 0;
                green_buffer[i] <= 0;
                blue_buffer[i] <= 0;
            end
        end
		  
		  if (ready_in && valid_in) begin
            // Shift the buffers left for red, green, and blue
            for (int i = 0; i < (image_width*4 + 6); i++) begin
                red_buffer[i] <= red_buffer[i+1];
                green_buffer[i] <= green_buffer[i+1];
                blue_buffer[i] <= blue_buffer[i+1];
            end
            // Insert new data for each color component
            red_buffer[(image_width*4 + 6)] <= red_in;
            green_buffer[(image_width*4 + 6)] <= green_in;
            blue_buffer[(image_width*4 + 6)] <= blue_in;
        end
    end

    always_ff @(posedge clk) begin : Convolution
        conv_result_r <= 0;
        conv_result_g <= 0;
        conv_result_b <= 0;

        conv_result_r <= (red_buffer[(0 * image_width) + 0] << kernel[0])
                        + (red_buffer[(0 * image_width) + 1] << kernel[1])
                        + (red_buffer[(0 * image_width) + 2] << kernel[2])
                        + (red_buffer[(0 * image_width) + 3] << kernel[3])
                        + (red_buffer[(0 * image_width) + 4] << kernel[4])
                        + (red_buffer[(0 * image_width) + 5] << kernel[5])
                        + (red_buffer[(0 * image_width) + 6] << kernel[6])
                        + (red_buffer[(1 * image_width) + 0] << kernel[7])
                        + (red_buffer[(1 * image_width) + 1] << kernel[8])
                        + (red_buffer[(1 * image_width) + 2] << kernel[9])
                        + (red_buffer[(1 * image_width) + 3] << kernel[10])
                        + (red_buffer[(1 * image_width) + 4] << kernel[11])
                        + (red_buffer[(1 * image_width) + 5] << kernel[12])
                        + (red_buffer[(1 * image_width) + 6] << kernel[13])
                        + (red_buffer[(2 * image_width) + 0] << kernel[14])
                        + (red_buffer[(2 * image_width) + 1] << kernel[15])
                        + (red_buffer[(2 * image_width) + 2] << kernel[16])
                        + (red_buffer[(2 * image_width) + 3] << kernel[17])
                        + (red_buffer[(2 * image_width) + 4] << kernel[18])
                        + (red_buffer[(2 * image_width) + 5] << kernel[19])
                        + (red_buffer[(2 * image_width) + 6] << kernel[20])
                        + (red_buffer[(3 * image_width) + 0] << kernel[21])
                        + (red_buffer[(3 * image_width) + 1] << kernel[22])
                        + (red_buffer[(3 * image_width) + 2] << kernel[23])
                        + (red_buffer[(3 * image_width) + 3] << kernel[24])
                        + (red_buffer[(3 * image_width) + 4] << kernel[25])
                        + (red_buffer[(3 * image_width) + 5] << kernel[26])
                        + (red_buffer[(3 * image_width) + 6] << kernel[27])
                        + (red_buffer[(4 * image_width) + 0] << kernel[28])
                        + (red_buffer[(4 * image_width) + 1] << kernel[29])
                        + (red_buffer[(4 * image_width) + 2] << kernel[30])
                        + (red_buffer[(4 * image_width) + 3] << kernel[31])
                        + (red_buffer[(4 * image_width) + 4] << kernel[32])
                        + (red_buffer[(4 * image_width) + 5] << kernel[33])
                        + (red_buffer[(4 * image_width) + 6] << kernel[34]);
        
        conv_result_g <= (green_buffer[(0 * image_width) + 0] << kernel[0])
                        + (green_buffer[(0 * image_width) + 1] << kernel[1])
                        + (green_buffer[(0 * image_width) + 2] << kernel[2])
                        + (green_buffer[(0 * image_width) + 3] << kernel[3])
                        + (green_buffer[(0 * image_width) + 4] << kernel[4])
                        + (green_buffer[(0 * image_width) + 5] << kernel[5])
                        + (green_buffer[(0 * image_width) + 6] << kernel[6])
                        + (green_buffer[(1 * image_width) + 0] << kernel[7])
                        + (green_buffer[(1 * image_width) + 1] << kernel[8])
                        + (green_buffer[(1 * image_width) + 2] << kernel[9])
                        + (green_buffer[(1 * image_width) + 3] << kernel[10])
                        + (green_buffer[(1 * image_width) + 4] << kernel[11])
                        + (green_buffer[(1 * image_width) + 5] << kernel[12])
                        + (green_buffer[(1 * image_width) + 6] << kernel[13])
                        + (green_buffer[(2 * image_width) + 0] << kernel[14])
                        + (green_buffer[(2 * image_width) + 1] << kernel[15])
                        + (green_buffer[(2 * image_width) + 2] << kernel[16])
                        + (green_buffer[(2 * image_width) + 3] << kernel[17])
                        + (green_buffer[(2 * image_width) + 4] << kernel[18])
                        + (green_buffer[(2 * image_width) + 5] << kernel[19])
                        + (green_buffer[(2 * image_width) + 6] << kernel[20])
                        + (green_buffer[(3 * image_width) + 0] << kernel[21])
                        + (green_buffer[(3 * image_width) + 1] << kernel[22])
                        + (green_buffer[(3 * image_width) + 2] << kernel[23])
                        + (green_buffer[(3 * image_width) + 3] << kernel[24])
                        + (green_buffer[(3 * image_width) + 4] << kernel[25])
                        + (green_buffer[(3 * image_width) + 5] << kernel[26])
                        + (green_buffer[(3 * image_width) + 6] << kernel[27])
                        + (green_buffer[(4 * image_width) + 0] << kernel[28])
                        + (green_buffer[(4 * image_width) + 1] << kernel[29])
                        + (green_buffer[(4 * image_width) + 2] << kernel[30])
                        + (green_buffer[(4 * image_width) + 3] << kernel[31])
                        + (green_buffer[(4 * image_width) + 4] << kernel[32])
                        + (green_buffer[(4 * image_width) + 5] << kernel[33])
                        + (green_buffer[(4 * image_width) + 6] << kernel[34]);

        conv_result_b <= (blue_buffer[(0 * image_width) + 0] << kernel[0])
                        + (blue_buffer[(0 * image_width) + 1] << kernel[1])
                        + (blue_buffer[(0 * image_width) + 2] << kernel[2])
                        + (blue_buffer[(0 * image_width) + 3] << kernel[3])
                        + (blue_buffer[(0 * image_width) + 4] << kernel[4])
                        + (blue_buffer[(0 * image_width) + 5] << kernel[5])
                        + (blue_buffer[(0 * image_width) + 6] << kernel[6])
                        + (blue_buffer[(1 * image_width) + 0] << kernel[7])
                        + (blue_buffer[(1 * image_width) + 1] << kernel[8])
                        + (blue_buffer[(1 * image_width) + 2] << kernel[9])
                        + (blue_buffer[(1 * image_width) + 3] << kernel[10])
                        + (blue_buffer[(1 * image_width) + 4] << kernel[11])
                        + (blue_buffer[(1 * image_width) + 5] << kernel[12])
                        + (blue_buffer[(1 * image_width) + 6] << kernel[13])
                        + (blue_buffer[(2 * image_width) + 0] << kernel[14])
                        + (blue_buffer[(2 * image_width) + 1] << kernel[15])
                        + (blue_buffer[(2 * image_width) + 2] << kernel[16])
                        + (blue_buffer[(2 * image_width) + 3] << kernel[17])
                        + (blue_buffer[(2 * image_width) + 4] << kernel[18])
                        + (blue_buffer[(2 * image_width) + 5] << kernel[19])
                        + (blue_buffer[(2 * image_width) + 6] << kernel[20])
                        + (blue_buffer[(3 * image_width) + 0] << kernel[21])
                        + (blue_buffer[(3 * image_width) + 1] << kernel[22])
                        + (blue_buffer[(3 * image_width) + 2] << kernel[23])
                        + (blue_buffer[(3 * image_width) + 3] << kernel[24])
                        + (blue_buffer[(3 * image_width) + 4] << kernel[25])
                        + (blue_buffer[(3 * image_width) + 5] << kernel[26])
                        + (blue_buffer[(3 * image_width) + 6] << kernel[27])
                        + (blue_buffer[(4 * image_width) + 0] << kernel[28])
                        + (blue_buffer[(4 * image_width) + 1] << kernel[29])
                        + (blue_buffer[(4 * image_width) + 2] << kernel[30])
                        + (blue_buffer[(4 * image_width) + 3] << kernel[31])
                        + (blue_buffer[(4 * image_width) + 4] << kernel[32])
                        + (blue_buffer[(4 * image_width) + 5] << kernel[33])
                        + (blue_buffer[(4 * image_width) + 6] << kernel[34]);

        if (ready_in && valid_in) begin
            if (is_underage) begin
                // Combine the normalized results for each color component
                data_out <= {conv_result_r[9:6], conv_result_g[9:6], conv_result_b[9:6]};
            end

            else begin
                // For no blur, pass through the data
                data_out <= data_in;
            end
        end
    end

endmodule