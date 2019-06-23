`include "src/define.sv"

module Tank0Display(
	input  [5:0] i_game_x,
	input  [5:0] i_game_y,
	input  [3:0] i_grid_x,
	input  [3:0] i_grid_y,
	input  [5:0] i_tank_x,
	input  [5:0] i_tank_y,
	input  [1:0] i_tank_dir,
	output logic [23:0] o_rgb_w
);

logic [ 1:0] mem [0:2499];
logic [23:0] center [0:3];

logic [ 5:0] x_w;
logic [ 5:0] y_w;

assign x_w = (i_game_x + 6'd2 - i_tank_x) * 4'd10 + i_grid_x;
assign y_w = (i_game_y + 6'd2 - i_tank_y) * 4'd10 + i_grid_y;

always_comb begin
	if( i_game_x >= i_tank_x - 6'd2 && i_game_x <= i_tank_x + 6'd2 && 
		i_game_y >= i_tank_y - 6'd2 && i_game_y <= i_tank_y + 6'd2) begin

		case (i_tank_dir)
			2'd0 : o_rgb_w = center[mem[      (y_w  * 50) +          x_w ]]; // up
			2'd1 : o_rgb_w = center[mem[((49 - y_w) * 50) + (49 - x_w)]]; // down
			2'd2 : o_rgb_w = center[mem[      (x_w  * 50) + (49 - y_w)]]; // left
			2'd3 : o_rgb_w = center[mem[((49 - x_w) * 50) +          y_w ]]; // right
		endcase
	end else o_rgb_w = 24'h0;
end

`ifdef COMPILE_SMALL
	initial $readmemh("resource/dat/tank0_4_labels.dat",mem);
	initial $readmemh("resource/dat/tank0_4_values.dat",center);
`endif

endmodule