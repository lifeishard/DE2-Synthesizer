module DE2_Audio_Example (	
	// Inputs
	CLOCK_50,
	AUD_ADCDAT,
	KEY,
	SW,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,
	I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,
	I2C_SCLK,
	LEDR
	
);

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input	[3:0]		KEY;
input	[17:0]	SW;
input				AUD_ADCDAT;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;
inout				I2C_SDAT;

// Outputs
output 			AUD_XCK;
output			AUD_DACDAT;
output			I2C_SCLK;
output [12:0]	LEDR;

// Internal Registers

reg	[13:0] 	frequency;

always @ *
	if (SW[0])
		frequency = 19'd65;
	else if (SW[1])
		frequency = 19'd69;
	else if (SW[2])
		frequency = 19'd73;
	else if (SW[3])
		frequency = 19'd78;
	else if (SW[4])
		frequency = 19'd82;
	else if (SW[5])
		frequency = 19'd87;
	else if (SW[6])
		frequency = 19'd92;
	else if (SW[7])
		frequency = 19'd98;
	else if (SW[8])
		frequency = 19'd104;
	else if (SW[9])
		frequency = 19'd110;
	else if (SW[10])
		frequency = 19'd117;
	else if (SW[11])
		frequency = 19'd123;
	else if (SW[12])
		frequency = 19'd131;
	else
		frequency = 19'd0;
		
	toneGen (
		// Inputs
		CLOCK_50,
		AUD_ADCDAT,
		KEY,
		SW,
		frequency,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,
		I2C_SDAT,

		// Outputs
		AUD_XCK,
		AUD_DACDAT,
		I2C_SCLK
	);

endmodule



module toneGen (
	// Inputs
	CLOCK_50,
	AUD_ADCDAT,
	KEY,
	SW,
	frequency,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,
	I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,
	I2C_SCLK
);


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input				AUD_ADCDAT;
input	[0:0]		KEY;
input	[17:0]	SW;
input [13:0] 	frequency;


// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;
inout				I2C_SDAT;

// Outputs
output 			AUD_XCK;
output			AUD_DACDAT;
output			I2C_SCLK;
/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire				audio_in_available;
wire				read_audio_in;
wire				audio_out_allowed;
wire	[31:0]	left_channel_audio_out;
wire	[31:0]	right_channel_audio_out;
wire				write_audio_out;
wire 	[1:0] 	waveform;

// Internal Registers

//reg 	[18:0] 	frequency;
reg 	[18:0] 	counter;
reg 	[18:0] 	tick;
reg 	[6:0] 	tablecount;
reg 	[31:0] 	sound;
reg 	[31:0] 	sound2;
reg	[31:0]	sound3;
reg 				silence;

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge CLOCK_50)
	if (tick == counter) begin
		tick = 0;
		tablecount <= tablecount + 1;
		if (tablecount == 64) tablecount <= 0;
	end else tick <= tick + 1;
	
/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/
assign waveform[1:0] = SW[17:16];
		
//processes special case of frequency = 0 (silence)
always @ *
	if (frequency != 0) begin
		silence = 0;
		counter = (50000000/frequency)/64; //64 samples per period
	end else begin
		silence = 1;
	end

