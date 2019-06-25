`include "src/define.sv"

module EndFrame(
	input  [ 9:0] i_x,
	input  [ 8:0] i_y,
	input  i_is_p1_win,
	output logic [23:0] o_rgb
);

localparam HORIZONTAL =  9'd320;
localparam VERTICAL   =  8'd240;
localparam PIXEL_BITS = 3;

logic [PIXEL_BITS-1 : 0] mem [0 : HORIZONTAL * VERTICAL -1];
logic [23:0] center [0 : (1 << PIXEL_BITS)-1];

logic [16:0] addr;
logic [PIXEL_BITS-1 : 0] current_pixel;
logic [23:0] pixel;

assign addr = i_y[8:1] * HORIZONTAL + i_x[9:1];
assign current_pixel = mem[addr];
assign pixel = center[current_pixel];

always_comb begin
	if(pixel) o_rgb = pixel;
	else o_rgb = i_is_p1_win ? `SHELL_0, `SHELL_1;
end

`ifdef COMPILE_FRAME
initial $readmemh("resource/dat/victory_labels.dat",mem);
initial $readmemh("resource/dat/victory_values.dat",center);
`endif

endmodule