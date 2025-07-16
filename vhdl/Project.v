module Project (
	input CLOCK_50, CLOCK_27,
	input [17:0] SW,
	input [3:0] KEY,
	output reg [1:0] LEDR,
	output [6:0] HEX0, HEX1, HEX2, HEX3,
	output [6:0] HEX4, HEX5, HEX6, HEX7,
	output reg [9:0] VGA_R, VGA_G, VGA_B, 
	output VGA_HS, VGA_VS, VGA_BLANK, VGA_CLK
);


//Screen parameters
parameter upper_lim_y=470;
parameter lower_lim_y=5;
parameter upper_lim_x=640;
parameter lower_lim_x=10;
parameter mid_line_x=325;
parameter mid_line_size_x = 1;
parameter mid_y = 238;


//Ball Parameters
parameter initial_ball_x=mid_line_x;
parameter initial_ball_y=mid_y-3 +disp_shift;
parameter BALL_SIZE=5;

//Ball positions
wire [9:0] after_score_ball_y;
random_number rng(CLOCK_50, upper_lim_y, after_score_ball_y);
reg[9:0] ball_x=initial_ball_x;
reg[9:0] ball_y=initial_ball_y;

//Ball speed
integer dx;
integer dy;
parameter initial_dx=1;
parameter initial_dy=1;
wire [9:0] initial_x_dir;
wire [9:0] initial_y_dir;
random_number rng_1 (CLOCK_50, 8, initial_x_dir);
random_number rng_2 (CLOCK_50, 10, initial_y_dir);

initial begin
	dx=initial_dx;
	dy=initial_dy;
end

//Ball collisions
wire ball_hits_paddle_1 =	(ball_x <= paddle_1_x + paddle_size_x ) &&
										(ball_y >= paddle_1_y) &&
										(ball_y <= paddle_1_y + paddle_size_y);
wire ball_hits_paddle_2 =	(ball_x >= paddle_2_x - BALL_SIZE) &&
										(ball_y >= paddle_2_y) &&
										(ball_y <= paddle_2_y + paddle_size_y);
										
reg hit_counter = 0;


//Paddle parameters
parameter paddle_size_x=10;
parameter paddle_size_y=100;

parameter disp_shift = 50;

parameter paddle_1_x=15;
parameter paddle_2_x=630;

parameter initial_paddle_dy = 3;
integer paddle_dy = initial_paddle_dy;

parameter initial_paddle_y = 200 +disp_shift;
reg [9:0] paddle_1_y;
initial paddle_1_y=initial_paddle_y;

reg [9:0] paddle_2_y;
initial paddle_2_y=initial_paddle_y;

//Paddle controls
reg btn_1_down;
reg btn_1_up;
reg btn_2_down;
reg btn_2_up;

//Debouncer for input buttons KEY
debounce btn_deb_0(CLOCK_50, KEY[0], btn_2_down);
debounce btn_deb_1(CLOCK_50, KEY[1], btn_2_up);
debounce btn_deb_2(CLOCK_50, KEY[2], btn_1_down);
debounce btn_deb_3(CLOCK_50, KEY[3], btn_1_up);

//Scores
integer score_1_ones = 0;
integer score_1_tens = 0;

integer score_2_ones = 0;
integer score_2_tens = 0;

//Initialized state
// 000: Initial state
// 001: Game in progress
// 010: Pause state
// 100: Score state
reg [2:0] state = 3'b000;
integer counter_score = 0;
wire reset = SW[17];

// State machine
always @ (posedge clk100Hz)
begin
if (reset) begin
	// Reset
		state <=3'b000;
		score_1_ones <= 0;
		score_1_tens <= 0;
		score_2_ones <= 0;
		score_2_tens <= 0;
		paddle_1_y <= initial_paddle_y;
		paddle_2_y <= initial_paddle_y;
		ball_x <= initial_ball_x;
		ball_y <= initial_ball_y;
		dx <= initial_dx;
		dy <= initial_dy;
