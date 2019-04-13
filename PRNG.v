module PRNG (output [1:0] random, output [7:0] randLA, input step, rerun, randomize, clk, reset);

	LFSR u1 (
		.random(random[0]),
		.randomLookAhead(randLA[3:0]),
		.step(step),
		.rerun(rerun),
		.randomize(randomize),
		.clk(clk),
		.reset(reset));
		
	LFSR #(.FILL(16'h0001)) u2 (
		.random(random[1]),
		.randomLookAhead(randLA[7:4]),
		.step(step),
		.rerun(rerun),
		.randomize(randomize),
		.clk(clk),
		.reset(reset));
					
endmodule