`include "src/define.sv"

module shellDisplay (
	//location
	input [5:0] i_display_x,
	input [5:0] i_display_y,
	input [3:0] i_grid_x,
	input [3:0] i_grid_y,

    //shell
    input [5:0] i_shell0_0_x,
    input [5:0] i_shell0_0_y,
    input [5:0] i_shell0_1_x,
    input [5:0] i_shell0_1_y,
    input [5:0] i_shell0_2_x,
    input [5:0] i_shell0_2_y,
    input [5:0] i_shell0_3_x,
    input [5:0] i_shell0_3_y,
    input [5:0] i_shell0_4_x,
    input [5:0] i_shell0_4_y,
    input [4:0] i_shell0_valid,

    input [5:0] i_shell1_0_x,
    input [5:0] i_shell1_0_y,
    input [5:0] i_shell1_1_x,
    input [5:0] i_shell1_1_y,
    input [5:0] i_shell1_2_x,
    input [5:0] i_shell1_2_y,
    input [5:0] i_shell1_3_x,
    input [5:0] i_shell1_3_y,
    input [5:0] i_shell1_4_x,
    input [5:0] i_shell1_4_y,
    input [4:0] i_shell1_valid,

    output logic [23:0] o_rgb_w
);

logic [9:0] mem [0:9];
logic [9:0] col;

`ifdef COMPILE_SMALL
initial $readmemb("resource/dat/gameShell.dat",mem);
`endif

assign col = mem[i_grid_y];

always_comb begin
	o_rgb_w = 24'h0;

	if(col[i_grid_x]) begin
		if( (i_shell0_0_x == i_display_x && i_shell0_0_y == i_display_y && i_shell0_valid[0]) || 
			(i_shell0_1_x == i_display_x && i_shell0_1_y == i_display_y && i_shell0_valid[1]) ||
			(i_shell0_2_x == i_display_x && i_shell0_2_y == i_display_y && i_shell0_valid[2]) ||
			(i_shell0_3_x == i_display_x && i_shell0_3_y == i_display_y && i_shell0_valid[3]) ||
			(i_shell0_4_x == i_display_x && i_shell0_4_y == i_display_y && i_shell0_valid[4]) ) o_rgb_w = `SHELL_0;

		if( (i_shell1_0_x == i_display_x && i_shell1_0_y == i_display_y && i_shell1_valid[0]) || 
			(i_shell1_1_x == i_display_x && i_shell1_1_y == i_display_y && i_shell1_valid[1]) ||
			(i_shell1_2_x == i_display_x && i_shell1_2_y == i_display_y && i_shell1_valid[2]) ||
			(i_shell1_3_x == i_display_x && i_shell1_3_y == i_display_y && i_shell1_valid[3]) ||
			(i_shell1_4_x == i_display_x && i_shell1_4_y == i_display_y && i_shell1_valid[4]) ) o_rgb_w = `SHELL_1;
	end

end

endmodule