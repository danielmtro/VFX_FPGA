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
    blurring_filter DUT (
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
    
    // Declare the file handle
    integer image_file_in, image_file_out;

    initial begin

        // Set variables to 0 to avoid red lines in testbench
        is_underage = 0;
        data_in = 0;
        ready_out = 0;
        data_out = 0;
			startofpacket_out = 0;
			endofpacket_out = 0;
/*
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
*/
        // Initialize image with a simple pattern (diamond with lines)
        for (i = 0; i < IMG_LENGTH; i = i + 1) begin
            for (j = 0; j < IMG_WIDTH; j = j + 1) begin

                // Base color for the image
                image[(i * IMG_WIDTH) + j] = 12'b010101101010; // Base colour (grey)


                // Add two lines to detect edges for
                if (((j > 9) && (j < 11)) || ((j > 209) && (j < 211))) begin
                    image[(i * IMG_WIDTH) + j] = 12'b000000000000; // Simple color (black)
                end

                // Make the diamond
                // Top half of the diamond
                if (i <= 120) begin
                    if ((j - 160) <= (i - 20)) begin
                        if ((j - 160) >= (20 - i)) begin
                            image[(i * IMG_WIDTH) + j] = 12'b111111111111;  // Diamond color (white)
                        end
                    end
                end

                // Bottom half of the diamond
                else begin
                    if ((j - 160) <= (220 - i)) begin
                        if ((j - 160) >= (i - 220)) begin
                            image[(i * IMG_WIDTH) + j] = 12'b111111111111;  // Diamond color (white)
                        end
                    end
                end
            end
        end

        // Open the file for input writing (in write mode)
        image_file_in = $fopen("input_image_data.txt", "w");
        if (image_file_in == 0) begin
            $display("Error opening file!");
            $finish; // Exit simulation if file opening fails
        end

        // Initialize the image data
        for (i = 0; i < IMG_LENGTH; i = i + 1) begin
            for (j = 0; j < IMG_WIDTH; j = j + 1) begin
                // Example: write the pixel data in binary format
                $fwrite(image_file_in, "%b\n", image[(i * IMG_WIDTH) + j]);
            end
        end

        // Close the file
        $fclose(image_file_in);

        // Open VCD file for waveform dumping
        $dumpfile("blurring_filter_tb.vcd");
        $dumpvars(0, blurring_filter_tb);
/*
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
*/
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

        // Open the file for output writing (in write mode)
        image_file_out = $fopen("output_image_data.txt", "w");
        if (image_file_out == 0) begin
            $display("Error opening file!");
            $finish; // Exit simulation if file opening fails
        end

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

                    /*// Test handshaking
                    if ((i % 10 == 0) || (j % 10 == 0)) begin
                        valid_in = 0;
                        #100
                        valid_in = 1;
                    end

                    if ((i % 15 == 0) || (j % 15 == 0)) begin
                        ready_in = 0;
                        #100
                        ready_in = 1;
                    end*/

                    // Example: write the pixel data in binary format
                    $fwrite(image_file_out, "%b\n", data_out);
                end
            end
        end

        // Close the file
        $fclose(image_file_out);

    endtask

endmodule