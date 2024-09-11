`timescale 1ns/1ps

module filter_fsm_tb;

    // Inputs to the DUT (Device Under Test)
    reg clk;
    reg [3:0] key; 

    // Outputs from the DUT
    reg [1:0] filter_type;

    // Instantiate the rng module with specific parameters
    difficulty_fsm dut (
        .clk(clk),
        .key(key),
        .filter_type(filter_type));

    // Clock generation
    initial begin
        clk = 0;
		  increment = 0;
        level = 2'b00;
        forever #10 clk = ~clk;  // 20ns clock period (50 MHz)
    end

    // Initial conditions and stimulus
    initial begin
        // Dump the waveform to a VCD file
        $dumpfile("waveform.vcd");
        $dumpvars();

        // Run the simulation for a specified time
        #10 $finish();
    end

endmodule