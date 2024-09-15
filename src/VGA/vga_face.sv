// Lewis (8/9/24): Added read_enable and fixed pixel_index_next to work on Quartus. Resubmitted changes.

module vga_face (
    input  logic        clk,             
    input  logic        reset,           
    input  logic [1:0]  face_select,     // 0: Happy, 1: Neutral, 2: Angry

    // Avalon-ST Interface:
    output logic [29:0] data,            // Data output to VGA (8 data bits + 2 padding bits for each colour Red, Green and Blue = 30 bits)
    output logic        startofpacket,   // Start of packet signal
    output logic        endofpacket,     // End of packet signal
    output logic        valid,           // Data valid signal
    input  logic        ready            // Data ready signal from VGA Module
);
    typedef enum logic [1:0] {Happy=2'd0, Neutral=2'd1, Angry=2'd2} face_t; // Define an enum type for readability (optional).

    localparam NumPixels     = 640 * 480; // Total number of pixels on the 640x480 screen
    localparam NumColourBits = 3;         // We are using a 3-bit colour space to fit 3 images within the 3.888 Mbits of BRAM on our FPGA.

    // Image ROMs:
    (* ram_init_file = "happy.mif" *)   logic [NumColourBits-1:0] happy_face   [NumPixels]; // The ram_init_file is a Quartus-only directive
    (* ram_init_file = "neutral.mif" *) logic [NumColourBits-1:0] neutral_face [NumPixels]; //   specifying the name of the initialisation file.
    (* ram_init_file = "angry.mif" *)   logic [NumColourBits-1:0] angry_face   [NumPixels]; //   and Verilator will ignore it.

    `ifdef VERILATOR
    initial begin : memset /* The 'ifdef VERILATOR' means this initial block is ignored in Quartus */
        $readmemh("images/happy.hex", happy_face);
        $readmemh("images/neutral.hex", neutral_face);
        $readmemh("images/angry.hex", angry_face);
    end
    `endif
     
    logic [18:0] pixel_index = 0, pixel_index_next; // The pixel counter/index. Set pixel_index_next in an always_comb block.
                                                    // Set pixel_index <= pixel_index_next in an always_ff block.

    logic [NumColourBits-1:0] happy_face_q, neutral_face_q, angry_face_q; // Registers for reading from each ROM.

    //always_ff @(posedge clk) begin : ROM_read       // This block is for correctly inferring BRAM in Quartus - we need read registers!
	 logic read_enable; // Need to have a read enable signal for the BRAM
	 assign read_enable = reset | (valid & ready); // If reset, read the first pixel value. If valid&ready (handshake), read the next pixel value for the next handshake.

     always_ff @(posedge clk) begin : bram_read
        if (read_enable) begin
            happy_face_q   <= happy_face[pixel_index_next];
            neutral_face_q <= neutral_face[pixel_index_next];
            angry_face_q   <= angry_face[pixel_index_next];
        end
    end

    logic [NumColourBits-1:0] current_pixel; //TODO assign this to one of happy_face_q, neutral_face_q or angry_face_q depending on the value of face_select.
    always_comb begin
        case(face_select)
            Happy: current_pixel = happy_face_q;
            Neutral: current_pixel = neutral_face_q;
            Angry: current_pixel = angry_face_q;
            default: current_pixel = happy_face_q;
        endcase
    end

    assign valid = (reset) ? 1'b0 : 1'b1; //TODO valid should be set to low when we are in reset - otherwise, we are constantly streaming data (valid stays high).

    assign startofpacket = (pixel_index == 0) ? 1'b1 : 1'b0;         // Start of frame
    assign endofpacket = pixel_index == NumPixels-1; // End of frame

    assign data = { {8{current_pixel[2]}}, 2'b00,
                    {8{current_pixel[1]}}, 2'b00,
                    {8{current_pixel[0]}}, 2'b00}; //TODO assign data. Keep in mind, each RGB channel should be 10 bits like so: {8 bits of colour data, 2 bits of zero padding}.
    // Remember, our 3-bit wide image ROMs only have 1-bit for each colour channel!! (Hint: use the replication operator to convert from 1-bit to 8-bit colour).

    always_comb begin
        pixel_index_next = reset ? 0 : (pixel_index == NumPixels - 1) ? 0 : pixel_index + 1;//TODO Set pixel_index_next (what **would be** the next value?)
    end

    always_ff @(posedge clk) begin
        if(reset)
        begin
            pixel_index <= 0;
        end
        else if(valid && ready)begin
            pixel_index <= pixel_index_next;
        end
        else begin
            pixel_index <= pixel_index;
        end
    end

endmodule