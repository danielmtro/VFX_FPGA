module edge_scale_output (
    input  clock_clk,
    input  logic  [23:0]data_in,
    input  logic                sop_in,
    input  logic                eop_in,
    input  logic                valid_in,
    output logic                ready_out,

    input  logic                ready_in,
    input  logic                reset,

    output logic [11:0] data_out,
    output logic                sop_out,
    output logic                eop_out,
    output logic                valid_out

);

    assign ready_out = ready_in;
    // expand the 12 bit RGB to 30 bit RGB
    assign data_out = {data_in[19:16],data_in[11:8],data_in[3:0]};

    // assign the signals as such
    assign eop_out = eop_in;
    assign sop_out = sop_in;
    assign valid_out = valid_in && (!reset);

endmodule