//lookup tables for waveforms
always @ (tablecount)
	if (silence != 0)
		sound = 32'd0;
	else begin
		case (waveform)
		2'b00: begin //square wave
			case (tablecount)
			0  :sound = 32'd10000000;
			1  :sound = 32'd10000000;
			2  :sound = 32'd10000000;
			3  :sound = 32'd10000000;
			4  :sound = 32'd10000000;
			5  :sound = 32'd10000000;
			6  :sound = 32'd10000000;
			7  :sound = 32'd10000000;
			8  :sound = 32'd10000000;
			9  :sound = 32'd10000000;
			10 :sound = 32'd10000000;
			11 :sound = 32'd10000000;
			12 :sound = 32'd10000000;
			13 :sound = 32'd10000000;
			14 :sound = 32'd10000000;
			15 :sound = 32'd10000000;
			16 :sound = 32'd10000000;
			17 :sound = 32'd10000000;
			18 :sound = 32'd10000000;
			19 :sound = 32'd10000000;
			20 :sound = 32'd10000000;
			21 :sound = 32'd10000000;
			22 :sound = 32'd10000000;
			23 :sound = 32'd10000000;
			24 :sound = 32'd10000000;
			25 :sound = 32'd10000000;
			26 :sound = 32'd10000000;
			27 :sound = 32'd10000000;
			28 :sound = 32'd10000000;
			29 :sound = 32'd10000000;
			30 :sound = 32'd10000000;
			31 :sound = 32'd10000000;
			32 :sound = -32'd10000000;
			33 :sound = -32'd10000000;
			34 :sound = -32'd10000000;
			35 :sound = -32'd10000000;
			36 :sound = -32'd10000000;
			37 :sound = -32'd10000000;
			38 :sound = -32'd10000000;
			39 :sound = -32'd10000000;
			40 :sound = -32'd10000000;
			41 :sound = -32'd10000000;
			42 :sound = -32'd10000000;
			43 :sound = -32'd10000000;
			44 :sound = -32'd10000000;
			45 :sound = -32'd10000000;
			46 :sound = -32'd10000000;
			47 :sound = -32'd10000000;
			48 :sound = -32'd10000000;
			49 :sound = -32'd10000000;
			50 :sound = -32'd10000000;
			51 :sound = -32'd10000000;
			52 :sound = -32'd10000000;
			53 :sound = -32'd10000000;
			54 :sound = -32'd10000000;
			55 :sound = -32'd10000000;
			56 :sound = -32'd10000000;
			57 :sound = -32'd10000000;
			58 :sound = -32'd10000000;
			59 :sound = -32'd10000000;
			60 :sound = -32'd10000000;
			61 :sound = -32'd10000000;
			62 :sound = -32'd10000000;
			63 :sound = -32'd10000000;
			default: sound = 32'd0;
			endcase
		end
		2'b01: begin //sawtooth wave
			case (tablecount)
			0  : sound = -32'd17320508;
			1  : sound = -32'd16779242;
			2  : sound = -32'd16237976;
			3  : sound = -32'd15696710;
			4  : sound = -32'd15155444;
			5  : sound = -32'd14614178;
			6  : sound = -32'd14072912;
			7  : sound = -32'd13531646;
			8  : sound = -32'd12990381;
			9  : sound = -32'd12449115;
			10 : sound = -32'd11907849;
			11 : sound = -32'd11366583;
			12 : sound = -32'd10825317;
			13 : sound = -32'd10284051;
			14 : sound = -32'd9742785;
			15 : sound = -32'd9201519;
			16 : sound = -32'd8660254;
			17 : sound = -32'd8118988;
			18 : sound = -32'd7577722;
			19 : sound = -32'd7036456;
			20 : sound = -32'd6495190;
			21 : sound = -32'd5953924;
			22 : sound = -32'd5412658;
			23 : sound = -32'd4871392;
			24 : sound = -32'd4330127;
			25 : sound = -32'd3788861;
			26 : sound = -32'd3247595;
			27 : sound = -32'd2706329;
			28 : sound = -32'd2165063;
			29 : sound = -32'd1623797;
			30 : sound = -32'd1082531;
			31 : sound = -32'd541265;
			32 : sound = 32'd0;
			33 : sound = 32'd541265;
			34 : sound = 32'd1082531;
			35 : sound = 32'd1623797;
			36 : sound = 32'd2165063;
			37 : sound = 32'd2706329;
			38 : sound = 32'd3247595;
			39 : sound = 32'd3788861;
			40 : sound = 32'd4330127;
			41 : sound = 32'd4871392;
			42 : sound = 32'd5412658;
			43 : sound = 32'd5953924;
			44 : sound = 32'd6495190;
			45 : sound = 32'd7036456;
			46 : sound = 32'd7577722;
			47 : sound = 32'd8118988;
			48 : sound = 32'd8660254;
			49 : sound = 32'd9201519;
			50 : sound = 32'd9742785;
			51 : sound = 32'd10284051;
			52 : sound = 32'd10825317;
			53 : sound = 32'd11366583;
			54 : sound = 32'd11907849;
			55 : sound = 32'd12449115;
			56 : sound = 32'd12990381;
			57 : sound = 32'd13531646;
			58 : sound = 32'd14072912;
			59 : sound = 32'd14614178;
			60 : sound = 32'd15155444;
			61 : sound = 32'd15696710;
			62 : sound = 32'd16237976;
			63 : sound = 32'd16779242;
			default: sound = 32'd0;
			endcase
		end
		2'b10: begin //sine wave
			case (tablecount)
			0  : sound = 32'd0;
			1  : sound = 32'd1386171;
			2  : sound = 32'd2758993;
			3  : sound = 32'd4105245;
			4  : sound = 32'd5411961;
			5  : sound = 32'd6666556;
			6  : sound = 32'd7856949;
			7  : sound = 32'd8971676;
			8  : sound = 32'd10000000;
			9  : sound = 32'd10932018;
			10 : sound = 32'd11758756;
			11 : sound = 32'd12472250;
			12 : sound = 32'd13065629;
			13 : sound = 32'd13533180;
			14 : sound = 32'd13870398;
			15 : sound = 32'd14074037;
			16 : sound = 32'd14142136;
			17 : sound = 32'd14074037;
			18 : sound = 32'd13870398;
			19 : sound = 32'd13533180;
			20 : sound = 32'd13065629;
			21 : sound = 32'd12472250;
			22 : sound = 32'd11758756;
			23 : sound = 32'd10932018;
			24 : sound = 32'd10000000;
			25 : sound = 32'd8971676;
			26 : sound = 32'd7856949;
			27 : sound = 32'd6666556;
			28 : sound = 32'd5411961;
			29 : sound = 32'd4105245;
			30 : sound = 32'd2758993;
			31 : sound = 32'd1386171;
			32 : sound = 32'd0;
			33 : sound = -32'd1386171;
			34 : sound = -32'd2758993;
			35 : sound = -32'd4105245;
			36 : sound = -32'd5411961;
			37 : sound = -32'd6666556;
			38 : sound = -32'd7856949;
			39 : sound = -32'd8971676;
			40 : sound = -32'd10000000;
			41 : sound = -32'd10932018;
			42 : sound = -32'd11758756;
			43 : sound = -32'd12472250;
			44 : sound = -32'd13065629;
			45 : sound = -32'd13533180;
			46 : sound = -32'd13870398;
			47 : sound = -32'd14074037;
			48 : sound = -32'd14142136;
			49 : sound = -32'd14074037;
			50 : sound = -32'd13870398;
			51 : sound = -32'd13533180;
			52 : sound = -32'd13065629;
			53 : sound = -32'd12472250;
			54 : sound = -32'd11758756;
			55 : sound = -32'd10932018;
			56 : sound = -32'd10000000;
			57 : sound = -32'd8971676;
			58 : sound = -32'd7856949;
			59 : sound = -32'd6666556;
			60 : sound = -32'd5411961;
			61 : sound = -32'd4105245;
			62 : sound = -32'd2758993;
			63 : sound = -32'd1386171;
			default: sound = 32'd0;
			endcase
		end
		2'b11: begin //triangle wave
			case (tablecount)
			0  : sound = 32'd0;
			1  : sound = 32'd1082531;
			2  : sound = 32'd2165063;
			3  : sound = 32'd3247595;
			4  : sound = 32'd4330127;
			5  : sound = 32'd5412658;
			6  : sound = 32'd6495190;
			7  : sound = 32'd7577722;
			8  : sound = 32'd8660254;
			9  : sound = 32'd9742785;
			10 : sound = 32'd10825317;
			11 : sound = 32'd11907849;
			12 : sound = 32'd12990381;
			13 : sound = 32'd14072912;
			14 : sound = 32'd15155444;
			15 : sound = 32'd16237976;
			16 : sound = 32'd17320508;
			17 : sound = 32'd16237976;
			18 : sound = 32'd15155444;
			19 : sound = 32'd14072912;
			20 : sound = 32'd12990381;
			21 : sound = 32'd11907849;
			22 : sound = 32'd10825317;
			23 : sound = 32'd9742785;
			24 : sound = 32'd8660254;
			25 : sound = 32'd7577722;
			26 : sound = 32'd6495190;
			27 : sound = 32'd5412658;
			28 : sound = 32'd4330127;
			29 : sound = 32'd3247595;
			30 : sound = 32'd2165063;
			31 : sound = 32'd1082531;
			32 : sound = 32'd0;
			33 : sound = -32'd1082531;
			34 : sound = -32'd2165063;
			35 : sound = -32'd3247595;
			36 : sound = -32'd4330127;
			37 : sound = -32'd5412658;
			38 : sound = -32'd6495190;
			39 : sound = -32'd7577722;
			40 : sound = -32'd8660254;
			41 : sound = -32'd9742785;
			42 : sound = -32'd10825317;
			43 : sound = -32'd11907849;
			44 : sound = -32'd12990381;
			45 : sound = -32'd14072912;
			46 : sound = -32'd15155444;
			47 : sound = -32'd16237976;
			48 : sound = -32'd17320508;
			49 : sound = -32'd16237976;
			50 : sound = -32'd15155444;
			51 : sound = -32'd14072912;
			52 : sound = -32'd12990381;
			53 : sound = -32'd11907849;
			54 : sound = -32'd10825317;
			55 : sound = -32'd9742785;
			56 : sound = -32'd8660254;
			57 : sound = -32'd7577722;
			58 : sound = -32'd6495190;
			59 : sound = -32'd5412658;
			60 : sound = -32'd4330127;
			61 : sound = -32'd3247595;
			62 : sound = -32'd2165063;
			63 : sound = -32'd1082531;
			default: sound = 32'd0;
			endcase
		end
		endcase
	end

