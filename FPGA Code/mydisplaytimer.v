module mydisplaytimer(myreset,CLOCK_50,timerdisplay);
input myreset;
input CLOCK_50;
output reg[7:0] timerdisplay;
reg [27:0] clockcounter;
always @ (posedge CLOCK_50)
begin
if(myreset)
begin
timerdisplay = 8'h00;
clockcounter = 28'h0000000;
end
else clockcounter = clockcounter + 1;
if(clockcounter == 28'd50000000)
begin
clockcounter = 28'h0000000;
timerdisplay = timerdisplay +1;
if(timerdisplay[3:0]== 4'ha)timerdisplay = timerdisplay + 6;
if(timerdisplay==8'h60)timerdisplay = 8'h00;
end
end

endmodule