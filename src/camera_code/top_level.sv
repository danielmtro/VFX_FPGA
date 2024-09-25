// File digital_cam_impl1/top_level.vhd translated with vhd2vl v3.0 VHDL to Verilog RTL translator
// vhd2vl settings:
//  * Verilog Module Declaration Style: 2001

// vhd2vl is Free (libre) Software:
//   Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd
//     http://www.ocean-logic.com
//   Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
//   Modifications (C) 2010 Shankar Giri
//   Modifications Copyright (C) 2002-2017 Larry Doolittle
//     http://doolittle.icarus.com/~larry/vhd2vl/
//   Modifications (C) 2017 Rodrigo A. Melo
//
//   vhd2vl comes with ABSOLUTELY NO WARRANTY.  Always check the resulting
//   Verilog for correctness, ideally with a formal verification tool.
//
//   You are welcome to redistribute vhd2vl under certain conditions.
//   See the license (GPLv2) file included with the source for details.

// The result of translation follows.  Its copyright status should be
// considered unchanged from the original VHDL.

// cristinel ababei; Jan.29.2015; CopyLeft (CL);
// code name: "digital cam implementation #1";
// project done using Quartus II 13.1 and tested on DE2-115;
//
// this design basically connects a CMOS camera (OV7670 module) to
// DE2-115 board; video frames are picked up from camera, buffered
// on the FPGA (using embedded RAM), and displayed on the VGA monitor,
// which is also connected to the board; clock signals generated
// inside FPGA using ALTPLL's that take as input the board's 50MHz signal
// from on-board oscillator; 
//
// this whole project is an adaptation of Mike Field's original implementation 
// that can be found here:
// http://hamsterworks.co.nz/mediawiki/index.php/OV7670_camera
// no timescale needed

module top_level(
	input wire clk_50,
	input wire [17:0]SW,
	output wire led_config_finished,
	output wire vga_hsync,
	output wire vga_vsync,
	output wire [7:0] vga_r,
	output wire [7:0] vga_g,
	output wire [7:0] vga_b,
	output wire vga_blank_N,
	output wire vga_sync_N,
	output wire vga_CLK,
	input wire ov7670_pclk,
	output wire ov7670_xclk,
	input wire ov7670_vsync,
	input wire ov7670_href,
	input wire [7:0] ov7670_data,
	output wire ov7670_sioc,
	inout wire ov7670_siod,
	output wire ov7670_pwdn,
	output wire ov7670_reset
);

	// DE2-115 board has an Altera Cyclone V E, which has ALTPLL's'
	
	wire btn_resend;
	assign btn_resend = SW[0];
	
	wire clk_50_camera;
	wire clk_25_vga;
	wire wren;
	wire resend;
	wire nBlank;
	wire vSync;
	wire [16:0] wraddress;
	wire [11:0] wrdata;
	logic [16:0] rdaddress;
	wire [11:0] rddata;
  logic [11:0] vga_data;
	wire [7:0] red; wire [7:0] green; wire [7:0] blue;
	wire activeArea;

  my_altpll Inst_vga_pll(
      .inclk0(clk_50),
    .c0(clk_50_camera),
    .c1(clk_25_vga));

  assign resend =  ~btn_resend;

  ov7670_controller Inst_ov7670_controller(
      .clk(clk_50_camera),
    .resend(resend),
    .config_finished(led_config_finished),
    .sioc(ov7670_sioc),
    .siod(ov7670_siod),
    .reset(ov7670_reset),
    .pwdn(ov7670_pwdn),
    .xclk(ov7670_xclk));

  ov7670_capture Inst_ov7670_capture(
      .pclk(ov7670_pclk),
    .vsync(ov7670_vsync),
    .href(ov7670_href),
    .d(ov7670_data),
    .addr(wraddress),
    .dout(wrdata),
    .we(wren));

  frame_buffer Inst_frame_buffer(
    .rdaddress(rdaddress),
    .rdclock(clk_25_vga),
    .q(rddata),
    .wrclock(ov7670_pclk),
    .wraddress(wraddress[16:0]),
    .data(wrdata),
    .wren(wren));



  reg vga_ready, vga_start, vga_end;  

  // create address generator
  address_generator ag0(
    .clk_25_vga(clk_25_vga),
    .resend(resend),
    .vga_ready(vga_ready),
    .vga_start_out(vga_start),
    .vga_end_out(vga_end),
    .rdaddress(rdaddress)
  );
	 
  vga_interface vgai0 (
			 .clk_clk(clk_25_vga),                                         //                                       clk.clk
			 .reset_reset_n(1'b1),                                   //                                     reset.reset_n
			 .video_scaler_0_avalon_scaler_sink_startofpacket(vga_start), //         video_scaler_0_avalon_scaler_sink.startofpacket
			 .video_scaler_0_avalon_scaler_sink_endofpacket(vga_end),   //                                          .endofpacket
			 .video_scaler_0_avalon_scaler_sink_valid(1'b1),         //                                          .valid
			.video_scaler_0_avalon_scaler_sink_ready(vga_ready),         //                                          .ready
		   .video_scaler_0_avalon_scaler_sink_data(rddata),          //                                          .data
			.video_vga_controller_0_external_interface_CLK(vga_CLK),   // video_vga_controller_0_external_interface.CLK
			.video_vga_controller_0_external_interface_HS(vga_hsync),    //                                          .HS
			.video_vga_controller_0_external_interface_VS(vga_vsync),    //                                          .VS
			.video_vga_controller_0_external_interface_BLANK(vga_blank_N), //                                          .BLANK
			.video_vga_controller_0_external_interface_SYNC(vga_sync_N),  //                                          .SYNC
		   .video_vga_controller_0_external_interface_R(vga_r),     //                                          .R
		   .video_vga_controller_0_external_interface_G(vga_g),     //                                          .G
		   .video_vga_controller_0_external_interface_B(vga_b)      //                                          .B
	);


endmodule
