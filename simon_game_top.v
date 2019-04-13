module simon_game_top (
	inout  [7:0] lcd_data,
	output [2:0] led0, led1, led2, led3,
	output lcd_enable, lcd_read, lcdregsel, spkr_out,
	output reg [7:0] nex_led,
	output [7:0] sev_seg, 
	output reg [3:0] anodes,
	input  [7:0] nex_btn, sim_btn,
	input switch,
	input reset, clk 
);

wire [3:0] sim_btn_n = ~sim_btn;

localparam [3:0] ASC = 4'b0011;
localparam SEC = (50000000 - 1);

localparam  SIMON_INIT = 0,
				SIMON_BTN_HELD = 1,
				SIMON_BTN_PLAY_NOTE = 2,
				SIMON_WAIT = 3,
				SIMON_CHK_ROUND = 4,
				SIMON_PLAYER_BTN_PRESS = 5,
				SIMON_PLAYER_BTN_HELD = 6,
				SIMON_BTN_VALIDATE = 7,
				SIMON_CHK_PLAYER_ROUND = 8,
				SIMON_PAUSE_0 = 9,
				SIMON_SUCESS_TONE_1 = 10,
				SIMON_PAUSE_1 = 11,
				SIMON_SUCESS_TONE_2 = 12,
				SIMON_PAUSE_2 = 13,
				SIMON_LOSER = 14,
				SIMON_INIT_0 = 15,
				SIMON_SUCESS_TONE_3 = 16,
				SIMON_PAUSE_3 = 17,
				SIMON_SUCESS_TONE_4 = 18,
				SIMON_PAUSE_4 = 19,
				SIMON_LOSER_PAUSE_0 = 20,
				SIMON_LOSER_PAUSE_1 = 21,
				SIMON_LOSER_PAUSE_2 = 22,
				SIMON_LOSER_PAUSE_3 = 23,
				SIMON_LOSER_PAUSE_4 = 24,
				SIMON_LOSER_PAUSE_5 = 25,
				SIMON_LOSER_PAUSE_6 = 26,
				SIMON_LOSER_PAUSE_7 = 27,
				SIMON_LOSER_PAUSE_8 = 28,
				SIMON_LOSER_TONE_1 = 29,
				SIMON_LOSER_TONE_2 = 30,
				SIMON_LOSER_TONE_3 = 31,
				SIMON_LOSER_TONE_4 = 32,
				SIMON_LOSER_TONE_5 = 33,
				SIMON_LOSER_TONE_6 = 34,
				SIMON_LOSER_TONE_7 = 35,
				SIMON_LOSER_TONE_8 = 36,
				SIMON_LOSER_TONE_9 = 37,
				SIMON_LOSER_PAUSE_9 = 38,
				SIMON_PLAY_NOTE_PAUSE = 39,
				SIMON_LOSER_TONE_10 = 40,
				SIMON_LOSER_PAUSE_10 = 41;
reg step_w, rerun_w, reset_w, randomize_w;
wire [1:0] random_w;

reg [1:0] col_sel_w;
reg [2:0] tone_sel_w;
reg spkr_enable, led_enable;

reg [15:0] score_count_bcd;
reg [11:0] score, round;
wire [3:0] sc_ones, sc_tens;
reg score_inc, score_reset, round_inc, round_reset;

reg [1:0] player_press, sim_btn_encoded;
wire [3:0] sim_btn_released, sim_btn_held, sim_btn_pressed, nex_btn_released, nex_btn_held, nex_btn_pressed;

reg [8*16-1:0] topline, bottomline;
reg lcd_reset;
reg lcd_string_print;

reg timer_reset, timer_enable;
reg [49:0] timer, timer_max_val, timer_reset_value;

reg [35:0] loser_timer_reset, loser_timer;

reg [7:0] state, next_state;

reg [3:0] pulse = 0;

wire [7:0] randLA;
reg [1:0] A, B, C, D;
wire [3:0] anodes_w;

reg loser;

