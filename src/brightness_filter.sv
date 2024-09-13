module brightness_filter (

	input logic 			clk,
	
	input  logic [11:0] 	data_in,
	output logic [11:0] 	data_out,
	
	input  logic [2:0] 	freq_flag
	
	);
	
	logic [3:0] red, green, blue;
	logic [3:0] red_br, green_br, blue_br;
	
	logic [3:0] MAX_VAL;
	assign MAX_VAL = 4'b1111;
	
	always_comb begin
		red 	= data_in[11:8];
		green = data_in[7:4];
		blue 	= data_in[3:0];
	end
	
	always_comb begin
		red_br 	= (red > (MAX_VAL / (freq_flag + 1))) ? MAX_VAL : (freq_flag + 1) * red;
		green_br = (green > (MAX_VAL / (freq_flag + 1))) ? MAX_VAL : (freq_flag + 1) * green;
		blue_br 	= (blue > (MAX_VAL / (freq_flag + 1))) ? MAX_VAL : (freq_flag + 1) * blue;
		
		
	end
	
	assign data_out = {red_br, green_br, blue_br};
	
endmodule 