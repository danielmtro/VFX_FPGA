module top_level (
		input  wire        CLOCK_50,
		input  wire [17:0] SW,
		input logic 			 KEY[3:0],
		
		output wire        VGA_CLK,    
		output wire        VGA_HS,     
		output wire        VGA_VS,     
		output wire        VGA_BLANK,  
		output wire        VGA_SYNC,   
		output wire [7:0]  VGA_R,        
		output wire [7:0]  VGA_G,        
		output wire [7:0]  VGA_B         
);

logic reset;
assign reset = KEY[0];

scaler scaler_0 (
		.clk_clk(CLOCK_50),
		.filter_num_filter_num(SW[1:0]),
		.freq_flag_freq_flag(SW[17:16]),
		.reset_reset_n(reset),
		.vga_CLK(VGA_CLK),
		.vga_HS(VGA_HS),
		.vga_VS(VGA_VS),
		.vga_BLANK(VGA_BLANK),
		.vga_SYNC(VGA_SYNC),
		.vga_R(VGA_R),
		.vga_G(VGA_G),
		.vga_B(VGA_B)
);

endmodule 