module timer(
	input clk,
	input rst_n,

	input [1:0] i_top_state,
	input i_VGA_buzy,

	output logic [2:0] o_min_ten,
	output logic [3:0] o_min_one,
	output logic [2:0] o_sec_ten,
	output logic [3:0] o_sec_one
);
logic [2:0] n_o_min_ten, n_o_sec_ten;
logic [3:0] n_o_min_one, n_o_sec_one;

logic [2:0] min_ten, sec_ten, n_min_ten, n_sec_ten;
logic [3:0] min_one, sec_one, n_min_one, n_sec_one;

logic [24:0] clk_counter, n_clk_counter;

always_comb begin
	if(i_top_state == 2'b01) begin
		n_min_ten = min_ten;
		n_min_one = min_one;
		n_sec_ten = sec_ten;
		n_sec_one = sec_one;
		n_clk_counter = clk_counter + 25'd1;

		if(clk_counter == 25'd24_999_999) begin
			n_clk_counter = 25'd0;

			if(sec_one == 4'd9) begin
				n_sec_one = 4'd0;

				if(sec_ten == 3'd5) begin
					n_o_sec_ten = 3'd0;

					if(min_one == 4'd9) begin
						n_min_one = 4'd0;
						n_min_ten = (min_ten == 3'd5) ? 3'd0 : min_ten + 3'd1;
					end else n_min_one = min_one + 4'd1;

				end else n_sec_ten = sec_ten + 3'd1;

			end else n_sec_one = sec_one + 4'd1;
		end
	end else begin
		n_min_ten = 4'd0;
		n_min_one = 4'd0;
		n_sec_ten = 4'd0;
		n_sec_one = 4'd0;
		n_clk_counter = 25'd0;
	end

end

always_comb begin
	if(i_VGA_buzy) begin
		n_o_min_ten = o_min_ten;
		n_o_min_one = o_min_one;
		n_o_sec_ten = o_sec_ten;
		n_o_sec_one = o_sec_one;
	end else begin
		n_o_min_ten = min_ten;
		n_o_min_one = min_one;
		n_o_sec_ten = sec_ten;
		n_o_sec_one = sec_one;
	end
end

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		o_min_ten <= 3'd0;
		o_min_one <= 4'd0;
		o_sec_ten <= 3'd0;
		o_sec_one <= 4'd0;

		min_ten <= 3'd0;
		min_one <= 4'd0;
		sec_ten <= 3'd0;
		sec_one <= 4'd0;
		clk_counter <= 25'd0;
	end else begin
		o_min_ten <= n_o_min_ten;
		o_min_one <= n_o_min_one;
		o_sec_ten <= n_o_sec_ten;
		o_sec_one <= n_o_sec_one;

		min_ten <= n_min_ten;
		min_one <= n_min_one;
		sec_ten <= n_sec_ten;
		sec_one <= n_sec_one;
		clk_counter <= n_clk_counter;
	end
end
endmodule