`include "src/define.sv"

module Wall(
	input [3:0] i_x,
	input [3:0] i_y,
	input i_is_wall,
	input i_sel,
	output logic [23:0] o_rgb_w
);

logic [1:0] mem [0:99];
logic [1:0] pixel;

assign pixel = mem[i_y * 10 + i_x];

always_comb begin
	if(i_is_wall) begin
		case (pixel)
			2'd0 : o_rgb_w = 24'h0;
			2'd1 : o_rgb_w = 24'h010101;
			2'd2 : o_rgb_w = i_sel ? `WALL_0 : `WALL_1;
			default : o_rgb_w = 24'h0;
		endcase
	end else o_rgb_w = 24'h0;

end

`ifdef COMPILE_SMALL
initial begin
	$readmemh("resource/dat/barrel.dat", mem);
end
`endif

endmodule