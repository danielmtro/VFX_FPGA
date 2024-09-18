
module scaling (
	sauce_ready,
	sauce_startofpacket,
	sauce_endofpacket,
	sauce_valid,
	sauce_data,
	sauce_channel,
	sink_startofpacket,
	sink_endofpacket,
	sink_valid,
	sink_ready,
	sink_data,
	reset_reset,
	clk_clk);	

	input		sauce_ready;
	output		sauce_startofpacket;
	output		sauce_endofpacket;
	output		sauce_valid;
	output	[11:0]	sauce_data;
	output	[1:0]	sauce_channel;
	input		sink_startofpacket;
	input		sink_endofpacket;
	input		sink_valid;
	output		sink_ready;
	input	[11:0]	sink_data;
	input		reset_reset;
	input		clk_clk;
endmodule
