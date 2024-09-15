module fft_pitch_detect (
    input clk,
    input audio_clk,
    input reset,
    dstream.in  audio_input,
    dstream.out pitch_output
);
    parameter W        = 16;   //NOTE: To change this, you must also change the Twiddle factor initialisations in r22sdf/Twiddle.v. You can use r22sdf/twiddle_gen.pl.
    parameter NSamples = 1024; //NOTE: To change this, you must also change the SdfUnit instantiations in r22sdf/FFT.v accordingly.

    logic           di_en;  //  Input Data Enable
    logic   [W-1:0] di_re;  //  Input Data (Real)
    logic   [W-1:0] di_im;  //  Input Data (Imag)

    logic           do_en;  //  Output Data Enable
    logic   [W-1:0] do_re;  //  Output Data (Real)
    logic   [W-1:0] do_im;  //  Output Data (Imag)

    assign  di_im = 0; // No imaginary parts (audio signal is purely real).

    logic           mag_valid;
    logic   [W*2:0] mag_sq;
	 
    fft_input_buffer #(.W(W), .NSamples(NSamples)) u_fft_input_buffer (
        .clk(clk), 
        .reset(reset), 
        .audio_clk(audio_clk), 
        .audio_input(audio_input), 
        .fft_input(di_re), 
        .fft_input_valid(di_en)
    );
	 
    FFT #(.WIDTH(W)) u_fft_ip (
        .clock(clk), 
        .reset(reset), 
        .di_en(di_en), 
        .di_re(di_re), 
        .di_im(di_im), 
        .do_en(do_en), 
        .do_re(do_re), 
        .do_im(do_im)
    );
	 
    fft_mag_sq #(.W(W)) u_fft_mag_sq (
        .clk(clk), 
        .reset(reset), 
        .fft_valid(do_en), 
        .fft_imag(do_im), 
        .fft_real(do_re), 
        .mag_sq(mag_sq), 
        .mag_valid(mag_valid)
    );
	 
    fft_find_peak #(.W(W*2+1),.NSamples(NSamples)) u_fft_find_peak (
        .clk(clk), 
        .reset(reset), 
        .mag(mag_sq), 
        .mag_valid(mag_valid), 
        .peak(), 
        .peak_k(pitch_output.data), 
        .peak_valid(pitch_output.valid)
    );

endmodule
