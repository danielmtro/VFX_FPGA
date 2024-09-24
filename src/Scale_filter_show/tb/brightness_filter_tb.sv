module brightness_filter_tb;
	
	logic clk;
	logic reset = 1;
	logic [1:0] freq_flag = 0;
	logic bri_use_flag = 1;
	
	logic [11:0] data_in = 0;
	logic sop_in = 0;
	logic eop_in = 0;
	logic valid_in = 0;
	logic bri_ready_in = 0;
	
	logic bri_ready_out;
	logic [11:0] bri_data;
	logic bri_sop_out;
	logic bri_eop_out;
	logic bri_valid_out;
	
	
	brightness_filter bright_filt(
		.clk(clk),
		.reset(reset),
		.freq_flag(freq_flag),
		.use_flag(bri_use_flag),
		
		.data_in(data_in),
		.sop_in(sop_in),
		.eop_in(eop_in),
		.valid_in(valid_in),
		.ready_in(bri_ready_in),
		
		.ready_out(bri_ready_out),
		.data_out(bri_data),
		.sop_out(bri_sop_out),
		.eop_out(bri_eop_out),
		.valid_out(bri_valid_out)	
	);
	
	// Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50 MHz clock
    end
	 
	
	initial begin : procedure
        $dumpfile("waveform.vcd");
        $dumpvars();
		  
		#40;
		reset = 0;
		valid_in = 1;
		sop_in = 1;
		#20;
		sop_in = 0;
		
		//testcase 1: do not brighten data (freq_flag = 0)
		#80;
		freq_flag = 0;
		data_in = 12'b0001_1000_1110;
		#20;
		$display("Testcase1: Received pixel: data_in = %b and freq_flag: %d and did not brighten to data_out: =%b ", 
                       data_in, freq_flag, bri_data);
		
		//testcase 2: brighten data by double
		#80;

		freq_flag = 1;
		data_in = 12'b0001_0100_1110;
		#20;
		$display("Testcase2: Received pixel: data_in = %b and freq_flag: %d and brghtened by double to data_out: =%b ", 
                       data_in, freq_flag, bri_data);
		
		//testcase 2: brighten data by triple
		#80;

		freq_flag = 2;
		data_in = 12'b0001_0100_1110;
		#20;
		$display("Testcase2: Received pixel: data_in = %b and freq_flag: %d and brghtened by triple to data_out: =%b ", 
                       data_in, freq_flag, bri_data);
		
		//testcase 4: usage flag is low: should output 0
		#80
		freq_flag = 2;
		bri_use_flag = 0;
		data_in = 12'b0001_0100_1110;
		#20;
		$display("Testcase4: Received pixel: data_in = %b and bri_use_flag: %d and outputted: =%b ", 
                       data_in, bri_use_flag, bri_data);
							  
		//testcase 5: valid_in is false
		#80;

		freq_flag = 2;
		valid_in = 0;
		data_in = 12'b0001_0100_1110;
		#20;
		$display("Testcase5: Received pixel: data_in = %b and valid_in: %d and inverted to data_out: =%b ", 
                       data_in, valid_in, bri_data);
		
		#80;
		eop_in = 1;
		#20;
		eop_in = 0;
		#40

			
		$finish();
	 end
	 
	 always_ff @(posedge clk) begin : vga_stall
        bri_ready_in <= ($urandom() % 8 >= 2); // VGA is ready to receive 75% of the time.
    end
	
endmodule
		
		