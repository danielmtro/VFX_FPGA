`timescale 1ns / 1ps

module blurring_filter #(
	parameter IMAGE_WIDTH = 320,
	parameter IMAGE_HEIGHT = 240

) (
    input logic clk,
    input logic ready_in,
    input logic valid_in,
    input logic startofpacket_in,
    input logic endofpacket_in,
    input logic freq_flag,
    input logic [12-1:0] data_in,
    output logic ready_out,
    output logic valid_out,
    output logic startofpacket_out,
    output logic endofpacket_out,
    output logic [12-1:0] data_out,
	 output logic[31:0] pixel_count_out
);

    /*
    TO-DO

    DETERMINE VALID CALCULATION

    */

    /*
    In general we are working with fixed point numbers - compute as such

    Note here I selet 14/7 because I want to use an even kernel for the 5x5
    blue.

    I want the kernel to have 1/25 in each of the elements for a low pass
    filter.

    to do this, the closest binary number to 1/25 is 0.0000101 which is
    about 0.39. This makes it obvious that i need 7 fractional bits. 
    We then have 4 integer bits

    */
    localparam BITS_PER_COLOUR = 4;
    localparam KERNEL_WIDTH = 5;
    localparam KERNEL_SIZE = 25; 
    localparam W = 11;
    localparam W_FRAC = 7;
    localparam TOTAL_PIXELS = IMAGE_WIDTH * IMAGE_HEIGHT;

    // size of the buffer required
    localparam N = IMAGE_WIDTH * (KERNEL_WIDTH - 1) + KERNEL_WIDTH;
	 
	 // this should store 2 rows plus an additional 3
	 localparam DELAY = IMAGE_WIDTH*2 + 3;

    // Extract RGB components from input data
    logic [W - 1:0] red_in, green_in, blue_in;

    // extract our bit values - pad them with zeroes on the start and the end
    // to turn them into 11/7 fixed point computations
    assign red_in   = {data_in[11:8], 7'b0000000};  // Bits 11-8 for red
    assign green_in = {data_in[7:4],  7'b0000000};   // Bits 7-4 for green
    assign blue_in  = {data_in[3:0],  7'b0000000};   // Bits 3-0 for blue


    // Image buffer for RGB components
    logic signed [W - 1:0] r_shift_reg [0:N - 1];
    logic signed [W - 1:0] g_shift_reg [0:N - 1];
    logic signed [W - 1:0] b_shift_reg [0:N - 1];

    // multiply outputs
    logic signed [2*W-1:0] r_mult_result [0:KERNEL_SIZE-1];
    logic signed [2*W-1:0] g_mult_result [0:KERNEL_SIZE-1];
    logic signed [2*W-1:0] b_mult_result [0:KERNEL_SIZE-1];

    // accumulate outputs
    logic signed [$clog2(N)+2*W:0] r_macc = 0; // $clog2(N)+1 to accomodate for overflows over the additions.
    logic signed [$clog2(N)+2*W:0] g_macc = 0;
    logic signed [$clog2(N)+2*W:0] b_macc = 0;

    // Define the kernel size 
    // logic signed [W-1:0] h [0:N-1];

    // Just use a constant type of kernel to make life easy here
    logic [W - 1:0] kernel_value;
    assign kernel_value = {4'b0000, 7'b0000101};

    // Shift incoming data into separate RGB buffers
    always_ff @(posedge clk) begin : Shift_register

        // only shift register on the handshake
        if(valid_in && ready_in) begin

            // shift all the values down
            for(int i = 0; i < N - 1; i += 1) begin
                r_shift_reg[i + 1] <= r_shift_reg[i];
                g_shift_reg[i + 1] <= g_shift_reg[i];
                b_shift_reg[i + 1] <= b_shift_reg[i];
            end

            // set the values at the start
            r_shift_reg[0] <= signed'(red_in);
            g_shift_reg[0] <= signed'(green_in);
            b_shift_reg[0] <= signed'(blue_in);

        end

    end

    // Compute the multiplications
    always_comb begin : h_multiply

        // loop through the KERNEL_WIDTH x KERNEL_WIDTH to come up with the multiplications
        for(int row = 0; row < KERNEL_WIDTH; ++row) begin

            for(int col = 0; col < KERNEL_WIDTH; ++ col) begin 
                
                // row * KERNEL_WIDTH + col: the corresponding index on the reduced WIDTH x WIDTH list
                // row*IMAGE_WIDTH + col : the index on the whole shift register
                r_mult_result[row*KERNEL_WIDTH + col] = r_shift_reg[row*IMAGE_WIDTH + col] * kernel_value;
                g_mult_result[row*KERNEL_WIDTH + col] = g_shift_reg[row*IMAGE_WIDTH + col] * kernel_value;
                b_mult_result[row*KERNEL_WIDTH + col] = b_shift_reg[row*IMAGE_WIDTH + col] * kernel_value;

            end
        end
    
    end

    // sum together the whole kernel
    always_comb begin : MAC
        r_macc = 0;
        g_macc = 0;
        b_macc = 0;
        // Set macc to be the sum of all elements in mult_result.
        // Hint: use a for loop.
        for(int i=0; i<KERNEL_SIZE; ++i) begin
            r_macc = r_macc + r_mult_result[i];
            g_macc = g_macc + g_mult_result[i];
            b_macc = b_macc + b_mult_result[i];
        end
    end


    logic overflow;
	 
	 logic [3:0] r_bits;
	 logic [3:0] g_bits;
	 logic [3:0] b_bits;
	 
	 // isolate just the bits that we are going to be keeping
	 always_comb begin
		r_bits = r_macc[BITS_PER_COLOUR -1 + 2 * W_FRAC:2 * W_FRAC];
		g_bits = g_macc[BITS_PER_COLOUR -1 + 2 * W_FRAC:2 * W_FRAC];
		b_bits = b_macc[BITS_PER_COLOUR -1 + 2 * W_FRAC:2 * W_FRAC];
	 end
 
    always_ff @(posedge clk) begin : output_reg
        if (valid_in & ready_in) begin

            // extract the relevant information
            data_out <= {r_bits,
								 g_bits,
								 b_bits};

            // check if we have overflowed the buffers
            overflow <= (r_macc < 0 || g_macc < 0 || b_macc < 0) ? 1 : 0;
            // x_valid_q <= 1'b1;
            // valid_out <= x_valid_q; // 2 clock cycles for valid data to get from x to y
        end
    end

    integer pixel_delay_counter = 0;    // How many pixels are we behind the current SOP
    integer pixel_count = 0;              // What pixel in the frame itself are we up to?
	 

    always_ff @(posedge clk) begin : count_pixels

        // on the handshake increment the counters
        if(valid_in && ready_in) begin

            // if we've received an SOP begin counting the number of pixels that have been 
            // received
            if(startofpacket_in) begin
                pixel_delay_counter <= 0;
            end
            else begin
                // increment the delay counter if we haven't reached the end of the buffer time
                // NOTE DOES NOT ACCOUNT FOR PIPELINING AT THE MOMENT
                pixel_delay_counter <= pixel_delay_counter + 1;
            end

            // if we've reached the buffer width, then we are at the start of the frame ready 
            // check that the current pixel count has exceeded the size of the frame before resetting
            if(pixel_delay_counter < DELAY && pixel_count > TOTAL_PIXELS) begin
					pixel_count <= 0;
				end
				else if(pixel_delay_counter < DELAY && pixel_count == 0) begin
					pixel_count <= 0;
				end
				else begin
					pixel_count <= pixel_count + 1;
				end

        end
    end

    // set up the outputs
    always_comb begin: output_setting

        // start of packet will occur when we reach the given delay count
        
        if(pixel_count == 0 && pixel_delay_counter == DELAY) begin
            startofpacket_out = 1'b1;
        end
		  else begin
				startofpacket_out = 1'b0;
		  end

        // end of packet will happen when we reach the end of all the pixels trying
        // to be counted
        
        if(pixel_count == TOTAL_PIXELS - 1) begin 
            endofpacket_out = 1'b1;
        end
		  else begin
				endofpacket_out = 1'b0;
		  end

        // if we haven't reached the buffer region yet or we've finished 
        // outputting a frame then set valid to be low
        if(pixel_count >= TOTAL_PIXELS) begin 
            valid_out = 1'b0;
        end 
		  else if(pixel_count == 0 && pixel_delay_counter < DELAY) begin
				// check that if pixel count is at zero and the delay counter is not yet reached
				valid_out = 1'b0;
		  end
		  else begin
				valid_out = 1'b1;
		  end

    end

     // Pass through ready signal
    assign ready_out = ready_in;
	 assign pixel_count_out = pixel_count;

endmodule