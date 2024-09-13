module inversion_filter (
	input 			clk,
	
	input[11:0] 	data_in,
	output[11:0] 	data_out

);

	logic [3:0] red, green, blue;
	logic [3:0] red_inv, green_inv, blue_inv;
	
	always_ff @(posedge clk) begin
		red 	<= data_in[11:8];
		green <= data_in[7:4];
		blue  <= data_in[3:0];
	end 
	
	always_comb begin
		red_inv 		= 4'b1111 - red;
		green_inv 	= 4'b1111 - green;
		blue_inv 	= 4'b1111 - blue;
	end 
	
	assign data_out = {red_inv, green_inv, blue_inv};
	
endmodule 