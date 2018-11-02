module notedecoder(cn,oneledout);
input [4:0]cn; 
output reg[15:0] oneledout;
always @(cn)
begin
case(cn)
	5'd0:oneledout <=16'b1000000000000000;
	5'd1:oneledout <=16'b0100000000000000;
	5'd2:oneledout <=16'b0010000000000000;
	5'd3:oneledout <=16'b0001000000000000;
	5'd4:oneledout <=16'b0000100000000000;
	5'd5:oneledout <=16'b0000010000000000;
	5'd6:oneledout <= 16'b0000001000000000;
	5'd7:oneledout <= 16'b0000000100000000;
	5'd8:oneledout <= 16'b0000000010000000;
	5'd9:oneledout <= 16'b0000000001000000;
	5'd10:oneledout <= 16'b0000000000100000;
	5'd11:oneledout <= 16'b0000000000010000;
	5'd12:oneledout <= 16'b0000000000001000;
	5'd13:oneledout <= 16'b0000000000000100;
	5'd14:oneledout <= 16'b0000000000000010;
	5'd15:oneledout <= 16'b0000000000000001;
 default:oneledout <= 16'b0000000000000000;
	endcase;
end

endmodule