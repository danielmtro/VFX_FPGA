/*
Needs to be modified to take in 12 bit data. But I don't have a hex file of that for now
*/

module inversion_filter (
	input logic				clk,
	
	input logic[11:0] 	data_in,
	output logic[11:0] 	data_out,

	input logic[2:0]		freq_flag //accomodates for 4 flags
	

);

	logic[3:0] red, green, blue;
	logic[3:0] red_inv, green_inv, blue_inv;
	
	always_comb begin
		red 	= data_in[11:8];
		green = data_in[7:4];
		blue  = data_in[3:0];
	end 
	
	always_comb begin
		red_inv 		= 4'b1111 - red;
		green_inv 	= 4'b1111 - green;
		blue_inv 	= 4'b1111 - blue;
	end 
	
	always_comb begin
		data_out = {red, green, blue};
		if (freq_flag > 1) begin
			data_out = {red_inv, green_inv, blue_inv};
		end
	end
	
endmodule 