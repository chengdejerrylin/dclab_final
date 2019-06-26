`include "src/define.sv"

module DE2_115(
	input CLOCK_50,
	input CLOCK2_50,
	input CLOCK3_50,
	input ENETCLK_25,
	input SMA_CLKIN,
	output SMA_CLKOUT,
	output [8:0] LEDG,
	output [17:0] LEDR,
	input [3:0] KEY,
	input [17:0] SW,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	output LCD_BLON,
	inout [7:0] LCD_DATA,
	output LCD_EN,
	output LCD_ON,
	output LCD_RS,
	output LCD_RW,
	output UART_CTS,
	input UART_RTS,
	input UART_RXD,
	output UART_TXD,
	inout PS2_CLK,
	inout PS2_DAT,
	inout PS2_CLK2,
	inout PS2_DAT2,
	output SD_CLK,
	inout SD_CMD,
	inout [3:0] SD_DAT,
	input SD_WP_N,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output [7:0] VGA_G,
	output VGA_HS,
	output [7:0] VGA_R,
	output VGA_SYNC_N,
	output VGA_VS,
	input AUD_ADCDAT,
	inout AUD_ADCLRCK,
	inout AUD_BCLK,
	output AUD_DACDAT,
	// inout AUD_DACLRCK,
	input AUD_DACLRCK,
	output AUD_XCK,
	output EEP_I2C_SCLK,
	inout EEP_I2C_SDAT,
	output I2C_SCLK,
	inout I2C_SDAT,
	output ENET0_GTX_CLK,
	input ENET0_INT_N,
	output ENET0_MDC,
	input ENET0_MDIO,
	output ENET0_RST_N,
	input ENET0_RX_CLK,
	input ENET0_RX_COL,
	input ENET0_RX_CRS,
	input [3:0] ENET0_RX_DATA,
	input ENET0_RX_DV,
	input ENET0_RX_ER,
	input ENET0_TX_CLK,
	output [3:0] ENET0_TX_DATA,
	output ENET0_TX_EN,
	output ENET0_TX_ER,
	input ENET0_LINK100,
	output ENET1_GTX_CLK,
	input ENET1_INT_N,
	output ENET1_MDC,
	input ENET1_MDIO,
	output ENET1_RST_N,
	input ENET1_RX_CLK,
	input ENET1_RX_COL,
	input ENET1_RX_CRS,
	input [3:0] ENET1_RX_DATA,
	input ENET1_RX_DV,
	input ENET1_RX_ER,
	input ENET1_TX_CLK,
	output [3:0] ENET1_TX_DATA,
	output ENET1_TX_EN,
	output ENET1_TX_ER,
	input ENET1_LINK100,
	input TD_CLK27,
	input [7:0] TD_DATA,
	input TD_HS,
	output TD_RESET_N,
	input TD_VS,
	inout [15:0] OTG_DATA,
	output [1:0] OTG_ADDR,
	output OTG_CS_N,
	output OTG_WR_N,
	output OTG_RD_N,
	input OTG_INT,
	output OTG_RST_N,
	input IRDA_RXD,
	output [12:0] DRAM_ADDR,
	output [1:0] DRAM_BA,
	output DRAM_CAS_N,
	output DRAM_CKE,
	output DRAM_CLK,
	output DRAM_CS_N,
	inout [31:0] DRAM_DQ,
	output [3:0] DRAM_DQM,
	output DRAM_RAS_N,
	output DRAM_WE_N,
	output [19:0] SRAM_ADDR,
	output SRAM_CE_N,
	inout [15:0] SRAM_DQ,
	output SRAM_LB_N,
	output SRAM_OE_N,
	output SRAM_UB_N,
	output SRAM_WE_N,
	output [22:0] FL_ADDR,
	output FL_CE_N,
	inout [7:0] FL_DQ,
	output FL_OE_N,
	output FL_RST_N,
	input FL_RY,
	output FL_WE_N,
	output FL_WP_N,
	inout [35:0] GPIO,
	input HSMC_CLKIN_P1,
	input HSMC_CLKIN_P2,
	input HSMC_CLKIN0,
	output HSMC_CLKOUT_P1,
	output HSMC_CLKOUT_P2,
	output HSMC_CLKOUT0,
	inout [3:0] HSMC_D,
	input [16:0] HSMC_RX_D_P,
	output [16:0] HSMC_TX_D_P,
	inout [6:0] EX_IO
);
/******************
    User Input
******************/
logic RST_N;
logic p1_up, p1_down, p1_left, p1_right, p1_fire;
logic p2_up, p2_down, p2_left, p2_right, p2_fire;
logic [4:0] p1_led, p2_led;

assign RST_N = KEY[0];

`ifdef USE_SWITCH
assign p2_up     = SW[2];
assign p2_down   = SW[1];
assign p2_left   = SW[3];
assign p2_right  = SW[0];
assign p2_fire   = SW[4];

