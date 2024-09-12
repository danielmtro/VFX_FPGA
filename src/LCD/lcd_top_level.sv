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
	 
	wire       address;     //   avalon_lcd_slave.address
	wire       chipselect;  //                   .chipselect
	wire       read;        //                   .read
	wire       write;       //                   .write
	wire [7:0] writedata;   //                   .writedata
	wire [7:0] readdata;    //                   .readdata
	wire       waitrequest; //                   .waitrequest


    // make sure that we don't reset whatever is on the boad

    // determine if we have a new state incoming

    // A 8 x 4 array for the different write data values stored
    logic [7:0] writeDataArray [3:0];
    logic [3:0] writeArray;

    // variable to store the different value of addresse
    logic [3:0] addressArray;
	 
	 logic [1:0] state_q0;
	 
	 // store the current state in a flip flop 
	 always_ff @(posedge clk) begin
		state_q0 <= current_state;
	 end
	 assign new_state = (state_q0 != current_state);

	COLOUR_lcd (
		 .clk(clk),
		 .reset(new_state),
		 // Avalon-MM signals to LCD_Controller slave
		 .address(addressArray[0]),          // Address line for LCD controller
		 .chipselect(),
		 .byteenable(),
		 .read(),
		 .write(writeArray[0]),
		 .waitrequest(waitrequest),
		 .readdata(),
		 .response(),
		 .writedata(writeDataArray[0])
	);

	BLUR_lcd (
		 .clk(clk),
		 .reset(new_state),
		 // Avalon-MM signals to LCD_Controller slave
		 .address(addressArray[1]),          // Address line for LCD controller
		 .chipselect(),
		 .byteenable(),
		 .read(),
		 .write(writeArray[1]),
		 .waitrequest(waitrequest),
		 .readdata(),
		 .response(),
		 .writedata(writeDataArray[1])
	);

	BRIGHTNESS_lcd (
		 .clk(clk),
		 .reset(new_state),
		 // Avalon-MM signals to LCD_Controller slave
		 .address(addressArray[2]),          // Address line for LCD controller
		 .chipselect(),
		 .byteenable(),
		 .read(),
		 .write(writeArray[2]),
		 .waitrequest(waitrequest),
		 .readdata(),
		 .response(),
		 .writedata(writeDataArray[2])
	);

	EDGE_DETECT_lcd (
		 .clk(clk),
		 .reset(new_state),
		 // Avalon-MM signals to LCD_Controller slave
		 .address(addressArray[3]),          // Address line for LCD controller
		 .chipselect(),
		 .byteenable(),
		 .read(),
		 .write(writeArray[3]),
		 .waitrequest(waitrequest),
		 .readdata(),
		 .response(),
		 .writedata(writeDataArray[3])
	);


    always_ff @(posedge clk) begin
        
        case(current_state)

            2'b00: begin
                write <= writeArray[0];
                writedata <= writeDataArray[0];
                address <= addressArray[0];
            end

            2'b01: begin
                write <= writeArray[1];
                writedata <= writeDataArray[1];
                address <= addressArray[1]; 
            end

            2'b10: begin
                write <= writeArray[2];
                writedata <= writeDataArray[2];
                address <= addressArray[2];
            end

            2'b11: begin
                write <= writeArray[3];
                writedata <= writeDataArray[3];
                address <= addressArray[3];
            end

            // default set it to the colour
            default: begin
                write <= writeArray[0];
                writedata <= writeDataArray[0];
                address <= addressArray[0];
            end
        endcase
    end

    assign chipselect = write;
    assign byteenable = write;
    assign read = 1'b0;

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