//distortion effect		
always @ *
	if (SW[14]) begin
		if (sound > 32'd9000000)
			sound2 = 32'd9000000;
		else if (sound < -32'd9000000)
			sound2 = -32'd9000000;
	end else
		sound2 = sound;

//volume adjustment
always @ *
	if (!SW[15])
		sound3 = sound2 * 10;
	else
		sound3 = sound2;		

assign LEDR = SW;


assign read_audio_in = audio_in_available & audio_out_allowed;
assign left_channel_audio_out	= sound3;
assign right_channel_audio_out = sound3;
assign write_audio_out = audio_in_available & audio_out_allowed;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset							(~KEY[0]),

	.clear_audio_in_memory		(),
	.read_audio_in					(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out				(write_audio_out),

	.AUD_ADCDAT						(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK						(AUD_BCLK),
	.AUD_ADCLRCK					(AUD_ADCLRCK),
	.AUD_DACLRCK					(AUD_DACLRCK),


	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(),
	.right_channel_audio_in		(),
	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK							(AUD_XCK),
	.AUD_DACDAT						(AUD_DACDAT),

);

avconf #(.USE_MIC_INPUT(1)) avc (
	.I2C_SCLK					(I2C_SCLK),
	.I2C_SDAT					(I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0])
);

endmodule