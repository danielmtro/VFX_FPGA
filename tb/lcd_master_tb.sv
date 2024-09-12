`timescale 1ns/1ps

module lcd_master_tb;

    // Inputs to the DUT (Device Under Test)
    reg clk;
    reg [3:0] key; 

    wire [7:0] LCD_DATA; // external_interface.DATA
    wire       LCD_ON;  //                   .ON
    wire       LCD_BLON;   //                   .BLON
    wire       LCD_EN;   //                   .EN
    wire       LCD_RS;     //                   .RS
    wire       LCD_RW;      //                   .RW

    // Outputs from the DUT
    reg [1:0] filter_type;



    // Instantiate the rng module with specific parameters
    // Note that we set the delay required by the debounce module here to 2 instead of 2500 (default)
    filter_fsm #(.DELAY_COUNTS(2)) fsm (
        .clk(clk),
        .key(key),
        .filter_type(filter_type));


    // iniate top level for the lcd control module
    lcd_top_level dut(.clk(clk),
                  .current_state(filter_type),
                  .LCD_DATA    (LCD_DATA),    // external_interface.export
                  .LCD_ON      (LCD_ON),      //                   .export
                  .LCD_BLON    (LCD_BLON),    //                   .export
                  .LCD_EN      (LCD_EN),      //                   .export
                  .LCD_RS      (LCD_RS),      //                   .export
                  .LCD_RW      (LCD_RW)       //                   .export)
    );

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

		  
        // wait 50 cycles at the start
        #80;

        // press the 1 button should cause a change in the level
        // wait more than 20 clock cycles so that debounce kicks in
        key[1] = 1;
        #80;
        key[1] = 0;
        $display("Current filter type %d", filter_type);

        #300;

		#80;
        key[2] = 1;
        #80;
        key[2] = 0;
        $display("Current filter type %d", filter_type);
        
        #300;

		#80;
        key[3] = 1;
        #80;
        key[3] = 0;
        $display("Current filter type %d", filter_type);

        #300;
        // Run the simulation for a specified time
        #150 $finish();
    end

endmodule