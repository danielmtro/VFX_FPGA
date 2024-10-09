`timescale 1ns / 1ps

module blurring_filter_tb;

    localparam TCLK = 20; // Clock period: 20 ns

    // Camera image size
   localparam IMG_WIDTH = 9;
   localparam IMG_HEIGHT = 7;
	
	logic start;

   // variables to go into the DUT
   logic clk = 0;
   logic ready_in = 0;
	logic valid_in = 0;
	logic startofpacket_in = 0;
	logic endofpacket_in = 0;
   logic freq_flag = 0; // Kernel size control
   logic [11:0] data_in;
   logic ready_out;
	logic valid_out;
	logic startofpacket_out;
	logic endofpacket_out;
   logic [11:0] data_out;
	logic [31:0] pixel_count;

    // Instantiate the blurring filter
    blurring_filter #(
		.IMAGE_WIDTH(IMG_WIDTH),
		.IMAGE_HEIGHT(IMG_HEIGHT)
	 ) DUT (
         .clk(clk),
         .ready_in(ready_in),
			.valid_in(valid_in),
			.startofpacket_in(startofpacket_in),
			.endofpacket_in(endofpacket_in),
         .freq_flag(freq_flag),
         .data_in(data_in),
         .ready_out(ready_out),
		   .valid_out(valid_out),
		   .startofpacket_out(startofpacket_out),
		   .endofpacket_out(endofpacket_out),
         .data_out(data_out),
			.pixel_count_out(pixel_count)
    );

    // Clock generation
    always #(TCLK / 2) clk = ~clk;

    // 15x15 image initialization (simple gradient for testing)
    localparam LEN = IMG_HEIGHT * IMG_WIDTH;
    logic [11:0] image [0:LEN-1];

    integer i=0, j=0;
    

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars();


        // set up blur test image
        for(int i = 0; i < LEN; ++i) begin
            image[i] = {12{1'b0}};
        end

        // set a white square in the middle of the image from row 3 to row 5
        // with a width of 3 
        for(int j = 1; j < 6; ++j) begin
         for(int i=IMG_WIDTH * j + 2; i < IMG_WIDTH * j + 7; ++i) begin
               image[i] = {12{1'b1}};
            end
        end

        // set beginning parameters
		  valid_in = 1;
        #(TCLK*5);
		  start = 1'b1;
			
        #(TCLK*250);
        $finish();
    end

	 
    // Input Driver:
	 always_ff @(posedge clk) begin
		  if (start) begin
				
				// oscillate ready in to mimic the scaler
				ready_in <= ~ready_in;
				
				// process the data that goes in
				data_in <= image[i];
            $display("input: %b, pixel_in: %d", data_in, i);
				
				// increment the index
				if(ready_in) begin
					i <= i < LEN ? i + 1 : LEN;
				end
				
		  end
	 end
	 
	 // always comb block to set SOP and EOP
	 always_comb begin
		startofpacket_in = (i == 0) ? 1'b1 : 1'b0;
		endofpacket_in = (i == LEN - 1) ? 1'b1 : 1'b0;
	 end
		 
		 
	// Output Checking
	always_ff @(posedge clk) begin
	
        if (start) begin
            $display("output: %b, pixel count: %d", data_out, pixel_count);
        end
    end
 

endmodule