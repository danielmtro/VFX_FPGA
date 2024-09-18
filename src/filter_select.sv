module filter_select(
	input logic				clk,
	
	input logic[11:0] 	data_in,
	output logic[11:0] 	data_out,
	
	input logic [2:0] filter_num,

	input logic[2:0]		freq_flag //accomodates for 4 flags


);
	enum logic [1:0] {
        COLOUR = 2'b00,
        BLUR = 2'b01,
        BRIGHTNESS = 2'b10,
        EDGES = 2'b11
    }state_type;

	logic [11:0] inv_data, blur_data, bri_data, edge_data;

	inversion_filter DUT (
		.clk(clk),
		.data_in(data_in),
		.data_out(inv_data),
		.freq_flag(freq_flag)
	 );
	 
	 always_comb begin
		
		case (filter_num) 
			COLOUR		: data_out = inv_data;
			BLUR			: data_out = blur_data;
			BRIGHTNESS 	: data_out = bri_data;
			EDGES			: data_out = edge_data;
			default		: data_out = data_in;
		
		
	 endcase
	end

endmodule 