end
else
begin
case (state)
	3'b000:	// Initial state
		if ((~btn_1_up || ~btn_1_down) && (~btn_2_up || ~btn_2_down)) state <= 3'b100;

	3'b001:	// Game state
	begin	
		ball_x <= ball_x + dx;
		ball_y <= ball_y + dy;
		
		// Checks if paddle 1 is within the bounds of the screen
		if (paddle_1_y<=upper_lim_y-paddle_size_y+disp_shift && paddle_1_y>=lower_lim_y+disp_shift) begin
			if (~btn_1_down) paddle_1_y <= paddle_1_y+paddle_dy;
			if (~btn_1_up) paddle_1_y <= paddle_1_y-paddle_dy;
		end
		else if (paddle_1_y >= upper_lim_y-paddle_size_y+disp_shift) begin // If it is above the upper limit (lower side of screen), allow only movement upwards (-y direction)
			if (~btn_1_down) paddle_1_y <= paddle_1_y;
			if (~btn_1_up) paddle_1_y <= paddle_1_y-paddle_dy;
		end
		else if (paddle_1_y <= lower_lim_y+disp_shift) begin // If it is above the lower limit (upper side of screen), allow only movement downwards (+y direction)
			if (~btn_1_down) paddle_1_y <= paddle_1_y+paddle_dy;
			if (~btn_1_up) paddle_1_y <= paddle_1_y;
		end

		// Same as above but for paddle 2
		if (paddle_2_y<=upper_lim_y-paddle_size_y+disp_shift && paddle_2_y>=lower_lim_y+disp_shift) begin
			if (~btn_2_down) paddle_2_y <= paddle_2_y+paddle_dy;
			if (~btn_2_up) paddle_2_y <= paddle_2_y-paddle_dy;
		end
		else if (paddle_2_y >= upper_lim_y-paddle_size_y+disp_shift) begin
			if (~btn_2_down) paddle_2_y <= paddle_2_y;
			if (~btn_2_up) paddle_2_y <= paddle_2_y-paddle_dy;
		end
		else if (paddle_2_y <= lower_lim_y+disp_shift) begin
			if (~btn_2_down) paddle_2_y <= paddle_2_y+paddle_dy;
			if (~btn_2_up) paddle_2_y <= paddle_2_y;
		end
		
		// Ball movement
		if (ball_y < lower_lim_y + disp_shift || ball_y > upper_lim_y-BALL_SIZE + disp_shift) begin 
			if (hit_counter==0)	begin
				dy <= -dy;
				hit_counter=~hit_counter;
			end
		end
		else if (ball_hits_paddle_1) begin
			if (hit_counter==0)	begin
				dx = -dx;
				hit_counter=~hit_counter;
				
				if (dx<0) dx=dx-1;
				else dx = dx+1;
				if (dy<0) dy=dy-1;
				else dy = dy+1;
				paddle_dy <= paddle_dy+1;
			end
		end
		else if (ball_hits_paddle_2)  begin
			if (hit_counter==0)	begin
				dx = -dx;
				hit_counter=~hit_counter;
				
				if (dx<0) dx=dx-1;
				else dx = dx+1;
				if (dy<0) dy=dy-1;
				else dy = dy+1;
				paddle_dy <= paddle_dy+1;
			end			
		end
		else
			hit_counter = 0;
		
		// Score
		if (ball_x > upper_lim_x-BALL_SIZE) begin
			ball_x<=initial_ball_x;
			ball_y<=after_score_ball_y;
			state<=3'b100;
			 
			if (score_1_ones == 9) begin
				score_1_ones <= 0;
				score_1_tens <= score_1_tens+1;
				end
			else if (score_1_tens == 9) begin
				score_1_tens <= 0;
				end
			else
				score_1_ones <=score_1_ones+1;
		end
		else if (ball_x < lower_lim_x) begin
			ball_x<=initial_ball_x;
			ball_y<=after_score_ball_y;
			state<=3'b100;
			 
			if (score_2_ones == 9) begin
				score_2_ones <= 0;
				score_2_tens <= score_2_tens+1;
				end
			else if (score_2_tens == 9) begin
				score_2_tens <= 0;
				end
			else
				score_2_ones <=score_2_ones+1;
		end
		
		// Pause state
		// If SW[0] is pressed, go to pause state
		// If SW[0] is released, go back to game state
		if (SW[0]) state <= 3'b010;
	end
	
	3'b010: // Pause state
		if (~SW[0]) state <= 3'b001;
		
	3'b100: // Score state
	begin
		if (initial_x_dir[1]==0)
		begin
			dx <= initial_dx;
			LEDR[0]<=0;
		end
		else
		begin
			dx <= -initial_dx;
			LEDR[0]<=1;
		end
		
		if (initial_y_dir[1]==0) dy <= initial_dy;
		else dy <= -initial_dy;
		
		paddle_dy <= initial_paddle_dy;
		counter_score <= counter_score+1;
		if (counter_score == 50) begin
			counter_score <= 0;
			state <= 3'b001;
		end
	end
endcase
end
end

hexdisplay score_1_ones_disp(score_1_ones ,HEX6);
hexdisplay score_1_tens_disp(score_1_tens ,HEX7);

hexdisplay score_2_ones_disp(score_2_ones ,HEX4);
hexdisplay score_2_tens_disp(score_2_tens ,HEX5); 


//CLOCKS
wire clk25, blank;

// Define 25 MHz clock
reg clkdiv = 0;
reg clk100Hz = 0;
// Define 1s clock
parameter COUNT_MAX = 250000;
integer count = 0;

always @(posedge CLOCK_50)
begin
	clkdiv <= ~clkdiv;
	count <= count + 1;
	if (count == COUNT_MAX) begin
		count <= 0;
		clk100Hz <= ~clk100Hz;
	end
end
	
assign clk25 = clkdiv;

// VGA signals
assign VGA_CLK = clk25;
assign VGA_BLANK = ~blank;

xvga vga(clk25, x, y, VGA_HS, VGA_VS, blank);

// Pixel to VGA
wire [9:0] x, y;

wire ball_on = 	(x >= ball_x) && (x < ball_x + BALL_SIZE) &&
						(y >= ball_y-disp_shift) && (y < ball_y + BALL_SIZE-disp_shift);
						
wire paddle_1 =	(x >= paddle_1_x) && (x < paddle_1_x + paddle_size_x) &&
						(y >= paddle_1_y-disp_shift) && (y < paddle_1_y + paddle_size_y-disp_shift);
						
wire paddle_2 =	(x >= paddle_2_x) && (x < paddle_2_x + paddle_size_x) &&
						(y >= paddle_2_y-disp_shift) && (y < paddle_2_y + paddle_size_y-disp_shift);
						
wire middle_line = (x>= mid_line_x) && (x < mid_line_x + mid_line_size_x) &&
						 (y>= lower_lim_y) && (y < upper_lim_y);

always @ (posedge clk25) begin
	VGA_R <= (~blank && (ball_on || paddle_1 || paddle_2 || middle_line)) ? 10'b1111111111 : 10'b0;
	VGA_G <= (~blank && (ball_on || paddle_1 || paddle_2 || middle_line)) ? 10'b1111111111 : 10'b0;
	VGA_B <= (~blank && (ball_on || paddle_1 || paddle_2 || middle_line)) ? 10'b1111111111 : 10'b0;
end

endmodule
