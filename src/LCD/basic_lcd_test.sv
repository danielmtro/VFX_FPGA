/*
Basic module used to verify the correctness of each LCD display module
The defualt used here is COLOUR lcd but it can be changed as desired
*/

`timescale 1 ps / 1 ps
module basic_lcd_test (
		input  wire       CLOCK_50,         //                clk.clk
		inout  wire [7:0] LCD_DATA,    // external_interface.DATA
		output wire       LCD_ON,      //                   .ON
		output wire       LCD_BLON,    //                   .BLON
		output wire       LCD_EN,      //                   .EN
		output wire       LCD_RS,      //                   .RS
		output wire       LCD_RW,      //                   .RW
		input  wire [3:0] KEY        //              reset.reset
	);
	 
	logic       address;     //   avalon_lcd_slave.address
	logic       chipselect;  //                   .chipselect
	logic       read;        //                   .read
	logic       write;       //                   .write
	logic [7:0] writedata;   //                   .writedata
	logic [7:0] readdata;    //                   .readdata
	logic       waitrequest; //                   .waitrequest
	
	
	COLOUR_lcd (
		 .clk(CLOCK_50),
		 .reset(~KEY[0]),
		 // Avalon-MM signals to LCD_Controller slave
		 .address(address),          // Address line for LCD controller
		 .chipselect(chipselect),
		 .byteenable(),
		 .read(),
		 .write(write),
		 .waitrequest(waitrequest),
		 .readdata(),
		 .response(),
		 .writedata(writedata)
	);

	char_display u_char_display (
		.clk         (CLOCK_50),         //                clk.clk
		.reset       (~KEY[0]),       //              reset.reset
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