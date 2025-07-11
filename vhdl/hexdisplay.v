module hexdisplay (in_HEX, out_SEG);

input [3:0] in_HEX;

output reg [6:0] out_SEG;

always @ (in_HEX)

case (in_HEX)
	4'h0: out_SEG <= 7'b1000000;
	4'h1: out_SEG <= 7'b1111001;
	4'h2: out_SEG <= 7'b0100100;
	4'h3: out_SEG <= 7'b0110000;
	4'h4: out_SEG <= 7'b0011001;
	4'h5: out_SEG <= 7'b0010010;
	4'h6: out_SEG <= 7'b0000010;
	4'h7: out_SEG <= 7'b1111000;
	4'h8: out_SEG <= 7'b0000000;
	4'h9: out_SEG <= 7'b0011000;

endcase

endmodule