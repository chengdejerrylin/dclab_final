module tank(
	//////global//////
	input clk,
	input rst_n,

    //////from Game(Dai)//////
    input [5:0] initial_x,
    input [5:0] initial_y,
    input [2:0] initial_direction,
    input [2:0] direction_in, //0_UP, 1_DOWN, 2_LEFT, 3_RIGHT, 4_STAND
    input valid_take_direction,
    
    //////To Game and VGA///////
    output logic [5:0] tank_x_pos,// tank central x pos
    output logic [5:0] tank_y_pos,// tank central y pos
    
    //////To VGA(Genn)//////
    output logic [1:0] direction_out
);

	//direction
	localparam UP = 0;
	localparam DOWN = 1;
	localparam LEFT = 2;
	localparam RIGHT = 3;
	localparam STAND = 4;

	//state
	localparam STATE_0 = 0;
	localparam STATE_1 = 1;
	localparam STATE_2 = 2;
	localparam STATE_3 = 3;
	localparam STATE_4 = 4;

	reg [2:0] state, state_n;
	reg [5:0] tank_x_pos_n, tank_y_pos_n;
	reg [2:0] direction_last, direction_last_n; //record the direction of last frame(not cycle!)
	reg [1:0] direction_out_n;

	always_comb begin
		direction_out_n = direction_out; 
		case(state)
			STATE_0: begin
				if (~valid_take_direction) begin
					state_n = state;
					tank_x_pos_n = tank_x_pos;
					tank_y_pos_n = tank_y_pos;
					direction_last_n = direction_last;
				end
				else begin
					if (direction_last != direction_in) begin
						state_n = STATE_0;
						tank_x_pos_n = tank_x_pos;
						tank_y_pos_n = tank_y_pos;
						direction_last_n = direction_in;
					end
					else begin
						state_n = STATE_1;
						tank_x_pos_n = tank_x_pos;
						tank_y_pos_n = tank_y_pos;
						direction_last_n = direction_in;
					end
				end
				
			end

			STATE_1: begin
				if (~valid_take_direction) begin
					state_n = state;
					tank_x_pos_n = tank_x_pos;
					tank_y_pos_n = tank_y_pos;
					direction_last_n = direction_last;
				end
				else begin
					if (direction_last != direction_in) begin
						state_n = STATE_0;
						tank_x_pos_n = tank_x_pos;
						tank_y_pos_n = tank_y_pos;
						direction_last_n = direction_in;
					end
					else begin
						state_n = STATE_2;
						tank_x_pos_n = tank_x_pos;
						tank_y_pos_n = tank_y_pos;
						direction_last_n = direction_last;
					end
				end
			end

			STATE_2: begin
				if (~valid_take_direction) begin
					state_n = state;
					tank_x_pos_n = tank_x_pos;
					tank_y_pos_n = tank_y_pos;
					direction_last_n = direction_last;
				end
				else begin
					if (direction_last != direction_in) begin
						state_n = STATE_0;
						tank_x_pos_n = tank_x_pos;
						tank_y_pos_n = tank_y_pos;
						direction_last_n = direction_in;
					end
					else begin
						state_n = STATE_3;
						tank_x_pos_n = tank_x_pos;
						tank_y_pos_n = tank_y_pos;
						direction_last_n = direction_in;
					end
				end
			end

			STATE_3: begin
				if (~valid_take_direction) begin
					state_n = state;
					tank_x_pos_n = tank_x_pos;
					tank_y_pos_n = tank_y_pos;
					direction_last_n = direction_last;
				end
				else begin
					if (direction_last != direction_in) begin
						state_n = STATE_0;
						tank_x_pos_n = tank_x_pos;
						tank_y_pos_n = tank_y_pos;
						direction_last_n = direction_in;
					end
					else begin
						state_n = STATE_4;
						tank_x_pos_n = tank_x_pos;
						tank_y_pos_n = tank_y_pos;
						direction_last_n = direction_in;
					end
				end
			end

			STATE_4: begin
				if (~valid_take_direction) begin
					state_n = state;
					tank_x_pos_n = tank_x_pos;
					tank_y_pos_n = tank_y_pos;
					direction_last_n = direction_last;
				end
				else begin
					if (direction_last != direction_in) begin
						state_n = STATE_0;
						tank_x_pos_n = tank_x_pos;
						tank_y_pos_n = tank_y_pos;
						direction_last_n = direction_in;
					end
					else begin
						state_n = STATE_0;
						direction_last_n = direction_in;
						tank_x_pos_n = tank_x_pos;
						tank_y_pos_n = tank_y_pos;
						if (direction_last == UP) begin
							tank_y_pos_n = tank_y_pos - 1;
							direction_out_n = direction_last [1:0];
						end
						else if (direction_last == DOWN) begin
							tank_y_pos_n = tank_y_pos + 1;
							direction_out_n = direction_last [1:0];
						end
						else if (direction_last == LEFT) begin
							tank_x_pos_n = tank_x_pos - 1;
							direction_out_n = direction_last [1:0];
						end
						else if (direction_last == RIGHT) begin
							tank_x_pos_n = tank_x_pos + 1;
							direction_out_n = direction_last [1:0];
						end
					end
				end
			end

			default : begin
				state_n = state;
				tank_x_pos_n = tank_x_pos;
				tank_y_pos_n = tank_y_pos;
				direction_last_n = direction_last;
			end
		endcase // state
	end

	always_ff @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			state <= STATE_0;
			tank_x_pos <= initial_x;
			tank_y_pos <= initial_y;
			direction_last <= STAND;
			direction_out <= initial_direction;
		end

		else begin
			state <= state_n;
			tank_x_pos <= tank_x_pos_n;
			tank_y_pos <= tank_y_pos_n;
			direction_last <= direction_last_n;
			direction_out <= direction_out_n;
		end
	end

endmodule // tank