seg_ctrl SC (
	.segments_n (sev_seg),
	.anodes_n (anodes_w),
	.D (D),
	.C (C),
	.B (B),
	.A (A),
	.clk(clk)
);

binary_to_BCD BTBN (
	.ONES ( sc_ones ),
	.TENS ( sc_tens ),
	.A    (round - 1)
);

PRNG PRNG_M (
	.random    ( random_w ), //This controls the led and tone
	.randLA    ( randLA  ),
	.step      ( step_w ),
	.rerun     ( rerun_w ),
	.randomize ( randomize_w ),
	.reset     ( reset_w  ),
	.clk       ( clk            )
);

lcd_string LS (
	.lcd_regsel(lcdregsel),
	.lcd_read  (lcd_read),
	.lcd_enable(lcd_enable),
	.lcd_data  (lcd_data), 
	.available(lcd_string_available),
	.print(lcd_string_print),
	.topline(topline),
	.bottomline(bottomline),
	.reset(lcd_reset),
	.clk(clk) 
);

simon_led_ctrl SLC (
	.led0     ( led0     ),
	.led1     ( led1     ),
	.led2     ( led2     ),
	.led3     ( led3     ),
	.col_sel  ( col_sel_w ),
	.enable   ( led_enable ),
	.loser    ( loser  ),
	.clk      ( clk )
);

top_spkr TS(
	.speaker  ( spkr_out),
	.tone_sel ( tone_sel_w),
	.SE          ( spkr_enable),
	.clk          ( clk)
);

/****DEBOUNCERS****/
debouncer DB0 (
	.released ( nex_btn_released [0] ),
	.held ( nex_btn_held [0] ),
	.pressed ( nex_btn_pressed [0] ),
	.button  ( nex_btn [0]  ),
	.clk     ( clk            )
);
debouncer DB1 (
	.released ( nex_btn_released [1] ),
	.held ( nex_btn_held [1] ),
	.pressed ( nex_btn_pressed [1] ),
	.button  ( nex_btn [1]  ), 
	.clk     ( clk            )
);
debouncer DB2 (
	.released ( nex_btn_released [2] ),
	.held ( nex_btn_held [2] ),
	.pressed ( nex_btn_pressed [2] ),
	.button  ( nex_btn [2]  ),
	.clk     ( clk            )
);
debouncer DB3 (
	.released ( nex_btn_released [3] ),
	.held ( nex_btn_held [3] ),
	.pressed ( nex_btn_pressed [3] ),
	.button  ( nex_btn[3]  ),
	.clk     ( clk            )
);

debouncer DB4 (
	.released ( sim_btn_released [0] ),
	.held ( sim_btn_held [0] ),
	.pressed ( sim_btn_pressed [0] ),
	.button  ( sim_btn_n[0]  ),
	.clk     ( clk            )
);
debouncer DB5 (
	.released ( sim_btn_released [1] ),
	.held ( sim_btn_held [1] ),
	.pressed ( sim_btn_pressed [1] ),
	.button  ( sim_btn_n[1]  ), 
	.clk     ( clk            )
);
debouncer DB6 (
	.released ( sim_btn_released [2] ),
	.held ( sim_btn_held [2] ),
	.pressed ( sim_btn_pressed [2] ),
	.button  ( sim_btn_n[2]  ),
	.clk     ( clk            )
);
debouncer DB7 (
	.released ( sim_btn_released [3] ),
	.held ( sim_btn_held [3] ),
	.pressed ( sim_btn_pressed [3] ),
	.button  ( sim_btn_n[3]  ),
	.clk     ( clk            )
);


/****CHEATMODE****/
always @ (posedge clk) begin
	if (switch) begin
		A <= {randLA[4], randLA[0]};
		B <= {randLA[5], randLA[1]};
		C <= {randLA[6], randLA[2]};
		D <= {randLA[7], randLA[3]};
		anodes <= anodes_w;
	end
	else anodes <= 4'b1111;
end

