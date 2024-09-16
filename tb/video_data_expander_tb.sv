module video_data_expander_tb;

	 logic        clk;
    logic        reset;
    logic [29:0] data;

    logic        valid;
    logic        ready = 1'b0;
	 logic [11:0] pixel_in = {11{1'b0}};
	 
	 video_data_expander 
			#(.NumColourBits(12))dut(
        .clk(clk),
        .reset(reset),
        .data(data),
		  .pixel_in(pixel_in),
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
		  
		  pixel_in = 12'b0011_1100_1010;
		  #40;
		  pixel_in = 12'b1010_0101_1111;
		  
		  #40;
		  
		  $finish();
	 end
	 
	// Monitor signals to verify behavior
    always_ff @(posedge clk) begin : monitor
        if (valid && ready) begin
            $display("Received pixel: pixel_in =%b, data = %b", 
                      pixel_in, data);
        end
    end

    always_ff @(posedge clk) begin : vga_stall
        ready <= ($urandom() % 8 >= 2); // VGA is ready to receive 75% of the time.
    end
	 
endmodule 