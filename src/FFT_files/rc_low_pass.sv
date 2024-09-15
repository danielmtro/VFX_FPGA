`timescale 1ns/1ns
module rc_low_pass #(parameter W=16,
                     parameter W_FRAC= 8,
                     ALPHA=0.5) ( // E.g W=16, W_FRAC=8
    input clk,
    dstream.in x,   //x.data fixed-point format: 8.8 (e.g. W=16, W_FRAC=8)
    dstream.out y   //y.data fixed-point format: 8.8 (e.g. W=16, W_FRAC=8)
);

    // 1. Assign x.ready : we are ready for data if the module we output to (y.ready) is ready (this module does not exert backpressure).
    assign x.ready = y.ready;
    localparam ONE = 1 << W_FRAC; // 1.0 in fixed point

    logic [W - 1:0] ONE_MINUS_ALPHA = signed'(ONE) - signed'(ALPHA);
                                                                     //*** Fixed point formats: (e.g. W=16, W_FRAC=8)
    logic signed [2*W-1:0]     a1_mult; // Output of -a_1 multiplier //** multiply: 16.16 (= 8.8 * 8.8)
    logic signed [2*(W+1)-1:0] b0_mult; // Output of b_0 multiplier  //** multiply: 18.16 (= 9.8 * 9.8)
    logic signed [W:0]         add_input; // Output of left adder    //** add: 9.8 (= 8.8 + 8.8) (truncate a1_mult to 8.8)
    logic signed [W-1:0]       register_delay = 0; // z^-1 delay     //** 8.8 (truncate to be same as inputs)
                                                                     //** You could choose larger widths with less truncation to decrease truncation error.
                                                                     //** The above are the minimum widths needed for passing the testcases with enough accuracy.

    // 2. always_ff to create the z^-1 register_delay. Only enable this register when x.valid =1 & x.ready = 1.
    // Hint: Make sure to use signed'() on add_input if you truncate it from 9.8 to 8.8.
    logic signed [W:0] z1_out;
    always_ff @(posedge clk) begin
        if(x.valid && x.ready) begin
            z1_out <= signed'(add_input);
        end
    end

    // 3. always_comb to set adder `add_input` and multipliers `a1_mult` and `b0_mult`
    // Hint: Make sure to use signed'() on x.data, ALPHA, ONE and any variable that you truncate. E.g. signed'(x.data)
    // Hint: When setting add_input, you can truncate a1_mult from 16.16 to 8.8. Remember to use signed'() on this!

    logic signed [W - 1:0] truncated_a1;
    always_comb begin

        // truncate the value for a1
        a1_mult = ONE_MINUS_ALPHA * z1_out;
        truncated_a1 = a1_mult[W -1 + W_FRAC: W_FRAC];
        add_input = signed'(truncated_a1) + signed'(x.data);
        b0_mult = signed'(add_input) * signed'(ALPHA);

    end
    // 4. Assign y.data (truncate b0_mult from 18.16 to 8.8)
    assign y.data = b0_mult[W - 1 + W_FRAC: W_FRAC];

    // 5. Assign y.valid: this should just be equal to x.valid.
    assign y.valid = x.valid;

    // IMPORTANT: make sure to make everything signed by using the signed'() cast!!!

endmodule