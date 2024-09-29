`timescale 1ns / 1ps

module blurring_filter (
    input logic clk,
    input logic [2:0] freq_flag,  // Kernel size: 0 for No blur, 1 for 3x3, 2 for 5x5
    input logic ready_in,
    input logic valid_in,
    input logic startofpacket_in,
    input logic endofpacket_in,
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

    // Extract RGB components from input data
    logic [3:0] red_in, green_in, blue_in;
    logic [3:0] red_out, green_out, blue_out;

    assign red_in   = data_in[11:8];  // Bits 11-8 for red
    assign green_in = data_in[7:4];   // Bits 7-4 for green
    assign blue_in  = data_in[3:0];   // Bits 3-0 for blue

    // 320x240 image
    localparam image_height = 8'b11110000;
    localparam image_width = 9'b101000000;

    // Image buffer for RGB components
    logic [3:0] red_buffer [0:(image_width*4 + 4)];
    logic [3:0] green_buffer [0:(image_width*4 + 4)];
    logic [3:0] blue_buffer [0:(image_width*4 + 4)];

    logic [9:0] partial_sum_r_stage1 [0:4], partial_sum_g_stage1 [0:4], partial_sum_b_stage1 [0:4];
    logic [9:0] partial_sum_r_stage2 [0:4], partial_sum_g_stage2 [0:4], partial_sum_b_stage2 [0:4];
    logic [9:0] partial_sum_r_stage3 [0:4], partial_sum_g_stage3 [0:4], partial_sum_b_stage3 [0:4];

    logic [9:0] conv_result_r, conv_result_g, conv_result_b;  // Final convolution results for RGB

    // Define the kernel weights (unchanged)
    logic [2:0] kernel [0:4][0:4];
    always_comb begin
        for (int i = 0; i < 5; i++) begin
            for (int j = 0; j < 5; j++) begin
                if (i == 0 || i == 4) begin
                    kernel[i][j] = (j == 0 || j == 4) ? 3'b001 : (j == 1 || j == 3) ? 3'b010 : 3'b011;
                end else if (i == 1 || i == 3) begin
                    kernel[i][j] = (j == 0 || j == 4) ? 3'b010 : (j == 1 || j == 3) ? 3'b011 : 3'b100;
                end else begin
                    kernel[i][j] = (j == 0 || j == 4) ? 3'b011 : (j == 1 || j == 3) ? 3'b100 : 3'b100;
                end
            end
        end

        /*
		1 2 3 2 1
		2 3 4 3 2
		3 4 4 4 3
		2 3 4 3 2
		1 2 3 2 1
		*/
    end

    // Shift incoming data into separate RGB buffers
    always_ff @(posedge clk) begin : Image_buffer
        if (ready_in) begin
            // Shift the buffers left for red, green, and blue
            for (int i = 0; i < (image_width*4 + 4); i++) begin
                red_buffer[i] <= red_buffer[i+1];
                green_buffer[i] <= green_buffer[i+1];
                blue_buffer[i] <= blue_buffer[i+1];
            end
            // Insert new data for each color component
            red_buffer[(image_width*4 + 4)] <= red_in;
            green_buffer[(image_width*4 + 4)] <= green_in;
            blue_buffer[(image_width*4 + 4)] <= blue_in;
        end
    end

    // Pipelined convolution for each color component

    // Stage 1: Load and multiply pixels for 3x3 kernel (RGB separately)
    always_ff @(posedge clk) begin
		  // Initialize partial sums
        for (int i = 0; i < 5; i++) begin
            partial_sum_r_stage1[i] <= 0;
            partial_sum_g_stage1[i] <= 0;
            partial_sum_b_stage1[i] <= 0;
        end
	 
        // 3x3 Kernel
        if (freq_flag == 1) begin
            // Red component
            for (int i = 0; i < 3; i++) begin
                partial_sum_r_stage1[i] <= red_buffer[(i * image_width)] * kernel[i+1][1];
            end
            // Green component
            for (int i = 0; i < 3; i++) begin
                partial_sum_g_stage1[i] <= green_buffer[(i * image_width)] * kernel[i+1][1];
            end
            // Blue component
            for (int i = 0; i < 3; i++) begin
                partial_sum_b_stage1[i] <= blue_buffer[(i * image_width)] * kernel[i+1][1];
            end
        end

        // 5x5 Kernel
        else if (freq_flag == 2) begin
            // Red component
            for (int i = 0; i < 5; i++) begin
                partial_sum_r_stage1[i] <= red_buffer[(i * image_width)] * kernel[i][0]
                                        + red_buffer[(i * image_width) + 1] * kernel[i][1];
            end
            // Green component
            for (int i = 0; i < 5; i++) begin
                partial_sum_g_stage1[i] <= green_buffer[(i * image_width)] * kernel[i][0]
                                        + green_buffer[(i * image_width) + 1] * kernel[i][1];
            end
            // Blue component
            for (int i = 0; i < 5; i++) begin
                partial_sum_b_stage1[i] <= blue_buffer[(i * image_width)] * kernel[i][0]
                                        + blue_buffer[(i * image_width) + 1] * kernel[i][1];
            end
        end
    end

    // Stage 2: Complete row-wise multiplication for RGB components (3x3)
    always_ff @(posedge clk) begin
		  // Initialize partial sums
        for (int i = 0; i < 5; i++) begin
            partial_sum_r_stage2[i] <= 0;
            partial_sum_g_stage2[i] <= 0;
            partial_sum_b_stage2[i] <= 0;
        end
	 
        if (freq_flag == 1) begin
            // Red component
            for (int i = 0; i < 3; i++) begin
                partial_sum_r_stage2[i] <= partial_sum_r_stage1[i] 
                    + red_buffer[(i * image_width) + 1] * kernel[i+1][2];
            end
            // Green component
            for (int i = 0; i < 3; i++) begin
                partial_sum_g_stage2[i] <= partial_sum_g_stage1[i] 
                    + green_buffer[(i * image_width) + 1] * kernel[i+1][2];
            end
            // Blue component
            for (int i = 0; i < 3; i++) begin
                partial_sum_b_stage2[i] <= partial_sum_b_stage1[i] 
                    + blue_buffer[(i * image_width) + 1] * kernel[i+1][2];
            end
        end

        else if (freq_flag == 2) begin
            // Red component
            for (int i = 0; i < 5; i++) begin
                partial_sum_r_stage2[i] <= partial_sum_r_stage1[i]
                    + red_buffer[(i * image_width) + 2] * kernel[i][2]
                    + red_buffer[(i * image_width) + 3] * kernel[i][3];
            end
            // Green component
            for (int i = 0; i < 5; i++) begin
                partial_sum_g_stage2[i] <= partial_sum_g_stage1[i]
                    + green_buffer[(i * image_width) + 1] * kernel[i][2]
                    + green_buffer[(i * image_width) + 3] * kernel[i][3];
            end
            // Blue component
            for (int i = 0; i < 5; i++) begin
                partial_sum_b_stage2[i] <= partial_sum_g_stage1[i]
                    + blue_buffer[(i * image_width) + 1] * kernel[i][2]
                    + blue_buffer[(i * image_width) + 3] * kernel[i][3];
            end
        end
    end

    // Stage 3: Complete row-wise multiplication for RGB components (3x3)
    always_ff @(posedge clk) begin
		  // Initialize partial sums
        for (int i = 0; i < 5; i++) begin
            partial_sum_r_stage3[i] <= 0;
            partial_sum_g_stage3[i] <= 0;
            partial_sum_b_stage3[i] <= 0;
        end
		  
        if (freq_flag == 1) begin
            // Red component
            for (int i = 0; i < 3; i++) begin
                partial_sum_r_stage3[i] <= partial_sum_r_stage1[i]
                    + red_buffer[(i * image_width) + 2] * kernel[i+1][3];
            end
            // Green component
            for (int i = 0; i < 3; i++) begin
                partial_sum_g_stage3[i] <= partial_sum_g_stage1[i]
                    + green_buffer[(i * image_width) + 2] * kernel[i+1][3];
            end
            // Blue component
            for (int i = 0; i < 3; i++) begin
                partial_sum_b_stage3[i] <= partial_sum_b_stage1[i]
                    + blue_buffer[(i * image_width) + 2] * kernel[i+1][3];
            end
        end

        else if (freq_flag == 2) begin
            // Red component
            for (int i = 0; i < 5; i++) begin
                partial_sum_r_stage2[i] <= partial_sum_r_stage1[i]
                    + red_buffer[(i * image_width) + 4] * kernel[i][4];
            end
            // Green component
            for (int i = 0; i < 5; i++) begin
                partial_sum_g_stage2[i] <= partial_sum_g_stage1[i] 
                    + green_buffer[(i * image_width) + 4] * kernel[i][4];
            end
            // Blue component
            for (int i = 0; i < 5; i++) begin
                partial_sum_b_stage2[i] <= partial_sum_g_stage1[i]
                    + blue_buffer[(i * image_width) + 4] * kernel[i][4];
            end
        end
    end

    // Stage 4: Accumulate rows for the final convolution result (RGB)
    always_ff @(posedge clk) begin
		  // Initialize partial sums
        for (int i = 0; i < 5; i++) begin
            conv_result_r[i] <= 0;
            conv_result_g[i] <= 0;
            conv_result_b[i] <= 0;
        end
	 
        // 3x3 Kernel
        if (freq_flag == 1) begin
            // Red component
            conv_result_r <= partial_sum_r_stage3[0] 
                + partial_sum_r_stage3[1] 
                + partial_sum_r_stage3[2];
            // Green component
            conv_result_g <= partial_sum_g_stage3[0] 
                + partial_sum_g_stage3[1] 
                + partial_sum_g_stage3[2];
            // Blue component
            conv_result_b <= partial_sum_b_stage3[0] 
                + partial_sum_b_stage3[1] 
                + partial_sum_b_stage3[2];
        end

        // 5x5 Kernel
        if (freq_flag == 2) begin
            // Red component
            conv_result_r <= partial_sum_r_stage3[0] 
                + partial_sum_r_stage3[1] 
                + partial_sum_r_stage3[2]
                + partial_sum_r_stage3[3] 
                + partial_sum_r_stage3[4];
            // Green component
            conv_result_g <= partial_sum_g_stage3[0] 
                + partial_sum_g_stage3[1] 
                + partial_sum_g_stage3[2]
                + partial_sum_g_stage3[3] 
                + partial_sum_g_stage3[4];
            // Blue component
            conv_result_b <= partial_sum_b_stage3[0] 
                + partial_sum_b_stage3[1] 
                + partial_sum_b_stage3[2]
                + partial_sum_b_stage3[3] 
                + partial_sum_b_stage3[4];
        end
    end

    // Stage 5: Normalise and output the result (RGB)
    always_ff @(posedge clk) begin
		  startofpacket_out <= startofpacket_in;
		  endofpacket_out <= endofpacket_in;

        // 5x5 Kernel
        if (freq_flag == 2) begin
            // Combine the normalized results for each color component
            data_out <= {conv_result_r[9:6], conv_result_g[9:6], conv_result_b[9:6]};
        end

        // 3x3 Kernel
        else if (freq_flag == 1) begin
            // Combine the normalized results for each color component
            data_out <= {conv_result_r[8:5], conv_result_g[8:5], conv_result_b[8:5]};
        end
		  
		  // For no blur, directly pass through the data
		  else if (freq_flag == 0) begin
            data_out <= data_in;
        end
    end

endmodule