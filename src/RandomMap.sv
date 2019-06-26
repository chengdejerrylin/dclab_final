module RandomMap(
	input clk, 
	input rst_n,

	input  [1:0] i_top_state,
	input  [5:0] i_hit_x,
	input  [5:0] i_hit_y,
	input  i_hit_valid,
	output logic [64*44-1 : 0] o_map
);
integer i;
localparam WALL_LIFE = 3;

logic update, n_update;
logic [31:0] random, n_random;
logic  [3:0] map_idx, n_map_idx;

//map
logic [64*44-1 : 0] n_o_map;
logic [2:0] wall_life [0: 64*44 -1];
logic [2:0] n_wall_life [0: 64*44 -1];

logic [63:0] map0_mem [0:43];
logic [63:0] map1_mem [0:43];
logic [63:0] map2_mem [0:43];

assign n_update = i_top_state == 2'b10;
assign n_map_idx = (!update) && i_top_state == 2'b10 ? random[27:24] : map_idx;
assign n_random = random*16807 % 2147483647;

always_comb begin
	for(i = 0; i < 64*44; i = i+1) begin : encode
		n_o_map[(i/64)*64 + (63 - i%64)] = map2_mem[i/64][63-i%64] && (wall_life[i] != 3'd0);

		if(i_top_state == 2'b01) begin
			n_wall_life[i] = wall_life[i];
			if(i_hit_valid && i/64 == i_hit_y && i%64 == i_hit_x)
				n_wall_life[i] = wall_life[i] ? wall_life[i] - 3'd1 : 3'd0;

		end else n_wall_life[i] = WALL_LIFE;
	end
end

initial begin
	$readmemb ("map/map.dat",  map0_mem);
	$readmemb ("map/map1.dat",  map1_mem);
	$readmemb ("map/map2.dat",  map2_mem);
end

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		update <= 1'b0;
		random <= 32'd37;
		map_idx <= 4'd8;

		o_map <= 0;
		for(i = 0; i < 64*44; i = i+1) begin : wall_seq
			wall_life[i] <= WALL_LIFE;
		end
	end else begin
		update <= n_update;
		random <= n_random;
		map_idx <= n_map_idx;

		o_map <= n_o_map;
		for(i = 0; i < 64*44; i = i+1) begin : wall_seq1
			wall_life[i] <= n_wall_life[i];
		end
	end
end

endmodule