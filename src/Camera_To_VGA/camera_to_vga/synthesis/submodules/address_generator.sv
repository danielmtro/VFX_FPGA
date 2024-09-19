module address_generator #(
	parameter NumPixels = 320*240,
    parameter DATA_WIDTH = 12
)(
	 // general signals
	 input  clk,
    // signals to interface with frame buffer
    input  logic  [DATA_WIDTH - 1:0] data_in,
    output  logic  [16:0]             rdaddress,

    // source signals
    input  logic                     reset,
	 input  logic						    ready,
    output logic                     sop_out,   // Start of packet signal
    output logic                     eop_out,     // End of packet signal
    output logic                     valid,            // valid output
    output logic [DATA_WIDTH - 1:0]  data_out
    
);
    // Data valid (constant)
    assign valid = (reset) ? 0 : 1;                    

    // The pixel counter/index. Set pixel_index_next in an always_comb block.
    // Set pixel_index <= pixel_index_next in an always_ff block.
    logic [16:0] pixel_index = 0, pixel_index_next; 


    //  pixel index next generation
    assign pixel_index_next = (reset || pixel_index == NumPixels - 1) ? 0 : pixel_index + 1;

    // flip flop to update the pixel_index value
    always_ff @(posedge clk) begin
        if (reset) begin
            pixel_index <= 0;
        end
        // handshake decides if we grab the next index
        else if (valid && ready) begin
            pixel_index <= pixel_index_next;
        end
    end

    assign sop_out = (pixel_index == 0);         // Start of frame
    assign eop_out = (pixel_index == NumPixels-1); // End of frame

    // set the data as the current pixel for output streaming
    assign data_out = data_in;
    assign rdaddress = pixel_index;


endmodule