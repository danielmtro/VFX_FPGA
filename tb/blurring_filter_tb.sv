`timescale 1ns / 1ps

module blurring_filter_tb;

    localparam TCLK = 20; // Clock period: 20 ns

	 // Camera image size
    localparam IMG_WIDTH = 320;
	 localparam IMG_LENGTH = 240;

    logic clk = 0;
	logic ready_in = 0;
    logic [2:0] freq_flag; // Kernel size control
    logic [11:0] data_in;
	logic ready_out;
    logic [11:0] data_out;

    // Instantiate the blurring filter
    blurring_filter DUT (
        .clk(clk),
	    .ready_in(ready_in),
        .freq_flag(freq_flag),
        .data_in(data_in),
		.ready_out(ready_out),
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
		#100
		ready_in = 1;

        // Test 1x1 kernel
        $display("Testing with 1x1 kernel");
        freq_flag = 3'b000; // Set to 1x1 kernel
        run_test();
		ready_in = 0;

		#100
		ready_in = 1;
		  
        // Test 3x3 kernel
        $display("Testing with 3x3 kernel");
        freq_flag = 3'b001; // Set to 3x3 kernel
        run_test();
		ready_in = 0;

		#100;
		ready_in = 1;
		  
        // Test 5x5 kernel
        $display("Testing with 5x5 kernel");
        freq_flag = 3'b010; // Set to 5x5 kernel
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
		#100
		ready_in = 1;

        // Test 1x1 kernel
        $display("Testing with 1x1 kernel");
        freq_flag = 3'b000; // Set to 1x1 kernel
        run_test();
		ready_in = 0;

		#100
		ready_in = 1;
		  
        // Test 3x3 kernel
        $display("Testing with 3x3 kernel");
        freq_flag = 3'b001; // Set to 3x3 kernel
        run_test();
		ready_in = 0;

		#100;
		ready_in = 1;
		  
        // Test 5x5 kernel
        $display("Testing with 5x5 kernel");
        freq_flag = 3'b010; // Set to 5x5 kernel
        run_test();
		ready_in = 0;
		
		#100

        // Finish simulation
        $finish;
    end

    task run_test;
        begin
            // Feed image data to the filter
            for (i = 0; i < IMG_LENGTH; i = i + 1) begin
                for (j = 0; j < IMG_WIDTH; j = j + 1) begin
                    data_in = image[i * IMG_LENGTH + j];
                    #TCLK; // Wait for processing
                    // Add output checks as needed for each kernel
                    $display("Pixel (%d, %d): Input = %h, Output = %h", i, j, data_in, data_out);
                end
            end
        end
    endtask

endmodule