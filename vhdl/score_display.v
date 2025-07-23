module score_display #(parameter x_pos=0, y_pos=0) (input [9:0] x,y, input [3:0] score, input clock, output [9:0] R_num, G_num, B_num);

wire [14:0] ram_addr= width*(y-y_pos) + (x-x_pos);
wire [8:0] img0pixel;


parameter width = 27;

integer x_offset = 0;

integer multiplier;

							
wire [8:0] pixel_out;

digits d (ram_addr[14:0], clock, img0pixel);

assign pixel_out = (visible_rect && ram_addr<4125) ? img0pixel:9'b0;

always @ (posedge clock)
begin
	multiplier <= score;
end

wire visible_rect = ((x>x_pos+width*multiplier+1) && (x<x_pos+width*multiplier+width+1)
							&& (y > y_pos) && (y<y_pos+38));

assign R_num = {pixel_out[8:6], 7'b1};
assign G_num = {pixel_out[5:3], 7'b1};
assign B_num = {pixel_out[2:0], 7'b1};

endmodule