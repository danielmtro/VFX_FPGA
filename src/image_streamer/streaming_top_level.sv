module streaming_top_level(
	input clk,
	input logic reset,
	input logic ready
);

    logic [11:0] im_data;
	 logic [29:0] vga_data;
    logic        image_startofpacket;
    logic        image_endofpacket;
	 logic			image_valid;
	 logic        vga_valid;
	 logic 			vga_startofpacket;
	 logic			vga_endofpacket;
    logic        valid;
	
artificial_video_streaming 
			#(.NumPixels(320*240), .NumColourBits(12))image_stream(
        .clk(clk),
        .reset(reset),
        .data(im_data),
        .startofpacket(image_startofpacket),
        .endofpacket(image_endofpacket),
        .valid(im_valid),
        .ready(ready)
    );
	 
	 
 video_data_expander #(
	.NumPixels(320*240),
	.NumColourBits(12)
)
 vga_stream(
    .clk(clk),            
    .reset(reset),  
	.data_in(im_data),

    .data(vga_data),         
    .startofpacket(vga_startofpacket),   
    .endofpacket(vga_endofpacket),    
    .valid(vga_valid),          
    .ready(ready)  
);

endmodule 