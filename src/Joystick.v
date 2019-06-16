module Joystick (
	input clk, 
	input rst_n,

	input i_up,
	input i_down,
	input i_left,
	input i_right,
	input i_fire, 

	output o_up,
	output o_down,
	output o_left,
	output o_right,
	output o_fire,
	output [4:0] o_led
);
assign o_vdd = 1'b1;
assign o_gnd = 1'b0;
assign o_led = {o_up, o_down, o_left, o_right, o_fire};

Debounce up   (.i_in(i_up)   , .i_clk(clk), .i_rst(rst_n), .o_debounced(o_up   ));
Debounce down (.i_in(i_down) , .i_clk(clk), .i_rst(rst_n), .o_debounced(o_down ));
Debounce left (.i_in(i_left) , .i_clk(clk), .i_rst(rst_n), .o_debounced(o_left ));
Debounce right(.i_in(i_right), .i_clk(clk), .i_rst(rst_n), .o_debounced(o_right));
Debounce fire (.i_in(i_fire) , .i_clk(clk), .i_rst(rst_n), .o_debounced(o_fire ));

endmodule // joystick