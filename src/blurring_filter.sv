`timescale 1ns / 1ps

module blurring_filter (
    input logic clk,
    input logic [2:0] freq_flag,  // Pitch input: 0 for 1x1, 1 for 3x3, 2 for 5x5
    input logic ready_in,
	input logic [12-1:0] data_in,
	output logic ready_out,
    output logic [12-1:0] data_out
);

    // 15x15 image
    localparam image_height = 8'b11110000;
    localparam image_width = 9'b101000000;

    // Kernel sizes
	 logic [2:0] KERNEL_SIZE;
    localparam KERNEL_SIZE_1x1 = 3'b001;
    localparam KERNEL_SIZE_3x3 = 3'b011;
    localparam KERNEL_SIZE_5x5 = 3'b101;

    // Image buffer (maximum size for 5x5 kernel)
    // For camera:
    logic [12-1:0] image_buffer [0:KERNEL_SIZE_5x5-1][0:320-1];
    logic [12-1:0] kernel [0:KERNEL_SIZE_5x5-1][0:KERNEL_SIZE_5x5-1];
    logic [2*12-1:0] conv_result;  // Double-width for intermediate result
	
	logic [9:0] buffer_col_count;
    logic [3:0] buffer_row_count;
    logic buffer_full;

    // Define the kernel weights based on freq_flag (Pitch input)
    always_comb begin
        case (freq_flag)
            3'b000: begin // 1x1 kernel
                kernel[0][0] = 12'h000001;
					/* 1 */
				KERNEL_SIZE <= KERNEL_SIZE_1x1;
            end
            3'b001: begin // 3x3 kernel with total wieght of 32
                // Corners are assigned as 3 and rest are assigned as 4
				for (int i = 0; i < KERNEL_SIZE_3x3; i++) begin
					for (int j = 0; j < KERNEL_SIZE_3x3; j++) begin
						if ((i % 2 == 0) && (j % 2 == 0)) begin
							kernel[i][j] = 12'h000003;
						end
						else begin
							kernel[i][j] = 12'h000004;
						end
					end
				end
				/*
				3 4 3
				4 4 4
				3 4 3
				*/
			    KERNEL_SIZE <= KERNEL_SIZE_3x3;
            end
            3'b010: begin // 5x5 kernel with total wieght of 64
               for (int i = 0; i < KERNEL_SIZE_5x5; i++) begin
						 for (int j = 0; j < KERNEL_SIZE_5x5; j++) begin
							  if (i == 0 || i == 4) begin
									kernel[i][j] = (j == 0 || j == 4) ? 12'h000001 : (j == 1 || j == 3) ? 12'h000002 : 12'h000003;
							  end
							  else if (i == 1 || i == 3) begin
									kernel[i][j] = (j == 0 || j == 4) ? 12'h000002 : (j == 1 || j == 3) ? 12'h000003 : 12'h000004;
							  end
							  else begin // For i == 2 (middle row)
									kernel[i][j] = (j == 0 || j == 4) ? 12'h000003 : (j == 1 || j == 3) ? 12'h000004 : 12'h000004;
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
            default: begin // Default to 1x1 kernel
                kernel[0][0] = 12'h000001;
					KERNEL_SIZE <= KERNEL_SIZE_1x1;
            end
        endcase
    end

    // Shift incoming data into the image buffer
    always_ff @(posedge clk) begin : Image_buffer
		if (ready_in) begin
            // Check if the buffer is filled with enough rows
            if (buffer_row_count < KERNEL_SIZE) begin
                // Fill in pixel
                if (buffer_col_count < image_width) begin
                    image_buffer[buffer_row_count][buffer_col_count] <= data_in; // Fill new row
						  
					if (buffer_col_count == image_width - 1) begin
						buffer_row_count <= buffer_row_count + 4'b0001;
					    buffer_col_count <= 0;
					end
					  
					else begin
						buffer_col_count <= buffer_col_count + 10'b0000000001;
					end
                end
            end

            if (buffer_row_count == KERNEL_SIZE) begin
                buffer_full <= 1;
            
					if (KERNEL_SIZE == KERNEL_SIZE_3x3) begin
						 // If buffer is full, shift rows up and add new row at the bottom
						 for (int i = 0; i < (KERNEL_SIZE_3x3 - 1); i++) begin
							  for (int j = 0; j < image_width; j++) begin
									image_buffer[i][j] <= image_buffer[i+1][j]; // Shift rows up
							  end
						 end
					end
					
					else if (KERNEL_SIZE == KERNEL_SIZE_5x5) begin
						 // If buffer is full, shift rows up and add new row at the bottom
						 for (int i = 0; i < (KERNEL_SIZE_5x5 - 1); i++) begin
							  for (int j = 0; j < image_width; j++) begin
									image_buffer[i][j] <= image_buffer[i+1][j]; // Shift rows up
							  end
						 end
					end
                    
                // Decrement the row
                buffer_row_count <= buffer_row_count - 1;
            end
        end
			
		else begin
			buffer_full <= 0;
			buffer_row_count <= 0;
			buffer_col_count <= 0;
		end
    end

    // Convolution operation
	always_ff @(posedge clk) begin : Convolution
		 ready_out <= 0;
		 data_out <= 12'b0;
		 
		 // Ensure the convolution result is reset only at the start of a new computation
		 if (ready_in) begin
			  // For 1x1 kernel
			  if (freq_flag == 0) begin
					data_out <= data_in;
			  end
			  
			  // For 3x3 kernel
			  else if (buffer_full && (freq_flag == 1)) begin
					conv_result = 0; // Reset the result only once at the beginning of the convolution
					if ((buffer_row_count >= 2) && (buffer_col_count >= 2)) begin
						for (int i = 0; i < KERNEL_SIZE_3x3; i++) begin
							 for (int j = 0; j < KERNEL_SIZE_3x3; j++) begin
								  conv_result += (image_buffer[buffer_row_count - 2 + i][buffer_col_count - 2 + j] * kernel[i][j]);
							 end
						end
					end
					// Divide by 32 (equivalent to right shift by 5)
					data_out <= conv_result[16:5]; // Adjust for the larger bitwidth
			  end
			  
			  // For 5x5 kernel
			  else if (buffer_full && (freq_flag == 2)) begin
					conv_result = 0; // Reset the result only once at the beginning of the convolution
					if ((buffer_row_count >= 4) && (buffer_col_count >= 4)) begin
						for (int i = 0; i < KERNEL_SIZE_5x5; i++) begin
							 for (int j = 0; j < KERNEL_SIZE_5x5; j++) begin
								  conv_result += (image_buffer[buffer_row_count - 4 + i][buffer_col_count - 4 + j] * kernel[i][j]);
							 end
						end
					end
					// Divide by 64 (equivalent to right shift by 6)
					data_out <= conv_result[17:6]; // Adjust for the larger bitwidth
			  end
			  
			  ready_out <= 1; // Indicate that the output is ready
		 end
	end


endmodule