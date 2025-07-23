module score_display #(parameter x_pos=0, y_pos=0) (input [3:0] score, input clock, output [9:0] R_num, G_num, B_num);

wire [14:0] ram_addr;
wire [8:0] img0pixel;

wire visible_rect = ((x>x_pos+1) && (x<x_pos+55+1)
							&& (y > y_pos) && (y<y_pos+75));
							
wire [8:0] pixel_out;

always @ (posedge clock)
begin
	case (score)
		4'b0000 : digit0 d0 (ram_addr[14:0], clock, img0pixel);
		4'b0001 : digit1 d1 (ram_addr[14:0], clock, img0pixel);
		4'b0010 : digit2 d2 (ram_addr[14:0], clock, img0pixel);
		4'b0011 : digit3 d3 (ram_addr[14:0], clock, img0pixel);
		4'b0100 : digit4 d4 (ram_addr[14:0], clock, img0pixel);
		4'b0101 : digit5 d5 (ram_addr[14:0], clock, img0pixel);
		4'b0110 : digit6 d6 (ram_addr[14:0], clock, img0pixel);
		4'b0111 : digit7 d7 (ram_addr[14:0], clock, img0pixel);
		4'b1000 : digit8 d8 (ram_addr[14:0], clock, img0pixel);
		4'b1001 : digit9 d9 (ram_addr[14:0], clock, img0pixel);
		default : null;
	endcase
end

assign pixel_out = (visible_rect && ram_addr<4125) ? img0pixel:9'b0;
assign R_num = {pixel_out[8:6], 7'b1};
assign G_num = {pixel_out[5:3], 7'b1};
assign B_num = {pixel_out[2:0], 7'b1};

endmodule