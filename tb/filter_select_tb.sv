`timescale 1 ns / 1 ns
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
	localparam IMG_WIDTH = 320;
    localparam IMG_LENGTH = 240;
	localparam LEN = IMG_LENGTH * IMG_WIDTH;
    logic [11:0] image [0:LEN-1];

    integer i, j;
	
	 


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
        
		  
		  for (i = 0; i < IMG_LENGTH; i = i + 1) begin
            for (j = 0; j < IMG_WIDTH; j = j + 1) begin
                    image[i * IMG_LENGTH + j] = (i * IMG_LENGTH + j) & 12'b111111111111; // Simple gradient
            end
        end
		  $dumpfile("waveform.vcd");
        $dumpvars();
		
		freq_flag = 3'b000; // Set to no blur
        run_test();
        ready_in = 0;
		  #100;
        ready_in = 1;

		  
		  freq_flag = 3'b001; // Set to no blur
        run_test();
        ready_in = 0;
		  #100;
        ready_in = 1;
		  
		  
		  freq_flag = 3'b010; // Set to no blur
        run_test();
        ready_in = 0;
		  #100;
        ready_in = 1;
		  
		  
		  freq_flag = 3'b011; // Set to no blur
        run_test();
        ready_in = 0;
		  #100;
        ready_in = 1;
		  
		  #1000

			
		$finish();
	 end
	 
	 task run_test;
        begin
            // Feed image data to the filter
            for (i = 0; i < IMG_LENGTH; i = i + 1) begin
                for (j = 0; j < IMG_WIDTH; j = j + 1) begin
                    if ((i == 0) && (j == 0)) begin
                        sop_in = 1;
                    end
                    else begin
                        sop_in = 0;
                    end
                    
                    if ((i == IMG_LENGTH-1) && (j == IMG_WIDTH-1)) begin
                        eop_in = 1;
                    end
                    else begin
                        eop_in = 0;
                        
                    end
                    data_in = image[i * IMG_LENGTH + j];
                    #20; // Wait for processing
                end
            end
        end
    endtask

endmodule 