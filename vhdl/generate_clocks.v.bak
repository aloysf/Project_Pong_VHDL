module generate_clocks(
    input CLOCK_50,
    output reg clk25, clk100Hz
);

reg clkdiv = 0;
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


endmodule