module simon_led_ctrl (
	output reg [2:0] led0, led1, led2, led3,
	input [1:0] col_sel,
	input loser, enable, clk
);

//send in encoded button press

reg [17:0] timer;

localparam RED = 3'b001, GREEN = 3'b010, BLUE = 3'b100, YELLOW = 3'b011, BLACK = 3'b000, MS = 50000;

always @(posedge clk) begin
	timer <= timer + 1;
	if (timer >= 5 * MS -1) begin
		timer <= 0;
	end
end

always @* begin
	if (loser) begin
			led0 = RED;
			led1 = RED;
			led2 = RED;
			led3 = RED;			
	end
	else begin
		//defaults
		if (timer < 1 * MS) begin
			led0 = GREEN;
			led1 = RED;
			led2 = BLUE;
			led3 = YELLOW;
		end
		else begin
			led0 = BLACK;
			led1 = BLACK;
			led2 = BLACK;
			led3 = BLACK;
		end 
		if(enable) begin
			case(col_sel) 
				0: led0 = GREEN;
				1: led1 = RED;
				2: led2 = BLUE;
				3: led3 = YELLOW; 
			endcase
		end
	end
end


endmodule