/****SCORECOUNT****/
always @ (posedge clk) begin
	if (score_reset)
		score <= 0;
	else if (score_inc)
		score <= score + 1;
end

/****ROUNDCOUNT****/
always @ (posedge clk) begin
	if (round_reset)
		round <= 1;
	else if (round_inc)
		round <= round + 1;
end

/****SIMBTNENCODER****/
always @ * begin
	sim_btn_encoded = 0;
	case(sim_btn_held)
		4'b0001: sim_btn_encoded = 0; // 00 GREEN
		4'b0010: sim_btn_encoded = 1; // 01 RED
		4'b0100: sim_btn_encoded = 2; // 10 BLUE
		4'b1000: sim_btn_encoded = 3; // 11 YELL
	endcase
end

/****GETPLAYERENTRY****/
always @(posedge clk) begin
	if(sim_btn_held) begin
		player_press <= sim_btn_encoded;
	end
end

always @ * begin 
	nex_led [0] =  random_w [1];
	nex_led [1] =  random_w [0];
	nex_led [2] = sim_btn_encoded [1];
	nex_led [3] = sim_btn_encoded [0];
	nex_led [4] = sim_btn_held [3];
	nex_led [5] = sim_btn_held [2];
	nex_led [6] = sim_btn_held [1];
	nex_led [7] = sim_btn_held [0];
end

/****STATEHANDLER****/
always @ (posedge clk) begin
	if (reset)
		state <= SIMON_INIT;
	else
		state <= next_state;
end

/****TIMER****/
always @(posedge clk) begin
	if (timer_reset) begin
		timer <= 0;
	end
	else begin
		timer <= timer + 1;
		if (timer >= SEC) begin
			timer <=0;
		end
	end
end

/****LOSERTIMER****/
always @(posedge clk) begin
	if (loser_timer_reset) begin
		loser_timer <= 0;
	end
	else begin
		loser_timer <= loser_timer + 1;
		if (loser_timer >= 59700000) begin
			loser_timer <=0;
		end
	end
