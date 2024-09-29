`timescale 1 ns / 1 ns
module top_level_tb;

		logic clk;
		logic [17:0] sw;
		logic  [3:0] KEY;
		
		 logic        VGA_CLK;    
		 logic       VGA_HS;     
		 logic        VGA_VS;     
		 logic        VGA_BLANK;  
		 logic        VGA_SYNC;   
		 logic [7:0]  VGA_R;        
		 logic [7:0]  VGA_G;       
		 logic [7:0]  VGA_B;
		 
		 
		 top_level DUT (
		.CLOCK_50(clk),
		.SW(sw),
		.KEY(KEY),
		
		.VGA_CLK(VGA_CLK),    
		.VGA_HS(VGA_HS),     
		.VGA_VS(VGA_VS),     
		.VGA_BLANK(VGA_BLANK),  
		.VGA_SYNC(VGA_SYNC),   
		.VGA_R(VGA_R),        
		.VGA_G(VGA_G),        
		.VGA_B(VGA_B)         
);

initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50 MHz clock
    end
	 
	 initial begin : procedure
        $dumpfile("waveform.vcd");
        $dumpvars();
		  
		  KEY = 4'b0000;
		  sw = 0;
		  
		  #20
		  //inversion filter
		  sw[17:16] = 2'b10;
		  sw[1:0] = 2'b00;
		  #20000;
		  
		  //reset
		  #20;
		  //blur filter
		  sw[17:16] = 2'b01;
		  sw[1:0] = 2'b01;
		  #20
		  //remove reset and wait
		  #20000;
		  
		  
		  //reset
		  #20;
		  //brightness filter
		  sw[17:16] = 2'b01;
		  sw[1:0] = 2'b10;
		  #20
		  //remove reset and wait
		  #20000;
		  
		  
		  //reset
		  #20;
		  //edge detect filter
		  sw[17:16] = 2'b01;
		  sw[1:0] = 2'b11;
		  #20
		  //remove reset and wait
		  #200000;

		  $finish();
	end 
		  
		  
	endmodule