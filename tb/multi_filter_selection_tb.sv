`timescale 1ns/1ps

module multi_filter_selection_tb;

    // Inputs to the DUT (Device Under Test)
    reg clk;
    reg [1:0] state; 

    wire pixel_in;

    // Outputs from the DUT
    reg pixel_out;



    // Instantiate the rng module with specific parameters
    // Note that we set the delay required by the debounce module here to 2 instead of 2500 (default)
    filter_fsm #(.DELAY_COUNTS(2)) fsm (
        .clk(clk),
        .state(state),
        .pixel_out(pixel_out));


    // iniate top level for the lcd control module
    multi_filter_selection dut(.clk(clk),
                  .state(state),
                  .pixel_out(pixel_out)
    );

    // Clock generation
    initial begin
        clk = 0;
		  
        filter_type = 2'b00;
        forever #10 clk = ~clk;  // 20ns clock period (50 MHz)
    end

    // Initial conditions and stimulus
    initial begin
        // Dump the waveform to a VCD file
        $dumpfile("waveform.vcd");
        $dumpvars();

		  
        // wait 50 cycles at the start
        #80;

        // press the 1 button should cause a change in the level
        // wait more than 20 clock cycles so that debounce kicks in
        state = 2'b00;
        $display("Current pixel out is %d", pixel_out);
        $display("Current filter is %d", state);

        #300;

		#80;
        state = 2'b01;
        $display("Current pixel out is %d", pixel_out);
        $display("Current filter is %d", state);
        
        #300;

		#80;
        state = 2'b11;
        $display("Current pixel out is %d", pixel_out);
        $display("Current filter is %d", state);


        #80;
        state = 2'b10;
        $display("Current pixel out is %d", pixel_out);
        $display("Current filter is %d", state);

        #300;
        // Run the simulation for a specified time
        #150 $finish();
    end

endmodule