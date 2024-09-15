module top_level (
	input    CLOCK_50,
	output	I2C_SCLK,
	inout		I2C_SDAT,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	input  [3:0] KEY,
	input		AUD_ADCDAT,
	input    AUD_BCLK,
	output   AUD_XCK,
	input    AUD_ADCLRCK,
	output logic [17:0] LEDR,
	output logic [7:0] LEDG
);
   localparam W        = 16;   //NOTE: To change this, you must also change the Twiddle factor initialisations in r22sdf/Twiddle.v. You can use r22sdf/twiddle_gen.pl.
   localparam NSamples = 1024; //NOTE: To change this, you must also change the SdfUnit instantiations in r22sdf/FFT.v accordingly.

	logic adc_clk; 
	
	adc_pll adc_pll_u (.areset(1'b0),.inclk0(CLOCK_50),.c0(adc_clk)); // generate 18.432 MHz clock
	logic i2c_clk; i2c_pll i2c_pll_u (.areset(1'b0),.inclk0(CLOCK_50),.c0(i2c_clk)); // generate 20 kHz clock

	set_audio_encoder set_codec_u (.i2c_clk(i2c_clk), .I2C_SCLK(I2C_SCLK), .I2C_SDAT(I2C_SDAT));

	dstream #(.N(W))                audio_input ();
	dstream #(.N(W)) 					  downsampled_audio_input();
	dstream #(.N(W)) 					  filtered_audio_input();
	
   dstream #(.N($clog2(NSamples))) pitch_output ();
	
	
	mic_load #(.N(W)) u_mic_load (
    .adclrc(AUD_ADCLRCK),
	 .bclk(AUD_BCLK),
	 .adcdat(AUD_ADCDAT),
    .sample_data(audio_input.data),
	 .valid(audio_input.valid)
   );
	
	
			
	assign AUD_XCK = adc_clk;
	
	// Determne when a SOP and an EOP is
	
	
//	FIR_filter u_fir_filter (
//		.clk(CLOCK_50),
//		.ast_sink_data(audio_input.data),
//		.ast_sink_valid(audio_input.valid),
//		.ast_source_data(filtered_audio_input.data),
//		.ast_source_valid(filtered_audio_input.valid)
//	);

	rc_low_pass #(.ALPHA(16'b00000000_0001100)) u_rc_low_pass (
		.clk(AUD_BLK),
		.x(audio_input),
		.y(filtered_audio_input)
	);
	
	downsample u_downsample(.clk(AUD_BLK),
									.x(filtered_audio_input),
									.y(downsampled_audio_input));
	


   fft_pitch_detect #(.W(W), .NSamples(NSamples)) DUT (
	    .clk(adc_clk),
		 .audio_clk(AUD_BCLK),
		 .reset(~KEY[0]),
		 .audio_input(audio_input),
		 .pitch_output(pitch_output)
    );
	 
	 
	logic [21:0] count;
	always_ff @(posedge CLOCK_50) begin
		if(count == 0) begin
			LEDR <= downsampled_audio_input.data;
			LEDG[0] <= audio_input.valid;
			LEDG[1] <= downsampled_audio_input.valid;
			LEDG[2] <= filtered_audio_input.valid;
		end
		count <= count + 1;
	end
	
	// Trying to slow down the noise
	logic [12:0] downsample_count;
	always_ff @(posedge CLOCK_50) begin
		if(downsample_count == 0) begin
			fft_value <= pitch_output.data;
		end
		downsample_count <= downsample_count + 1;
	end
	
	
	// correction to increase sensitivity
	logic [10:0] fft_value;

	display u_display (.clk(adc_clk),.value(fft_value),.display0(HEX0),.display1(HEX1),.display2(HEX2),.display3(HEX3));

endmodule
