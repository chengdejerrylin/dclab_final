module Number(
	input [4:0] i_x,
	input [5:0] i_y,
	input [3:0] i_num,
	output o_dot
);

logic [29:0] mem [0:39] [0:9];

logic [29:0] col;

assign col = mem[i_num][i_y];
assign o_dot = col[i_x];

`ifdef COMPILE_SMALL
$readmemb("resource/dat/0.bmp.dat", mem[0]);
$readmemb("resource/dat/1.bmp.dat", mem[1]);
$readmemb("resource/dat/2.bmp.dat", mem[2]);
$readmemb("resource/dat/3.bmp.dat", mem[3]);
$readmemb("resource/dat/4.bmp.dat", mem[4]);
$readmemb("resource/dat/5.bmp.dat", mem[5]);
$readmemb("resource/dat/6.bmp.dat", mem[6]);
$readmemb("resource/dat/7.bmp.dat", mem[7]);
$readmemb("resource/dat/8.bmp.dat", mem[8]);
$readmemb("resource/dat/9.bmp.dat", mem[9]);
`endif
endmodule