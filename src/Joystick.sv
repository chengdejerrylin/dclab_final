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
wire fire_debounced, fire_neg;

assign o_led = {fire_debounced, o_left, o_up, o_down, o_right};
assign o_fire = ~fire_neg;

Debounce up   (.i_in(i_up)   , .i_clk(clk), .i_rst(rst_n), .o_debounced(o_up   ));
Debounce down (.i_in(i_down) , .i_clk(clk), .i_rst(rst_n), .o_debounced(o_down ));
Debounce left (.i_in(i_left) , .i_clk(clk), .i_rst(rst_n), .o_debounced(o_left ));
Debounce right(.i_in(i_right), .i_clk(clk), .i_rst(rst_n), .o_debounced(o_right));
Debounce fire (.i_in(i_fire) , .i_clk(clk), .i_rst(rst_n), .o_debounced(fire_debounced ), .o_neg(fire_neg));

endmodule // joystick