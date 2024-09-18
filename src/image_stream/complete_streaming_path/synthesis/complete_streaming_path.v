// complete_streaming_path.v

// Generated using ACDS version 20.1 711

`timescale 1 ps / 1 ps
module complete_streaming_path (
		input  wire       clk_clk,       //   clk.clk
		input  wire       reset_reset_n, // reset.reset_n
		output wire       vga_CLK,       //   vga.CLK
		output wire       vga_HS,        //      .HS
		output wire       vga_VS,        //      .VS
		output wire       vga_BLANK,     //      .BLANK
		output wire       vga_SYNC,      //      .SYNC
		output wire [7:0] vga_R,         //      .R
		output wire [7:0] vga_G,         //      .G
		output wire [7:0] vga_B          //      .B
	);

	wire         static_data_0_avalon_streaming_source_valid;           // static_data_0:valid -> data_expander_0:valid_in
	wire  [11:0] static_data_0_avalon_streaming_source_data;            // static_data_0:data -> data_expander_0:data_in
	wire         static_data_0_avalon_streaming_source_ready;           // data_expander_0:ready_out -> static_data_0:ready
	wire         static_data_0_avalon_streaming_source_startofpacket;   // static_data_0:startofpacket -> data_expander_0:sop_in
	wire         static_data_0_avalon_streaming_source_endofpacket;     // static_data_0:endofpacket -> data_expander_0:eop_in
	wire         data_expander_0_avalon_streaming_source_valid;         // data_expander_0:valid_out -> video_vga_controller_0:valid
	wire  [29:0] data_expander_0_avalon_streaming_source_data;          // data_expander_0:data_out -> video_vga_controller_0:data
	wire         data_expander_0_avalon_streaming_source_ready;         // video_vga_controller_0:ready -> data_expander_0:ready_in
	wire         data_expander_0_avalon_streaming_source_startofpacket; // data_expander_0:sop_out -> video_vga_controller_0:startofpacket
	wire         data_expander_0_avalon_streaming_source_endofpacket;   // data_expander_0:eop_out -> video_vga_controller_0:endofpacket
	wire         video_pll_0_vga_clk_clk;                               // video_pll_0:vga_clk_clk -> [data_expander_0:clock_clk, rst_controller:clk, static_data_0:clk, video_vga_controller_0:clk]
	wire         rst_controller_reset_out_reset;                        // rst_controller:reset_out -> [data_expander_0:reset, static_data_0:reset, video_vga_controller_0:reset]
	wire         video_pll_0_reset_source_reset;                        // video_pll_0:reset_source_reset -> rst_controller:reset_in0
	wire         rst_controller_001_reset_out_reset;                    // rst_controller_001:reset_out -> video_pll_0:ref_reset_reset

	data_expander #(
		.INTIAL_DATA_WIDTH (12),
		.FINAL_DATA_WIDTH  (30)
	) data_expander_0 (
		.reset     (rst_controller_reset_out_reset),                        //                   reset.reset
		.data_in   (static_data_0_avalon_streaming_source_data),            //   avalon_streaming_sink.data
		.eop_in    (static_data_0_avalon_streaming_source_endofpacket),     //                        .endofpacket
		.sop_in    (static_data_0_avalon_streaming_source_startofpacket),   //                        .startofpacket
		.valid_in  (static_data_0_avalon_streaming_source_valid),           //                        .valid
		.ready_out (static_data_0_avalon_streaming_source_ready),           //                        .ready
		.data_out  (data_expander_0_avalon_streaming_source_data),          // avalon_streaming_source.data
		.eop_out   (data_expander_0_avalon_streaming_source_endofpacket),   //                        .endofpacket
		.sop_out   (data_expander_0_avalon_streaming_source_startofpacket), //                        .startofpacket
		.valid_out (data_expander_0_avalon_streaming_source_valid),         //                        .valid
		.ready_in  (data_expander_0_avalon_streaming_source_ready),         //                        .ready
		.clock_clk (video_pll_0_vga_clk_clk)                                //                   clock.clk
	);

	static_data_initialisation #(
		.NumPixels     (76800),
		.DATA_WIDTH    (12)
	) static_data_0 (
		.clk           (video_pll_0_vga_clk_clk),                             //                   clock.clk
		.reset         (rst_controller_reset_out_reset),                      //                   reset.reset
		.data          (static_data_0_avalon_streaming_source_data),          // avalon_streaming_source.data
		.endofpacket   (static_data_0_avalon_streaming_source_endofpacket),   //                        .endofpacket
		.ready         (static_data_0_avalon_streaming_source_ready),         //                        .ready
		.startofpacket (static_data_0_avalon_streaming_source_startofpacket), //                        .startofpacket
		.valid         (static_data_0_avalon_streaming_source_valid)          //                        .valid
	);

	complete_streaming_path_video_pll_0 video_pll_0 (
		.ref_clk_clk        (clk_clk),                            //      ref_clk.clk
		.ref_reset_reset    (rst_controller_001_reset_out_reset), //    ref_reset.reset
		.vga_clk_clk        (video_pll_0_vga_clk_clk),            //      vga_clk.clk
		.reset_source_reset (video_pll_0_reset_source_reset)      // reset_source.reset
	);

	complete_streaming_path_video_vga_controller_0 video_vga_controller_0 (
		.clk           (video_pll_0_vga_clk_clk),                               //                clk.clk
		.reset         (rst_controller_reset_out_reset),                        //              reset.reset
		.data          (data_expander_0_avalon_streaming_source_data),          //    avalon_vga_sink.data
		.startofpacket (data_expander_0_avalon_streaming_source_startofpacket), //                   .startofpacket
		.endofpacket   (data_expander_0_avalon_streaming_source_endofpacket),   //                   .endofpacket
		.valid         (data_expander_0_avalon_streaming_source_valid),         //                   .valid
		.ready         (data_expander_0_avalon_streaming_source_ready),         //                   .ready
		.VGA_CLK       (vga_CLK),                                               // external_interface.export
		.VGA_HS        (vga_HS),                                                //                   .export
		.VGA_VS        (vga_VS),                                                //                   .export
		.VGA_BLANK     (vga_BLANK),                                             //                   .export
		.VGA_SYNC      (vga_SYNC),                                              //                   .export
		.VGA_R         (vga_R),                                                 //                   .export
		.VGA_G         (vga_G),                                                 //                   .export
		.VGA_B         (vga_B)                                                  //                   .export
	);

	altera_reset_controller #(
		.NUM_RESET_INPUTS          (1),
		.OUTPUT_RESET_SYNC_EDGES   ("deassert"),
		.SYNC_DEPTH                (2),
		.RESET_REQUEST_PRESENT     (0),
		.RESET_REQ_WAIT_TIME       (1),
		.MIN_RST_ASSERTION_TIME    (3),
		.RESET_REQ_EARLY_DSRT_TIME (1),
		.USE_RESET_REQUEST_IN0     (0),
		.USE_RESET_REQUEST_IN1     (0),
		.USE_RESET_REQUEST_IN2     (0),
		.USE_RESET_REQUEST_IN3     (0),
		.USE_RESET_REQUEST_IN4     (0),
		.USE_RESET_REQUEST_IN5     (0),
		.USE_RESET_REQUEST_IN6     (0),
		.USE_RESET_REQUEST_IN7     (0),
		.USE_RESET_REQUEST_IN8     (0),
		.USE_RESET_REQUEST_IN9     (0),
		.USE_RESET_REQUEST_IN10    (0),
		.USE_RESET_REQUEST_IN11    (0),
		.USE_RESET_REQUEST_IN12    (0),
		.USE_RESET_REQUEST_IN13    (0),
		.USE_RESET_REQUEST_IN14    (0),
		.USE_RESET_REQUEST_IN15    (0),
		.ADAPT_RESET_REQUEST       (0)
	) rst_controller (
		.reset_in0      (video_pll_0_reset_source_reset), // reset_in0.reset
		.clk            (video_pll_0_vga_clk_clk),        //       clk.clk
		.reset_out      (rst_controller_reset_out_reset), // reset_out.reset
		.reset_req      (),                               // (terminated)
		.reset_req_in0  (1'b0),                           // (terminated)
		.reset_in1      (1'b0),                           // (terminated)
		.reset_req_in1  (1'b0),                           // (terminated)
		.reset_in2      (1'b0),                           // (terminated)
		.reset_req_in2  (1'b0),                           // (terminated)
		.reset_in3      (1'b0),                           // (terminated)
		.reset_req_in3  (1'b0),                           // (terminated)
		.reset_in4      (1'b0),                           // (terminated)
		.reset_req_in4  (1'b0),                           // (terminated)
		.reset_in5      (1'b0),                           // (terminated)
		.reset_req_in5  (1'b0),                           // (terminated)
		.reset_in6      (1'b0),                           // (terminated)
		.reset_req_in6  (1'b0),                           // (terminated)
		.reset_in7      (1'b0),                           // (terminated)
		.reset_req_in7  (1'b0),                           // (terminated)
		.reset_in8      (1'b0),                           // (terminated)
		.reset_req_in8  (1'b0),                           // (terminated)
		.reset_in9      (1'b0),                           // (terminated)
		.reset_req_in9  (1'b0),                           // (terminated)
		.reset_in10     (1'b0),                           // (terminated)
		.reset_req_in10 (1'b0),                           // (terminated)
		.reset_in11     (1'b0),                           // (terminated)
		.reset_req_in11 (1'b0),                           // (terminated)
		.reset_in12     (1'b0),                           // (terminated)
		.reset_req_in12 (1'b0),                           // (terminated)
		.reset_in13     (1'b0),                           // (terminated)
		.reset_req_in13 (1'b0),                           // (terminated)
		.reset_in14     (1'b0),                           // (terminated)
		.reset_req_in14 (1'b0),                           // (terminated)
		.reset_in15     (1'b0),                           // (terminated)
		.reset_req_in15 (1'b0)                            // (terminated)
	);

	altera_reset_controller #(
		.NUM_RESET_INPUTS          (1),
		.OUTPUT_RESET_SYNC_EDGES   ("deassert"),
		.SYNC_DEPTH                (2),
		.RESET_REQUEST_PRESENT     (0),
		.RESET_REQ_WAIT_TIME       (1),
		.MIN_RST_ASSERTION_TIME    (3),
		.RESET_REQ_EARLY_DSRT_TIME (1),
		.USE_RESET_REQUEST_IN0     (0),
		.USE_RESET_REQUEST_IN1     (0),
		.USE_RESET_REQUEST_IN2     (0),
		.USE_RESET_REQUEST_IN3     (0),
		.USE_RESET_REQUEST_IN4     (0),
		.USE_RESET_REQUEST_IN5     (0),
		.USE_RESET_REQUEST_IN6     (0),
		.USE_RESET_REQUEST_IN7     (0),
		.USE_RESET_REQUEST_IN8     (0),
		.USE_RESET_REQUEST_IN9     (0),
		.USE_RESET_REQUEST_IN10    (0),
		.USE_RESET_REQUEST_IN11    (0),
		.USE_RESET_REQUEST_IN12    (0),
		.USE_RESET_REQUEST_IN13    (0),
		.USE_RESET_REQUEST_IN14    (0),
		.USE_RESET_REQUEST_IN15    (0),
		.ADAPT_RESET_REQUEST       (0)
	) rst_controller_001 (
		.reset_in0      (~reset_reset_n),                     // reset_in0.reset
		.clk            (clk_clk),                            //       clk.clk
		.reset_out      (rst_controller_001_reset_out_reset), // reset_out.reset
		.reset_req      (),                                   // (terminated)
		.reset_req_in0  (1'b0),                               // (terminated)
		.reset_in1      (1'b0),                               // (terminated)
		.reset_req_in1  (1'b0),                               // (terminated)
		.reset_in2      (1'b0),                               // (terminated)
		.reset_req_in2  (1'b0),                               // (terminated)
		.reset_in3      (1'b0),                               // (terminated)
		.reset_req_in3  (1'b0),                               // (terminated)
		.reset_in4      (1'b0),                               // (terminated)
		.reset_req_in4  (1'b0),                               // (terminated)
		.reset_in5      (1'b0),                               // (terminated)
		.reset_req_in5  (1'b0),                               // (terminated)
		.reset_in6      (1'b0),                               // (terminated)
		.reset_req_in6  (1'b0),                               // (terminated)
		.reset_in7      (1'b0),                               // (terminated)
		.reset_req_in7  (1'b0),                               // (terminated)
		.reset_in8      (1'b0),                               // (terminated)
		.reset_req_in8  (1'b0),                               // (terminated)
		.reset_in9      (1'b0),                               // (terminated)
		.reset_req_in9  (1'b0),                               // (terminated)
		.reset_in10     (1'b0),                               // (terminated)
		.reset_req_in10 (1'b0),                               // (terminated)
		.reset_in11     (1'b0),                               // (terminated)
		.reset_req_in11 (1'b0),                               // (terminated)
		.reset_in12     (1'b0),                               // (terminated)
		.reset_req_in12 (1'b0),                               // (terminated)
		.reset_in13     (1'b0),                               // (terminated)
		.reset_req_in13 (1'b0),                               // (terminated)
		.reset_in14     (1'b0),                               // (terminated)
		.reset_req_in14 (1'b0),                               // (terminated)
		.reset_in15     (1'b0),                               // (terminated)
		.reset_req_in15 (1'b0)                                // (terminated)
	);

endmodule
