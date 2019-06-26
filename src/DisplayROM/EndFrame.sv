`include "src/define.sv"

module EndFrame(
	input  [ 9:0] i_x,
	input  [ 8:0] i_y,
	input  i_is_p1_win,
	output logic [23:0] o_rgb
);

localparam HORIZONTAL =  9'd320;
localparam VERTICAL   =  8'd240;
localparam PIXEL_BITS = 4;

logic [PIXEL_BITS-1 : 0] mem [0 : HORIZONTAL * VERTICAL -1];
logic [23:0] center [0 : (1 << PIXEL_BITS)-1];

logic [16:0] addr;
logic [PIXEL_BITS-1 : 0] current_pixel;
logic [23:0] pixel;

assign addr = i_y[8:1] * HORIZONTAL + i_x[9:1];
assign current_pixel = mem[addr];
assign pixel = center[current_pixel];

always_comb begin
	if(pixel) begin
		if(pixel[23:20] && (pixel[15 : 12] == 0) && (pixel[7 : 4] == 0)) 
			o_rgb = i_is_p1_win ? pixel : {pixel[7:0], pixel[15:8], pixel[23:16]};

		else o_rgb = pixel;
	end  else o_rgb = i_is_p1_win ? 24'h9e0302 : 24'h02039e;
end

`ifdef COMPILE_FRAME
initial $readmemh("resource/dat/tankVictory_labels.dat",mem);
initial $readmemh("resource/dat/tankVictory_values.dat",center);
`endif

endmodule