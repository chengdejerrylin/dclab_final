module RandomMap(
	input clk, 
	input rst_n,

	input  [1:0] i_top_state,
	output [64*44-1 : 0] o_map
);
integer i;

logic update, n_update;
logic [31:0] random, n_random;
logic  [3:0] map_idx, n_map_idx;

logic [63:0] map0_mem [0:43];
logic [63:0] map1_mem [0:43];

assign n_update = update ? i_top_state != 2'b10 : i_top_state == 2'b10;
assign n_map_idx = (!update) && i_top_state == 2'b10 ? random[27:24] : map_idx;
assign n_random = random*16807 % 2147483647;

always_comb begin
	for(i = 0; i < 44; i = i+1) begin : encode
		o_map[64*i +: 64] = map_idx[3] ? map0_mem[i] : map1_mem[i];
	end
end

initial begin
	$readmemb ("map/map.dat",  map0_mem);
	$readmemb ("map/map1.dat",  map1_mem);
end

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		update <= 1'b0;
		random <= 32'd37;
		map_idx <= 4'd8;
	end else begin
		update <= n_update;
		random <= n_random;
		map_idx <= n_map_idx;
	end
end

endmodule