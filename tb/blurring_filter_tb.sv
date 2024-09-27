`timescale 1ns / 1ps

module blurring_filter_tb;

    localparam TCLK = 20; // Clock period: 20 ns

     // Camera image size
    localparam IMG_WIDTH = 320;
     localparam IMG_LENGTH = 240;

    logic clk = 0;
    logic ready_in = 0;
	 logic valid_in = 1;
	 logic startofpacket_in = 0;
	 logic endofpacket_in = 0;
    logic [2:0] freq_flag; // Kernel size control
    logic [11:0] data_in;
    logic ready_out;
	 logic valid_out;
	 logic startofpacket_out;
	 logic endofpacket_out;
    logic [11:0] data_out;

    // Instantiate the blurring filter
    blurring_filter DUT (
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
        .data_out(data_out)
    );

    // Clock generation
    always #(TCLK / 2) clk = ~clk;

    // 15x15 image initialization (simple gradient for testing)
    localparam LEN = IMG_LENGTH * IMG_WIDTH;
    logic [11:0] image [0:LEN-1];

    integer i, j;

    initial begin
     
          // Set variables to 0 to avoid red lines in testbench
          freq_flag = 0;
          data_in = 0;
          ready_out = 0;
          data_out = 0;
			 startofpacket_out = 0;
			 endofpacket_out = 0;
     
        // Initialize image with a 1's to ensure base functionality
        for (i = 0; i < IMG_LENGTH; i = i + 1) begin
            for (j = 0; j < IMG_WIDTH; j = j + 1) begin
                image[i * IMG_LENGTH + j] = 12'h001; // Simple gradient
            end
        end

        // Open VCD file for waveform dumping
        $dumpfile("blurring_filter_tb.vcd");
        $dumpvars(0, blurring_filter_tb);

        // Delay before entering each test
        #100;
        ready_in = 1;
          
        // Test no blur
        $display("Testing with no blur");
        freq_flag = 3'b000; // Set to no blur
        run_test();
        ready_in = 0;

        // Delay before entering each test
        #100;
        ready_in = 1;
          
        // Test 3x3 kernel
        $display("Testing with 3x3 kernel");
        freq_flag = 3'b001; // Set to 3x3 kernel
        run_test();
        ready_in = 0;
        
        // Delay before entering each test
        #100;
        ready_in = 1;
          
        // Test 5x5 kernel
        $display("Testing with 5x5 kernel");
        freq_flag = 3'b010; // Set to 5x5 kernel
        run_test();
        ready_in = 0;

        // Delay before entering each test
        #100;
        ready_in = 1;
          
        // Test 7x7 kernel
        $display("Testing with 7x7 kernel");
        freq_flag = 3'b011; // Set to 7x7 kernel
        run_test();
        ready_in = 0;
        
        #1000
        
        // Initialize image with a simple pattern (gradient)
        for (i = 0; i < IMG_LENGTH; i = i + 1) begin
            for (j = 0; j < IMG_WIDTH; j = j + 1) begin
                     image[i * IMG_LENGTH + j] = (i * IMG_LENGTH + j) & 12'hFFF; // Simple gradient
            end
        end

        // Open VCD file for waveform dumping
        $dumpfile("blurring_filter_tb.vcd");
        $dumpvars(0, blurring_filter_tb);
          
        // Delay before entering each test
        #100;
        ready_in = 1;
          
        // Test no blur
        $display("Testing with no blur");
        freq_flag = 3'b000; // Set to no blur
        run_test();
        ready_in = 0;
          
        // Delay before entering each test
        #100;
        ready_in = 1;
          
        // Test 3x3 kernel
        $display("Testing with 3x3 kernel");
        freq_flag = 3'b001; // Set to 3x3 kernel
        run_test();
        ready_in = 0;
        
        // Delay before entering each test
        #100;
        ready_in = 1;
          
        // Test 5x5 kernel
        $display("Testing with 5x5 kernel");
        freq_flag = 3'b010; // Set to 5x5 kernel
        run_test();
        ready_in = 0;

        // Delay before entering each test
        #100;
        ready_in = 1;
          
        // Test 7x7 kernel
        $display("Testing with 7x7 kernel");
        freq_flag = 3'b011; // Set to 7x7 kernel
        run_test();
        ready_in = 0;
        
        #1000

        // Finish simulation
        $finish;
    end

    task run_test;
        begin
            // Feed image data to the filter
            for (i = 0; i < IMG_LENGTH; i = i + 1) begin
                for (j = 0; j < IMG_WIDTH; j = j + 1) begin
						 if ((i == 0) && (j == 0)) begin
							startofpacket_in = 1;
						 end
						 else begin
							startofpacket_in = 0;
						 end
						 
						 if ((i == IMG_LENGTH-1) && (j == IMG_WIDTH-1)) begin
							endofpacket_in = 1;
						 end
					    else begin
							endofpacket_in = 0;
							
						 end
                    data_in = image[i * IMG_LENGTH + j];
                    #TCLK; // Wait for processing
                end
            end
        end
    endtask

endmodule