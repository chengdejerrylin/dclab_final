`define START_PICTURE "../pic/snow_tree.jpg.dat"
`define SECOND_PICTURE "../pic/arch_nebula.jpg.dat"

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

	//top
	input i_state
);

//protocal
parameter H_SYNC  = 11'd120;
parameter H_BACK  = 11'd64;
parameter H_DISP  = 11'd800;
parameter H_FRONT = 11'd56;
parameter H_TOTAL = 11'd1040;

parameter V_SYNC  = 10'd6;
parameter V_BACK  = 10'd23;
parameter V_DISP  = 10'd600;
parameter V_FRONT = 10'd37;
parameter V_TOTAL = 10'd666;

//control
logic [10:0] h_counter, n_h_counter;
logic [ 9:0] v_counter, n_v_counter;
logic [18:0] pic_addr , n_pic_addr;
logic is_display_w;

//VGA
logic [7:0] n_VGA_R, n_VGA_G, n_VGA_B;
logic n_VGA_HS, n_VGA_VS, n_VGA_BLANK_N;

//mem
logic [2:0] start_pic_mem [0 : (H_DISP * V_DISP -1)];
logic [2:0] second_pic_mem [0 : (H_DISP * V_DISP -1)];
logic [2:0] curr_pixel_w;

//assignment
assign VGA_CLK = clk;
assign VGA_SYNC_N = 1'b0;
assign n_VGA_HS = (h_counter >= H_SYNC);
assign n_VGA_VS = (v_counter >= V_SYNC);
assign n_VGA_BLANK_N = is_display_w;
assign n_h_counter = (h_counter == (H_TOTAL - 11'd1) ) ? 11'd0 : h_counter + 11'd1;
assign is_display_w = (h_counter >= H_SYNC + H_BACK) && (h_counter < H_SYNC + H_BACK + H_DISP) && 
					  (v_counter >= V_SYNC + V_BACK) && (v_counter < V_SYNC + V_BACK + V_DISP);

assign curr_pixel_w = i_state ? second_pic_mem[pic_addr] : start_pic_mem[pic_addr];
// assign curr_pixel_w = i_state ? 24'hFFFF00 : 24'hFFFFFF;
assign n_VGA_R = {8{curr_pixel_w[2]}};
assign n_VGA_G = {8{curr_pixel_w[1]}};
assign n_VGA_B = {8{curr_pixel_w[0]}};

initial begin
	$readmemh(`START_PICTURE, start_pic_mem);
	$readmemh(`SECOND_PICTURE, second_pic_mem);
end 

always_comb begin
	if(h_counter == H_TOTAL - 11'd1)n_v_counter = (v_counter == (V_TOTAL - 10'd1) ) ? 10'd0 : v_counter + 10'd1;
	else n_v_counter = v_counter;

	if(is_display_w)n_pic_addr = (pic_addr == (H_DISP * V_DISP - 19'd1) ) ? 19'd0 : pic_addr + 19'd1;
	else n_pic_addr = pic_addr;
end

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		h_counter <= 11'd0;
		v_counter <= 10'd0;
		pic_addr  <= 19'd0;

		VGA_R <= 8'd0;
		VGA_G <= 8'd0;
		VGA_B <= 8'd0;
		VGA_HS <= 1'b0;
		VGA_VS <= 1'b0;
		VGA_BLANK_N <= 1'b0;
	end else begin
		h_counter <= n_h_counter;
		v_counter <= n_v_counter;
		pic_addr  <= n_pic_addr;

		VGA_R <= n_VGA_R;
		VGA_G <= n_VGA_G;
		VGA_B <= n_VGA_B;
		VGA_HS <= n_VGA_HS;
		VGA_VS <= n_VGA_VS;
		VGA_BLANK_N <= n_VGA_BLANK_N;
	end
end
endmodule