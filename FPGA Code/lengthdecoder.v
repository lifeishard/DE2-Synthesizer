module lengthdecoder(pressedkey,mlength);
input [7:0]pressedkey;
output reg [2:0] mlength;
always @(pressedkey)
begin
case (pressedkey)
8'h16: mlength <= 3'd00;  //Key 1 
8'h1E: mlength  <= 3'd01; //Key 2
8'h26:  mlength  <= 3'd02; //Key 3
8'h25: mlength  <= 3'd03;	//Key 4
8'h2E: mlength  <= 3'd04;	//Key 5
8'h36: mlength <= 3'd05;//Key 6
8'h3D: mlength  <= 3'd06;	//Key 7
8'h3E: mlength  <= 3'd07;	//Key 8
default:  mlength  <= 3'd00;
endcase
end
endmodule
