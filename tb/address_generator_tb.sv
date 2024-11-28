`timescale 1 ns / 1 ns
module address_generator_tb;
    
    localparam TCLK = 50;

    logic   clk = 0,
            ready = 0,
            resend = 1'b1,
            start,
            out;
    logic [16:0] address;
    
    always #(TCLK/2) clk = ~clk;

    address_generator DUT (
        .clk_25_vga(clk),
        .vga_ready(ready),
        .resend(resend),
        .vga_start_out(start),
        .vga_end_out(out),
        .rdaddress(address)
    );

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars();

        start = 0;
        out = 0;
        address = 0;

        #(TCLK*2);
        resend = 0;

        #(TCLK*2);
        ready = 1'b1;
        $display("Start of packet: vga_start_out = %b", start);

        #(TCLK);
        $display("Address: %d", address);

        #(TCLK*4);
        resend = 1;
        #(TCLK)
        resend = 0;

        #(TCLK);
        ready = 1'b1;

        #(TCLK);
        $display("Address: %d", address);

        #(TCLK*76800);
        ready = 0;
        #(TCLK);
        ready = 1'b1;

        $finish();

    end

endmodule