assign p1_up     = SW[15];
assign p1_down   = SW[14];
assign p1_left   = SW[16];
assign p1_right  = SW[13];
assign p1_fire   = SW[17];

`else 

//A : up
//B : right
//C : down
//D : left
//k : fire
assign p1_right  = GPIO[3];
assign p1_down   = GPIO[5];
assign p1_up     = GPIO[1];
assign p1_left   = GPIO[7];
assign p1_fire   = GPIO[9];

assign p2_right  = GPIO[29];
assign p2_down   = GPIO[31];
assign p2_up     = GPIO[27];
assign p2_left   = GPIO[33];
assign p2_fire   = GPIO[35];
`endif

assign LEDR[4:0] = p2_led;
assign LEDR[17:13] = p1_led;

/******************
       Clock
******************/
logic CLOCK_25;
pll pll(.clk_clk(CLOCK_50), .reset_reset_n(RST_N), .altpll_0_c0_clk(CLOCK_25));

/******************
       Module
******************/
logic up_1_joy_state, down_1_joy_state, left_1_joy_state, right_1_joy_state, fire_1_joy_state, start_1_joy_state;
logic up_2_joy_state, down_2_joy_state, left_2_joy_state, right_2_joy_state, fire_2_joy_state, start_2_joy_state;
logic [5:0] tank_1_pos_x, tank_1_pos_y, tank_2_pos_x, tank_2_pos_y;
logic [2:0] tank_1_life, tank_2_life;
logic tank_1_hurt, tank_2_hurt;
logic [5:0] o_init_tank_1_pos_x, o_init_tank_1_pos_y, o_init_tank_2_pos_x, o_init_tank_2_pos_y;
logic [4:0] valid_shell_1, valid_shell_2;
logic [5:0] shell_1_0_pos_x, shell_1_0_pos_y, shell_1_1_pos_x, shell_1_1_pos_y, shell_1_2_pos_x,
			shell_1_2_pos_y, shell_1_3_pos_x, shell_1_3_pos_y, shell_1_4_pos_x, shell_1_4_pos_y;
logic [5:0] shell_2_0_pos_x, shell_2_0_pos_y, shell_2_1_pos_x, shell_2_1_pos_y, shell_2_2_pos_x,
			shell_2_2_pos_y, shell_2_3_pos_x, shell_2_3_pos_y, shell_2_4_pos_x, shell_2_4_pos_y;
logic [4:0] shell_vanish_1, shell_vanish_2;
logic valid_frame_1, valid_frame_2;
logic [2:0] direction_1_state_tank, direction_2_state_tank;
logic fire_1, fire_2;
logic [5:0] x_pos_vga_state, y_pos_vga_state;
logic is_map;
logic [1:0] game_state;
logic [1:0] who_wins;
logic [1:0] direction_tank_1, direction_tank_2;
logic [4:0] valid_1_shell, valid_2_shell;

//VGA
logic VGA_busy;

//timer
logic [2:0] min_ten, sec_ten;
logic [3:0] min_one, sec_one;


VGA vga(.clk(CLOCK_25), .rst_n(RST_N), .VGA_B(VGA_B), .VGA_BLANK_N(VGA_BLANK_N), .VGA_CLK(VGA_CLK), 
	.VGA_G(VGA_G), .VGA_HS(VGA_HS), .VGA_R(VGA_R), .VGA_SYNC_N(VGA_SYNC_N), .VGA_VS(VGA_VS), 
	.i_state(game_state), .i_tank0_x(tank_1_pos_x), .i_tank0_y(tank_1_pos_y), 
	.i_tank0_dir(direction_tank_1), .o_buzy(VGA_busy), .i_min_ten(min_ten), .i_min_one(min_one), 
	.i_sec_ten(sec_ten), .i_sec_one(sec_one), .i_tank1_x(tank_2_pos_x), .i_tank1_y(tank_2_pos_y), 
	.i_tank1_dir(direction_tank_2), .i_is_wall(is_map), .o_request_x(x_pos_vga_state), 
	.o_request_y(y_pos_vga_state), .i_p1_win(who_wins[0]), 
	.i_shell0_0_x(shell_1_0_pos_x), .i_shell0_0_y(shell_1_0_pos_y), 
	.i_shell0_1_x(shell_1_1_pos_x), .i_shell0_1_y(shell_1_1_pos_y), 
	.i_shell0_2_x(shell_1_2_pos_x), .i_shell0_2_y(shell_1_2_pos_y), 
	.i_shell0_3_x(shell_1_3_pos_x), .i_shell0_3_y(shell_1_3_pos_y), 
	.i_shell0_4_x(shell_1_4_pos_x), .i_shell0_4_y(shell_1_4_pos_y), 
	.i_shell1_0_x(shell_2_0_pos_x), .i_shell1_0_y(shell_2_0_pos_y), 
	.i_shell1_1_x(shell_2_1_pos_x), .i_shell1_1_y(shell_2_1_pos_y), 
	.i_shell1_2_x(shell_2_2_pos_x), .i_shell1_2_y(shell_2_2_pos_y), 
	.i_shell1_3_x(shell_2_3_pos_x), .i_shell1_3_y(shell_2_3_pos_y), 
	.i_shell1_4_x(shell_2_4_pos_x), .i_shell1_4_y(shell_2_4_pos_y), 
	.i_shell0_valid(valid_1_shell), .i_shell1_valid(valid_2_shell), 
	.i_tank0_life(tank_1_life), .i_tank1_life(tank_2_life));

