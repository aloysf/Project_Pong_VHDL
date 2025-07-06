module random_number( 
	input clk,
	input [9:0] limit,
	output reg [9:0] number
);

integer counter=1;

always @ (posedge clk)
begin
	counter = counter +1;
	if (counter > limit) counter=1;
	number = counter;

end

endmodule	
	
	