`include "src/define.sv"

module Colon(
	input [5:0] i_x,
	input [5:0] i_y,
	output o_dot
);

logic [39:0] mem [0:39];
logic [39:0] col;

assign col = mem[i_y];
assign o_dot = col[i_x];

`ifdef COMPILE_SMALL
initial begin
	$readmemb("resource/dat/colon.dat", mem);
end
`endif

endmodule