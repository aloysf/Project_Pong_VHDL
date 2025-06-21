module vgabild (CLOCK_50, VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B, VGA_BLANK, VGA_CLK);

input CLOCK_50;

output VGA_HS, VGA_VS, VGA_BLANK, VGA_CLK;
output reg [9:0] VGA_R, VGA_G, VGA_B;

wire [9:0] x, y;
wire blank;

// Pixel clock and HV sync

wire pixel_clk;

//pll25 pll (CLOCK_50, pixel_clk);

assign VGA_BLANK = ~blank;
assign VGA_CLK = pixel_clk;

xvga hvsync (pixel_clk, x, y, VGA_HS, VGA_VS, blank);

// Create image from RAM data

wire [8:0] img0_pixel;

sprite img0 (240, 180, x, y, pixel_clk, img0_pixel);

// VGA RGB output

wire [9:0] R = {img0_pixel[8:6], 7'b1};
wire [9:0] G = {img0_pixel[5:3], 7'b1};
wire [9:0] B = {img0_pixel[2:0], 7'b1};

always @(posedge pixel_clk) begin
    VGA_R <= (~blank) ? R : 10'b0;
    VGA_G <= (~blank) ? G : 10'b0;
    VGA_B <= (~blank) ? B : 10'b0;
end

endmodule