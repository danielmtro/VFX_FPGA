`timescale 1ns/1ps

module lcd_master_tb;

    // Inputs to the DUT (Device Under Test)
    localparam MEMSIZE = 32768;
    reg clk;
    reg reset;
    integer i, j;
    reg [9:0] pitch_out;

    dstream #(.N(16)) audio_input ();
    // Read in the data

    (* ram_init_file = "hex_recording.mif" *)  logic [15:0] audio_file [MEMSIZE];

    // iniate top level for the lcd control module

    fft_pitch_detect #(.W(W), .NSamples(NSamples)) DUT (
	    .clk(clk),
        .audio_clk(clk),
        .reset(reset),
        .audio_input(data_out),
        .pitch_output(pitch_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        reset = 1;
        audio_input.valid = 0;

        forever #27.15 clk = ~clk;  // 20ns clock period (18.432 MHz)
        // Load the memory with the hex file
        $readmemh("hex_recording.hex", audio_file);
    end

    // Initial conditions and stimulus
    initial begin
        // Dump the waveform to a VCD file
        $dumpfile("waveform.vcd");
        $dumpvars();

        // Wait for a few clock cycles
         #54.3;
         #54.3;
         #54.3;
         #54.3;
         #54.3;
         #54.3;
         #54.3;
         #54.3;

        reset = 0;

        // Stream the data one bit at a time
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
        for (j = 0; j < 16; j = j + 1) begin
            audio_input.data = audio_file[i][j];
            audio_input.valid = 1;
            #54.3; // Wait for one clock cycle
            audio_input.valid = 1;
        end
        end


        #54.3;
        #54.3;
        #54.3;
        #54.3;
         #54.3;
         #54.3;
        // Run the simulation for a specified time
        #150 $finish();
    end

endmodule