module edge_detection_tb;

	logic       clk;
	logic[11:0] data_in = 0;
	logic[11:0] data_out;
	logic[2:0]  freq_flag = 0;
	

	 
	 edge_detection DUT (
		.clk(clk),
		.data_in(data_in),
		.data_out(data_out),
		.freq_flag(freq_flag)
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
		  
			
		#80;
		data_in = 12'b0101_1010_0010;
		
		#80;
		$display("Received pixel: data_in = %b and inverted to data_out: =%b ", 
                       data_in, data_out);
		freq_flag = 2;
		data_in = 12'b0110_1100_0101;
		
		#80;
		$display("Received pixel: data_in = %b and edge detected to data_out: =%b ", 
                       data_in, data_out);
		data_in = 12'b0110_1001_0110;
		
		#80
		$display("Received pixel: data_in = %b and inverted to data_out: =%b ", 
                       data_in, data_out);
			
		  $finish();
	 end
	 


 
	 
endmodule 