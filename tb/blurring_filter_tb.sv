`timescale 1ns / 1ps

module blurring_filter_tb;

    localparam TCLK = 20; // Clock period: 20 ns

    // Camera image size
    localparam IMG_WIDTH = 320;
    localparam IMG_LENGTH = 240;

    logic clk = 0;
    logic ready_in = 0;
	logic valid_in = 0;
	logic startofpacket_in = 0;
	logic endofpacket_in = 0;
    logic is_underage; // Kernel size control
    logic [11:0] data_in;
    logic ready_out;
	logic valid_out;
	logic startofpacket_out;
	logic endofpacket_out;
    logic [11:0] data_out;

    // Instantiate the blurring filter
    dm_blurring_filter DUT (
        .clk(clk),
        .ready_in(ready_in),
		.valid_in(valid_in),
		.startofpacket_in(startofpacket_in),
		.endofpacket_in(endofpacket_in),
        .is_underage(is_underage),
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
        is_underage = 0;
        data_in = 0;
        ready_out = 0;
        data_out = 0;
			startofpacket_out = 0;
			endofpacket_out = 0;

        // Initialize image with a 1's to ensure base functionality
        for (i = 0; i < IMG_LENGTH; i = i + 1) begin
            for (j = 0; j < IMG_WIDTH; j = j + 1) begin
                image[i * IMG_LENGTH + j] = 12'b010101101010; // Simple colour
            end
        end

        // Open VCD file for waveform dumping
        $dumpfile("blurring_filter_tb.vcd");
        $dumpvars(0, blurring_filter_tb);

        // Delay before entering each test
        #100;
        ready_in = 1;
        valid_in = 1;

        // Test no blur
        $display("Testing with no blur");
        is_underage = 0; // Set to no blur
        run_test();
        ready_in = 0;
        valid_in = 0;

        // Delay before entering each test
        #100;
        ready_in = 1;
        valid_in = 1;

        // Test blur
        $display("Testing with blur");
        is_underage = 1;
        run_test();
        ready_in = 0;
        valid_in = 0;

        #1000

       // Initialize image with a simple pattern (thick line)
        for (i = 0; i < IMG_LENGTH; i = i + 1) begin
            for (j = 0; j < IMG_WIDTH; j = j + 1) begin
                if (j > 80 && j < 120)  begin
                    image[i * IMG_LENGTH + j] = 12'b111111111111;
                end
                else begin
                    image[i * IMG_LENGTH + j] = 12'b000000000000;
                end
            end
        end

        // Open VCD file for waveform dumping
        $dumpfile("blurring_filter_tb.vcd");
        $dumpvars(0, blurring_filter_tb);

        // Delay before entering each test
        #100;
        ready_in = 1;
        valid_in = 1;

        // Test no blur
        $display("Testing with no blur");
        is_underage = 0; // Set to no blur
        run_test();
        ready_in = 0;
        valid_in = 0;

        // Delay before entering each test
        #100;
        ready_in = 1;
        valid_in = 1;

        // Test blur
        $display("Testing with blur");
        is_underage = 1;
        run_test();
        ready_in = 0;
        valid_in = 0;

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

                    // Test handshaking
                    if ((i % 10 == 0) || (j % 10 == 0)) begin
                        valid_in = 0;
                        #100
                        valid_in = 1;
                    end

                    if ((i % 15 == 0) || (j % 15 == 0)) begin
                        ready_in = 0;
                        #100
                        ready_in = 1;
                    end
                end
            end
        end
    endtask

endmodule