/*
THIS MODULE IS TO BE USED AS A INTEGRATION TEST ON THE BOARD ITSELF

This module integrates both the filter fsm and the lcd display.
It takes in the key, clock and relevant LCD outputs.

This can be used as a top level to verify that lcd_top_level 
is working as intended on the board
*/

`timescale 1 ps / 1 ps
module lcd_state_machine_integration(
    input       [3:0] KEY,
    input  wire       CLOCK2_50,         //                clk.clk
    inout  wire [7:0] LCD_DATA,    // external_interface.DATA
    output wire       LCD_ON,      //                   .ON
    output wire       LCD_BLON,    //                   .BLON
    output wire       LCD_EN,      //                   .EN
    output wire       LCD_RS,      //                   .RS
    output wire       LCD_RW,      //                   .RW
    output wire [17:0] LEDR
);

    logic [1:0] filter_type;
    filter_fsm(.clk(CLOCK2_50), 
               .key(KEY),
               .filter_type(filter_type));
    
    // view the current state on the LED's
	assign LEDR[0] = filter_type[0];
	assign LEDR[1] = filter_type[1];

    // iniate top level for the lcd control module
    lcd_top_level(.clk(CLOCK2_50),
                  .current_state(filter_type),
                  .LCD_DATA    (LCD_DATA),    // external_interface.export
                  .LCD_ON      (LCD_ON),      //                   .export
                  .LCD_BLON    (LCD_BLON),    //                   .export
                  .LCD_EN      (LCD_EN),      //                   .export
                  .LCD_RS      (LCD_RS),      //                   .export
                  .LCD_RW      (LCD_RW)       //                   .export)
    );


endmodule