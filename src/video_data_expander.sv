module video_data_expander #(
	parameter NumPixels = 12*12,
	parameter NumColourBits = 3
)
 (
    input  logic        clk,             
    input  logic        reset,           

    // Avalon-ST Interface:
    output logic [29:0] data,            // Data output to VGA (8 data bits + 2 padding bits for each colour Red, Green and Blue = 30 bits)
    output logic        startofpacket,   // Start of packet signal
    output logic        endofpacket,     // End of packet signal
    output logic        valid,           // Data valid signal
    input  logic        ready      // Data ready signal from VGA Module
);
    typedef enum logic [1:0] {Happy=2'd0, Neutral=2'd1, Angry=2'd2} face_t; // Define an enum type for readability (optional).

//    localparam NumPixels     = 12 * 12; // Total number of pixels on the 640x480 screen
//    localparam NumColourBits = 3;         // We are using a 3-bit colour space to fit 3 images within the 3.888 Mbits of BRAM on our FPGA.

    // Image ROMs:
	 // The ram_init_file is a Quartus-only directive
	//specifying the name of the initialisation file,
	//and Verilator will ignore it.
    /*(* ram_init_file = "linear-gradient.mif" *) */  logic [NumColourBits-1:0] linear_grad   [NumPixels];


    
    initial begin : memset /* The 'ifdef VERILATOR' means this initial block is ignored in Quartus */
        $readmemh("linear-gradient.hex", linear_grad);
    end
    
    
    // The pixel counter/index. Set pixel_index_next in an always_comb block.
    // Set pixel_index <= pixel_index_next in an always_ff block.
    logic [18:0] pixel_index = 0, pixel_index_next; 
    
 
    // Registers for reading from each ROM.
    logic [NumColourBits-1:0] linear_grad_q; 
      
    logic read_enable; // Need to have a read enable signal for the BRAM

    // If reset, read the first pixel value. If valid&ready (handshake), read the next pixel value for the next handshake.
    assign read_enable = reset | (valid & ready); 

    always_ff @(posedge clk) begin : bram_read // This block is for correctly inferring BRAM in Quartus - we need read registers!
        if (read_enable) begin
            linear_grad_q   <= linear_grad[pixel_index_next];
        end
    end
    
    /* Complete the TODOs below */

    logic [NumColourBits-1:0] current_pixel; //TODO assign this to one of happy_face_q, neutral_face_q or angry_face_q depending on the value of face_select.
    always_comb begin

        current_pixel <= linear_grad_q;

    end

    assign valid = (reset) ? 0 : 1;//TODO valid should be set to low when we are in reset - otherwise, we are constantly streaming data (valid stays high).

    assign startofpacket = (pixel_index == 0);         // Start of frame
    assign endofpacket = (pixel_index == NumPixels-1); // End of frame

//	 integer num_repeats;
//	 assign num_repeats = 8 / (NumColourBits / 3);
    assign data = {{8{current_pixel[2]}}, {2{1'b0}}, {8{current_pixel[1]}}, {2{1'b0}}, {8{current_pixel[0]}}, {2{1'b0}}}; //TODO assign data. Keep in mind, each RGB channel should be 10 bits like so: {8 bits of colour data, 2 bits of zero padding}.
    // Remember, our 3-bit wide image ROMs only have 1-bit for each colour channel!! (Hint: use the replication operator to convert from 1-bit to 8-bit colour).

    assign pixel_index_next = (reset || pixel_index == NumPixels - 1) ? 0 : pixel_index + 1;//TODO Set pixel_index_next (what **would be** the next value?)
                              //TODO ^^^ Also, make pixel_index_next = 0 if reset == 1.
                              //TODO ^^^ Also, make pixel_index_next = 0 if reset == 1.
                              //TODO ^^^ Also, make pixel_index_next = 0 if reset == 1.
                              //TODO ^^^ Also, make pixel_index_next = 0 if reset == 1.
    always_ff @(posedge clk) begin
        //TODO Set pixel_index based on handshaking protocol. Remember the reset!!
        if (reset) begin
            pixel_index <= 0;
        end else if (valid && ready) begin
            pixel_index <= pixel_index_next;
        end
    end


endmodule