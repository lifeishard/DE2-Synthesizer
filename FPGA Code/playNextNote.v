module playNextNote (
	CLOCK_50,
	length,
	tempo,
	playNext
);

input				CLOCK_50;
input	[2:0]		length;
input	[1:0]		tempo;

output reg			playNext;

reg 	[32:0] 		counter;
reg 	[32:0]	 	tick;
reg		[3:0]		len;
reg		[7:0]		bpm;

//assigns bpms depending on the tempo input
always @ *
	case (tempo)
	2'b00: bpm = 8'd120;
	2'b01: bpm = 8'd240;
	default: bpm = 8'd240;
	endcase
always @(bpm)
begin	
 counter = 32'd3000000000/bpm;
end
always @(posedge CLOCK_50)
	if (tick == counter) begin
		//playNext <= 0;
		tick <= 0;
		len <= len + 1;
		if (len == length)  begin
			len <= 0;
			playNext <= 1;
		end
		else playNext <= 0;
		
	end else begin
		tick <= tick + 1;
		playNext <= 0;
	end

endmodule