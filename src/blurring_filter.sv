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
    logic [3:0] kernel [0:4][0:6];

    always_comb begin
        kernel[0][0] = 15;
        kernel[0][1] = 15;
        kernel[0][2] = 0;
        kernel[0][3] = 0;
        kernel[0][4] = 0;
        kernel[0][5] = 1;
        kernel[0][6] = 1;

        kernel[1][0] = 15;
        kernel[1][1] = 0;
        kernel[1][2] = 0;
        kernel[1][3] = 0;
        kernel[1][4] = 1;
        kernel[1][5] = 1;
        kernel[1][6] = 1;

        kernel[2][0] = 0;
        kernel[2][1] = 0;
        kernel[2][2] = 0;
        kernel[2][3] = 1;
        kernel[2][4] = 1;
        kernel[2][5] = 1;
        kernel[2][6] = 2;

        kernel[3][0] = 0;
        kernel[3][1] = 0;
        kernel[3][2] = 1;
        kernel[3][3] = 1;
        kernel[3][4] = 1;
        kernel[3][5] = 2;
        kernel[3][6] = 2;

        kernel[4][0] = 0;
        kernel[4][1] = 1;
        kernel[4][2] = 1;
        kernel[4][3] = 1;
        kernel[4][4] = 2;
        kernel[4][5] = 2;
        kernel[4][6] = 2;

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

        conv_result_r <= (red_buffer[(0 * image_width) + 0] << kernel[0][0])
                        + (red_buffer[(0 * image_width) + 1] << kernel[0][1])
                        + (red_buffer[(0 * image_width) + 2] << kernel[0][2])
                        + (red_buffer[(0 * image_width) + 3] << kernel[0][3])
                        + (red_buffer[(0 * image_width) + 4] << kernel[0][4])
                        + (red_buffer[(0 * image_width) + 5] << kernel[0][5])
                        + (red_buffer[(0 * image_width) + 6] << kernel[0][6])
                        + (red_buffer[(1 * image_width) + 0] << kernel[1][0])
                        + (red_buffer[(1 * image_width) + 1] << kernel[1][1])
                        + (red_buffer[(1 * image_width) + 2] << kernel[1][2])
                        + (red_buffer[(1 * image_width) + 3] << kernel[1][3])
                        + (red_buffer[(1 * image_width) + 4] << kernel[1][4])
                        + (red_buffer[(1 * image_width) + 5] << kernel[1][5])
                        + (red_buffer[(1 * image_width) + 6] << kernel[1][6])
                        + (red_buffer[(2 * image_width) + 0] << kernel[2][0])
                        + (red_buffer[(2 * image_width) + 1] << kernel[2][1])
                        + (red_buffer[(2 * image_width) + 2] << kernel[2][2])
                        + (red_buffer[(2 * image_width) + 3] << kernel[2][3])
                        + (red_buffer[(2 * image_width) + 4] << kernel[2][4])
                        + (red_buffer[(2 * image_width) + 5] << kernel[2][5])
                        + (red_buffer[(2 * image_width) + 6] << kernel[2][6])
                        + (red_buffer[(3 * image_width) + 0] << kernel[3][0])
                        + (red_buffer[(3 * image_width) + 1] << kernel[3][1])
                        + (red_buffer[(3 * image_width) + 2] << kernel[3][2])
                        + (red_buffer[(3 * image_width) + 3] << kernel[3][3])
                        + (red_buffer[(3 * image_width) + 4] << kernel[3][4])
                        + (red_buffer[(3 * image_width) + 5] << kernel[3][5])
                        + (red_buffer[(3 * image_width) + 6] << kernel[3][6])
                        + (red_buffer[(4 * image_width) + 0] << kernel[4][0])
                        + (red_buffer[(4 * image_width) + 1] << kernel[4][1])
                        + (red_buffer[(4 * image_width) + 2] << kernel[4][2])
                        + (red_buffer[(4 * image_width) + 3] << kernel[4][3])
                        + (red_buffer[(4 * image_width) + 4] << kernel[4][4])
                        + (red_buffer[(4 * image_width) + 5] << kernel[4][5])
                        + (red_buffer[(4 * image_width) + 6] << kernel[4][6]);
        
        conv_result_g <= (green_buffer[(0 * image_width) + 0] << kernel[0][0])
                        + (green_buffer[(0 * image_width) + 1] << kernel[0][1])
                        + (green_buffer[(0 * image_width) + 2] << kernel[0][2])
                        + (green_buffer[(0 * image_width) + 3] << kernel[0][3])
                        + (green_buffer[(0 * image_width) + 4] << kernel[0][4])
                        + (green_buffer[(0 * image_width) + 5] << kernel[0][5])
                        + (green_buffer[(0 * image_width) + 6] << kernel[0][6])
                        + (green_buffer[(1 * image_width) + 0] << kernel[1][0])
                        + (green_buffer[(1 * image_width) + 1] << kernel[1][1])
                        + (green_buffer[(1 * image_width) + 2] << kernel[1][2])
                        + (green_buffer[(1 * image_width) + 3] << kernel[1][3])
                        + (green_buffer[(1 * image_width) + 4] << kernel[1][4])
                        + (green_buffer[(1 * image_width) + 5] << kernel[1][5])
                        + (green_buffer[(1 * image_width) + 6] << kernel[1][6])
                        + (green_buffer[(2 * image_width) + 0] << kernel[2][0])
                        + (green_buffer[(2 * image_width) + 1] << kernel[2][1])
                        + (green_buffer[(2 * image_width) + 2] << kernel[2][2])
                        + (green_buffer[(2 * image_width) + 3] << kernel[2][3])
                        + (green_buffer[(2 * image_width) + 4] << kernel[2][4])
                        + (green_buffer[(2 * image_width) + 5] << kernel[2][5])
                        + (green_buffer[(2 * image_width) + 6] << kernel[2][6])
                        + (green_buffer[(3 * image_width) + 0] << kernel[3][0])
                        + (green_buffer[(3 * image_width) + 1] << kernel[3][1])
                        + (green_buffer[(3 * image_width) + 2] << kernel[3][2])
                        + (green_buffer[(3 * image_width) + 3] << kernel[3][3])
                        + (green_buffer[(3 * image_width) + 4] << kernel[3][4])
                        + (green_buffer[(3 * image_width) + 5] << kernel[3][5])
                        + (green_buffer[(3 * image_width) + 6] << kernel[3][6])
                        + (green_buffer[(4 * image_width) + 0] << kernel[4][0])
                        + (green_buffer[(4 * image_width) + 1] << kernel[4][1])
                        + (green_buffer[(4 * image_width) + 2] << kernel[4][2])
                        + (green_buffer[(4 * image_width) + 3] << kernel[4][3])
                        + (green_buffer[(4 * image_width) + 4] << kernel[4][4])
                        + (green_buffer[(4 * image_width) + 5] << kernel[4][5])
                        + (green_buffer[(4 * image_width) + 6] << kernel[4][6]);

        conv_result_b <= (blue_buffer[(0 * image_width) + 0] << kernel[0][0])
                        + (blue_buffer[(0 * image_width) + 1] << kernel[0][1])
                        + (blue_buffer[(0 * image_width) + 2] << kernel[0][2])
                        + (blue_buffer[(0 * image_width) + 3] << kernel[0][3])
                        + (blue_buffer[(0 * image_width) + 4] << kernel[0][4])
                        + (blue_buffer[(0 * image_width) + 5] << kernel[0][5])
                        + (blue_buffer[(0 * image_width) + 6] << kernel[0][6])
                        + (blue_buffer[(1 * image_width) + 0] << kernel[1][0])
                        + (blue_buffer[(1 * image_width) + 1] << kernel[1][1])
                        + (blue_buffer[(1 * image_width) + 2] << kernel[1][2])
                        + (blue_buffer[(1 * image_width) + 3] << kernel[1][3])
                        + (blue_buffer[(1 * image_width) + 4] << kernel[1][4])
                        + (blue_buffer[(1 * image_width) + 5] << kernel[1][5])
                        + (blue_buffer[(1 * image_width) + 6] << kernel[1][6])
                        + (blue_buffer[(2 * image_width) + 0] << kernel[2][0])
                        + (blue_buffer[(2 * image_width) + 1] << kernel[2][1])
                        + (blue_buffer[(2 * image_width) + 2] << kernel[2][2])
                        + (blue_buffer[(2 * image_width) + 3] << kernel[2][3])
                        + (blue_buffer[(2 * image_width) + 4] << kernel[2][4])
                        + (blue_buffer[(2 * image_width) + 5] << kernel[2][5])
                        + (blue_buffer[(2 * image_width) + 6] << kernel[2][6])
                        + (blue_buffer[(3 * image_width) + 0] << kernel[3][0])
                        + (blue_buffer[(3 * image_width) + 1] << kernel[3][1])
                        + (blue_buffer[(3 * image_width) + 2] << kernel[3][2])
                        + (blue_buffer[(3 * image_width) + 3] << kernel[3][3])
                        + (blue_buffer[(3 * image_width) + 4] << kernel[3][4])
                        + (blue_buffer[(3 * image_width) + 5] << kernel[3][5])
                        + (blue_buffer[(3 * image_width) + 6] << kernel[3][6])
                        + (blue_buffer[(4 * image_width) + 0] << kernel[4][0])
                        + (blue_buffer[(4 * image_width) + 1] << kernel[4][1])
                        + (blue_buffer[(4 * image_width) + 2] << kernel[4][2])
                        + (blue_buffer[(4 * image_width) + 3] << kernel[4][3])
                        + (blue_buffer[(4 * image_width) + 4] << kernel[4][4])
                        + (blue_buffer[(4 * image_width) + 5] << kernel[4][5])
                        + (blue_buffer[(4 * image_width) + 6] << kernel[4][6]);

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