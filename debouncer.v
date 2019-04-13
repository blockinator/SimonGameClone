module debouncer (
	output held, pressed, released,
	input button, clk, reset
);

	localparam sampletime = 999999; //20ms

	reg [19:0] timer;
	reg button_sampled, button_debounced, button_debounced_d;

	always @(posedge clk) begin
		timer <= timer - 1;
		if(timer ==0)
			timer <=sampletime;
	end

	always @(posedge clk) begin
		button_debounced_d <= button_debounced;
		if (timer == 0 ) begin
			button_sampled <= button;
			if (button == button_sampled)
				button_debounced <= button;
		end
	end

	assign debounced = button_debounced & ~button_debounced_d;

	assign held = button_debounced;
	assign pressed = button_debounced & ~button_debounced_d;
   assign released = ~button_debounced & button_debounced_d;

endmodule