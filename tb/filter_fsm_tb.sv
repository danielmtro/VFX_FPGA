`timescale 1ns/1ps

module filter_fsm_tb;

    // Inputs to the DUT (Device Under Test)
    reg clk;
    reg [3:0] key; 

    // Outputs from the DUT
    reg [1:0] filter_type;

    // Instantiate the rng module with specific parameters
    // Note that we set the delay required by the debounce module here to 2 instead of 2500 (default)
    filter_fsm #(.DELAY_COUNTS(2)) dut (
        .clk(clk),
        .key(key),
        .filter_type(filter_type));

    // Clock generation
    initial begin
        clk = 0;
		  key[0] = 0;
		  key[1] = 0;
		  key[2] = 0;
		  key[3] = 0;
		  
        filter_type = 2'b00;
        forever #10 clk = ~clk;  // 20ns clock period (50 MHz)
    end

    // Initial conditions and stimulus
    initial begin
        // Dump the waveform to a VCD file
        $dumpfile("waveform.vcd");
        $dumpvars();

        $display("Current filter type %d", filter_type);
		  
		  // wait 50 cycles at the start
		  #80;

        // press the 1 button should cause a change in the level
        // wait more than 20 clock cycles so that debounce kicks in
        key[1] = 1;
        #80;
        key[1] = 0;
        $display("Current filter type %d", filter_type);

		  #80;
        key[2] = 1;
        #80;
        key[2] = 0;
        $display("Current filter type %d", filter_type);
			
		  #80;
        key[3] = 1;
        #80;
        key[3] = 0;
        $display("Current filter type %d", filter_type);


        // Run the simulation for a specified time
        #150 $finish();
    end

endmodule