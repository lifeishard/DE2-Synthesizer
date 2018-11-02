module ps2_keyboard(	
					input	iCLK_50,
					inout   ps2_dat,
					input   ps2_clk,
					input   sys_clk,
					input   reset,
					input   reset1,
					output  reg [30:0]keycounter,
					output  reg[7:0]scandata,
					output reg key1_on,
					output reg key2_on,
					output reg [7:0]key1_code,
					output reg [7:0]key2_code,
					output reg entered
					);


////////////Keyboard Initially/////////
	reg [10:0] MCNT;
	always @(negedge reset or posedge sys_clk) 
	begin
		if (!reset) 
			MCNT=0;
		else if(MCNT < 500) 
			MCNT=MCNT+1;
//		else if ( !is_key && (key1_code!=keycode_o))
//			MCNT=0;
	end

///// sequence generator /////
//	reg	[7:0]	revcnt;`
	wire rev_tr=(MCNT<12)?1:0;
	
//	always @(posedge rev_tr or posedge ps2_clk)
//	begin
//		if (rev_tr)
//			revcnt=0;
//		else if (revcnt >=10) 
//			revcnt=0;
//		else
//			revcnt=revcnt+1;
//	end
	
//////KeyBoard serial data in /////
//	reg [9:0]keycode_o;
//	always @(posedge ps2_clk) begin
//		case (revcnt[3:0])
//		1:keycode_o[0]=ps2_dat;
//		2:keycode_o[1]=ps2_dat;
//		3:keycode_o[2]=ps2_dat;
//		4:keycode_o[3]=ps2_dat;
//		5:keycode_o[4]=ps2_dat;
//		6:keycode_o[5]=ps2_dat;
//		7:keycode_o[6]=ps2_dat;
//		8:keycode_o[7]=ps2_dat;
//		endcase
//	end
	wire [7:0]rc=keycode_o;
	wire HOST_ACK=(revcnt==10)?~(rc[7]^rc[6]^rc[5]^rc[4]^rc[3]^rc[2]^rc[1]^rc[0]) :1;
//////////PS2 InOut/////////
//	assign   ps2_dat =(HOST_ACK)?1'bz:1'b0;


///////KeyBoard Scan-Code trigger//////
	reg keyready;
	always @(posedge rev_tr or negedge ps2_clk) begin 
		if (rev_tr)	
			keyready=0;
		else if (revcnt[3:0]==10)
			keyready=1;
		else	
			keyready=0;
    end			
/////////////////////////////////////Key1-Key2 Output///////////////////////////
	wire is_key=(
		(keycode_o==8'h1a)?1:(  //Key z
		(keycode_o==8'h1b)?1:(  //Key s
		(keycode_o==8'h22)?1:(  //Key x
		(keycode_o==8'h23)?1:(	//Key d
		(keycode_o==8'h21)?1:(	//Key c
		(keycode_o==8'h2a)?1:(	//Key v
		(keycode_o==8'h34)?1:(	//Key g
		(keycode_o==8'h32)?1:(	//Key b
		(keycode_o==8'h33)?1:(	//Key h
		(keycode_o==8'h31)?1:(	//Key n
		(keycode_o==8'h3b)?1:(	//Key j
		(keycode_o==8'h3a)?1:(  //Key m
		(keycode_o==8'h41)?1:(  //Key ,
		(keycode_o==8'h5a)?1:(  //Key Enter
		(keycode_o==8'h29)?1:( //Key space
		(keycode_o==8'h16)?1:( //Key 1
		(keycode_o==8'h1E)?1:( //Key 2
		(keycode_o==8'h26)?1:( //Key 3
		(keycode_o==8'h25)?1:( //Key 4
		(keycode_o==8'h2E)?1:( //Key 5
		(keycode_o==8'h36)?1:( //Key 6
		(keycode_o==8'h3D)?1:( //Key 7
		(keycode_o==8'h3E)?1:0 //Key 8   
	//	(keycode_o==8'h35)?1:(
		//(keycode_o==8'h2c)?1:(
		//(keycode_o==8'h24)?1:(
	//	(keycode_o==8'h1d)?1:(
	//	(keycode_o==8'h15)?1:0
		))))))))))))))))))))))
	);
	
//////////////key1 & key2 Assign///////////
	wire keyboard_off=((MCNT==200) || (!reset1))?0:1;

	always @(posedge keyready) scandata = keycode_o;
always @(negedge key1_on)
begin
keycounter = keycounter +1;
//if(key1_code==8'h5a) entered = 0;
//else entered = 1;
end

always @(posedge keyready)
begin
if(keycode_o==8'h5a) entered = 0;
else entered = 1;
end


always @(negedge keyboard_off  or posedge keyready) 
begin
	if (!keyboard_off) 
	begin 
		key1_on=0;
		key2_on=0;
		key1_code=8'hf0;
		key2_code=8'hf0;
	end 
	else if (scandata==8'hf0) 	
	begin
		if (keycode_o==key1_code) 
		begin 
			//testkeycounter =testkeycounter +1;
			 
			key1_on=0; 
			key1_code=8'hf0;
		end
		else if (keycode_o==key2_code) 
		begin 
			
			key2_on=0; 
			key2_code=8'hf0;
		end	
	end		
	else if (is_key) 		
	begin
		if ((!key1_on) && (key2_code!=keycode_o)) 
		begin
			key1_code=keycode_o;		
			key1_on=1;
			
		end
		else if ((!key2_on) && (key1_code!=keycode_o)) 
		begin
			key2_code=keycode_o;
			key2_on=1;
			
		end
	end
end


reg       ps2_clk_in,ps2_clk_syn1,ps2_dat_in,ps2_dat_syn1;
wire      clk,ps2_dat_syn0,ps2_clk_syn0;
//tristate output control for PS2_DAT and PS2_CLK;
assign ps2_clk_syn0 = ps2_clk;
assign ps2_dat_syn0 = ps2_dat;

//clk division, derive a 97.65625KHz clock from the 50MHz source;
reg [8:0] clk_div;
always@(posedge iCLK_50)
	begin
		clk_div <= clk_div+1;
	end
	
assign clk = clk_div[8];
//multi-clock region simple synchronization
always@(posedge clk)
begin
	ps2_clk_syn1 <= ps2_clk_syn0;
	ps2_clk_in   <= ps2_clk_syn1;
	ps2_dat_syn1 <= ps2_dat_syn0;
	ps2_dat_in   <= ps2_dat_syn1;
end
reg [7:0]	keycode_o;
reg	[7:0]	revcnt;
	
always @( posedge ps2_clk_in or negedge keyboard_off)
	begin
		if (!keyboard_off)
			revcnt=0;
		else if (revcnt >=10) 
			revcnt=0;
		else
			revcnt=revcnt+1;
	end
	
always @(posedge ps2_clk_in) 
begin
	case (revcnt[3:0])
		1:keycode_o[0]=ps2_dat_in;
		2:keycode_o[1]=ps2_dat_in;
		3:keycode_o[2]=ps2_dat_in;
		4:keycode_o[3]=ps2_dat_in;
		5:keycode_o[4]=ps2_dat_in;
		6:keycode_o[5]=ps2_dat_in;
		7:keycode_o[6]=ps2_dat_in;
		8:keycode_o[7]=ps2_dat_in;
	endcase
end
endmodule