end
always @* begin

	//DEFAULTS
	step_w = 0;
	rerun_w = 0;
	randomize_w = 0;
	next_state = state;
	spkr_enable = 0;
	led_enable = 0;
	lcd_reset = 0;
	score_inc = 0;
	score_reset = 0;
	round_inc =0;
	round_reset = 0;
	timer_reset = 0;
	timer_enable = 1;
	score_count_bcd = {ASC, sc_tens, ASC, sc_ones};
	loser = 0;
	loser_timer_reset = 0;
	case(state)
		SIMON_INIT_0: begin
			if(timer >= 100000) begin
				lcd_reset = 1;
				next_state = SIMON_INIT;
			end
		end
		SIMON_INIT: begin
			
			topline    = "  WELCOME PRESS ";
			bottomline = " GREEN TO PLAY  ";
			timer_reset_value = 0;
			timer_reset = 1;
			timer_max_val = SEC;
			score_reset = 1;
			round_reset = 1;
			led_enable = 1;
			col_sel_w = 2'b00;
			if (sim_btn_held[0]) begin
				next_state = SIMON_BTN_HELD;
			end
		end
		
		SIMON_BTN_HELD: begin
			topline    = "                ";
			bottomline = "                ";
			randomize_w = 1;
			if (!sim_btn_held) begin
				timer_reset = 1;
				next_state = SIMON_PLAY_NOTE_PAUSE;
			end
		end
		
		SIMON_PLAY_NOTE_PAUSE: begin
			topline    = "     MY TURN!   ";
			bottomline = {"PLAYER SCORE  ",score_count_bcd};
			if(timer >= 3750000) begin
				next_state = SIMON_BTN_PLAY_NOTE;
			end
		end
	
		SIMON_BTN_PLAY_NOTE: begin
			topline    = "     MY TURN!   ";
			bottomline = {"PLAYER SCORE  ",score_count_bcd};
			spkr_enable = 1;
			led_enable = 1;
			tone_sel_w = random_w;
			col_sel_w = random_w;
			if (/*nex_btn_pressed[0]*/timer >= 37500000) begin
				next_state = SIMON_WAIT;
			end
		end

		SIMON_WAIT: begin
			topline    = "     MY TURN!   ";
			bottomline = {"PLAYER SCORE  ",score_count_bcd};
			if (/*nex_btn_pressed[1]*/timer >= SEC) begin
				step_w = 1;
				score_inc = 1;
				next_state = SIMON_CHK_ROUND;
			end
		end

		SIMON_CHK_ROUND: begin
			topline    = "     MY TURN!   ";
			bottomline = {"PLAYER SCORE  ",score_count_bcd};
			if (score >= round) begin
				score_reset = 1;
				rerun_w = 1;
				next_state = SIMON_PLAYER_BTN_PRESS;
			end
			else begin
				next_state = SIMON_BTN_PLAY_NOTE;
			end
		end
		
		SIMON_PLAYER_BTN_PRESS: begin
			topline    = "  YOUR TURN!    ";
			bottomline = {"PLAYER SCORE  ",score_count_bcd};
			if (nex_btn_pressed[3]) begin
				timer_reset = 1;
				next_state = SIMON_BTN_PLAY_NOTE;
			end 
			else if (sim_btn_held) begin
				next_state = SIMON_PLAYER_BTN_HELD;
			end
		end

		SIMON_PLAYER_BTN_HELD: begin
			topline    = "                ";
			bottomline = {"PLAYER SCORE  ",score_count_bcd};
			spkr_enable = 1;
			led_enable = 1;
			col_sel_w = sim_btn_encoded;
			tone_sel_w = sim_btn_encoded;
			if(!sim_btn_held) begin
				next_state = SIMON_BTN_VALIDATE;
			end
		end
				
		SIMON_BTN_VALIDATE: begin
			if (player_press == random_w) begin
				score_inc = 1;
				step_w = 1;
				next_state = SIMON_CHK_PLAYER_ROUND;
			end
			else begin
				next_state = SIMON_LOSER_PAUSE_0;
			end
		end
	
		SIMON_CHK_PLAYER_ROUND: begin
			topline    = "                ";
			bottomline = "                ";
			if (score >= round) begin
				score_reset = 1;
				rerun_w = 1;
				round_inc = 1;
				timer_reset = 1;
				next_state = SIMON_PAUSE_0;
			end
			else begin
				next_state = SIMON_PLAYER_BTN_PRESS;
			end
		end
		SIMON_PAUSE_0: begin
			topline    = "                ";
			bottomline = "                ";
			if (timer >= SEC) begin
				next_state = SIMON_SUCESS_TONE_1;
			end
		end
		SIMON_SUCESS_TONE_1: begin
			topline    = "   SUCCESS!!!!! ";
			bottomline = "                ";
			spkr_enable = 1;
			led_enable = 1;
			tone_sel_w = 2'b00;
			col_sel_w = 2'b00;
			if (timer >= 20000000) begin
				timer_reset = 1;
				next_state = SIMON_PAUSE_1;
			end
		end
		
		SIMON_PAUSE_1: begin
			topline    = "   SUCCESS!!!!! ";
			bottomline = "                ";
			if (timer >= 2000000) begin
				timer_reset = 1;
				next_state = SIMON_SUCESS_TONE_2;
			end
		end
		
		SIMON_SUCESS_TONE_2: begin
			topline    = "   SUCCESS!!!!! ";
			bottomline = "                ";
			spkr_enable = 1;
			led_enable = 1;
			tone_sel_w = 2'b01;
			col_sel_w = 2'b01;
			if (timer >= 20000000) begin
				timer_reset = 1;
				next_state = SIMON_PAUSE_2;
			end
		end
		
		SIMON_PAUSE_2: begin
			topline    = "   SUCCESS!!!!! ";
			bottomline = "                ";
			if (timer >= 2000000) begin
				timer_reset = 1;
				next_state = SIMON_SUCESS_TONE_3;
			end
		end

		SIMON_SUCESS_TONE_3: begin
			topline    = "   SUCCESS!!!!! ";
			bottomline = "                ";
			spkr_enable = 1;
			led_enable = 1;
			tone_sel_w = 2'b10;
			col_sel_w = 2'b10;
			if (timer >= 20000000) begin
				timer_reset = 1;
				next_state = SIMON_PAUSE_3;
			end
		end
		
		SIMON_PAUSE_3: begin
			topline    = "   SUCCESS!!!!! ";
			bottomline = "                ";
			if (timer >= 2000000) begin
				timer_reset = 1;
				next_state = SIMON_SUCESS_TONE_4;
			end
		end
		
		SIMON_SUCESS_TONE_4: begin
			topline    = "   SUCCESS!!!!! ";
			bottomline = "                ";
			spkr_enable = 1;
			led_enable = 1;
			tone_sel_w = 2'b11;
			col_sel_w = 2'b11;
			if (timer >= 20000000) begin
				timer_reset = 1;
				next_state = SIMON_PAUSE_4;
			end
		end
		
		SIMON_PAUSE_4: begin
			topline    = "                ";
			bottomline = "                ";
			if (timer >= SEC) begin
				timer_reset = 1;
				next_state = SIMON_BTN_PLAY_NOTE;
			end
		end
