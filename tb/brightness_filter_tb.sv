module brightness_filter_tb;

	logic [11:0] data_in = 0;
	logic [11:0] data_out = 0;
	
	logic clk;
	
	logic [2:0] freq_flag = 0;
	
	brightness_filter DUT (
		.clk(clk),
		.data_in(data_in),
		.data_out(data_out),
		.freq_flag(freq_flag)
	);
	
	// Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50 MHz clock
    end
	 
	
	initial begin : procedure
        $dumpfile("waveform.vcd");
        $dumpvars();
		  
			
		#80;
		data_in = 12'b0001_0101_1101;
		#80;
		$display("Received pixel: data_in = %b and inverted to data_out: =%b ", 
                       data_in, data_out);
		freq_flag = 1;
		data_in = 12'b0011_0110_0111;
		
		#80;
		$display("Received pixel: data_in = %b and inverted to data_out: =%b ", 
                       data_in, data_out);
		freq_flag = 2;
		data_in = 12'b0111_1000_0110;
		
		#80
		$display("Received pixel: data_in = %b and inverted to data_out: =%b ", 
                       data_in, data_out);
			
		  $finish();
	 end
	
endmodule
		
		