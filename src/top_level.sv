// Overall Top Level Module For Everything

/*
INFORMATION

SW[0] CONTROLS RESETTING THE CAMERA DO THIS IF:
	- THE IMAGE IS GREEN
	- THE IMAGE LOOKS ANY WAY WRONG

KEY[0] - KEY[3] CHOOSES THE FILTER
*/
module top_level(
	input wire clk_50,
	
	// GENERAL IO
	input wire [3:0] KEY,
	input wire [17:0]SW, // for resetting the camera on SW[0]
	output wire led_config_finished, // LED To let us know if reset is running
	
	// VGA inputs and outputs
	output wire vga_hsync,
	output wire vga_vsync,
	output wire [7:0] vga_r,
	output wire [7:0] vga_g,
	output wire [7:0] vga_b,
	output wire vga_blank_N,
	output wire vga_sync_N,
	output wire vga_CLK,
	
	// Camera Inputs and Outputs
	input wire ov7670_pclk,
	output wire ov7670_xclk,
	input wire ov7670_vsync,
	input wire ov7670_href,
	input wire [7:0] ov7670_data,
	output wire ov7670_sioc,
	inout wire ov7670_siod,
	output wire ov7670_pwdn,
	output wire ov7670_reset,
	
	// LCD Inputs and Outputs
	inout  wire [7:0] LCD_DATA,    // external_interface.DATA
   output wire       LCD_ON,      //                   .ON
   output wire       LCD_BLON,    //                   .BLON
   output wire       LCD_EN,      //                   .EN
   output wire       LCD_RS,      //                   .RS
   output wire       LCD_RW      //                   .RW
);


	/*
	THE SECTION BELOW IS FOR THE STATE MACHINE AND LCD STUFF
	*/
	
	logic [1:0] filter_type;
	state_machine_with_display smwd_0(
    .KEY(KEY),
    .clk(clk_50),         //                Clock to be used
    .LCD_DATA(LCD_DATA),    // external_interface.DATA
    .LCD_ON(LCD_ON),      //                   .ON
    .LCD_BLON(LCD_BLON),    //                   .BLON
    .LCD_EN(LCD_EN),      //                   .EN
    .LCD_RS(LCD_RS),      //                   .RS
    .LCD_RW(LCD_RW),      //                   .RW
    .filter_type(filter_type)  // output the current state
	);
	
	/*
	THE SECTION BELOW IS FOR FFT STUFF
	*/

	/*
	THE SECTION BELOW IS FOR THE CAMERA VISION STUFF
	*/

	//dummy frequency flag until FFT included here
	logic [1:0] freq_flag = 2'b10;
	logic valid;
	assign valid = 1'b1;
	logic [11:0] filtered_data;
	logic filter_sop_out, filter_eop_out, filter_ready, filter_valid_out;

	filter_select fs0(
		.clk(clk_50),
		.reset(resend),
		.freq_flag(freq_flag),
		.filter_num(filter_type),
		.data_in(rddata),
		.sop_in(vga_start),
		.eop_in(vga_end),
		.valid_in(valid),
		
		//receiving back pressure from sink
		.ready_in(vga_ready),
		
		//put back pressure on previous module
		.ready_out(filter_ready),
		
		//source ports
		.data_out(filtered_data),
		.sop_out(filter_sop_out),
		.eop_out(filter_eop_out),
		.valid_out(filter_valid_out) //accomodates for 4 flags
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
    .vga_ready(filter_ready),
    .vga_start_out(vga_start),
    .vga_end_out(vga_end),
    .rdaddress(rdaddress)
  );
	 
  vga_interface vgai0 (
			 .clk_clk(clk_25_vga),                                         //                                       clk.clk
			 .reset_reset_n(1'b1),                                   //                                     reset.reset_n
			 .video_scaler_0_avalon_scaler_sink_startofpacket(filter_sop_out), //         video_scaler_0_avalon_scaler_sink.startofpacket
			 .video_scaler_0_avalon_scaler_sink_endofpacket(filter_eop_out),   //                                          .endofpacket
			 .video_scaler_0_avalon_scaler_sink_valid(filter_valid_out),         //                                          .valid
			.video_scaler_0_avalon_scaler_sink_ready(vga_ready),         //                                          .ready
		   .video_scaler_0_avalon_scaler_sink_data(filtered_data),          //                                          .data
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
