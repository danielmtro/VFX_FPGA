/*
State machine to control which filter is selected at a given point in time.
Module also includes debouncing and edge detection for the keys

    Here we map the followng
    KEY[0] -> Select Colour Filter
    KEY[1] -> Select Blur Filter
    KEY[2] -> Select Brightness Filter
    KEY[3] -> Select Edges Filter

Filter type is a 2 bit state output 
00: COLOUR
01: BLUR
10: BRIGHTNESS
11: EDGES
*/

module filter_fsm(
    input           		  clk,
    input        [3:0]        key,
    output logic [1:0]        filter_type
);

    // Stores the debounced signals and edge detect signals 
    logic [3:0] debounce, edges;

    // Debounce the key input
    for(i=0; i<4; i++) begin  : debounce_keys
        debounce d_i (.clk(clk),
                        .button(key[i]),
                        .button_pressed(debounce[i]));
    end

    // edge detect all the key inputs
    for(i = 0; i < 4; ++i) begin : edge_detect_keys
        edge_detect e_i (.clk(clk),
                          .button(debounce[i]),
                          .button_edge(edges[i]));
    end


    // State teypedef enum used here
	 // Note that we specify the exact encoding that we want to use for each state
    typedef enum logic [1:0] {
        COLOUR = 2'b00,
        BLUR = 2'b01,
        BRIGHTNESS = 2'b10,
        EDGES = 2'b11
    } state_type;
    state_type current_state = COLOUR, next_state;

    // always_comb block for next state logic

    /*
    Here we map the followng
    KEY[0] -> Select Colour Filter
    KEY[1] -> Select Blur Filter
    KEY[2] -> Select Brightness Filter
    KEY[3] -> Select Edges Filter
    */
    always_comb begin
        next_state = current_state;

        if(edges[0] == 1'b1) begin
            next_state = COLOUR;
        end
        else if (edges[1] == 1'b1) begin
            next_state = BLUR;
        end
        else if (edges[2] == 1'b1) begin
            next_state = BRIGHTNESS;
        end
        else if (edges[3] == 1'b1) begin
            next_state = EDGES;
        end
        else begin
            next_state = current_state;
        end
    end

    // always_ff for FSM state variable flip_flops
    always_ff @(posedge clk) begin
        current_state <= next_state;
    end

    // assign outputs
    assign filter_type = current_state;

endmodule