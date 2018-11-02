/*
SW[17] ->pitch shift
SW[16] -> filter
SW[15] & SW[14] -> tempo
SW[13] & SW[12] -> waveforms
SW[11] & SW[10] -> Volume
SW[9] & SW[8] & SW[7]-> Track
SW[6] & SW[5] -> Octave
SW[4] - SW[0] -> Mode selection
LEDR -> Current Note #
LEDG -> State machine display debugging
LCD -> Display name and mode
HEX[7] pitch shift
HEX[6] tempo
HEX[5] waveforms
HEX[4] volume
HEX[3] track
HEX[2] octave
HEX[1] & HEX [0] timer; 
KEY[0] resets audio and lcd buffer
*/

//statemachine module

module DE2_synthesizer (

		////////////////////	Clock Input	 	////////////////////	 
		CLOCK_27,							//	27 MHz
		CLOCK_50,							//	50 MHz
		EXT_CLOCK,						//	External Clock
		////////////////////	Push Button		////////////////////
		KEY,							//	Button[3:0]
		////////////////////	DPDT Switch		////////////////////
		SW,						//	DPDT Switch[17:0]
		////////////////////	7-SEG Dispaly	////////////////////
		HEX0,							//	Seven Segment Digital 0
		HEX1,							//	Seven Segment Digital 1
		HEX2,							//	Seven Segment Digital 2
		HEX3,							//	Seven Segment Digital 3
		HEX4,							//	Seven Segment Digital 4
		HEX5,							//	Seven Segment Digital 5
		HEX6,							//	Seven Segment Digital 6
		HEX7,							//	Seven Segment Digital 7
		////////////////////////	LED		////////////////////////
		LEDG,						//	LED Green[8:0]
		LEDR,						//	LED Red[17:0]

		////////////////////	LCD Module 16X2		////////////////
		LCD_ON,							//	LCD Power ON/OFF
		LCD_BLON,						//	LCD Back Light ON/OFF
		LCD_RW,							//	LCD Read/Write Select, 0 = Write, 1 = Read
		LCD_EN,							//	LCD Enable
		LCD_RS,							//	LCD Command/Data Select, 0 = Command, 1 = Data
		LCD_DATA,						//	LCD Data bus 8 bits

		////////////////////	I2C		////////////////////////////
		I2C_SDAT,						//	I2C Data
		I2C_SCLK,						//	I2C Clock
		////////////////////	PS2		////////////////////////////
		PS2_DAT,						//	PS2 Data
		PS2_CLK,						//	PS2 Clock
	
		////////////////	Audio CODEC		////////////////////////
		AUD_ADCLRCK,					//	Audio CODEC ADC LR Clock
		AUD_ADCDAT,						//	Audio CODEC ADC Data
		AUD_DACLRCK,					//	Audio CODEC DAC LR Clock
		AUD_DACDAT,						//	Audio CODEC DAC Data
		AUD_BCLK,						//	Audio CODEC Bit-Stream Clock
		AUD_XCK						//	Audio CODEC Chip Clock

	);

////////////////////////	Clock Input	 	////////////////////////
	input			   CLOCK_27;					//	27 MHz
	input			   CLOCK_50;					//	50 MHz
	input			   EXT_CLOCK;				//	External Clock
////////////////////////	Push Button		////////////////////////
	input	  [3:0]	KEY;					//	Button[3:0]
////////////////////////	DPDT Switch		////////////////////////
	input	  [17:0]	SW;				//	DPDT Switch[17:0]
////////////////////////	7-SEG Dispaly	////////////////////////
	output	[6:0]	HEX0;					//	Seven Segment Digital 0
	output	[6:0]	HEX1;					//	Seven Segment Digital 1
	output	[6:0]	HEX2;					//	Seven Segment Digital 2
	output	[6:0]	HEX3;					//	Seven Segment Digital 3
	output	[6:0]	HEX4;					//	Seven Segment Digital 4
	output	[6:0]	HEX5;					//	Seven Segment Digital 5
	output	[6:0]	HEX6;					//	Seven Segment Digital 6
	output	[6:0]	HEX7;					//	Seven Segment Digital 7
