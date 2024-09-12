/*
This module acts as a pseudo top level for LCD control.
We are still taking in a current state and the clock so not really.

Current filter type passes into this module and it controls the input on the LCD
screen. 

All inputs that are in CAPS should just be wired to a board output directly
*/

`timescale 1 ps / 1 ps
module lcd_top_level (
      input  [1:0]		current_state,
		input  wire       clk,         //                clk.clk
		inout  wire [7:0] LCD_DATA,    // external_interface.DATA
		output wire       LCD_ON,      //                   .ON
		output wire       LCD_BLON,    //                   .BLON
		output wire       LCD_EN,      //                   .EN
		output wire       LCD_RS,      //                   .RS
		output wire       LCD_RW      //                   .RW
	);
	 

	// These variables will be used by the overall LCD control

	logic       address;     //   avalon_lcd_slave.address
	logic       chipselect;  //                   .chipselect
	logic       read;        //                   .read
	logic       write;       //                   .write
	logic [7:0] writedata;   //                   .writedata
	logic [7:0] readdata;    //                   .readdata
	logic       waitrequest; //                   .waitrequest


    // Create unique variables for each possible LCD display that we have
	logic  [3:0]  address_i; 
	logic  [3:0] chipselect_i;
	logic  [3:0]  read_i;
	logic  [3:0] write_i;

	// The data for each possible LCD display
    logic [7:0] writedata0;
    logic [7:0] writedata1;
    logic [7:0] writedata2;
    logic [7:0] writedata3;

	// Create an edge detection block for new states.
	// If we enter a new state then we want to reset before continuing.

    logic [1:0] state_q0 = 2'b11, state_q1 = 2'b11;
    // store the current state in a flip flop 
    always_ff @(posedge clk) begin

        // double buffer to make reset last 2 clock cycles instead of 1
        state_q0 <= current_state;
        state_q1 <= state_q0;
    end
    assign new_state = (state_q1 != current_state);


	// Initialise colour module
	COLOUR_lcd c_lcd (
		 .clk(clk),
		 .reset(new_state),
		 .address(address_i[0]),
		 .chipselect(chipselect_i[0]),
		 .byteenable(),
		 .read(),
		 .write(write_i[0]),
		 .waitrequest(waitrequest),
		 .readdata(),
		 .response(),
		 .writedata(writedata0)
	);

	// Initialise blur module
    BLUR_lcd  b_lcd (
		 .clk(clk),
		 .reset(new_state),
		 .address(address_i[1]),
		 .chipselect(chipselect_i[1]),
		 .byteenable(),
		 .read(),
		 .write(write_i[1]),
		 .waitrequest(waitrequest),
		 .readdata(),
		 .response(),
		 .writedata(writedata1)
    );
	 
	 // Initialise brightness module
	BRIGHTNESS_lcd br_lcd (
		 .clk(clk),
		 .reset(new_state),
		 .address(address_i[2]),
		 .chipselect(chipselect_i[2]),
		 .byteenable(),
		 .read(),
		 .write(write_i[2]),
		 .waitrequest(waitrequest),
		 .readdata(),
		 .response(),
		 .writedata(writedata2)
    );
	 
	// Initialise edge detection module
	EDGE_DETECT_lcd e_lcd (
		 .clk(clk),
		 .reset(new_state),
		 .address(address_i[3]),
		 .chipselect(chipselect_i[3]),
		 .byteenable(),
		 .read(),
		 .write(write_i[3]),
		 .waitrequest(waitrequest),
		 .readdata(),
		 .response(),
		 .writedata(writedata3)
    );

	// combinatorial block that controls what are the actual controls
	// It varies depending on the current state of the system
    always_comb begin
        
        case(current_state)

            2'b00: begin
                write = write_i[0];
                chipselect = chipselect_i[0];
                address = address_i[0];
                writedata = writedata0;
            end

            2'b01: begin
                write = write_i[1];
                chipselect = chipselect_i[1];
                address = address_i[1];
                writedata = writedata1;
            end

            2'b10: begin
                write = write_i[2];
                chipselect = chipselect_i[2];
                address = address_i[2];
                writedata = writedata2;
            end

            2'b11: begin
                write = write_i[3];
                chipselect = chipselect_i[3];
                address = address_i[3];
                writedata = writedata3;
            end

			// default set it to the colour
			default: begin
				write = write_i[0];
				chipselect = chipselect_i[0];
				address = address_i[0];
				writedata = writedata0;
			end
        endcase
    end

	// actual control for the LCD works here (through some IP) 
	char_display u_char_display (
		.clk         (clk),         //                clk.clk
		.reset       (new_state),       //              reset.reset
		.address     (address),     //   avalon_lcd_slave.address
		.chipselect  (chipselect),  //                   .chipselect
		.read        (read),        //                   .read
		.write       (write),       //                   .write
		.writedata   (writedata),   //                   .writedata
		.readdata    (readdata),    //                   .readdata
		.waitrequest (waitrequest), //                   .waitrequest
		.LCD_DATA    (LCD_DATA),    // external_interface.export
		.LCD_ON      (LCD_ON),      //                   .export
		.LCD_BLON    (LCD_BLON),    //                   .export
		.LCD_EN      (LCD_EN),      //                   .export
		.LCD_RS      (LCD_RS),      //                   .export
		.LCD_RW      (LCD_RW)       //                   .export
	);

endmodule