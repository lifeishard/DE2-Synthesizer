module pitchdecoder(pressedkey,mnote,key1_on);
input [7:0]pressedkey;
input key1_on;
output reg [3:0] mnote;
always @(posedge key1_on)
begin
case (pressedkey)
8'h1a: mnote <= 4'd00;  //Key z
8'h1b:mnote <= 4'd01; //Key s
8'h22: mnote <= 4'd02; //Key x
8'h23:mnote <= 4'd03;	//Key d
8'h21:mnote <= 4'd04;	//Key c
8'h2a:	mnote <= 4'd05;//Key v
8'h34:mnote <= 4'd06;	//Key g
8'h32:mnote <= 4'd07;	//Key b
8'h33:mnote <= 4'd08;	//Key h
8'h31:mnote <= 4'd09;	//Key n
8'h3b:	mnote <= 4'd10;//Key j
8'h3a: mnote <= 4'd11; //Key m
8'h41: mnote <= 4'd12; //Key ,
default: mnote <= 4'd13;
endcase
end
endmodule