timer t(.clk(CLOCK_25), .rst_n(RST_N), .i_top_state(game_state), .i_VGA_buzy(VGA_busy), .o_min_ten(min_ten), .o_min_one(min_one), 
	.o_sec_ten(sec_ten), .o_sec_one(sec_one));


Joystick p1(.clk(CLOCK_25), .rst_n(RST_N), .i_up(p1_up), .i_down (p1_down), .i_left (p1_left), 
			.i_right(p1_right), .i_fire (p1_fire), .o_up(up_1_joy_state), .o_down(down_1_joy_state),
			.o_left(left_1_joy_state), .o_right(right_1_joy_state), .o_fire(fire_1_joy_state),
			.o_led(p1_led), .o_start(start_1_joy_state));
Joystick p2(.clk(CLOCK_25), .rst_n(RST_N), .i_up(p2_up), .i_down (p2_down), .i_left (p2_left), 
			.i_right(p2_right), .i_fire (p2_fire), .o_up(up_2_joy_state), .o_down(down_2_joy_state),
			.o_left(left_2_joy_state), .o_right(right_2_joy_state), .o_fire(fire_2_joy_state), 
			.o_led(p2_led), .o_start(start_2_joy_state));

state state_1(.clk(CLOCK_25), .rst_n(RST_N), .press_up_1(up_1_joy_state), .press_down_1(down_1_joy_state),
			  .press_left_1(left_1_joy_state), .press_right_1(right_1_joy_state), 
			  .press_fire_1(fire_1_joy_state), .press_up_2(up_2_joy_state),
			  .press_down_2(down_2_joy_state), .press_left_2(left_2_joy_state),
			  .press_right_2(right_2_joy_state), .press_fire_2(fire_2_joy_state),
			  .tank_1_pos_x(tank_1_pos_x), .tank_1_pos_y(tank_1_pos_y), .tank_2_pos_x(tank_2_pos_x),
			  .tank_2_pos_y(tank_2_pos_y), .o_init_tank_1_pos_x(o_init_tank_1_pos_x),
			  .o_init_tank_1_pos_y(o_init_tank_1_pos_y), .o_init_tank_2_pos_x(o_init_tank_2_pos_x),
			  .o_init_tank_2_pos_y(o_init_tank_2_pos_y), .i_valid_shell_1(valid_1_shell),
			  .i_valid_shell_2(valid_2_shell), .shell_1_0_pos_x(shell_1_0_pos_x), 
			  .shell_1_0_pos_y(shell_1_0_pos_y), .shell_1_1_pos_x(shell_1_1_pos_x), 
			  .shell_1_1_pos_y(shell_1_1_pos_y), .shell_1_2_pos_x(shell_1_2_pos_x),
			  .shell_1_2_pos_y(shell_1_2_pos_y), .shell_1_3_pos_x(shell_1_3_pos_x), 
			  .shell_1_3_pos_y(shell_1_3_pos_y), .shell_1_4_pos_x(shell_1_4_pos_x),
			  .shell_1_4_pos_y(shell_1_4_pos_y), .shell_2_0_pos_x(shell_2_0_pos_x), 
			  .shell_2_0_pos_y(shell_2_0_pos_y), .shell_2_1_pos_x(shell_2_1_pos_x),
			  .shell_2_1_pos_y(shell_2_1_pos_y), .shell_2_2_pos_x(shell_2_2_pos_x),
			  .shell_2_2_pos_y(shell_2_2_pos_y), .shell_2_3_pos_x(shell_2_3_pos_x),
			  .shell_2_3_pos_y(shell_2_3_pos_y), .shell_2_4_pos_x(shell_2_4_pos_x),
			  .shell_2_4_pos_y(shell_2_4_pos_y), .o_shell_vanish_1(shell_vanish_1),
			  .o_shell_vanish_2(shell_vanish_2), .o_valid_frame_1(valid_frame_1), 
			  .o_valid_frame_2(valid_frame_2), .o_dir_1(direction_1_state_tank),
			  .o_dir_2(direction_2_state_tank), .o_fire_1(fire_1), .o_fire_2(fire_2), 
			  .i_x_pos(x_pos_vga_state), .i_y_pos(y_pos_vga_state), .i_busy(VGA_busy),
			  .o_is_map(is_map), .o_state(game_state), .o_who_wins(who_wins), 
			  .tank_1_dir(direction_tank_1), .tank_2_dir(direction_tank_2), 
			  .tank_1_life(tank_1_life), .tank_2_life(tank_2_life), 
			  .o_tank_1_hurt(tank_1_hurt), .o_tank_2_hurt(tank_2_hurt));