////////////////////////////	LED		////////////////////////////
	output	[7:0]	LEDG;				//	LED Green[8:0]
	output  [17:0]	LEDR;				//	LED Red[17:0]
////////////////////	LCD Module 16X2	////////////////////////////
	inout	 [7:0]	LCD_DATA;				//	LCD Data bus 8 bits
	output			LCD_ON;					//	LCD Power ON/OFF
	output			LCD_BLON;				//	LCD Back Light ON/OFF
	output			LCD_RW;					//	LCD Read/Write Select, 0 = Write, 1 = Read
	output			LCD_EN;					//	LCD Enable
	output			LCD_RS;					//	LCD Command/Data Select, 0 = Command, 1 = Data
////////////////////////	I2C		////////////////////////////////
	inout			   I2C_SDAT;				//	I2C Data
	output			I2C_SCLK;				//	I2C Clock
////////////////////////	PS2		////////////////////////////////
	inout		 	   PS2_DAT;				//	PS2 Data
	input			   PS2_CLK;				//	PS2 Clock

////////////////////	Audio CODEC		////////////////////////////
inout			   AUD_ADCLRCK;			//	Audio CODEC ADC LR Clock
	inout			   AUD_DACLRCK;			//	Audio CODEC DAC LR Clock
	input			   AUD_ADCDAT;			    //	Audio CODEC ADC Data
	output			AUD_DACDAT;				//	Audio CODEC DAC Data
	inout			   AUD_BCLK;				//	Audio CODEC Bit-Stream Clock
	output			AUD_XCK;				//	Audio CODEC Chip Clock

//KEY0 go to restart state;
//one hot encoding
//SW0 playback on
//SW1 pitch mode on 
//SW2 length mode on
//all off standby mode;

//SW0  0 standby state  1 -> not standby
//SW1  0 playback mode  1 -> edit mode
//SW2  0 edit note  1 -> edit length
parameter sstandby = 5'd00000, splay = 5'b00011, srecordnote = 5'b00101, srecordlength = 5'b01001, slimbo = 5'b10000, sendplay = 5'b10011;
/*parameter nc1 = 11'd65, nc2 = 11'd69, nd1 = 11'd73, nd2 = 11'd78, ne = 11'd82, nf1 = 11'd87, nf2 = 11'd92, ng1 = 11'd98, ng2 = 11'd104, na1 = 11'd110, 
na2 = 11'd117, nb = 11'd123, nc3 = 11'd131, nn = 11'd1, nl=11'd2;	
*/	
reg [8:0] t0n0,t0n1,t0n2,t0n3,t0n4,t0n5,t0n6,t0n7,t0n8,t0n9,t0n10,t0n11,t0n12,t0n13,t0n14,t0n15;
reg [8:0] t1n0,t1n1,t1n2,t1n3,t1n4,t1n5,t1n6,t1n7,t1n8,t1n9,t1n10,t1n11,t1n12,t1n13,t1n14,t1n15;
reg [8:0] t2n0,t2n1,t2n2,t2n3,t2n4,t2n5,t2n6,t2n7,t2n8,t2n9,t2n10,t2n11,t2n12,t2n13,t2n14,t2n15;
reg [8:0] t3n0,t3n1,t3n2,t3n3,t3n4,t3n5,t3n6,t3n7,t3n8,t3n9,t3n10,t3n11,t3n12,t3n13,t3n14,t3n15;
reg [8:0] t4n0,t4n1,t4n2,t4n3,t4n4,t4n5,t4n6,t4n7,t4n8,t4n9,t4n10,t4n11,t4n12,t4n13,t4n14,t4n15;
reg [8:0] t5n0,t5n1,t5n2,t5n3,t5n4,t5n5,t5n6,t5n7,t5n8,t5n9,t5n10,t5n11,t5n12,t5n13,t5n14,t5n15;
reg [8:0] t6n0,t6n1,t6n2,t6n3,t6n4,t6n5,t6n6,t6n7,t6n8,t6n9,t6n10,t6n11,t6n12,t6n13,t6n14,t6n15;
reg [8:0] t7n0,t7n1,t7n2,t7n3,t7n4,t7n5,t7n6,t7n7,t7n8,t7n9,t7n10,t7n11,t7n12,t7n13,t7n14,t7n15;
reg [3:0] t0l,t1l,t2l,t3l,t4l,t5l,t6l,t7l,t8l,t9l,t10l,t11l,t12l,t13l,t14l,t15l;
//8:6 length 
//5:4 octave
//3:0 pitch
//

