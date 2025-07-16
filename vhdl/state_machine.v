module state_machine #(parameter upper_lim_y=0, lower_lim_y=0, upper_lim_x=0, lower_lim_x=0,
    BALL_SIZE=0,
    initial_ball_x=0, initial_ball_y=0,
    initial_dx=0, initial_dy=0,
    paddle_size_x=0, paddle_size_y=0,
    disp_shift=0,
    paddle_1_x=0, paddle_2_x=0,
    initial_paddle_dy=0, initial_paddle_y=0

)(
    input clk100Hz, CLOCK_50, reset, pause,
    input btn_1_up, btn_1_down, btn_2_up, btn_2_down,
    
    output integer score_1_ones, score_1_tens, score_2_ones, score_2_tens,
    output reg [9:0] paddle_1_y, paddle_2_y,
    output reg [9:0] ball_x, ball_y
);

//BALL VARIABLES
//Ball positions
wire [9:0] after_score_ball_y;
random_number rng(CLOCK_50, upper_lim_y, after_score_ball_y);

initial ball_x=initial_ball_x;
initial ball_y=initial_ball_y;

// Ball speed
integer dx;
integer dy;
initial begin
	dx=initial_dx;
	dy=initial_dy;
end

// Ball direction
wire [9:0] initial_x_dir;
wire [9:0] initial_y_dir;
random_number rng_1 (CLOCK_50, 8, initial_x_dir);
random_number rng_2 (CLOCK_50, 10, initial_y_dir);

//Ball collisions
wire ball_hits_paddle_1 =	(ball_x <= paddle_1_x + paddle_size_x ) &&
										(ball_y >= paddle_1_y) &&
										(ball_y <= paddle_1_y + paddle_size_y);
wire ball_hits_paddle_2 =	(ball_x >= paddle_2_x - BALL_SIZE) &&
										(ball_y >= paddle_2_y) &&
										(ball_y <= paddle_2_y + paddle_size_y);
										
reg hit_counter = 0;


// PADDLES VARIABLES
integer paddle_dy;
initial paddle_dy = initial_paddle_dy;

initial paddle_1_y=initial_paddle_y;
initial paddle_2_y=initial_paddle_y;


//Initialized state
// 000: Initial state
// 001: Game in progress
// 010: Pause state
// 100: Score state
reg [2:0] state = 3'b000;
integer counter_score = 0;


// STATE MACHINE
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
		if (pause) state <= 3'b010;
	end
	
	3'b010: // Pause state
		if (~pause) state <= 3'b001;
		
	3'b100: // Score state
	begin
		if (initial_x_dir[1]==0)
		begin
			dx <= initial_dx;
		end
		else
		begin
			dx <= -initial_dx;
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

endmodule