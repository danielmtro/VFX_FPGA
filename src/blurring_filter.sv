`timescale 1ns / 1ps

module blurring_filter (
    input logic clk,
    input logic [2:0] freq_flag,  // Pitch input: 0 for 1x1, 1 for 3x3, 2 for 5x5
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

    // 320x240 image
    localparam image_height = 8'b11110000;
    localparam image_width = 9'b101000000;

    // Kernel sizes
	 logic [2:0] KERNEL_SIZE;
    localparam KERNEL_SIZE_1x1 = 3'b001;
    localparam KERNEL_SIZE_3x3 = 3'b011;
    localparam KERNEL_SIZE_5x5 = 3'b101;

    // Image buffer (maximum size for 5x5 kernel)
    // For camera:
    logic [12-1:0] image_buffer [0:(image_width*4 + 5)-1];
    logic [12-1:0] kernel [0:KERNEL_SIZE_5x5-1][0:KERNEL_SIZE_5x5-1];
    logic [2*12-1:0] conv_result;  // Double-width for intermediate result
	
	logic [9:0] buffer_col_count;
    logic [3:0] buffer_row_count;
	 logic [9:0] start_buffer_count;
	 logic[3:0] calc_buffer;
	 logic [9:0] end_buffer_count;
	 
	 // Registers for intermediate results and pipeline stages
	logic signed [16:0] partial_sum_3x3_stage1 [2:0];   // Row sums for 3x3 kernel (Stage 1)
	logic signed [16:0] partial_sum_3x3_stage2 [2:0];   // Row sums for 3x3 kernel (Stage 2)
	logic signed [17:0] partial_sum_5x5_stage1 [4:0];   // Row sums for 5x5 kernel (Stage 1)
	logic signed [17:0] partial_sum_5x5_stage2 [4:0];   // Row sums for 5x5 kernel (Stage 2)
	logic signed [16:0] conv_result_3x3_stage;          // Final conv result for 3x3 kernel
	logic signed [17:0] conv_result_5x5_stage;          // Final conv result for 5x5 kernel

    // Define the kernel weights based on freq_flag (Pitch input)
    always_comb begin// 5x5 kernel with total wieght of 64
		for (int i = 0; i < KERNEL_SIZE_5x5; i++) begin
			 for (int j = 0; j < KERNEL_SIZE_5x5; j++) begin
				  if (i == 0 || i == 4) begin
						kernel[i][j] = (j == 0 || j == 4) ? 3'b001 : (j == 1 || j == 3) ? 3'b010 :  3'b011;
				  end
				  else if (i == 1 || i == 3) begin
						kernel[i][j] = (j == 0 || j == 4) ? 3'b010 : (j == 1 || j == 3) ?  3'b011 :  3'b100;
				  end
				  else begin // For i == 2 (middle row)
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
		KERNEL_SIZE <= KERNEL_SIZE_5x5;
    end

    // Shift incoming data into the image buffer
    always_ff @(posedge clk) begin : Image_buffer
		if (ready_in) begin
			// Shift the entire buffer left by 1 pixel to make space for the new data
			for (int i = 0; i < (image_width*4 + 4); i++) begin
				 image_buffer[i] <= image_buffer[i+1];
			end
			image_buffer[(image_width*4 + 4)] <= data_in;  // Insert new pixel at the end
		end
			
		else begin
			buffer_row_count <= 0;
			buffer_col_count <= 0;
		end
    end

	// Pipelined convolution process

    // Stage 1: Load pixels and perform initial multiplications for 3x3 kernel
	always_ff @(posedge clk) begin
		 if (freq_flag == 1) begin
			  // Load and multiply pixels for each row
			  for (int i = 0; i < 3; i++) begin
					partial_sum_3x3_stage1[i] <= image_buffer[(i * image_width)] * kernel[i+1][1];
			  end
		 end
		 else if (freq_flag == 2) begin
			  // Load and multiply pixels for each row (5x5 kernel)
			  for (int i = 0; i < 5; i++) begin
					partial_sum_5x5_stage1[i] <= image_buffer[(i * image_width)] * kernel[i][0];
			  end
		 end
	end

	// Stage 2: Complete row-wise multiplication for 3x3 and 5x5 kernels
	always_ff @(posedge clk) begin
		 if (freq_flag == 1) begin
			  // Perform second and third multiplications for each row of 3x3 kernel
			  for (int i = 0; i < 3; i++) begin
					partial_sum_3x3_stage2[i] <= partial_sum_3x3_stage1[i] 
													  + image_buffer[(i * image_width) + 1] * kernel[i+1][2]
													  + image_buffer[(i * image_width) + 2] * kernel[i+1][3];
			  end
		 end
		 else if (freq_flag == 2) begin
			  // Perform second to fifth multiplications for each row of 5x5 kernel
			  for (int i = 0; i < 5; i++) begin
					partial_sum_5x5_stage2[i] <= partial_sum_5x5_stage1[i] 
													  + image_buffer[(i * image_width) + 1] * kernel[i][1]
													  + image_buffer[(i * image_width) + 2] * kernel[i][2]
													  + image_buffer[(i * image_width) + 3] * kernel[i][3]
													  + image_buffer[(i * image_width) + 4] * kernel[i][4];
			  end
		 end
	end

	// Stage 3: Accumulate rows for the final convolution result (3x3 and 5x5 kernels)
	always_ff @(posedge clk) begin
		 if (freq_flag == 1) begin
			  // Sum up rows for the 3x3 kernel
			  conv_result_3x3_stage <= partial_sum_3x3_stage2[0] 
											 + partial_sum_3x3_stage2[1] 
											 + partial_sum_3x3_stage2[2];
		 end
		 else if (freq_flag == 2) begin
			  // Sum up rows for the 5x5 kernel
			  conv_result_5x5_stage <= partial_sum_5x5_stage2[0] 
											 + partial_sum_5x5_stage2[1] 
											 + partial_sum_5x5_stage2[2] 
											 + partial_sum_5x5_stage2[3] 
											 + partial_sum_5x5_stage2[4];
		 end
	end

	// Stage 4: Normalise and output the result
	always_ff @(posedge clk) begin
		 if (freq_flag == 1) begin
			  ready_out <= 0;
			  startofpacket_out <= 0;
			  endofpacket_out <= 0;
			  
			  // First packet reset buffer count
			  if (startofpacket_in) begin
				  start_buffer_count <= 0;
			  end
			  
			  // Wait until buffer count is on row 1 column 1 and account for the calculation buffer
			  else if (start_buffer_count < (image_width + 1 + 4)) begin
				  start_buffer_count <= start_buffer_count + 1;
			  end
			  
			  // Start image output as 0
			  else if (start_buffer_count == (image_width + 1 + 4)) begin
				  startofpacket_out <= 1;
				  data_out <= 0;
				  ready_out <= 1;
				  start_buffer_count <= start_buffer_count + 1;
			  end
			  
			  // Continue image output as 0 until full kernel can be filled
			  else if (start_buffer_count < (2*(image_width + 1) + 4)) begin
				  data_out <= 0;
				  ready_out <= 1;
				  start_buffer_count <= start_buffer_count + 1;
			  end
			  
			  // Output convoluted result as kernel is full until end packet flag is read
			  else if (!endofpacket_in) begin
			  // Normalise for the 5x5 kernel (divide by 64, right shift by 6)
				  data_out <= conv_result_5x5_stage[17:6];
				  ready_out <= 1;
			  end

			  // Wait for remaining convoluted pixels in the pipeline to be calculated and output
			  else if (calc_buffer < 4) begin
				  data_out <= conv_result_5x5_stage[17:6];
				  ready_out <= 1;
				  calc_buffer <= calc_buffer + 1;
			  end

			  // Outuput remaining pixels in image as 0
			  else if (end_buffer_count < ((2*image_width) + 2)) begin
			  	  data_out <= 0;
				  ready_out <= 1;
				  end_buffer_count <= end_buffer_count + 1;
			  end

			  // Outuput final pixel in image as 0
			  else if (end_buffer_count < ((2*image_width) + 2)) begin
			  	  data_out <= 0;
				  ready_out <= 1;
				  end_buffer_count <= end_buffer_count + 1;
				  endofpacket_out <= 1;
			  end

			  // Reset counters and flags to 0
			  else begin
				  startofpacket_out <= 0;
				  endofpacket_out <= 0;
				  start_buffer_count <= 0;
				  end_buffer_count <= 0;
			  end
		 end
		 else if (freq_flag == 2) begin
			  ready_out <= 0;
			  startofpacket_out <= 0;
			  endofpacket_out <= 0;
			  
			  // First packet reset buffer count
			  if (startofpacket_in) begin
				  start_buffer_count <= 0;
				  calc_buffer <= 0;
				  end_buffer_count <= 0;
			  end
			  
			  // Wait until buffer count is on row 2 column 2
			  else if (start_buffer_count < ((2*image_width) + 2 + 4)) begin
				  start_buffer_count <= start_buffer_count + 1;
			  end
			  
			  // Start image output as 0
			  else if (start_buffer_count == ((2*image_width) + 2 + 4)) begin
				  startofpacket_out <= 1;
				  start_buffer_count <= start_buffer_count + 1;
			  end
			  
			  // Continue image output as 0 until full kernel can be filled
			  else if (start_buffer_count < (2*((2*image_width) + 2) + 4)) begin
				  data_out <= 0;
				  ready_out <= 1;
				  start_buffer_count <= start_buffer_count + 1;
			  end
			  
			  // Output convoluted result as kernel is full until end packet flag is read
			  else if (!endofpacket_in) begin
			  // Normalise for the 5x5 kernel (divide by 64, right shift by 6)
				  data_out <= conv_result_5x5_stage[17:6];
				  ready_out <= 1;
			  end 
			  
			  // Wait for remaining convoluted pixels in the pipeline to be calculated and output
			  else if (calc_buffer < 4) begin
				  data_out <= conv_result_5x5_stage[17:6];
				  ready_out <= 1;
				  calc_buffer <= calc_buffer + 1;
			  end

			  // Outuput remaining pixels in image as 0
			  else if (end_buffer_count < ((2*image_width) + 2)) begin
			  	  data_out <= 0;
				  ready_out <= 1;
				  end_buffer_count <= end_buffer_count + 1;
			  end

			  // Outuput final pixel in image as 0
			  else if (end_buffer_count < ((2*image_width) + 2)) begin
			  	  data_out <= 0;
				  ready_out <= 1;
				  end_buffer_count <= end_buffer_count + 1;
				  endofpacket_out <= 1;
			  end

			  // Reset counters and flags to 0
			  else begin
				  startofpacket_out <= 0;
				  endofpacket_out <= 0;
				  start_buffer_count <= 0;
				  end_buffer_count <= 0;
			  end
		 end
		 else if (freq_flag == 0) begin
			  // For 1x1 kernel, directly pass through the data
			  data_out <= data_in;
			  ready_out <= ready_in;
			  startofpacket_out <= startofpacket_in;
			  endofpacket_out <= endofpacket_in;
		 end
	end


endmodule