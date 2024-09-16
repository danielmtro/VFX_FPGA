module video_data_expander #(
	parameter NumColourBits = 12
)
 (
    input  logic        clk,             
    input  logic        reset, 

	 input logic[11:0] 	pixel_in,

    // Avalon-ST Interface:
    output logic [29:0] data,            // Data output to VGA (8 data bits + 2 padding bits for each colour Red, Green and Blue = 30 bits)
    output logic        valid,           // Data valid signal
    input  logic        ready      // Data ready signal from VGA Module
);

//    localparam NumPixels     = 12 * 12; // Total number of pixels on the 640x480 screen
//    localparam NumColourBits = 3;         // We are using a 3-bit colour space to fit 3 images within the 3.888 Mbits of BRAM on our FPGA.


 
    
    /* Complete the TODOs below */

    logic [NumColourBits-1:0] current_pixel; //TODO assign this to one of happy_face_q, neutral_face_q or angry_face_q depending on the value of face_select.
    always_comb begin

        current_pixel <= pixel_in;

    end

    assign valid = (reset) ? 0 : 1;//TODO valid should be set to low when we are in reset - otherwise, we are constantly streaming data (valid stays high).

//	 integer num_repeats;
//	 assign num_repeats = 8 / (NumColourBits / 3);
    assign data = {{2{current_pixel[11:8]}}, {2{1'b0}}, {2{current_pixel[7:4]}}, {2{1'b0}}, {2{current_pixel[3:0]}}, {2{1'b0}}}; //TODO assign data. Keep in mind, each RGB channel should be 10 bits like so: {8 bits of colour data, 2 bits of zero padding}.
    // Remember, our 3-bit wide image ROMs only have 1-bit for each colour channel!! (Hint: use the replication operator to convert from 1-bit to 8-bit colour).



endmodule