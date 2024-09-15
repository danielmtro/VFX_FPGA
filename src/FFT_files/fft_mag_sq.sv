module fft_mag_sq #(
    parameter W = 16
) (
    input                clk,
    input                reset,
    input                fft_valid,
    input        [W-1:0] fft_imag,
    input        [W-1:0] fft_real,
    output logic [W*2:0] mag_sq,
    output logic         mag_valid
);

    logic signed [W*2-1:0] multiply_stage_real, multiply_stage_imag;
    logic signed [W*2:0]   add_stage;
    
    always_ff @(posedge clk) begin

       multiply_stage_real <= signed'(fft_real) * signed'(fft_real);
       multiply_stage_imag <= signed'(fft_imag) * signed'(fft_imag);

       add_stage <= multiply_stage_real + multiply_stage_imag;

    end

    // Flip flop to create the 2 clock cycle delay 
    logic [1:0] shiftRegister;
    always_ff @(posedge clk) begin
        shiftRegister[1] <= shiftRegister[0];
        shiftRegister[0] <= fft_valid;
    end

    assign mag_sq = add_stage;
    assign mag_valid = shiftRegister[1];

endmodule