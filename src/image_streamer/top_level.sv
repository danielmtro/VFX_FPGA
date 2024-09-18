module top_level (
		input  wire        CLOCK_50,
		input  wire [17:0] SW,
		
		output wire        VGA_CLK,    
		output wire        VGA_HS,     
		output wire        VGA_VS,     
		output wire        VGA_BLANK,  
		output wire        VGA_SYNC,   
		output wire [7:0]  VGA_R,        
		output wire [7:0]  VGA_G,        
		output wire [7:0]  VGA_B         
);



	video_data_expander vde0 (

	);

	artificial_video_streaming avs0 (

	);

	
	
endmodule