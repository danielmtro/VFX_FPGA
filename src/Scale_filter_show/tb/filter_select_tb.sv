module filter_select_tb;

	logic clk;
	logic reset = 1;
	logic [1:0] freq_flag = 0;
	logic [1:0] filter_num = 0;
	
	logic [11:0] data_in = 0;
	logic sop_in = 0;
	logic eop_in = 0;
	logic valid_in = 0;
	
	logic ready_in = 0;
	logic ready_out;
	
	logic [11:0] data_out;
	logic sop_out;
	logic eop_out;
	logic valid_out;

	enum logic [1:0] {
        COLOUR = 2'b00,
        BLUR = 2'b01,
        BRIGHTNESS = 2'b10,
        EDGES = 2'b11
    }state_type;

	filter_select DUT(
	.clk(clk),
	.reset(reset),
	.freq_flag(freq_flag),
	.filter_num(filter_num),
	

	.data_in(data_in),
	.sop_in(sop_in),
	.eop_in(eop_in),
	.valid_in(valid_in),
	

	.ready_in(ready_in),

	.ready_out(ready_out),

	.data_out(data_out),
	.sop_out(sop_out),
	.eop_out(eop_out),
	.valid_out(valid_out));


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
		
		//testcase 1: inversion
		
		#80;
		freq_flag = 2;
		filter_num = COLOUR;
		data_in = 12'b0001_1000_1111;
		#20;
		$display("Testcase1: Received pixel: data_in = %b and freq_flag: %d and inverted to data_out: =%b ", 
                       data_in, freq_flag, data_out);
		
		//testcase 2: brightness
		#80;

		freq_flag = 2;
		filter_num = BRIGHTNESS;
		data_in = 12'b0001_1000_1111;
		#20;
		$display("Testcase2: Received pixel: data_in = %b and freq_flag: %d and brightened by double to data_out: =%b ", 
                       data_in, freq_flag, data_out);
	
	
		
		#80;
		eop_in = 1;
		#20;
		eop_in = 0;
		#40

			
		$finish();
	 end
	 
	 always_ff @(posedge clk) begin : vga_stall
        ready_in <= ($urandom() % 8 >= 2); // VGA is ready to receive 75% of the time.
    end


endmodule 