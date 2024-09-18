// scaling_path.v

// Generated using ACDS version 20.1 711

`timescale 1 ps / 1 ps
module scaling_path (
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

	wire         artificial_video_streaming_0_avalon_streaming_source_valid;         // artificial_video_streaming_0:valid -> video_scaler_0:stream_in_valid
	wire  [11:0] artificial_video_streaming_0_avalon_streaming_source_data;          // artificial_video_streaming_0:data -> video_scaler_0:stream_in_data
	wire         artificial_video_streaming_0_avalon_streaming_source_ready;         // video_scaler_0:stream_in_ready -> artificial_video_streaming_0:ready
	wire         artificial_video_streaming_0_avalon_streaming_source_startofpacket; // artificial_video_streaming_0:startofpacket -> video_scaler_0:stream_in_startofpacket
	wire         artificial_video_streaming_0_avalon_streaming_source_endofpacket;   // artificial_video_streaming_0:endofpacket -> video_scaler_0:stream_in_endofpacket
	wire         video_data_expander_0_avalon_streaming_source_valid;                // video_data_expander_0:valid -> video_vga_controller_0:valid
	wire  [29:0] video_data_expander_0_avalon_streaming_source_data;                 // video_data_expander_0:data -> video_vga_controller_0:data
	wire         video_data_expander_0_avalon_streaming_source_ready;                // video_vga_controller_0:ready -> video_data_expander_0:ready
	wire         video_data_expander_0_avalon_streaming_source_startofpacket;        // video_data_expander_0:startofpacket -> video_vga_controller_0:startofpacket
	wire         video_data_expander_0_avalon_streaming_source_endofpacket;          // video_data_expander_0:endofpacket -> video_vga_controller_0:endofpacket
	wire         video_pll_0_vga_clk_clk;                                            // video_pll_0:vga_clk_clk -> [artificial_video_streaming_0:clk, avalon_st_adapter:in_clk_0_clk, rst_controller:clk, video_data_expander_0:clk, video_scaler_0:clk, video_vga_controller_0:clk]
	wire         video_scaler_0_avalon_scaler_source_valid;                          // video_scaler_0:stream_out_valid -> avalon_st_adapter:in_0_valid
	wire  [11:0] video_scaler_0_avalon_scaler_source_data;                           // video_scaler_0:stream_out_data -> avalon_st_adapter:in_0_data
	wire         video_scaler_0_avalon_scaler_source_ready;                          // avalon_st_adapter:in_0_ready -> video_scaler_0:stream_out_ready
	wire   [1:0] video_scaler_0_avalon_scaler_source_channel;                        // video_scaler_0:stream_out_channel -> avalon_st_adapter:in_0_channel
	wire         video_scaler_0_avalon_scaler_source_startofpacket;                  // video_scaler_0:stream_out_startofpacket -> avalon_st_adapter:in_0_startofpacket
	wire         video_scaler_0_avalon_scaler_source_endofpacket;                    // video_scaler_0:stream_out_endofpacket -> avalon_st_adapter:in_0_endofpacket
	wire         avalon_st_adapter_out_0_valid;                                      // avalon_st_adapter:out_0_valid -> video_data_expander_0:valid_in
	wire  [11:0] avalon_st_adapter_out_0_data;                                       // avalon_st_adapter:out_0_data -> video_data_expander_0:data_in
	wire         avalon_st_adapter_out_0_startofpacket;                              // avalon_st_adapter:out_0_startofpacket -> video_data_expander_0:sop_in
	wire         avalon_st_adapter_out_0_endofpacket;                                // avalon_st_adapter:out_0_endofpacket -> video_data_expander_0:eop_in
	wire         rst_controller_reset_out_reset;                                     // rst_controller:reset_out -> [artificial_video_streaming_0:reset, avalon_st_adapter:in_rst_0_reset, video_data_expander_0:reset, video_scaler_0:reset, video_vga_controller_0:reset]
	wire         video_pll_0_reset_source_reset;                                     // video_pll_0:reset_source_reset -> rst_controller:reset_in0
	wire         rst_controller_001_reset_out_reset;                                 // rst_controller_001:reset_out -> video_pll_0:ref_reset_reset

	artificial_video_streaming #(
		.NumPixels     (76800),
		.NumColourBits (12)
	) artificial_video_streaming_0 (
		.clk           (video_pll_0_vga_clk_clk),                                            //                   clock.clk
		.reset         (rst_controller_reset_out_reset),                                     //                   reset.reset
		.data          (artificial_video_streaming_0_avalon_streaming_source_data),          // avalon_streaming_source.data
		.endofpacket   (artificial_video_streaming_0_avalon_streaming_source_endofpacket),   //                        .endofpacket
		.ready         (artificial_video_streaming_0_avalon_streaming_source_ready),         //                        .ready
		.startofpacket (artificial_video_streaming_0_avalon_streaming_source_startofpacket), //                        .startofpacket
		.valid         (artificial_video_streaming_0_avalon_streaming_source_valid)          //                        .valid
	);

	video_data_expander #(
		.NumPixels     (76800),
		.NumColourBits (12)
	) video_data_expander_0 (
		.clk           (video_pll_0_vga_clk_clk),                                     //                   clock.clk
		.reset         (rst_controller_reset_out_reset),                              //                   reset.reset
		.data_in       (avalon_st_adapter_out_0_data),                                //   avalon_streaming_sink.data
		.eop_in        (avalon_st_adapter_out_0_endofpacket),                         //                        .endofpacket
		.sop_in        (avalon_st_adapter_out_0_startofpacket),                       //                        .startofpacket
		.valid_in      (avalon_st_adapter_out_0_valid),                               //                        .valid
		.data          (video_data_expander_0_avalon_streaming_source_data),          // avalon_streaming_source.data
		.endofpacket   (video_data_expander_0_avalon_streaming_source_endofpacket),   //                        .endofpacket
		.ready         (video_data_expander_0_avalon_streaming_source_ready),         //                        .ready
		.startofpacket (video_data_expander_0_avalon_streaming_source_startofpacket), //                        .startofpacket
		.valid         (video_data_expander_0_avalon_streaming_source_valid)          //                        .valid
	);

	scaling_path_video_pll_0 video_pll_0 (
		.ref_clk_clk        (clk_clk),                            //      ref_clk.clk
		.ref_reset_reset    (rst_controller_001_reset_out_reset), //    ref_reset.reset
		.vga_clk_clk        (video_pll_0_vga_clk_clk),            //      vga_clk.clk
		.reset_source_reset (video_pll_0_reset_source_reset)      // reset_source.reset
	);

	scaling_path_video_scaler_0 video_scaler_0 (
		.clk                      (video_pll_0_vga_clk_clk),                                            //                  clk.clk
		.reset                    (rst_controller_reset_out_reset),                                     //                reset.reset
		.stream_in_startofpacket  (artificial_video_streaming_0_avalon_streaming_source_startofpacket), //   avalon_scaler_sink.startofpacket
		.stream_in_endofpacket    (artificial_video_streaming_0_avalon_streaming_source_endofpacket),   //                     .endofpacket
		.stream_in_valid          (artificial_video_streaming_0_avalon_streaming_source_valid),         //                     .valid
		.stream_in_ready          (artificial_video_streaming_0_avalon_streaming_source_ready),         //                     .ready
		.stream_in_data           (artificial_video_streaming_0_avalon_streaming_source_data),          //                     .data
		.stream_out_ready         (video_scaler_0_avalon_scaler_source_ready),                          // avalon_scaler_source.ready
		.stream_out_startofpacket (video_scaler_0_avalon_scaler_source_startofpacket),                  //                     .startofpacket
		.stream_out_endofpacket   (video_scaler_0_avalon_scaler_source_endofpacket),                    //                     .endofpacket
		.stream_out_valid         (video_scaler_0_avalon_scaler_source_valid),                          //                     .valid
		.stream_out_data          (video_scaler_0_avalon_scaler_source_data),                           //                     .data
		.stream_out_channel       (video_scaler_0_avalon_scaler_source_channel)                         //                     .channel
	);

	scaling_path_video_vga_controller_0 video_vga_controller_0 (
		.clk           (video_pll_0_vga_clk_clk),                                     //                clk.clk
		.reset         (rst_controller_reset_out_reset),                              //              reset.reset
		.data          (video_data_expander_0_avalon_streaming_source_data),          //    avalon_vga_sink.data
		.startofpacket (video_data_expander_0_avalon_streaming_source_startofpacket), //                   .startofpacket
		.endofpacket   (video_data_expander_0_avalon_streaming_source_endofpacket),   //                   .endofpacket
		.valid         (video_data_expander_0_avalon_streaming_source_valid),         //                   .valid
		.ready         (video_data_expander_0_avalon_streaming_source_ready),         //                   .ready
		.VGA_CLK       (vga_CLK),                                                     // external_interface.export
		.VGA_HS        (vga_HS),                                                      //                   .export
		.VGA_VS        (vga_VS),                                                      //                   .export
		.VGA_BLANK     (vga_BLANK),                                                   //                   .export
		.VGA_SYNC      (vga_SYNC),                                                    //                   .export
		.VGA_R         (vga_R),                                                       //                   .export
		.VGA_G         (vga_G),                                                       //                   .export
		.VGA_B         (vga_B)                                                        //                   .export
	);

	scaling_path_avalon_st_adapter #(
		.inBitsPerSymbol (4),
		.inUsePackets    (1),
		.inDataWidth     (12),
		.inChannelWidth  (2),
		.inErrorWidth    (0),
		.inUseEmptyPort  (0),
		.inUseValid      (1),
		.inUseReady      (1),
		.inReadyLatency  (0),
		.outDataWidth    (12),
		.outChannelWidth (0),
		.outErrorWidth   (0),
		.outUseEmptyPort (0),
		.outUseValid     (1),
		.outUseReady     (0),
		.outReadyLatency (0)
	) avalon_st_adapter (
		.in_clk_0_clk        (video_pll_0_vga_clk_clk),                           // in_clk_0.clk
		.in_rst_0_reset      (rst_controller_reset_out_reset),                    // in_rst_0.reset
		.in_0_data           (video_scaler_0_avalon_scaler_source_data),          //     in_0.data
		.in_0_valid          (video_scaler_0_avalon_scaler_source_valid),         //         .valid
		.in_0_ready          (video_scaler_0_avalon_scaler_source_ready),         //         .ready
		.in_0_startofpacket  (video_scaler_0_avalon_scaler_source_startofpacket), //         .startofpacket
		.in_0_endofpacket    (video_scaler_0_avalon_scaler_source_endofpacket),   //         .endofpacket
		.in_0_channel        (video_scaler_0_avalon_scaler_source_channel),       //         .channel
		.out_0_data          (avalon_st_adapter_out_0_data),                      //    out_0.data
		.out_0_valid         (avalon_st_adapter_out_0_valid),                     //         .valid
		.out_0_startofpacket (avalon_st_adapter_out_0_startofpacket),             //         .startofpacket
		.out_0_endofpacket   (avalon_st_adapter_out_0_endofpacket)                //         .endofpacket
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
