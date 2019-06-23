module shell(
    //////global//////
    input clk,
    input rst_n,
    //////From Game(Dai)//////
    input fire_1,
    input fire_2,
    input valid_give_shell_1,
    input valid_give_shell_2,
    input [4:0] vanish_1,
    input [4:0] vanish_2,
    //////From Tank(Me)//////
    input [1:0] direction_1_in, //0_up, 1_down, 2_left, 3_right
    input [1:0] direction_2_in, //0_up, 1_down, 2_left, 3_right
    input [5:0] tank_1_x_pos,
    input [5:0] tank_1_y_pos,
    input [5:0] tank_2_x_pos,
    input [5:0] tank_2_y_pos,
    //////To Game and VGA//////
    output logic [5:0] shell_1_0_x_pos,// tank 1 shell 1 x pos
    output logic [5:0] shell_1_0_y_pos,// tank 1 shell 1 y pos
    output logic [5:0] shell_1_1_x_pos,// tank 1 shell 2 x pos
    output logic [5:0] shell_1_1_y_pos,// tank 1 shell 2 y pos
    output logic [5:0] shell_1_2_x_pos,// tank 1 shell 3 x pos
    output logic [5:0] shell_1_2_y_pos,// tank 1 shell 3 y pos
    output logic [5:0] shell_1_3_x_pos,// tank 1 shell 4 x pos
    output logic [5:0] shell_1_3_y_pos,// tank 1 shell 4 y pos
    output logic [5:0] shell_1_4_x_pos,// tank 1 shell 5 x pos
    output logic [5:0] shell_1_4_y_pos,// tank 1 shell 5 y pos
    output logic [5:0] shell_2_0_x_pos,// tank 1 shell 1 x pos
    output logic [5:0] shell_2_0_y_pos,// tank 1 shell 1 y pos
    output logic [5:0] shell_2_1_x_pos,// tank 1 shell 2 x pos
    output logic [5:0] shell_2_1_y_pos,// tank 1 shell 2 y pos
    output logic [5:0] shell_2_2_x_pos,// tank 1 shell 3 x pos
    output logic [5:0] shell_2_2_y_pos,// tank 1 shell 3 y pos
    output logic [5:0] shell_2_3_x_pos,// tank 1 shell 4 x pos
    output logic [5:0] shell_2_3_y_pos,// tank 1 shell 4 y pos
    output logic [5:0] shell_2_4_x_pos,// tank 1 shell 5 x pos
    output logic [5:0] shell_2_4_y_pos,// tank 1 shell 5 y pos
    output logic [4:0] valid_1_shell, //1 means valid, 0 means used
    output logic [4:0] valid_2_shell //1 means valid, 0 means used
    );
    
    logic [4:0] fire_1_out, fire_2_out;
    select_shell select_shell_1(.fire(fire_1), .valid_give_shell(valid_give_shell_1),
                                .valid_shell(valid_1_shell), .fire_out(fire_1_out));
    select_shell select_shell_2(.fire(fire_2), .valid_give_shell(valid_give_shell_2),
                                .valid_shell(valid_2_shell), .fire_out(fire_2_out));

    single_shell single_shell_1_0(.clk(clk), .rst_n(rst_n), .vanish(vanish_1[0]), 
                                  .fire(fire_1_out[0]), .direction_in(direction_1_in), 
                                  .tank_x_pos(tank_1_x_pos), .tank_y_pos(tank_1_y_pos), 
                                  .shell_x_pos(shell_1_0_x_pos), .shell_y_pos(shell_1_0_y_pos), 
                                  .valid_shell(valid_1_shell[0]));
    single_shell single_shell_1_1(.clk(clk), .rst_n(rst_n), .vanish(vanish_1[1]), 
                                  .fire(fire_1_out[1]), .direction_in(direction_1_in), 
                                  .tank_x_pos(tank_1_x_pos), .tank_y_pos(tank_1_y_pos), 
                                  .shell_x_pos(shell_1_1_x_pos), .shell_y_pos(shell_1_1_y_pos), 
                                  .valid_shell(valid_1_shell[1]));
    single_shell single_shell_1_2(.clk(clk), .rst_n(rst_n), .vanish(vanish_1[2]), 
                                  .fire(fire_1_out[2]), .direction_in(direction_1_in), 
                                  .tank_x_pos(tank_1_x_pos), .tank_y_pos(tank_1_y_pos), 
                                  .shell_x_pos(shell_1_2_x_pos), .shell_y_pos(shell_1_2_y_pos), 
                                  .valid_shell(valid_1_shell[2]));
    single_shell single_shell_1_3(.clk(clk), .rst_n(rst_n), .vanish(vanish_1[3]), 
                                  .fire(fire_1_out[3]), .direction_in(direction_1_in), 
                                  .tank_x_pos(tank_1_x_pos), .tank_y_pos(tank_1_y_pos), 
                                  .shell_x_pos(shell_1_3_x_pos), .shell_y_pos(shell_1_3_y_pos), 
                                  .valid_shell(valid_1_shell[3]));
    single_shell single_shell_1_4(.clk(clk), .rst_n(rst_n), .vanish(vanish_1[4]), 
                                  .fire(fire_1_out[4]), .direction_in(direction_1_in), 
                                  .tank_x_pos(tank_1_x_pos), .tank_y_pos(tank_1_y_pos), 
                                  .shell_x_pos(shell_1_4_x_pos), .shell_y_pos(shell_1_4_y_pos), 
                                  .valid_shell(valid_1_shell[4]));

    single_shell single_shell_2_0(.clk(clk), .rst_n(rst_n), .vanish(vanish_2[0]), 
                                  .fire(fire_2_out[0]), .direction_in(direction_2_in), 
                                  .tank_x_pos(tank_2_x_pos), .tank_y_pos(tank_2_y_pos), 
                                  .shell_x_pos(shell_2_0_x_pos), .shell_y_pos(shell_2_0_y_pos), 
                                  .valid_shell(valid_2_shell[0]));
    single_shell single_shell_2_1(.clk(clk), .rst_n(rst_n), .vanish(vanish_2[1]), 
                                  .fire(fire_2_out[1]), .direction_in(direction_2_in), 
                                  .tank_x_pos(tank_2_x_pos), .tank_y_pos(tank_2_y_pos), 
                                  .shell_x_pos(shell_2_1_x_pos), .shell_y_pos(shell_2_1_y_pos), 
                                  .valid_shell(valid_2_shell[1]));
    single_shell single_shell_2_2(.clk(clk), .rst_n(rst_n), .vanish(vanish_2[2]), 
                                  .fire(fire_2_out[2]), .direction_in(direction_2_in), 
                                  .tank_x_pos(tank_2_x_pos), .tank_y_pos(tank_2_y_pos), 
                                  .shell_x_pos(shell_2_2_x_pos), .shell_y_pos(shell_2_2_y_pos), 
                                  .valid_shell(valid_2_shell[2]));
    single_shell single_shell_2_3(.clk(clk), .rst_n(rst_n), .vanish(vanish_2[3]), 
                                  .fire(fire_2_out[3]), .direction_in(direction_2_in), 
                                  .tank_x_pos(tank_2_x_pos), .tank_y_pos(tank_2_y_pos), 
                                  .shell_x_pos(shell_2_3_x_pos), .shell_y_pos(shell_2_3_y_pos), 
                                  .valid_shell(valid_2_shell[3]));
    single_shell single_shell_2_4(.clk(clk), .rst_n(rst_n), .vanish(vanish_2[4]), 
                                  .fire(fire_2_out[4]), .direction_in(direction_2_in), 
                                  .tank_x_pos(tank_2_x_pos), .tank_y_pos(tank_2_y_pos), 
                                  .shell_x_pos(shell_2_4_x_pos), .shell_y_pos(shell_2_4_y_pos), 
                                  .valid_shell(valid_2_shell[4]));
