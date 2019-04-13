module top_spkr (
	output reg   speaker,
	input [2:0]  tone_sel,
	input        SE, clk
);

wire [17:0] counter_comp;

speaker_mod SPKR(
	.counter_comp( counter_comp),
	.tone_sel( tone_sel ),
	.clk     ( clk )
);
	reg [16:0] counter;

	always @(posedge clk) begin
		counter <= counter + 1;
		if (counter >= counter_comp)
			counter <= 0;
	end
	
	always @* begin
		if (SE) begin
			if (counter == counter_comp/2) begin
				speaker = 0;
			end
			else if (counter == counter_comp)
				speaker = 1;
		end
	end

endmodule