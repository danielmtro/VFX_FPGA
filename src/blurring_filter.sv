`timescale 1ns / 1ps

module blurring_filter (
    input logic clk,
    input logic [2:0] freq_flag,  // Kernel size: 0 for 1x1, 1 for 3x3, 2 for 5x5
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

    assign red_in   = data_in[11:8];  // Bits 11-8 for red
    assign green_in = data_in[7:4];   // Bits 7-4 for green
    assign blue_in  = data_in[3:0];   // Bits 3-0 for blue

    // 320x240 image
    localparam image_height = 8'b11110000;
    localparam image_width = 9'b101000000;

    // Kernel sizes
    logic [2:0] KERNEL_SIZE;
    localparam KERNEL_SIZE_7x7 = 3'b111;

    // Image buffer for RGB components
    logic [3:0] red_buffer [0:(image_width*6 + 6)];
    logic [3:0] green_buffer [0:(image_width*6 + 6)];
    logic [3:0] blue_buffer [0:(image_width*6 + 6)];

    logic signed [10:0] partial_sum_r_stage1 [6:0], partial_sum_g_stage1 [6:0], partial_sum_b_stage1 [6:0];
    logic signed [10:0] partial_sum_r_stage2 [6:0], partial_sum_g_stage2 [6:0], partial_sum_b_stage2 [6:0];
	logic signed [10:0] partial_sum_r_stage3 [6:0], partial_sum_g_stage3 [6:0], partial_sum_b_stage3 [6:0];

    logic signed [10:0] conv_result_r, conv_result_g, conv_result_b;  // Final convolution results for RGB

    // Define the kernel weights (unchanged)
    logic [2:0] kernel [0:KERNEL_SIZE_7x7-1][0:KERNEL_SIZE_7x7-1];
    always_comb begin
        // Fill the outer border of the kernel
        for (int i = 0; i < KERNEL_SIZE_7x7; i++) begin
            for (int j = 0; j < KERNEL_SIZE_7x7; j++) begin
                if (i == 0 || i == 6) begin // Top and Bottom rows
                    kernel[i][j] = (j == 0 || j == 6) ? 3'b010 : // 2
                                    (j == 1 || j == 5) ? 3'b010 : // 2
                                    (j == 2) ? 3'b011 : // 3
                                    (j == 3) ? 3'b100 : // 4
                                    3'b011; // 3 for other cases
                end
                else if (j == 0 || j == 6) begin // Left and Right columns
                    kernel[i][j] = (i == 1 || i == 5) ? 3'b010 : // 2
                                    (i == 2 || i == 4) ? 3'b011 : // 3
                                    3'b100; // 4 for the center row
                end
            end
        end

        // Fill the inner kernel shifted from (0,0 to 4,4) to (1,1 to 5,5)
        for (int i = 1; i <= 5; i++) begin
            for (int j = 1; j <= 5; j++) begin
                if (i == 1 || i == 5) begin
                    kernel[i][j] = (j == 1 || j == 5) ? 3'b001 : (j == 2 || j == 4) ? 3'b010 : 3'b011;
                end
                else if (i == 2 || i == 4) begin
                    kernel[i][j] = (j == 1 || j == 5) ? 3'b010 : (j == 2 || j == 4) ? 3'b011 : 3'b100;
                end
                else begin
                    kernel[i][j] = (j == 1 || j == 5) ? 3'b011 : (j == 2 || j == 4) ? 3'b100 : 3'b100;
                end
            end
        end

        /*
        2 2 3 4 3 2 2
		2 1 2 3 2 1 2
		3 2 3 4 3 2 3
		4 3 4 4 4 3 4
		3 2 3 4 3 2 3
		2 1 2 3 2 1 2
        2 2 3 4 3 2 2
		*/
        
        KERNEL_SIZE <= KERNEL_SIZE_7x7;
    end

    // Shift incoming data into separate RGB buffers
    always_ff @(posedge clk) begin : Image_buffer
        if (ready_in) begin
            // Shift the buffers left for red, green, and blue
            for (int i = 0; i < (image_width*6 + 6); i++) begin
                red_buffer[i] <= red_buffer[i+1];
                green_buffer[i] <= green_buffer[i+1];
                blue_buffer[i] <= blue_buffer[i+1];
            end
            // Insert new data for each color component
            red_buffer[(image_width*6 + 6)] <= red_in;
            green_buffer[(image_width*6 + 6)] <= green_in;
            blue_buffer[(image_width*6 + 6)] <= blue_in;
        end
    end

    // Pipelined convolution for each color component

    // Stage 1: Load and multiply pixels for 3x3 kernel (RGB separately)
    always_ff @(posedge clk) begin

        // For 3x3 blur, use middle kernel values from 2-4, complete first row sum
        if (freq_flag == 1) begin
            // Red component
            for (int i = 0; i < 3; i++) begin
                partial_sum_r_stage1[i] <= red_buffer[(i * image_width) + 2] * kernel[i+2][2];
            end
            // Green component
            for (int i = 0; i < 3; i++) begin
                partial_sum_g_stage1[i] <= green_buffer[(i * image_width) + 2] * kernel[i+2][2];
            end
            // Blue component
            for (int i = 0; i < 3; i++) begin
                partial_sum_b_stage1[i] <= blue_buffer[(i * image_width) + 2] * kernel[i+2][2];
            end
        end

        // For 5x5 blur, use middle kernel values from 1-5, complete first 2 rows sum
        else if (freq_flag == 2) begin
            // Red component
            for (int i = 0; i < 5; i++) begin
                partial_sum_r_stage1[i] <= red_buffer[(i * image_width) + 1] * kernel[i+1][1]
                                        + red_buffer[(i * image_width) + 2] * kernel[i+1][2];
            end
            // Green component
            for (int i = 0; i < 5; i++) begin
                partial_sum_g_stage1[i] <= green_buffer[(i * image_width) + 1] * kernel[i+1][1]
                                        + green_buffer[(i * image_width) + 2] * kernel[i+1][2];
            end
            // Blue component
            for (int i = 0; i < 5; i++) begin
                partial_sum_b_stage1[i] <= blue_buffer[(i * image_width) + 1] * kernel[i+1][1]
                                        + blue_buffer[(i * image_width) + 2] * kernel[i+1][2];
            end
        end

        // For 7x7 blur, use all kernel values from 0-6, complete first 3 rows sum
        else if (freq_flag == 3) begin
            // Red component
            for (int i = 0; i < 7; i++) begin
                partial_sum_r_stage1[i] <= red_buffer[(i * image_width)] * kernel[i][0]
                                        + red_buffer[(i * image_width) + 1] * kernel[i][1]
                                        + red_buffer[(i * image_width) + 2] * kernel[i][2];
            end
            // Green component
            for (int i = 0; i < 7; i++) begin
                partial_sum_g_stage1[i] <= green_buffer[(i * image_width)] * kernel[i][0]
                                        + green_buffer[(i * image_width) + 1] * kernel[i][1]
                                        + green_buffer[(i * image_width) + 2] * kernel[i][2];
            end
            // Blue component
            for (int i = 0; i < 7; i++) begin
                partial_sum_b_stage1[i] <= blue_buffer[(i * image_width)] * kernel[i][0]
                                        + blue_buffer[(i * image_width) + 1] * kernel[i][1]
                                        + blue_buffer[(i * image_width) + 2] * kernel[i][2];
            end
        end
    end

    // Stage 2: Complete row-wise multiplication for RGB components (3x3)
    always_ff @(posedge clk) begin

        // For 3x3 blur, use middle kernel values from 2-4, complete middle row sum and add to previous sum
        if (freq_flag == 1) begin
            // Red component
            for (int i = 0; i < 3; i++) begin
                partial_sum_r_stage2[i] <= partial_sum_r_stage1[i]
                    + red_buffer[(i * image_width) + 3] * kernel[i+2][3];
            end
            // Green component
            for (int i = 0; i < 3; i++) begin
                partial_sum_g_stage2[i] <= partial_sum_g_stage1[i]
                    + green_buffer[(i * image_width) + 3] * kernel[i+2][3];
            end
            // Blue component
            for (int i = 0; i < 3; i++) begin
                partial_sum_b_stage2[i] <= partial_sum_b_stage1[i]
                    + blue_buffer[(i * image_width) + 3] * kernel[i+2][3];
            end
        end

        // For 5x5 blur, use middle kernel values from 1-5, complete middle 2 rows sum and add to previous sum
        else if (freq_flag == 2) begin
            // Red component
            for (int i = 0; i < 5; i++) begin
                partial_sum_r_stage2[i] <= partial_sum_r_stage1[i]
                    + red_buffer[(i * image_width) + 3] * kernel[i+1][3]
                    + red_buffer[(i * image_width) + 4] * kernel[i+1][4];
            end
            // Green component
            for (int i = 0; i < 5; i++) begin
                partial_sum_g_stage2[i] <= partial_sum_g_stage1[i] 
                    + green_buffer[(i * image_width) + 3] * kernel[i+1][3]
                    + green_buffer[(i * image_width) + 4] * kernel[i+1][4];
            end
            // Blue component
            for (int i = 0; i < 5; i++) begin
                partial_sum_b_stage2[i] <= partial_sum_b_stage1[i] 
                    + blue_buffer[(i * image_width) + 3] * kernel[i+1][3]
                    + blue_buffer[(i * image_width) + 4] * kernel[i+1][4];
            end
        end

        // For 7x7 blur, use all kernel values from 0-6, complete middle 3 rows sum and add to previous sum
        else if (freq_flag == 3) begin
            // Red component
            for (int i = 0; i < 7; i++) begin
                partial_sum_r_stage2[i] <= partial_sum_r_stage1[i]
                    + red_buffer[(i * image_width) + 3] * kernel[i][3]
                    + red_buffer[(i * image_width) + 4] * kernel[i][4];
            end
            // Green component
            for (int i = 0; i < 7; i++) begin
                partial_sum_g_stage2[i] <= partial_sum_g_stage1[i]
                    + green_buffer[(i * image_width) + 3] * kernel[i][3]
                    + green_buffer[(i * image_width) + 4] * kernel[i][4];
            end
            // Blue component
            for (int i = 0; i < 7; i++) begin
                partial_sum_b_stage2[i] <= partial_sum_b_stage1[i]
                    + blue_buffer[(i * image_width) + 3] * kernel[i][3]
                    + blue_buffer[(i * image_width) + 4] * kernel[i][4];
            end
        end
    end
	 
	 // Stage 3: Complete row-wise multiplication for RGB components (3x3)
    always_ff @(posedge clk) begin

        // For 3x3 blur, use middle kernel values from 2-4, complete last row sum and add to previous sum
        if (freq_flag == 1) begin
            // Red component
            for (int i = 0; i < 3; i++) begin
                partial_sum_r_stage3[i] <= partial_sum_r_stage2[i]
                    + red_buffer[(i * image_width) + 4] * kernel[i+2][4];
            end
            // Green component
            for (int i = 0; i < 3; i++) begin
                partial_sum_g_stage3[i] <= partial_sum_g_stage2[i]
                    + green_buffer[(i * image_width) + 4] * kernel[i+2][4];
            end
            // Blue component
            for (int i = 0; i < 3; i++) begin
                partial_sum_b_stage3[i] <= partial_sum_b_stage2[i]
                    + blue_buffer[(i * image_width) + 4] * kernel[i+2][4];
            end
        end

        // For 5x5 blur, use middle kernel values from 1-5, complete last row sum and add to previous sum
        else if (freq_flag == 2) begin
            // Red component
            for (int i = 0; i < 5; i++) begin
                partial_sum_r_stage3[i] <= partial_sum_r_stage2[i]
                    + red_buffer[(i * image_width) + 5] * kernel[i+1][5];
            end
            // Green component
            for (int i = 0; i < 5; i++) begin
                partial_sum_g_stage3[i] <= partial_sum_g_stage2[i]
                    + green_buffer[(i * image_width) + 5] * kernel[i+1][5];
            end
            // Blue component
            for (int i = 0; i < 5; i++) begin
                partial_sum_b_stage3[i] <= partial_sum_b_stage2[i]
                    + blue_buffer[(i * image_width) + 5] * kernel[i+1][5];
            end
        end

        // For 7x7 blur, use all kernel values from 0-6, complete last 2 rows sum and add to previous sum
        else if (freq_flag == 3) begin
            // Red component
            for (int i = 0; i < 7; i++) begin
                partial_sum_r_stage3[i] <= partial_sum_r_stage2[i]
                    + red_buffer[(i * image_width) + 5] * kernel[i][5]
                    + red_buffer[(i * image_width) + 6] * kernel[i][6];
            end
            // Green component
            for (int i = 0; i < 7; i++) begin
                partial_sum_g_stage3[i] <= partial_sum_g_stage2[i]
                    + green_buffer[(i * image_width) + 5] * kernel[i][5]
                    + green_buffer[(i * image_width) + 6] * kernel[i][6];
            end
            // Blue component
            for (int i = 0; i < 7; i++) begin
                partial_sum_b_stage3[i] <= partial_sum_b_stage2[i]
                    + blue_buffer[(i * image_width) + 5] * kernel[i][5]
                    + blue_buffer[(i * image_width) + 6] * kernel[i][6];
            end
        end
    end

    // Stage 4: Accumulate rows for the final convolution result (RGB)
    always_ff @(posedge clk) begin
		  
		  // For no blur
		  if (freq_flag == 0) begin
			  conv_result_r <= red_in;
			  conv_result_g <= green_in;
			  conv_result_b <= blue_in;
		  end
		  
        // For 3x3 blur, add all 3 partial sums
        else if (freq_flag == 1) begin
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

        // For 5x5 blur, add all 5 partial sums
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

        // For 7x7 blur, add all 7 partial sums
        if (freq_flag == 3) begin
            // Red component
            conv_result_r <= partial_sum_r_stage3[0] 
                + partial_sum_r_stage3[1] 
                + partial_sum_r_stage3[2]
                + partial_sum_r_stage3[3] 
                + partial_sum_r_stage3[4]
                + partial_sum_r_stage3[5] 
                + partial_sum_r_stage3[6];
            // Green component
            conv_result_g <= partial_sum_g_stage3[0] 
                + partial_sum_g_stage3[1] 
                + partial_sum_g_stage3[2]
                + partial_sum_g_stage3[3] 
                + partial_sum_g_stage3[4]
                + partial_sum_g_stage3[5] 
                + partial_sum_g_stage3[6];
            // Blue component
            conv_result_b <= partial_sum_b_stage3[0] 
                + partial_sum_b_stage3[1] 
                + partial_sum_b_stage3[2]
                + partial_sum_b_stage3[3] 
                + partial_sum_b_stage3[4]
                + partial_sum_b_stage3[5] 
                + partial_sum_b_stage3[6];
        end
    end

    // Stage 5: Normalise and output the result (RGB)
    always_ff @(posedge clk) begin

        // For 7x7 blur, output rgb values bit shifted by 7 (Divide by 128)
        if (freq_flag == 3) begin
            startofpacket_out <= 0;
            endofpacket_out <= 0;

            // Combine the normalized results for each color component
            data_out <= {conv_result_r[10:7], conv_result_g[10:7], conv_result_b[10:7]};
            
            // First packet reset buffer count and counters
			  if (startofpacket_in) begin
				  startofpacket_out <= 1;
			  end

            // Continue image output as 0 until full kernel can be filled
		      if (endofpacket_in) begin
				  endofpacket_out <= 1;
			  end
        end

        // For 5x5 blur, output rgb values bit shifted by 6 (Divide by 64)
        if (freq_flag == 2) begin
            startofpacket_out <= 0;
            endofpacket_out <= 0;

            // Combine the normalized results for each color component
            data_out <= {conv_result_r[9:6], conv_result_g[9:6], conv_result_b[9:6]};
            
            // First packet reset buffer count and counters
			  if (startofpacket_in) begin
				  startofpacket_out <= 1;
			  end

            // Continue image output as 0 until full kernel can be filled
		      if (endofpacket_in) begin
				  endofpacket_out <= 1;
			  end
        end

         // For 3x3 blur, output rgb values bit shifted by 5 (Divide by 32)
        else if (freq_flag == 1) begin
            startofpacket_out <= 0;
            endofpacket_out <= 0;

            // Combine the normalized results for each color component
            data_out <= {conv_result_r[8:5], conv_result_g[8:5], conv_result_b[8:5]};
            
            // First packet reset buffer count and counters
			  if (startofpacket_in) begin
				  startofpacket_out <= 1;
			  end

            // Continue image output as 0 until full kernel can be filled
			  if (endofpacket_in) begin
				  endofpacket_out <= 1;
			  end

        // For 1x1 blur, output the input
        end else if (freq_flag == 0) begin
            // For 1x1 kernel, directly pass through the data
            data_out <= data_in;
            startofpacket_out <= startofpacket_in;
            endofpacket_out <= endofpacket_in;
        end
    end

endmodule