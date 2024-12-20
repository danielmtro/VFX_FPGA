module top_level_entity (input CLOCK_50, input [3:0] KEY, output [7:0] LEDG);

my_softcore u0 (
		.clk_clk(CLOCK_50),           //        clk.clk
		.led_output_export(LEDG),     // led_output.export
		.reset_reset_n(KEY[0])        //      reset.reset_n
	);
	
endmodule
