module inversion_filter_tb;
	
	logic clk;
	logic reset = 1;
	logic [1:0] freq_flag = 0;
	
	logic [11:0] data_in = 0;
	logic sop_in = 0;
	logic eop_in = 0;
	logic valid_in = 0;
	logic inv_ready_in = 0;
	
	logic inv_ready_out;
	logic [11:0] inv_data;
	logic inv_sop_out;
	logic inv_eop_out;
	logic inv_valid_out;
	
	
	inversion_filter inv_filt(
		.clk(clk),
		.reset(reset),
		.freq_flag(freq_flag),
		
		.data_in(data_in),
		.sop_in(sop_in),
		.eop_in(eop_in),
		.valid_in(valid_in),
		.ready_in(inv_ready_in),
		
		.ready_out(inv_ready_out),
		.data_out(inv_data),
		.sop_out(inv_sop_out),
		.eop_out(inv_eop_out),
		.valid_out(inv_valid_out)
	 );
	
	// Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50 MHz clock
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
		freq_flag = 0;
		data_in = 12'b0001_1000_1111;
		#20;
		$display("Testcase1: Received pixel: data_in = %b and freq_flag: %d and did not invert to data_out: =%b ", 
                       data_in, freq_flag, inv_data);
		
		//testcase 2: invert data (freq_flag >= 1)
		#80;

		freq_flag = 2;
		data_in = 12'b0001_1000_1111;
		#20;
		$display("Testcase2: Received pixel: data_in = %b and freq_flag: %d and inverted to data_out: =%b ", 
                       data_in, freq_flag, inv_data);
	
		//testcase 3: valid_in is false
		#80;

		freq_flag = 2;
		valid_in = 0;
		data_in = 12'b0001_1000_1111;
		#20;
		$display("Testcase3: Received pixel: data_in = %b and valid_in: %d and inverted to data_out: =%b ", 
                       data_in, valid_in, inv_data);
		
		#80;
		eop_in = 1;
		#20;
		eop_in = 0;
		#40

			
		$finish();
	 end
	 
	 always_ff @(posedge clk) begin : vga_stall
        inv_ready_in <= ($urandom() % 8 >= 2); // VGA is ready to receive 75% of the time.
    end
	
endmodule
		
		