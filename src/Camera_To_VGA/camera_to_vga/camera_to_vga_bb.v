
module camera_to_vga (
	reset_reset_n,
	clk_clk,
	rdaddress_writebyteenable_n,
	data_in_beginbursttransfer,
	vga_CLK,
	vga_HS,
	vga_VS,
	vga_BLANK,
	vga_SYNC,
	vga_R,
	vga_G,
	vga_B);	

	input		reset_reset_n;
	input		clk_clk;
	output	[16:0]	rdaddress_writebyteenable_n;
	input	[11:0]	data_in_beginbursttransfer;
	output		vga_CLK;
	output		vga_HS;
	output		vga_VS;
	output		vga_BLANK;
	output		vga_SYNC;
	output	[7:0]	vga_R;
	output	[7:0]	vga_G;
	output	[7:0]	vga_B;
endmodule
