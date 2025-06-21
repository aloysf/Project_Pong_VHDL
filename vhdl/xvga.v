module xvga (clk_25, hcount, vcount, hsync, vsync, blank);

input clk_25;

output [10:0] hcount;
output [9:0] vcount;
output vsync;
output hsync;
output blank;

reg hsync, vsync, hblank, vblank, blank;
reg [10:0] hcount;
reg [9:0] vcount;

wire hsyncon, hsyncoff, hreset, hblankon;

assign hblankon = (hcount == 639);
assign hsyncon = (hcount == 652);
assign hsyncoff = (hcount == 747);
assign hreset = (hcount == 794);

wire vsyncon, vsyncoff, vreset, vblankon;

assign vblankon = hreset & (vcount == 479);
assign vsyncon = hreset & (vcount == 492);
assign vsyncoff = hreset & (vcount == 494);
assign vreset = hreset & (vcount == 527);

wire next_hblank, next_vblank;

assign next_hblank = hreset ? 0 : hblankon ? 1 : hblank;
assign next_vblank = vreset ? 0 : vblankon ? 1 : vblank;

always @ (posedge clk_25)
begin
	hcount <= hreset ? 0 : hcount+1;
	hblank <= next_hblank;  
	hsync <= hsyncon ? 0 : hsyncoff ? 1 : hsync;
	
	vcount <= hreset ? (vreset ? 0 : vcount+1) : vcount;
	vblank <= next_vblank;
	vsync <= vsyncon ? 0 : vsyncoff ? 1 : vsync;
	
	blank <= next_vblank | (next_hblank & ~hreset);
end

endmodule