module multi_filter_selection(
    input clk,
    input wire [7:0] pixel_in,        // 8-bit pixel data input
    input wire [1:0] state,             // 2-bit control signal for filter selection
    output reg [7:0] pixel_out        // 8-bit pixel data output after filtering
);

    // Instantiate Filters inside Multiplexer
    
    // Filter outputs
    wire [7:0] filter0_out;
    wire [7:0] filter1_out;
    wire [7:0] filter2_out;
    wire [7:0] filter3_out;

    filter0 f0(.pixel_in(pixel_in), .pixel_out(filter0_out));
    filter1 f1(.pixel_in(pixel_in), .pixel_out(filter1_out));
    filter2 f2(.pixel_in(pixel_in), .pixel_out(filter2_out));
    filter3 f3(.pixel_in(pixel_in), .pixel_out(filter3_out));

    // Multiplexer to select the appropriate filter output
    always_ff @(posedge clk) begin
        case(sel)
            2'b00: pixel_out = filter0_out;   // Select filter 0
            2'b01: pixel_out = filter1_out;   // Select filter 1
            2'b10: pixel_out = filter2_out;   // Select filter 2
            2'b11: pixel_out = filter3_out;   // Select filter 3
            default: pixel_out = 8'b0;        // Default case (should not happen)
        endcase
    end


endmodule