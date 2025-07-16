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


//SCREEN PARAMETERS
parameter upper_lim_y=470;
parameter lower_lim_y=5;
parameter upper_lim_x=640;
parameter lower_lim_x=10;
parameter mid_line_x=325;
parameter mid_line_size_x = 1;
parameter mid_y = 238;


//BALL PARAMETERS
//Ball size
parameter BALL_SIZE=5;

//Ball positions
parameter initial_ball_x=mid_line_x;
parameter initial_ball_y=mid_y-3 +disp_shift;

reg[9:0] ball_x;
reg[9:0] ball_y;

//Ball speed
parameter initial_dx=1;
parameter initial_dy=1;


//PADDLE PARAMETERS
parameter paddle_size_x=10;
parameter paddle_size_y=100;

parameter disp_shift = 50;

parameter paddle_1_x=15;
parameter paddle_2_x=630;

parameter initial_paddle_dy = 3;
parameter initial_paddle_y = 200 +disp_shift;

reg [9:0] paddle_1_y;


reg [9:0] paddle_2_y;


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


//RESET
wire reset = SW[17];
wire pause = SW[0];


//SCORES
integer score_1_ones = 0;
integer score_1_tens = 0;

integer score_2_ones = 0;
integer score_2_tens = 0;


//STATE MACHINE
state_machine #(
	.upper_lim_y(upper_lim_y), .lower_lim_y(lower_lim_y), .upper_lim_x(upper_lim_x), .lower_lim_x(lower_lim_x),
	.BALL_SIZE(BALL_SIZE),
	.initial_ball_x(initial_ball_x), .initial_ball_y(initial_ball_y),
	.initial_dx(initial_dx), .initial_dy(initial_dy),
	.paddle_size_x(paddle_size_x), .paddle_size_y(paddle_size_y),
	.disp_shift(disp_shift),
	.paddle_1_x(paddle_1_x), .paddle_2_x(paddle_2_x),
	.initial_paddle_dy(initial_paddle_dy), .initial_paddle_y(initial_paddle_y)
) sm (
	clk100Hz, CLOCK_50, reset, pause,
	btn_1_up, btn_1_down, btn_2_up, btn_2_down,

	score_1_ones, score_1_tens, score_2_ones, score_2_tens,
	paddle_1_y, paddle_2_y,
	ball_x, ball_y
);


//HEX DISPLAY
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
