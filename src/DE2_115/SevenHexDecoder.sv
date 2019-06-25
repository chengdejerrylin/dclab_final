module SevenHexDecoder(
  input [5:0] i_data, // SRAM address
  output logic [6:0] o_seven_ten,
  output logic [6:0] o_seven_one
);

//=======================================================
//----------------Seven Segment Display------------------
//=======================================================

  /* The layout of seven segment display, 1: dark
   *    00
   *   5  1
   *    66
   *   4  2
   *    33
   */
  parameter D0 = 7'b1000000;
  parameter D1 = 7'b1111001;
  parameter D2 = 7'b0100100;
  parameter D3 = 7'b0110000;
  parameter D4 = 7'b0011001;
  parameter D5 = 7'b0010010;
  parameter D6 = 7'b0000010;
  parameter D7 = 7'b1011000;
  parameter D8 = 7'b0000000;
  parameter D9 = 7'b0010000;
  parameter DN = 7'b1111111;

  logic [3:0] one;
  logic [5:0] ten;

  assign one = i_data % 4'd10;
  assign ten = i_data - one;

always_comb begin
	case (one)
		4'd0 : o_seven_one = D0;
		4'd1 : o_seven_one = D1;
		4'd2 : o_seven_one = D2;
		4'd3 : o_seven_one = D3;
		4'd4 : o_seven_one = D4;
		4'd5 : o_seven_one = D5;
		4'd6 : o_seven_one = D6;
		4'd7 : o_seven_one = D7;
		4'd8 : o_seven_one = D8;
		4'd9 : o_seven_one = D9;
		default : o_seven_one = DN;
	endcase

	case (ten)
		6'd00 : o_seven_ten = D0;
		6'd10 : o_seven_ten = D1;
		6'd20 : o_seven_ten = D2;
		6'd30 : o_seven_ten = D3;
		6'd40 : o_seven_ten = D4;
		6'd50 : o_seven_ten = D5;
		6'd60 : o_seven_ten = D6;
		default : o_seven_ten = DN;
	endcase
end
endmodule
