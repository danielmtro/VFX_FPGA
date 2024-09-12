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
	 
	logic       address;     //   avalon_lcd_slave.address
	logic       chipselect;  //                   .chipselect
	logic       read;        //                   .read
	logic       write;       //                   .write
	logic [7:0] writedata;   //                   .writedata
	logic [7:0] readdata;    //                   .readdata
	logic       waitrequest; //                   .waitrequest


    // make sure that we don't reset whatever is on the boad

    // determine if we have a new state incoming

    // A 8 x 4 array for the different write data values stored
	logic [3:0]  address_i;     //   avalon_lcd_slave.address
	logic  [3:0] chipselect_i;  //                   .chipselect
	logic [3:0]  read_i;        //                   .read
	logic  [3:0] write_i;       //                   .write

    logic [7:0] writedata0;   //                   .writedata
    logic [7:0] writedata1;
    logic [7:0] writedata2;
    logic [7:0] writedata3;

    logic [1:0] state_q0 = 2'b11, state_q1 = 2'b11;
    // store the current state in a flip flop 
    always_ff @(posedge clk) begin

        // double buffer changes
        state_q0 <= current_state;
        state_q1 <= state_q0;
    end
    assign new_state = (state_q1 != current_state);


	COLOUR_lcd c_lcd (
		 .clk(clk),
		 .reset(new_state),
		 // Avalon-MM signals to LCD_Controller slave
		 .address(address_i[0]),          // Address line for LCD controller
		 .chipselect(chipselect_i[0]),
		 .byteenable(),
		 .read(),
		 .write(write_i[0]),
		 .waitrequest(waitrequest),
		 .readdata(),
		 .response(),
		 .writedata(writedata0)
	);

    BLUR_lcd  b_lcd (
		 .clk(clk),
		 .reset(new_state),
		 // Avalon-MM signals to LCD_Controller slave
		 .address(address_i[1]),          // Address line for LCD controller
		 .chipselect(chipselect_i[1]),
		 .byteenable(),
		 .read(),
		 .write(write_i[1]),
		 .waitrequest(waitrequest),
		 .readdata(),
		 .response(),
		 .writedata(writedata1)
    );
	 
	 BRIGHTNESS_lcd br_lcd (
		 .clk(clk),
		 .reset(new_state),
		 // Avalon-MM signals to LCD_Controller slave
		 .address(address_i[2]),          // Address line for LCD controller
		 .chipselect(chipselect_i[2]),
		 .byteenable(),
		 .read(),
		 .write(write_i[2]),
		 .waitrequest(waitrequest),
		 .readdata(),
		 .response(),
		 .writedata(writedata2)
    );
	 

	 EDGE_DETECT_lcd e_lcd (
		 .clk(clk),
		 .reset(new_state),
		 // Avalon-MM signals to LCD_Controller slave
		 .address(address_i[3]),          // Address line for LCD controller
		 .chipselect(chipselect_i[3]),
		 .byteenable(),
		 .read(),
		 .write(write_i[3]),
		 .waitrequest(waitrequest),
		 .readdata(),
		 .response(),
		 .writedata(writedata3)
    );


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