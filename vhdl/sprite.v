module sprite_score (x_pos, y_pos, x, y, pixel_clk, pixel_out);

input [9:0] x_pos, y_pos; // Position of the sprite
input [9:0] x, y; // Current pixel position
input pixel_clk; // Pixel clock

output [8:0] pixel_out; // Output pixel value

parameter x_offset = 0, y_offset = 0, width = 55, height = 75;

// The image has 19200 pixel entries (160x120)
// the next higher power of 2 is 32768
// So we need 15 address bits

wire [14:0] ram_addr = width * (y-y_pos) + (x-x_pos);

wire [8:0] img0_pixel;

img_rom img0 (ram_addr[14:0], pixel_clk, img0_pixel);

wire visible_rect = ((x > x_pos + x_offset+1) && (x < x_pos + x_offset + width +1) &&
                     (y > y_pos + y_offset) && (y < y_pos + y_offset + height));

assign pixel_out = (visible_rect && ram_addr < 4125) ? img0_pixel : 9'b0;

endmodule