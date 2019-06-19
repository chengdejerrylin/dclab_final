module StartFrame(
	input  [ 9:0] i_x,
	input  [ 8:0] i_y,
	output [23:0] o_rgb
);

localparam HORIZONTAL =  9'd320;
localparam VERTICAL   =  8'd240;
localparam PIXEL_BITS = 3;

logic [PIXEL_BITS-1 : 0] mem [0 : HORIZONTAL * VERTICAL -1];
logic [16:0] addr;
logic [PIXEL_BITS-1 : 0] current_pixel;

assign addr = i_y * HORIZONTAL + i_x;
assign current_pixel = mem[addr];
assign o_rgb = { {8{current_pixel[2]}}, {8{current_pixel[1]}}, {8{current_pixel[0]}} };

`ifdef COMPILE_FRAME
initial $readmemh("resource/dat/road_rgb_sierra.dat",mem);
`endif
endmodule