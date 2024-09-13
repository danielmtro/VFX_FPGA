module artificial_video_streaming_tb;
	logic        clk;
    logic        reset;
    logic [2:0] data;
    logic        startofpacket;
    logic        endofpacket;
    logic        valid;
    logic        ready = 1'b0;
	 
	 artificial_video_streaming 
			#(.NumPixels(12*12), .NumColourBits(3))dut(
        .clk(clk),
        .reset(reset),
        .data(data),
        .startofpacket(startofpacket),
        .endofpacket(endofpacket),
        .valid(valid),
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
		  
		  #(20*250);
		  
		  $finish();
	 end
	 
	// Monitor signals to verify behavior
    always_ff @(posedge clk) begin : monitor
        if (valid && ready) begin
            $display("Received pixel: pixel_index =%d, data = %b", 
                      dut.pixel_index, data);
        end
    end

    always_ff @(posedge clk) begin : vga_stall
        ready <= ($urandom() % 8 >= 2); // VGA is ready to receive 75% of the time.
    end

endmodule