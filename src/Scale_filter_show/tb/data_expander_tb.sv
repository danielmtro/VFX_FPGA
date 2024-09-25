module data_expander_tb;

	logic clock_clk;
	logic [11:0] data_in = 0;
	logic sop_in = 0;
	logic eop_in = 0;
	logic valid_in = 0;
	logic ready_out;
	
	logic ready_in = 0;
	logic reset = 1;
	
	logic [29:0] data_out;
	logic sop_out;
	logic eop_out;
	logic valid_out;

data_expander #(
    .INTIAL_DATA_WIDTH(12),
    .FINAL_DATA_WIDTH(30)
)DUT(
	 .clock_clk,
    .data_in,
    .sop_in,
    .eop_in,
    .valid_in,
    .ready_out,

    .ready_in,
    .reset,

    .data_out,
    .sop_out,
    .eop_out,
    .valid_out

);

	initial begin
        clock_clk = 0;
        forever #10 clock_clk = ~clock_clk; // 50 MHz clock
    end
	 
	 
	 initial begin : procedure
        $dumpfile("waveform.vcd");
        $dumpvars();
		  
		
		//testcase 1: do not invert data (freq_flag = 0)
		#40;
		reset = 0;
		valid_in = 1;
		sop_in = 1;
		#20;
		sop_in = 0;
		#80;
		data_in = 12'b0001_1000_1111;
		#20;
		$display("Testcase1: Received pixel: data_in = %b expanded to data_out: =%b ", 
                       data_in, data_out);
		
		
		
		#80;
		eop_in = 1;
		#20;
		eop_in = 0;
		#40

			
		$finish();
	 end
	 
	 always_ff @(posedge clock_clk) begin : vga_stall
        ready_in <= ($urandom() % 8 >= 2); // VGA is ready to receive 75% of the time.
    end

endmodule 