`timescale 1ns / 1ps

module blurring_filter_tb;

    // Parameters
    localparam IMG_SIZE = 10; // 10x10 image

    // Inputs
    reg clk;
    reg [2:0] freq_flag; // Kernel size control
    reg [11:0] data_in;

    // Outputs
    wire [11:0] data_out;

    // Instantiate the blurring filter
    blurring_filter #(
        .DATA_WIDTH(12)
    ) uut (
        .clk(clk),
        .freq_flag(freq_flag),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Clock generation
    always begin
        #5 clk = ~clk; // 100 MHz clock
    end

    // Testbench logic
    initial begin
        // Initialize
        clk = 0;
        freq_flag = 3'b000; // Start with 1x1 kernel
        data_in = 0;

        // Load 10x10 image
        reg [11:0] image [0:IMG_SIZE*IMG_SIZE-1]; // 10x10 image
        integer i;
        integer j;

        // Initialize image with some values (e.g., a gradient or pattern)
        for (i = 0; i < IMG_SIZE; i = i + 1) begin
            for (j = 0; j < IMG_SIZE; j = j + 1) begin
                image[i*IMG_SIZE + j] = i*IMG_SIZE + j; // Just an example pattern
            end
        end

        // Apply 1x1 convolution kernel and check results
        $display("Testing with 1x1 kernel");
        freq_flag = 3'b000; // Set to 1x1 kernel
        for (i = 0; i < IMG_SIZE; i = i + 1) begin
            for (j = 0; j < IMG_SIZE; j = j + 1) begin
                data_in = image[i*IMG_SIZE + j];
                #10; // Wait for processing
                if (data_out !== image[i*IMG_SIZE + j]) begin
                    $display("Error: Expected %d, but got %d at (%d,%d)", 
                            image[i*IMG_SIZE + j], data_out, i, j);
                end
            end
        end

        // Change kernel size to 3x3 and apply convolution again
        freq_flag = 3'b010; // Set to 3x3 kernel
        $display("Testing with 3x3 kernel");
        for (i = 1; i < IMG_SIZE-1; i = i + 1) begin
            for (j = 1; j < IMG_SIZE-1; j = j + 1) begin
                data_in = image[i*IMG_SIZE + j];
                #10; // Wait for processing
            end
        end

        // Change kernel size to 5x5 and apply convolution again
        freq_flag = 3'b100; // Set to 5x5 kernel
        $display("Testing with 5x5 kernel");
        for (i = 2; i < IMG_SIZE-2; i = i + 1) begin
            for (j = 2; j < IMG_SIZE-2; j = j + 1) begin
                data_in = image[i*IMG_SIZE + j];
                #10; // Wait for processing
            end
        end

        // Change kernel size to 7x7 and apply convolution again
        freq_flag = 3'b011; // Set to 7x7 kernel
        $display("Testing with 7x7 kernel");
        for (i = 3; i < IMG_SIZE-3; i = i + 1) begin
            for (j = 3; j < IMG_SIZE-3; j = j + 1) begin
                data_in = image[i*IMG_SIZE + j];
                #10; // Wait for processing
            end
        end

        // Finish simulation
        #1000;
        $stop;
    end

endmodule