/*
B3, C4#, D4, D4, C4#, A3, C4#, C4#, B3


001, 010, 011, 011, 010, 000, 010, 010, 001

*/
		SIMON_LOSER_PAUSE_0: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			if(timer >= SEC) begin
				next_state = SIMON_LOSER_TONE_1;
			end
		end
		
		SIMON_LOSER_TONE_1: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			spkr_enable = 1;
			led_enable = 1;
			tone_sel_w = 3'b001;
			loser = 1;
			//col_sel_w = 2'b01;
			if (loser_timer >= 59700000) begin
				loser_timer_reset = 1;
				next_state = SIMON_LOSER_PAUSE_1;
			end
		end
		
		SIMON_LOSER_PAUSE_1: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			if (loser_timer >= 200000) begin
				loser_timer_reset = 1;
				next_state = SIMON_LOSER_TONE_2;
			end
		end
		
		SIMON_LOSER_TONE_2: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			spkr_enable = 1;
			led_enable = 1;
			tone_sel_w = 3'b010;
			loser = 1;
			//col_sel_w = 2'b10;
			if (loser_timer >= 8550000) begin
				loser_timer_reset = 1;
				next_state = SIMON_LOSER_PAUSE_2;
			end
		end
		
		SIMON_LOSER_PAUSE_2: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			if (loser_timer >= 200000) begin
				loser_timer_reset = 1;
				next_state = SIMON_LOSER_TONE_3;
			end
		end

		SIMON_LOSER_TONE_3: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			spkr_enable = 1;
			led_enable = 1;
			tone_sel_w = 3'b011;
			loser = 1;
			//col_sel_w = 2'b01;
			if (loser_timer >= 34100000) begin
				loser_timer_reset = 1;
				next_state = SIMON_LOSER_PAUSE_3;
			end
		end
		
		SIMON_LOSER_PAUSE_3: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			if (loser_timer >= 200000) begin
				loser_timer_reset = 1;
				next_state = SIMON_LOSER_TONE_4;
			end
		end
		
		SIMON_LOSER_TONE_4: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			spkr_enable = 1;
			led_enable = 1;
			tone_sel_w = 3'b011;
			loser = 1;
			//col_sel_w = 2'b00;
			if (loser_timer >= 51150000) begin
				loser_timer_reset = 1;
				next_state = SIMON_LOSER_PAUSE_4;
			end
		end
		
		SIMON_LOSER_PAUSE_4: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			if (loser_timer >= 200000) begin
				loser_timer_reset = 1;
				next_state = SIMON_LOSER_TONE_5;
			end
		end
			
		SIMON_LOSER_TONE_5: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			spkr_enable = 1;
			led_enable = 1;
			tone_sel_w = 3'b011;
			loser = 1;
			//col_sel_w = 2'b00;
			if (loser_timer >= 51150000) begin
				loser_timer_reset = 1;
				next_state = SIMON_LOSER_PAUSE_5;
			end
		end
		
		SIMON_LOSER_PAUSE_5: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			if (loser_timer >= 200000) begin
				loser_timer_reset = 1;
				next_state = SIMON_LOSER_TONE_6;
			end
		end

		SIMON_LOSER_TONE_6: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			spkr_enable = 1;
			led_enable = 1;
			tone_sel_w = 3'b010;
			loser = 1;
			//col_sel_w = 2'b01;
			if (loser_timer >= 51150000) begin
				loser_timer_reset = 1;
				next_state = SIMON_LOSER_PAUSE_6;
			end
		end
		
		SIMON_LOSER_PAUSE_6: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			if (loser_timer >= 200000) begin
				loser_timer_reset = 1;
				next_state = SIMON_LOSER_TONE_7;
			end
		end
		
		SIMON_LOSER_TONE_7: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			spkr_enable = 1;
			led_enable = 1;
			tone_sel_w = 3'b000;
			loser = 1;
			//col_sel_w = 2'b10;
			if (loser_timer >= 51150000) begin
				loser_timer_reset = 1;
				next_state = SIMON_LOSER_PAUSE_7;
			end
		end
		
		SIMON_LOSER_PAUSE_7: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			if (loser_timer >= 200000) begin
				loser_timer_reset = 1;
				next_state = SIMON_LOSER_TONE_8;
			end
		end

		SIMON_LOSER_TONE_8: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			spkr_enable = 1;
			led_enable = 1;
			tone_sel_w = 3'b010;
			loser = 1;
			//col_sel_w = 2'b01;
			if (loser_timer >= 51150000) begin
				loser_timer_reset = 1;
				next_state = SIMON_LOSER_PAUSE_8;
			end
		end
		
		SIMON_LOSER_PAUSE_8: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			if (loser_timer >= 200000) begin
				loser_timer_reset = 1;
				next_state = SIMON_LOSER_TONE_9;
			end
		end
		
		SIMON_LOSER_TONE_9: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			spkr_enable = 1;
			led_enable = 1;
			tone_sel_w = 3'b010;
			loser = 1;
			//col_sel_w = 2'b00;
			if (loser_timer >= 51150000) begin
				loser_timer_reset = 1;
				next_state = SIMON_LOSER_PAUSE_9;
			end
		end
		
		SIMON_LOSER_PAUSE_9: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			if (loser_timer >= 200000) begin
				loser_timer_reset = 1;
				next_state = SIMON_LOSER_TONE_10;
			end
		end
		
		SIMON_LOSER_TONE_10: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			spkr_enable = 1;
			led_enable = 1;
			tone_sel_w = 3'b001;
			loser = 1;
			//col_sel_w = 2'b00;
			if (loser_timer >= 51150000) begin
				loser_timer_reset = 1;
				next_state = SIMON_LOSER_PAUSE_10;
			end
		end		
		SIMON_LOSER_PAUSE_10: begin
			topline    = "  NO...  NO...  ";
			bottomline = "YOU HAVE LOST!!!";
			if (loser_timer >= SEC) begin
				loser_timer_reset = 1;
				next_state = SIMON_INIT;
			end
		end
	endcase
end

/****LCDPRINTER****/
always @* begin
	lcd_string_print = 0;
	if (lcd_string_available) begin
		lcd_string_print = 1;
	end
end

/****TIMER***
always @(posedge clk) begin
	if (timer_reset) begin
		timer <= timer_reset_value;
	end
	else if (timer_enable) begin
		timer <= timer + 1;
		if (timer >= timer_max_val)
			timer <=0;
	end
end*/

endmodule