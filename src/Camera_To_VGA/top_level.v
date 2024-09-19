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
		input wire btn_resend,
		output wire led_config_finished,
		input wire ov7670_pclk,
		output wire ov7670_xclk,
		input wire ov7670_vsync,
		input wire ov7670_href,
		input wire [7:0] ov7670_data,
		output wire ov7670_sioc,
		inout wire ov7670_siod,
		output wire ov7670_pwdn,
		output wire ov7670_reset,

    // VGA signals
		output wire        VGA_CLK,    
		output wire        VGA_HS,     
		output wire        VGA_VS,     
		output wire        VGA_BLANK,  
		output wire        VGA_SYNC,   
		output wire [7:0]  VGA_R,        
		output wire [7:0]  VGA_G,        
		output wire [7:0]  VGA_B   
);


// DE2-115 board has an Altera Cyclone V E, which has ALTPLL's'
wire clk_50_camera;
assign clk_50_camera = clk_50;

wire clk_25_vga;
assign VGA_CLK = clk_25_vga;

wire wren;
wire resend;
wire nBlank;
wire vSync;
wire [16:0] wraddress;
wire [11:0] wrdata;
wire [16:0] rdaddress;
wire [11:0] rddata;
wire [7:0] red; wire [7:0] green; wire [7:0] blue;

  // take the inverted push button because KEY0 on DE2-115 board generates
  // a signal 111000111; with 1 with not pressed and 0 when pressed/pushed;
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


  // connect the outputs to rdaddress and connect the input clk_25_vga
  // connect the rddata correctly 
  
  camera_to_vga ctv0 (.data_in_beginbursttransfer(data_in),
							 .vga_clk_clk(clk_25_vga),
							 .rdaddress_writebyteenable_n(rdaddress),
							 .reset_reset_n(1'b1),
							 .vga_CLK(VGA_CLK),
							 .vga_HS(VGA_HS),
							 .vga_VS(VGA_VS),
							 .vga_BLANK(VGA_BLANK),
							 .vga_SYNC(VGA_SYNC),
							 .vga_R(VGA_R),
							 .vga_G(VGA_G),
							 .vga_B(VGA_B));
  



endmodule
