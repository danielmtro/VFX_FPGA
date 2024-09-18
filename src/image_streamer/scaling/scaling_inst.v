	scaling u0 (
		.sauce_ready         (<connected-to-sauce_ready>),         // sauce.ready
		.sauce_startofpacket (<connected-to-sauce_startofpacket>), //      .startofpacket
		.sauce_endofpacket   (<connected-to-sauce_endofpacket>),   //      .endofpacket
		.sauce_valid         (<connected-to-sauce_valid>),         //      .valid
		.sauce_data          (<connected-to-sauce_data>),          //      .data
		.sauce_channel       (<connected-to-sauce_channel>),       //      .channel
		.sink_startofpacket  (<connected-to-sink_startofpacket>),  //  sink.startofpacket
		.sink_endofpacket    (<connected-to-sink_endofpacket>),    //      .endofpacket
		.sink_valid          (<connected-to-sink_valid>),          //      .valid
		.sink_ready          (<connected-to-sink_ready>),          //      .ready
		.sink_data           (<connected-to-sink_data>),           //      .data
		.reset_reset         (<connected-to-reset_reset>),         // reset.reset
		.clk_clk             (<connected-to-clk_clk>)              //   clk.clk
	);

