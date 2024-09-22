module image_streamer_tb;

	logic        clk;
    logic        reset;
    logic        ready = 1'b0;
	
streaming_top_level dut(
	.clk(clk),
	.reset(reset),
	.ready(ready)
	);



 localparam CLK_T = 20;

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50 MHz clock
    end
	 
	 initial begin : procedure
        $dumpfile("waveform.vcd");
        $dumpvars();
		  
		  reset = 1'b1;

        // Apply reset
        #20 reset = 1'b0;
		  
		  #(20*400);
		  
		  $finish();
	 end
	 
	 always_ff @(posedge clk) begin : vga_stall
        ready <= ($urandom() % 8 >= 2); // VGA is ready to receive 75% of the time.
    end

endmodule 