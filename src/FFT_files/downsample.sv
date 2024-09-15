`timescale 1ns/1ns
module downsample #(parameter W = 16,
                    parameter DOWNSAMPLE_FACTOR = 32) (
    input clk,
    input reset,
    dstream.in x,   //x.data fixed-point format: 8.8 (e.g. W=16, W_FRAC=8)
    dstream.out y 
);

    // MODULE ASSUMES DOWNSAMPLE FACTOR IS A POWER OF 2
    reg [$clog2(DOWNSAMPLE_FACTOR) - 1:0] sample_counter;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sample_counter <= 0;
            y.valid <= 0;
        end else begin
            if (x.valid) begin
                if (sample_counter == 0) begin
                    y.data <= x.data;
                    y.valid <= 1;
                end else begin
                    y.valid <= 0;
                end
                sample_counter <= sample_counter + 1;
            end else begin
                y.valid <= 0;
            end
        end
    end

endmodule
