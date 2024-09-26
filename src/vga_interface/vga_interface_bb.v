
module vga_interface (
	clk_clk,
	reset_reset_n,
	video_scaler_0_avalon_scaler_sink_startofpacket,
	video_scaler_0_avalon_scaler_sink_endofpacket,
	video_scaler_0_avalon_scaler_sink_valid,
	video_scaler_0_avalon_scaler_sink_ready,
	video_scaler_0_avalon_scaler_sink_data,
	video_vga_controller_0_external_interface_CLK,
	video_vga_controller_0_external_interface_HS,
	video_vga_controller_0_external_interface_VS,
	video_vga_controller_0_external_interface_BLANK,
	video_vga_controller_0_external_interface_SYNC,
	video_vga_controller_0_external_interface_R,
	video_vga_controller_0_external_interface_G,
	video_vga_controller_0_external_interface_B);	

	input		clk_clk;
	input		reset_reset_n;
	input		video_scaler_0_avalon_scaler_sink_startofpacket;
	input		video_scaler_0_avalon_scaler_sink_endofpacket;
	input		video_scaler_0_avalon_scaler_sink_valid;
	output		video_scaler_0_avalon_scaler_sink_ready;
	input	[11:0]	video_scaler_0_avalon_scaler_sink_data;
	output		video_vga_controller_0_external_interface_CLK;
	output		video_vga_controller_0_external_interface_HS;
	output		video_vga_controller_0_external_interface_VS;
	output		video_vga_controller_0_external_interface_BLANK;
	output		video_vga_controller_0_external_interface_SYNC;
	output	[7:0]	video_vga_controller_0_external_interface_R;
	output	[7:0]	video_vga_controller_0_external_interface_G;
	output	[7:0]	video_vga_controller_0_external_interface_B;
endmodule
