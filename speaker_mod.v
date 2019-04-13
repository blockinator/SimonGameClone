module speaker_mod (
	output reg [17:0] counter_comp,
	input      [2:0]  tone_sel,
	input         clk
);

	always @* begin
			case(tone_sel)
				  3'b000: counter_comp = 113636; //A3
				  3'b001: counter_comp = 101239; //B3
				  3'b010: counter_comp = 90192;  //C4#
				  3'b011: counter_comp = 85131;  //D4
				  3'b100: counter_comp = 75843;  //E4
				  3'b101: counter_comp = 67568;  //F4#
				  3'b110: counter_comp = 60196;  //G4#
				  3'b111: counter_comp = 56818;  //A5
			endcase
	end

endmodule

/*
B3, C4#, D4, D4, C4#, A3, C4#, C4#, B3


001, 010, 011, 011, 010, 000, 010, 010, 001

*/