reg [4:0] ns;
reg [4:0] cs;
assign LEDG[4:0] = cs;
assign LEDG[5] = cplay;

always @(negedge screenrefresh,negedge enterpress,negedge cplay)
case(cs)
	sstandby:
			if(SW[2]) ns = srecordnote;
			else if(SW[1]) ns = srecordlength;
			else if(SW[0]) ns = splay;
			else ns = sstandby;
	srecordlength:
			if(SW[2]) 
			ns = srecordnote;
			else if(SW[1])
			begin
			if(~enterpress)ns = slimbo;
			else ns = srecordlength;
			end
			else if(SW[0]) ns = splay;
			else ns = sstandby;
			
	splay:
			if(SW[2]) ns = srecordnote;
			else if(SW[1]) ns = srecordlength;
			else if(SW[0])
			begin	
			if(~cplay) ns = sendplay;
			else ns = splay;
			//ns = splay;
			end
			else ns = sstandby;
			
	srecordnote:
			if(SW[2]) 
			begin
			if(~enterpress)ns = slimbo;
			else ns = srecordnote;
			end
			else if(SW[1]) ns = srecordlength;
			else if(SW[0]) ns = splay;
			else ns = sstandby;
			
	slimbo:
			if(screenrefresh)ns = slimbo;
			else
			begin
			if(SW[2]) ns = srecordnote;
			else if(SW[1]) ns = srecordlength;
			else if(SW[0]) ns = splay;
			else ns = sstandby;
			end
			
	sendplay:
			if(screenrefresh)ns = sendplay;
			else
			begin
			if(SW[2]) ns = srecordnote;
			else if(SW[1]) ns = srecordlength;
			else if(SW[0]) ns = splay;
			else ns = sstandby;
			end
	default:
		ns = sstandby;
endcase	

//wire tochangestate = (entered & screenrefresh);

reg [4:0] cn;
reg [4:0] playn;
reg [4:0] pitchn;
reg [4:0] lengthn;

always @(cs)
begin
case(cs)
	splay: cn = playn;
	srecordlength:cn= lengthn;
	srecordnote:cn = pitchn;
	default: cn = 5'b00000;
endcase
end

wire [15:0] oneledout;
notedecoder maindisplaycurrentnote(cn,oneledout);

reg [15:0]tled;
assign LEDR[17:2] = tled;
assign LEDR[1:0] = t0n0[1:0];
assign LEDG[7:6] = t0l[1:0];
//assign LEDR[1:0] = cn[3:2];
//assign LEDG[7:6] = cn[1:0];
always @(CLOCK_50)
begin
case(cs)
	splay: tled = oneledout;
	srecordlength:tled = oneledout;
	srecordnote:tled = oneledout;
	default: tled = 16'h0000;
endcase
end
/*
always @ (negedge key1_on,negedge screenrefresh)
begin
case(cs)
	srecordlength:
		if(~screenrefresh) cn <=0;
		else 
		begin
		if(key1_code!=8'h5a)cn <= cn + 1;
		end
	srecordnote:
		if(~screenrefresh) cn <=0;
		else 
		begin
		if(key1_code!=8'h5a)cn <= cn + 1;
		end
	default:cn <= 0;
	endcase
end
*/

