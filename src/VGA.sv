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
    output logic o_buzy,
    input i_is_wall,
    output logic [5:0] o_request_x,
    output logic [5:0] o_request_y,
    
    //tank & shell
    input i_is_tank_1,
    input i_is_tank_2,
    input i_is_shell_1,
    input i_is_shell_2
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
logic [23:0] start_rgb;

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

always_comb begin
	case (i_state)
		2'b00 : n_VGA_RGB = start_rgb;

		2'b01 : begin //game
			n_VGA_RGB = 24'd0;

			if(is_display_w) begin
				if(display_y < STATUS_BAR_HEIGHT)begin
					n_VGA_RGB =  STATUS_BAR_COLOR;
				end
				else begin
					n_VGA_RGB = GROUND_COLOR;
				end
			end
		end
		default : n_VGA_RGB = 24'hffffff;
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
		//IO
		o_request_x <= n_o_request_x;
		o_request_y <= n_o_request_y;
		o_buzy <= n_o_buzy;
	end
end
endmodule