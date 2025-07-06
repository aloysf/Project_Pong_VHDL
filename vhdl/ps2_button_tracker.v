module ps2_button_tracker(
	input wire clk, reset, scan_code_ready,
	input wire [7:0] scan_code,
	
	output reg w_down, s_down, up_down, down_down
);

// Internal state
reg break_code=0; 

always @(posedge clk or posedge reset) begin
	if (reset) begin
		w_down <=0;
		s_down <=0;
		up_down <=0;
		down_down <=0;
		break_code <=0;
		
	end 
	else if (scan_code_ready) begin
		case (scan_code)
		
			8'hF0: break_code <= 1;
			
			8'h57: w_down <= ~break_code;	//W
			8'h53: s_down <= ~break_code;	//S
			8'h75: up_down <= ~break_code;	//Up arrow
			8'h72: down_down <= ~break_code;	//Down arrow
			
			default: break_code <= 0;
		endcase
	end
end
endmodule