shell shell_1(.clk(CLOCK_25), .rst_n(RST_N), .fire_1(fire_1), .fire_2(fire_2),
			  .valid_give_shell_1(valid_frame_1), .valid_give_shell_2(valid_frame_2),
			  .vanish_1(shell_vanish_1), .vanish_2(shell_vanish_2), .direction_1_in(direction_tank_1),
			  .direction_2_in(direction_tank_2), .tank_1_x_pos(tank_1_pos_x), .tank_1_y_pos(tank_1_pos_y), 
			  .tank_2_x_pos(tank_2_pos_x), .tank_2_y_pos(tank_2_pos_y), 
			  .game_state(game_state),
			  .shell_1_0_x_pos(shell_1_0_pos_x), 
			  .shell_1_0_y_pos(shell_1_0_pos_y), .shell_1_1_x_pos(shell_1_1_pos_x), 
			  .shell_1_1_y_pos(shell_1_1_pos_y), .shell_1_2_x_pos(shell_1_2_pos_x),
			  .shell_1_2_y_pos(shell_1_2_pos_y), .shell_1_3_x_pos(shell_1_3_pos_x), 
			  .shell_1_3_y_pos(shell_1_3_pos_y), .shell_1_4_x_pos(shell_1_4_pos_x),
			  .shell_1_4_y_pos(shell_1_4_pos_y), .shell_2_0_x_pos(shell_2_0_pos_x), 
			  .shell_2_0_y_pos(shell_2_0_pos_y), .shell_2_1_x_pos(shell_2_1_pos_x),
			  .shell_2_1_y_pos(shell_2_1_pos_y), .shell_2_2_x_pos(shell_2_2_pos_x),
			  .shell_2_2_y_pos(shell_2_2_pos_y), .shell_2_3_x_pos(shell_2_3_pos_x),
			  .shell_2_3_y_pos(shell_2_3_pos_y), .shell_2_4_x_pos(shell_2_4_pos_x),
			  .shell_2_4_y_pos(shell_2_4_pos_y), .valid_1_shell(valid_1_shell), 
			  .valid_2_shell(valid_2_shell));

tank tank_1(.clk(CLOCK_25), .rst_n(RST_N), .initial_x(o_init_tank_1_pos_x), 
			.initial_y(o_init_tank_1_pos_y), .initial_direction(2'd3), 
			.direction_in(direction_1_state_tank), .valid_take_direction(valid_frame_1),
			.game_state(game_state), 
			.tank_x_pos(tank_1_pos_x), .tank_y_pos(tank_1_pos_y), .direction_out(direction_tank_1), 
			.tank_life(tank_1_life), .is_hurt(tank_1_hurt));
    
tank tank_2(.clk(CLOCK_25), .rst_n(RST_N), .initial_x(o_init_tank_2_pos_x), 
			.initial_y(o_init_tank_2_pos_y), .initial_direction(2'd2), 
			.direction_in(direction_2_state_tank), .valid_take_direction(valid_frame_2), 
			.game_state(game_state),
			.tank_x_pos(tank_2_pos_x), .tank_y_pos(tank_2_pos_y), .direction_out(direction_tank_2), 
			.tank_life(tank_2_life), .is_hurt(tank_2_hurt));

/******************
       Debug
******************/
SevenHexDecoder t1x(.i_data(tank_1_pos_x), .o_seven_ten(HEX7), .o_seven_one(HEX6));
SevenHexDecoder t1y(.i_data(tank_1_pos_y), .o_seven_ten(HEX5), .o_seven_one(HEX4));
SevenHexDecoder t2x(.i_data(tank_2_pos_x), .o_seven_ten(HEX3), .o_seven_one(HEX2));
SevenHexDecoder t2y(.i_data(tank_2_pos_y), .o_seven_ten(HEX1), .o_seven_one(HEX0));

assign LEDG[ 4: 0] = valid_2_shell;
assign LEDR[11: 7] = valid_1_shell;
assign LEDG[ 7: 6] = game_state;

endmodule
