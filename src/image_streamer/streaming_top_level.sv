module streaming_top_level(
	input wire CLOCK_50,
	input wire SW0,
	input wire SW1,
	
		output wire        VGA_CLK,    
		output wire        VGA_HS,     
		output wire        VGA_VS,     
		output wire        VGA_BLANK,  
		output wire        VGA_SYNC,   
		output wire [7:0]  VGA_R,        
		output wire [7:0]  VGA_G,        
		output wire [7:0]  VGA_B 
);

    logic [11:0] im_data;
	 logic [29:0] vga_data;
    logic        image_startofpacket;
    logic        image_endofpacket;
	 logic			image_valid;
	 logic        vga_valid;
	 logic 			vga_startofpacket;
	 logic			vga_endofpacket;
    logic        valid;
	
expansion_pack (
		.clk_clk(CLOCK_50),       //   clk.clk
		.reset_reset_n(0), // reset.reset_n
		.vga_CLK(VGA_CLK),       //   vga.CLK
		.vga_HS(VGA_HS),        //      .HS
		.vga_VS(VGA_VS),        //      .VS
		.vga_BLANK(VGA_BLANK),     //      .BLANK
		.vga_SYNC(VGA_SYNC),      //      .SYNC
		.vga_R(VGA_R),         //      .R
		.vga_G(VGA_G),         //      .G
		.vga_B(VGA_B)          //      .B
	);

endmodule 