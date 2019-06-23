`include "src/define.sv"

module VGA(
	input clk, 
	input rst_n,

	//VGA
	output logic [7:0] VGA_B,
	output logic       VGA_BLANK_N,
	output             VGA_CLK,
	output logic [7:0] VGA_G,
	output logic       VGA_HS,
	output logic [7:0] VGA_R,
	output             VGA_SYNC_N,
	output logic       VGA_VS,
    
    //game
    input [1:0] i_state,
    input i_p1_win,
    output logic o_buzy,
    output logic [5:0] o_request_x,
    output logic [5:0] o_request_y,
    input i_is_wall,

    //tank
    input [5:0] i_tank0_x,
    input [5:0] i_tank0_y,
    input [1:0] i_tank0_dir,
    input [5:0] i_tank1_x,
    input [5:0] i_tank1_y,
    input [1:0] i_tank1_dir,

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
);

//protocal
parameter H_SYNC  = 10'd96;
parameter H_BACK  = 10'd48;
parameter H_DISP  = 10'd640;
parameter H_FRONT = 10'd16;
parameter H_TOTAL = 10'd800;

parameter V_SYNC  = 10'd2;
parameter V_BACK  = 10'd33;
parameter V_DISP  = 10'd480;
parameter V_FRONT = 10'd10;
parameter V_TOTAL = 10'd525;

//gamefield
parameter PIXEL_PER_GRID = 4'd10;
parameter STATUS_BAR_HEIGHT = 6'd4;
parameter WIDTH  = H_DISP / PIXEL_PER_GRID;
parameter HEIGHT = V_DISP / PIXEL_PER_GRID;
parameter GAME_HEIGHT = HEIGHT - STATUS_BAR_HEIGHT;

//control
logic [ 9:0] h_counter, n_h_counter;
logic [ 9:0] v_counter, n_v_counter;
logic [ 5:0] display_x, n_display_x;
logic [ 5:0] display_y, n_display_y;
logic [ 3:0] grid_x, n_grid_x;
logic [ 3:0] grid_y, n_grid_y;
logic [ 9:0] frame_x, n_frame_x;
logic [ 8:0] frame_y, n_frame_y;
logic is_display_w;

//VGA
logic [23:0] n_VGA_RGB;
logic n_VGA_HS, n_VGA_VS, n_VGA_BLANK_N;

//IO
logic [5:0] n_o_request_x, n_o_request_y;
logic n_o_buzy;

//frame
logic [23:0] start_rgb, p1_rgb, p2_rgb;

//symbol
logic [5:0] symbol_x_w;
logic [5:0] symbol_y_w;
logic [3:0] symbol_type_w;

logic symbol_dot_w, colon_dot_w;
logic [23:0] tank0_rgb_w, tank1_rgb_w, shell_rgb_w, wall_rgb_w;
logic [23:0] game_rgb_w;

function [2:0] remain;
	input [4:0] valid;
	remain = {2'd0, valid[4]} + {2'd0, valid[3]} + {2'd0, valid[2]} + {2'd0, valid[1]} + {2'd0, valid[0]};
endfunction

/**************************
          assignment
***************************/

//control
assign n_h_counter = (h_counter == (H_TOTAL - 11'd1) ) ? 11'd0 : h_counter + 11'd1;
assign is_display_w = (h_counter >= H_SYNC + H_BACK) && (h_counter < H_SYNC + H_BACK + H_DISP) && 
					  (v_counter >= V_SYNC + V_BACK) && (v_counter < V_SYNC + V_BACK + V_DISP);

//VGA
assign VGA_CLK = clk;
assign VGA_SYNC_N = 1'b0;
assign n_VGA_HS = (h_counter >= H_SYNC);
assign n_VGA_VS = (v_counter >= V_SYNC);
assign n_VGA_BLANK_N = is_display_w;

//IO
assign n_o_buzy = (v_counter >= V_SYNC + V_BACK) && (v_counter < V_SYNC + V_BACK + V_DISP);

//display
assign game_rgb_w = (tank0_rgb_w | tank1_rgb_w) | (shell_rgb_w | wall_rgb_w);

always_comb begin
	symbol_x_w = 6'd0;
	symbol_y_w = 6'd0;
	symbol_type_w = 4'd0;

	case (i_state)
		2'b00 : n_VGA_RGB = start_rgb;

		2'b01 : begin //game
			n_VGA_RGB = 24'd0;

			if(is_display_w) begin
				if(display_y < STATUS_BAR_HEIGHT)begin
					case (display_x)
						6'd1, 6'd2, 6'd3 : begin //shell 0
							symbol_x_w = (display_x - 6'd1)* PIXEL_PER_GRID + grid_x;
							symbol_y_w = display_y * PIXEL_PER_GRID + grid_y;
							symbol_type_w = 4'd10;
							n_VGA_RGB = symbol_dot_w ? `SHELL_0 : `STATUS_BAR_COLOR;
						end
						
						6'd4, 6'd5, 6'd6 : begin //shell 0 remain
							symbol_x_w = (display_x - 6'd4)* PIXEL_PER_GRID + grid_x;
							symbol_y_w = display_y * PIXEL_PER_GRID + grid_y;
							symbol_type_w = remain(i_shell0_valid);
							n_VGA_RGB = symbol_dot_w ? 24'd0 : `STATUS_BAR_COLOR;
						end

						6'd30, 6'd31, 6'd32, 6'd33 : begin //colon
							symbol_x_w = (display_x - 6'd30)* PIXEL_PER_GRID + grid_x;
							symbol_y_w = display_y * PIXEL_PER_GRID + grid_y;
							n_VGA_RGB = colon_dot_w ? 24'd0 : `STATUS_BAR_COLOR;
						end

						6'd57, 6'd58, 6'd59 : begin //shell 1 remain
							symbol_x_w = (display_x - 6'd57)* PIXEL_PER_GRID + grid_x;
							symbol_y_w = display_y * PIXEL_PER_GRID + grid_y;
							symbol_type_w = remain(i_shell1_valid);
							n_VGA_RGB = symbol_dot_w ? 24'd0 : `STATUS_BAR_COLOR;
						end 

						6'd60, 6'd61, 6'd62 : begin //shell 1
							symbol_x_w = (display_x - 6'd60)* PIXEL_PER_GRID + grid_x;
							symbol_y_w = display_y * PIXEL_PER_GRID + grid_y;
							symbol_type_w = 4'd10;
							n_VGA_RGB = symbol_dot_w ? `SHELL_1 : `STATUS_BAR_COLOR;
						end
						
						default : n_VGA_RGB =  `STATUS_BAR_COLOR;
					endcase
				end
				else begin
					n_VGA_RGB = game_rgb_w ? game_rgb_w : `GROUND_COLOR;
				end
			end
		end//game

		2'b10 : n_VGA_RGB = i_p1_win ? p1_rgb : p2_rgb; 
		default : n_VGA_RGB = {frame_y[7:0], ~frame_y[7:0], frame_x[7:0]};
	endcase
end

always_comb begin
	//control
	if(h_counter == H_TOTAL - 11'd1)n_v_counter = (v_counter == (V_TOTAL - 10'd1) ) ? 10'd0 : v_counter + 10'd1;
	else n_v_counter = v_counter;

	if(is_display_w) begin 
		n_grid_x = (grid_x == PIXEL_PER_GRID - 4'd1) ? 4'd0 : grid_x + 4'd1;
		n_frame_x = (frame_x == H_DISP - 10'd1) ? 10'd0 : frame_x + 10'd1;
	end else begin 
		n_grid_x = grid_x;
		n_frame_x = frame_x;
	end

	if(grid_x == PIXEL_PER_GRID - 4'd1) n_display_x = (display_x == WIDTH -6'd1) ? 6'd0 : display_x + 6'd1;
	else n_display_x = display_x;

	if(frame_x == H_DISP - 10'd1 ) begin
		n_grid_y = (grid_y == PIXEL_PER_GRID - 4'd1) ? 4'd0 : grid_y + 4'd1;
		n_frame_y = (frame_y == V_DISP - 9'd1) ? 9'd0 : frame_y + 9'd1;
	end else begin 
		n_grid_y = grid_y;
		n_frame_y = frame_y;
	end

	if((frame_x == H_DISP - 10'd1) && (grid_y == PIXEL_PER_GRID - 4'd1) ) 
		n_display_y = (display_y == HEIGHT -6'd1) ? 6'd0 : display_y + 6'd1;
	else n_display_y = display_y;

	//IO
	if(grid_x == PIXEL_PER_GRID - 4'd2) n_o_request_x = (o_request_x == WIDTH -6'd1) ? 6'd0 : o_request_x + 6'd1;
	else n_o_request_x = o_request_x;

	if((grid_x == PIXEL_PER_GRID - 4'd2) && (display_x == WIDTH - 6'd1) && (grid_y == PIXEL_PER_GRID - 4'd1) && (display_y >= STATUS_BAR_HEIGHT)) 
		n_o_request_y = (o_request_y == GAME_HEIGHT -6'd1) ? 6'd0 : o_request_y + 6'd1;
	else n_o_request_y = o_request_y;
end

StartFrame sf(.i_x(frame_x), .i_y(frame_y), .o_rgb(start_rgb));
p1Frame p1(.i_x(frame_x), .i_y(frame_y), .o_rgb(p1_rgb));
p2artFrame p2(.i_x(frame_x), .i_y(frame_y), .o_rgb(p2_rgb));

Symbol symbol(.i_x(symbol_x_w[4:0]), .i_y(symbol_y_w), .i_type(symbol_type_w), .o_dot(symbol_dot_w));
Colon colon (.i_x(symbol_x_w), .i_y(symbol_y_w), .o_dot(colon_dot_w));

Tank0Display t0(.i_game_x  (display_x), .i_game_y  (display_y - STATUS_BAR_HEIGHT), .i_grid_x  (grid_x), 
	.i_grid_y  (grid_y), .i_tank_x(i_tank0_x), .i_tank_y(i_tank0_y), .i_tank_dir(i_tank0_dir), .o_rgb_w(tank0_rgb_w));
Tank1Display t1(.i_game_x  (display_x), .i_game_y  (display_y - STATUS_BAR_HEIGHT), .i_grid_x  (grid_x), 
	.i_grid_y  (grid_y), .i_tank_x(i_tank1_x), .i_tank_y(i_tank1_y), .i_tank_dir(i_tank1_dir), .o_rgb_w(tank1_rgb_w));

shellDisplay shell(.i_display_x(display_x), .i_display_y(display_y - STATUS_BAR_HEIGHT), .i_grid_x(grid_x),
	.i_grid_y(grid_y), .i_shell0_0_x(i_shell0_0_x), .i_shell0_0_y(i_shell0_0_y), .i_shell0_1_x(i_shell0_1_x), 
	.i_shell0_1_y  (i_shell0_1_y), .i_shell0_2_x(i_shell0_2_x), .i_shell0_2_y(i_shell0_2_y), .i_shell0_3_x(i_shell0_3_x), 
	.i_shell0_3_y  (i_shell0_3_y), .i_shell0_4_x(i_shell0_4_x), .i_shell0_4_y(i_shell0_4_y), .i_shell0_valid(i_shell0_valid), 
	.i_shell1_0_x  (i_shell1_0_x), .i_shell1_0_y(i_shell1_0_y), .i_shell1_1_x(i_shell1_1_x), .i_shell1_1_y(i_shell1_1_y), 
	.i_shell1_2_x  (i_shell1_2_x), .i_shell1_2_y(i_shell1_2_y), .i_shell1_3_x(i_shell1_3_x), .i_shell1_3_y(i_shell1_3_y), 
	.i_shell1_4_x  (i_shell1_4_x), .i_shell1_4_y(i_shell1_4_y), .i_shell1_valid(i_shell1_valid), .o_rgb_w(shell_rgb_w));

Wall wall(.i_x(grid_x), .i_y(grid_y), .i_is_wall(i_is_wall), .i_sel(display_y[0] ^ display_x[0]), .o_rgb_w  (wall_rgb_w));
always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		//control
		h_counter <= 11'd0;
		v_counter <= 10'd0;
		display_x <= 6'd0;
		display_y <= 6'd0;
		grid_x <= 4'd0;
		grid_y <= 4'd0;
		frame_x <= 10'd0;
		frame_y <=  9'd0;

		//VGA
		VGA_R <= 8'd0;
		VGA_G <= 8'd0;
		VGA_B <= 8'd0;
		VGA_HS <= 1'b0;
		VGA_VS <= 1'b0;
		VGA_BLANK_N <= 1'b0;

		//IO
		o_request_x <= 6'd0;
		o_request_y <= 6'd0;
		o_buzy <= 1'b0;
	end else begin
		//control
		h_counter <= n_h_counter;
		v_counter <= n_v_counter;
		display_x <= n_display_x;
		display_y <= n_display_y;
		grid_x <= n_grid_x;
		grid_y <= n_grid_y;
		frame_x <= n_frame_x;
		frame_y <= n_frame_y;

		//VGA
		VGA_R <= n_VGA_RGB[23:16];
		VGA_G <= n_VGA_RGB[16: 8];
		VGA_B <= n_VGA_RGB[ 7: 0];
		VGA_HS <= n_VGA_HS;
		VGA_VS <= n_VGA_VS;
		VGA_BLANK_N <= n_VGA_BLANK_N;

		//IO
		o_request_x <= n_o_request_x;
		o_request_y <= n_o_request_y;
		o_buzy <= n_o_buzy;
	end
end
endmodule