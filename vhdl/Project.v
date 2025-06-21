module Project (
	input CLOCK_50,
	input [3:0] KEY,
	output reg [9:0] VGA_R, VGA_G, VGA_B, 
	output VGA_HS, VGA_VS, VGA_BLANK, VGA_CLK
);

wire [9:0] x, y;
wire clk25, blank;

// Define 25 MHz clock
reg clkdiv = 0;
reg clk1s = 0;
// Define 1s clock
parameter COUNT_MAX = 250000;
integer count = 0;

always @(posedge CLOCK_50)
begin
	clkdiv <= ~clkdiv;
	count <= count + 1;
	if (count == COUNT_MAX) begin
		count <= 0;
		clk1s <= ~clk1s;
	end
end
	
assign clk25 = clkdiv;

// VGA signals
assign VGA_CLK = clk25;
assign VGA_BLANK = ~blank;

xvga vga(clk25, x, y, VGA_HS, VGA_VS, blank);

reg[9:0] ball_x=400;
reg[9:0] ball_y=200;
parameter BALL_SIZE=5;

parameter paddle_1_x=15;
reg [9:0] paddle_1_y;
initial paddle_1_y=200;
parameter paddle_2_x=630;
reg [9:0] paddle_2_y;
initial paddle_2_y=200;
parameter paddle_size_x=10;
parameter paddle_size_y=100;

parameter upper_lim_y=380;
parameter lower_lim_y=10;
parameter upper_lim_x=640;
parameter lower_lim_x=15;

integer dx;
integer dy;

initial begin
	dx=-1;
	dy=1;
end

wire btn_1_down;
wire btn_1_up;
wire btn_2_down;
wire btn_2_up;

debounce btn_deb_0(CLOCK_50, KEY[0], btn_2_down);
debounce btn_deb_1(CLOCK_50, KEY[1], btn_2_up);
debounce btn_deb_2(CLOCK_50, KEY[2], btn_1_down);
debounce btn_deb_3(CLOCK_50, KEY[3], btn_1_up);

wire ball_hits_paddle_1 =	(ball_x <= paddle_1_x + paddle_size_x ) &&
										(ball_y >= paddle_1_y) &&
										(ball_y <= paddle_1_y + paddle_size_y);
										

always @ (posedge clk1s)
begin
	//Checks if paddle 1 is within the bounds of the screen
	if (paddle_1_y<=upper_lim_y && paddle_1_y>=lower_lim_y) begin
		if (~btn_1_down) paddle_1_y <= paddle_1_y+1;
		if (~btn_1_up) paddle_1_y <= paddle_1_y-1;
	end
	else if (paddle_1_y >= upper_lim_y) begin // If it is above the upper limit (lower side of screen), allow only movement upwards (-y direction)
		if (~btn_1_down) paddle_1_y <= paddle_1_y;
		if (~btn_1_up) paddle_1_y <= paddle_1_y-1;
	end
	else if (paddle_1_y <= lower_lim_y) begin // If it is above the lower limit (upper side of screen), allow only movement downwards (+y direction)
		if (~btn_1_down) paddle_1_y <= paddle_1_y+1;
		if (~btn_1_up) paddle_1_y <= paddle_1_y;
	end
	 //Same as above but for paddle 2
	if (paddle_2_y<=upper_lim_y && paddle_2_y>=lower_lim_y) begin
		if (~btn_2_down) paddle_2_y <= paddle_2_y+1;
		if (~btn_2_up) paddle_2_y <= paddle_2_y-1;
	end
	else if (paddle_2_y >= upper_lim_y) begin
		if (~btn_2_down) paddle_2_y <= paddle_2_y;
		if (~btn_2_up) paddle_2_y <= paddle_2_y-1;
	end
	else if (paddle_2_y <= lower_lim_y) begin
		if (~btn_2_down) paddle_2_y <= paddle_2_y+1;
		if (~btn_2_up) paddle_2_y <= paddle_2_y;
	end
	
	ball_x <= ball_x + dx;
	ball_y <= ball_y + dy;
	

	
	


	
	
	
end

wire ball_on = 	(x >= ball_x) && (x < ball_x + BALL_SIZE) &&
						(y >= ball_y) && (y < ball_y + BALL_SIZE);
						
wire paddle_1 =	(x >= paddle_1_x) && (x < paddle_1_x + paddle_size_x) &&
						(y >= paddle_1_y) && (y < paddle_1_y + paddle_size_y);
						
wire paddle_2 =	(x >= paddle_2_x) && (x < paddle_2_x + paddle_size_x) &&
						(y >= paddle_2_y) && (y < paddle_2_y + paddle_size_y);

always @ (posedge clk25) begin
	VGA_R <= (~blank && (ball_on || paddle_1 || paddle_2)) ? 10'b1111111111 : 10'b0;
	VGA_G <= (~blank && (ball_on || paddle_1 || paddle_2)) ? 10'b1111111111 : 10'b0;
	VGA_B <= (~blank && (ball_on || paddle_1 || paddle_2)) ? 10'b1111111111 : 10'b0;
	
	if (ball_y <= lower_lim_y || ball_y >= upper_lim_y-BALL_SIZE) dy <= -dy;
	if (ball_x <= lower_lim_x || ball_x >= upper_lim_x-BALL_SIZE) dx <= -dx;
	if (ball_hits_paddle_1) dx <= -dx;
end

endmodule