endmodule

module select_shell(
    //////From Game(Dai)//////
    input fire,
    input valid_give_shell,
    //////From single_shell(Me)//////
    input [4:0] valid_shell,
    //////To single_shell(Me)//////
    output logic [4:0] fire_out//fire signal to 5 shells
    );
    assign fire_out = (fire == 0) ? 5'b00000 :
                      (valid_give_shell == 0) ? 5'b00000:
                      (valid_shell == 5'b11111) ? 5'b00001 :
                      (valid_shell == 5'b11110) ? 5'b00010 :
                      (valid_shell == 5'b11101) ? 5'b00001 :
                      (valid_shell == 5'b11100) ? 5'b00100 :
                      (valid_shell == 5'b11011) ? 5'b00001 :
                      (valid_shell == 5'b11010) ? 5'b00010 :
                      (valid_shell == 5'b11001) ? 5'b00001 :
                      (valid_shell == 5'b11000) ? 5'b01000 :
                      (valid_shell == 5'b10111) ? 5'b00001 :
                      (valid_shell == 5'b10110) ? 5'b00010 :
                      (valid_shell == 5'b10101) ? 5'b00001 :
                      (valid_shell == 5'b10100) ? 5'b00100 :
                      (valid_shell == 5'b10011) ? 5'b00001 :
                      (valid_shell == 5'b10010) ? 5'b00010 :
                      (valid_shell == 5'b10001) ? 5'b00001 :
                      (valid_shell == 5'b10000) ? 5'b10000 :
                      (valid_shell == 5'b01111) ? 5'b00001 :
                      (valid_shell == 5'b01110) ? 5'b00010 :
                      (valid_shell == 5'b01101) ? 5'b00001 :
                      (valid_shell == 5'b01100) ? 5'b00100 :
                      (valid_shell == 5'b01011) ? 5'b00001 :
                      (valid_shell == 5'b01010) ? 5'b00010 :
                      (valid_shell == 5'b01001) ? 5'b00001 :
                      (valid_shell == 5'b01000) ? 5'b01000 :
                      (valid_shell == 5'b00111) ? 5'b00001 :
                      (valid_shell == 5'b00110) ? 5'b00010 :
                      (valid_shell == 5'b00101) ? 5'b00001 :
                      (valid_shell == 5'b00100) ? 5'b00100 :
                      (valid_shell == 5'b00011) ? 5'b00001 :
                      (valid_shell == 5'b00010) ? 5'b00010 :
                      (valid_shell == 5'b00001) ? 5'b00001 :
                      (valid_shell == 5'b00000) ? 5'b00000 : 5'b00000;  
endmodule


module single_shell(
    //////global//////
    input clk,
    input rst_n,
    //////From Game(Dai)//////   
    input vanish,
    input fire,
    //////From tank(Me)//////
    input [1:0] direction_in, //0_up, 1_down, 2_left, 3_right
    input [5:0] tank_x_pos,
    input [5:0] tank_y_pos,
    //////To Game and VGA//////
    output logic [5:0] shell_x_pos,// shell x pos
    output logic [5:0] shell_y_pos,// shell y pos
    output logic valid_shell //1 means valid, 0 means used
);

    reg [19:0] count;
    reg [19:0] count_n;
    reg state, state_n;
    reg [5:0] shell_x_pos_n, shell_y_pos_n;
    reg [2:0] record_direction, record_direction_n;

    //state
    localparam IDLE = 0;
    localparam SHOOT = 1;

    //direction
    localparam UP = 0;
    localparam DOWN = 1;
    localparam LEFT = 2;
    localparam RIGHT = 3;
    localparam STAND = 4;
    
    always_comb begin
        case(state) 
            IDLE: begin
                count_n = 0;
                shell_x_pos_n = tank_x_pos;
                shell_y_pos_n = tank_y_pos;
                state_n = state;
                valid_shell = 1;
                record_direction_n = STAND;
                if (fire) begin
                    state_n = SHOOT;
                    valid_shell = 0;
                    record_direction_n = direction_in;
                end
            end

            SHOOT: begin
                count_n = count + 1;
                shell_x_pos_n = shell_x_pos;
                shell_y_pos_n = shell_y_pos;
                state_n = SHOOT;
                valid_shell = 0;
                record_direction_n = record_direction;
                if (count == 20'd400000) begin
                    count_n = 0;
                    if (record_direction == UP) begin
                        shell_y_pos_n = shell_y_pos + 1;
                    end
                    else if (record_direction == DOWN) begin
                        shell_y_pos_n = shell_y_pos - 1;
                    end
                    else if (record_direction == LEFT) begin
                        shell_x_pos_n = shell_x_pos - 1;
                    end
                    else if (record_direction == RIGHT) begin
                        shell_x_pos_n = shell_x_pos + 1;
                    end
                end
                if (vanish) begin
                    count_n = 0;
                    valid_shell = 1;
                    state_n = IDLE;
                end
            end
        endcase // state
    end

    always_ff @(posedge clk) begin
        if (~rst_n) begin
            state <= IDLE;
            count <= 0;
            shell_x_pos <= tank_x_pos;
            shell_y_pos <= tank_y_pos;
            record_direction <= STAND;
        end

        else begin
            state <= state_n;
            count <= count_n;
            shell_x_pos <= shell_x_pos_n;
            shell_y_pos <= shell_y_pos_n;
            record_direction <= record_direction_n;
        end
    end
endmodule // shell