//wire clearn;
//assign clearn = (~key1_on & screenrefresh); 
always @ (negedge key1_on)
begin
case(cs)
	srecordnote:
	begin
		if(key1_code!=8'h5a)pitchn <= pitchn + 1;
		lengthn <= 0;
	end
		
	srecordlength:
	begin
		if(key1_code!=8'h5a)lengthn <= lengthn + 1;
		pitchn <= 0;
	end
	
	default:
	begin 
	pitchn <= 0;
	lengthn <= 0;
	end
	endcase
end

wire [8:0] tsilence;
assign tsilence = 4'b000001111;
always @(posedge tochangenote)
begin
case(cs)
splay:
playn <= playn +1;

default:
playn <=0; 
endcase
end

reg[8:0] currentnote;

always @(posedge tochangenote)
case (cs)
	splay:
	case (SW[9:7])
	3'b000:
		case(playn)
		5'd0:currentnote = t0n0;
		5'd1:currentnote = t0n1;
		5'd2:currentnote = t0n2;
		5'd3:currentnote = t0n3;
		5'd4:currentnote = t0n4;
		5'd5:currentnote = t0n5;
		5'd6:currentnote = t0n6;
		5'd7:currentnote = t0n7;
		5'd8:currentnote = t0n8;
		5'd9:currentnote = t0n9;
		5'd10:currentnote = t0n10;
		5'd11:currentnote = t0n11;
		5'd12:currentnote = t0n12;
		5'd13:currentnote = t0n13;
		5'd14:currentnote = t0n14;
		5'd15:currentnote = t0n15;
		default:currentnote = tsilence;
		endcase
	3'b001:
		case(playn)
		5'd0:currentnote = t1n0;
		5'd1:currentnote = t1n1;
		5'd2:currentnote = t1n2;
		5'd3:currentnote = t1n3;
		5'd4:currentnote = t1n4;
		5'd5:currentnote = t1n5;
		5'd6:currentnote = t1n6;
		5'd7:currentnote = t1n7;
		5'd8:currentnote = t1n8;
		5'd9:currentnote = t1n9;
		5'd10:currentnote = t1n10;
		5'd11:currentnote = t1n11;
		5'd12:currentnote = t1n12;
		5'd13:currentnote = t1n13;
		5'd14:currentnote = t1n14;
		5'd15:currentnote = t1n15;
		default:currentnote = tsilence;
		endcase
	default:currentnote = tsilence;
	endcase
	default:
	currentnote = tsilence;
endcase
wire [13:0] frequency;
noteLookup calculatecurrentfrequency(currentnote[3:0],currentnote[5:4],frequency);

wire tochangenote;
playNextNote whentoplaynextnote(
	CLOCK_50,
	currentnote[8:6],
	SW[15:14],
	tochangenote
);
//assign cplay =1;

always @(playn , t0l,t1l)
	if(cs == splay| cs == sendplay)
	case (SW[9:7])
	3'b000:
		if(playn > t0l)cplay <= 0;
		else cplay <= 1; 
	3'b001:
		if(playn > t1l)cplay <= 0;
		else cplay <= 1; 
	default: cplay <=1;
	endcase
	else 
	cplay <=1;

reg cplay;//0 finished 1 notfinished

	reg [4:0]swreg;
	reg screenrefresh;
	always @(posedge CLOCK_50)
	begin
	if(swreg != SW[4:0])
	begin 
	screenrefresh = 0;
	swreg = SW[4:0];


	end
	else 
	begin
	swreg = SW[4:0];
	screenrefresh = 1;
	end
	end


wire [3:0]mnote;

wire [2:0]mlength;
wire  [5:0]mfnote = {SW[6:5],mnote}; 
lengthdecoder getlengthfromkey(key1_code,mlength);
	pitchdecoder getpitchfromkey(key1_code,mnote,key1_on);
/*
always @ (*)
begin
 t0n0[5:0] = 6'b000000;
 t0n1[5:0] = 6'b000001;
 t0n2[5:0] = 6'b000010;
 t0n3[5:0] = 6'b000011;
 t0n4[5:0] = 6'b000100;
 t0n5[5:0] = 6'b000101;
 t0n6[5:0] = 6'b000110;
 end
*/

always @(posedge key1_on)
begin
case (cs)
	srecordnote:
	if(key1_code!=8'h5a)
	begin
	case (SW[9:7])
	3'b000:
		begin
		case (pitchn)
		4'd00: t0n0[5:0] <= mfnote;
		4'd01: t0n1[5:0] <= mfnote;
		4'd02: t0n2[5:0] <= mfnote;
		4'd03: t0n3[5:0] <= mfnote;
		4'd04: t0n4[5:0] <= mfnote;
		4'd05: t0n5[5:0] <= mfnote;
		4'd06: t0n6[5:0] <= mfnote;
		4'd07: t0n7[5:0] <= mfnote;
		4'd08: t0n8[5:0] <= mfnote;
		4'd09: t0n9[5:0] <= mfnote;
		4'd10: t0n10[5:0] <= mfnote;
		4'd11: t0n11[5:0] <= mfnote;
		4'd12: t0n12[5:0] <= mfnote;
		4'd13: t0n13[5:0] <= mfnote;
		4'd14: t0n14[5:0] <= mfnote;
		4'd15: t0n15[5:0] <= mfnote;
		endcase
		t0l <= pitchn;
		end
	3'b001:
		begin
		case (pitchn)
		4'd00: t1n0[5:0] <= mfnote;
		4'd01: t1n1[5:0] <= mfnote;
		4'd02: t1n2[5:0] <= mfnote;
		4'd03: t1n3[5:0] <= mfnote;
		4'd04: t1n4[5:0] <= mfnote;
		4'd05: t1n5[5:0] <= mfnote;
		4'd06: t1n6[5:0] <= mfnote;
		4'd07: t1n7[5:0] <= mfnote;
		4'd08: t1n8[5:0] <= mfnote;
		4'd09: t1n9[5:0] <= mfnote;
		4'd10: t1n10[5:0] <= mfnote;
		4'd11: t1n11[5:0] <= mfnote;
		4'd12: t1n12[5:0] <= mfnote;
		4'd13: t1n13[5:0] <= mfnote;
		4'd14: t1n14[5:0] <= mfnote;
		4'd15: t1n15[5:0] <= mfnote;
		endcase
		t1l <= pitchn;
		end
		endcase
	end
	srecordlength:
	if(key1_code!=8'h5a)
	begin
	case (SW[9:7])
	3'b000:
		case (lengthn)
		4'd00: t0n0[8:6] <= mlength;
		4'd01: t0n1[8:6] <= mlength;
		4'd02: t0n2[8:6] <= mlength;
		4'd03: t0n3[8:6] <= mlength;
		4'd04: t0n4[8:6] <= mlength;
		4'd05: t0n5[8:6] <= mlength;
		4'd06: t0n6[8:6] <= mlength;
		4'd07: t0n7[8:6] <= mlength;
		4'd08: t0n8[8:6] <= mlength;
		4'd09: t0n9[8:6] <= mlength;
		4'd10: t0n10[8:6] <= mlength;
		4'd11: t0n11[8:6] <= mlength;
		4'd12: t0n12[8:6] <= mlength;
		4'd13: t0n13[8:6] <= mlength;
		4'd14: t0n14[8:6] <= mlength;
		4'd15: t0n15[8:6] <= mlength;
		endcase
	3'b001:
		case (lengthn)
		4'd00: t1n0[8:6] <= mlength;
		4'd01: t1n1[8:6] <= mlength;
		4'd02: t1n2[8:6] <= mlength;
		4'd03: t1n3[8:6] <= mlength;
		4'd04: t1n4[8:6] <= mlength;
		4'd05: t1n5[8:6] <= mlength;
		4'd06: t1n6[8:6] <= mlength;
		4'd07: t1n7[8:6] <= mlength;
		4'd08: t1n8[8:6] <= mlength;
		4'd09: t1n9[8:6] <= mlength;
		4'd10: t1n10[8:6] <= mlength;
		4'd11: t1n11[8:6] <= mlength;
		4'd12: t1n12[8:6] <= mlength;
		4'd13: t1n13[8:6] <= mlength;
		4'd14: t1n14[8:6] <= mlength;
		4'd15: t1n15[8:6] <= mlength;
		endcase
		endcase
	end
	endcase
end

 toneGen soundgenerator(
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

reg enterpress;
always @ (posedge CLOCK_50)
begin
if(key1_on & key1_code==8'h5a)enterpress = 0;
else enterpress = 1;
end

always @(posedge CLOCK_50)
begin
		cs <= ns;
end
	
//  7-SEG 

	SEG7_LUT_8 			u0	(	HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7,hexoutput);//testkeycounter);//31'h00001112 );

	reg    [31:0]VGA_CLK_o;

	assign   keyboard_sysclk = VGA_CLK_o[12];
	//assign   demo_clock      = VGA_CLK_o[18]; 
	//assign   VGA_CLK         = VGA_CLK_o[0];

	always @( posedge CLOCK_50 )
   begin	
		VGA_CLK_o <= VGA_CLK_o + 1;
	end


// KeyBoard Scan //

	wire [7:0]scan_code;

	wire get_gate;

	wire key1_on;

	wire key2_on;

	wire [7:0]key1_code;

	wire [7:0]key2_code;
	wire [30:0] keycounter;
	wire [31:0] hexoutput;
	wire entered;
	/*
	assign hexoutput[31:28] = mnote;
	assign hexoutput[27:24] = t0n1[3:0];
	assign hexoutput[23:20] = t0n2[3:0];
	assign hexoutput[19:16] = t0n3[3:0];
	assign hexoutput[15:12] = t0n4[3:0];
	assign hexoutput[11:8] = t0n5[3:0];
	*/
		
	assign hexoutput[29:28] = SW[17:16];
	assign hexoutput[31:30] = 2'b00;
	assign hexoutput[25:24] = SW[15:14];
	assign hexoutput[27:26] = 2'b00;
	assign hexoutput[21:20] = SW[13:12];
	assign hexoutput[23:22] = 2'b00;
	assign hexoutput[17:16] = SW[11:10];
	assign hexoutput[19:18] = 2'b00;
	assign hexoutput[14:12] = SW[9:7];
	assign hexoutput[15] = 1'b0;
	assign hexoutput[9:8] = SW[6:5];
	assign hexoutput[11:10] = 2'b00;
	mydisplaytimer showclock(~SW[0],CLOCK_50,hexoutput[7:0]);
	ps2_keyboard keyboard(
	   .iCLK_50  (CLOCK_50),
		.ps2_dat  ( PS2_DAT ),		    //ps2bus data  		
		.ps2_clk  ( PS2_CLK ),		    //ps2bus clk      	
		.sys_clk  ( keyboard_sysclk ),  //system clock		
		.reset    ( KEY[3] ), 		    //system reset		
    	.reset1   ( KEY[2] ),			//keyboard reset	
    	.scandata ( scan_code ),		//scan code    		
    	.key1_on  ( key1_on ),			//key1 triger
    	.key2_on  ( key2_on ),			//key2 triger
    	.key1_code( key1_code ),		//key1 code
    	.key2_code( key2_code ), 		//key2 code
		.keycounter(keycounter),
		.entered(entered)
	);
	
//reg[13:0] frequency;
//assign frequency =14'd0440;

//	LCD 

	assign	LCD_ON		=	1'b1;
	
	assign	LCD_BLON	=	1'b1;

	
	LCD_TEST 			u5	(	
	
							//	Host Side
							
							.iCLK  	( CLOCK_50 ),
							.iRST_N	(( KEY[0] & screenrefresh)),
							.LCD_MODE(SW[4:0]),
							
							//	LCD Side
							
							.LCD_DATA( LCD_DATA ),
							.LCD_RW  ( LCD_RW ),
							.LCD_EN	( LCD_EN ),
							.LCD_RS  ( LCD_RS )	
							
							);

				
endmodule