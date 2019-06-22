`include "src/define.sv"

module Symbol(
	input [4:0] i_x,
	input [5:0] i_y,
	input [3:0] i_type,
	output o_dot
);

logic [29:0] mem0 [0:39];
logic [29:0] mem1 [0:39];
logic [29:0] mem2 [0:39];
logic [29:0] mem3 [0:39];
logic [29:0] mem4 [0:39];
logic [29:0] mem5 [0:39];
logic [29:0] mem6 [0:39];
logic [29:0] mem7 [0:39];
logic [29:0] mem8 [0:39];
logic [29:0] mem9 [0:39];
logic [29:0] memA [0:39];

logic [29:0] all_col [0:10];
logic [29:0] col;

assign all_col[0]  = mem0[i_y];
assign all_col[1]  = mem1[i_y];
assign all_col[2]  = mem2[i_y];
assign all_col[3]  = mem3[i_y];
assign all_col[4]  = mem4[i_y];
assign all_col[5]  = mem5[i_y];
assign all_col[6]  = mem6[i_y];
assign all_col[7]  = mem7[i_y];
assign all_col[8]  = mem8[i_y];
assign all_col[9]  = mem9[i_y];
assign all_col[10] = memA[i_y];

assign col = all_col[i_type];
assign o_dot = col[i_x];

`ifdef COMPILE_SMALL
initial begin
	$readmemb("resource/dat/0.bmp.dat", mem0);
	$readmemb("resource/dat/1.bmp.dat", mem1);
	$readmemb("resource/dat/2.bmp.dat", mem2);
	$readmemb("resource/dat/3.bmp.dat", mem3);
	$readmemb("resource/dat/4.bmp.dat", mem4);
	$readmemb("resource/dat/5.bmp.dat", mem5);
	$readmemb("resource/dat/6.bmp.dat", mem6);
	$readmemb("resource/dat/7.bmp.dat", mem7);
	$readmemb("resource/dat/8.bmp.dat", mem8);
	$readmemb("resource/dat/9.bmp.dat", mem9);
end
`endif

endmodule