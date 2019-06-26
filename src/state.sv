`define MAP     "./map/map.dat"     //name for map
`include "src/define.sv"

module state(
    input clk,
    input rst_n,
    
    //player press
    input press_up_1,    
    input press_down_1,
    input press_left_1,
    input press_right_1,
    input press_fire_1,


    input press_up_2,
    input press_down_2,
    input press_left_2,
    input press_right_2,
    input press_fire_2,
    
    //object
    input[5:0] tank_1_pos_x,
    input[5:0] tank_1_pos_y,
    input[5:0] tank_2_pos_x,
    input[5:0] tank_2_pos_y,
    input[1:0] tank_1_dir,
    input[1:0] tank_2_dir,
    input[2:0] tank_1_life,
    input[2:0] tank_2_life,

    output[5:0] o_init_tank_1_pos_x,
    output[5:0] o_init_tank_1_pos_y,
    output[5:0] o_init_tank_2_pos_x,
    output[5:0] o_init_tank_2_pos_y,
    output logic o_tank_1_hurt,
    output logic o_tank_2_hurt,
    
    input[4:0] i_valid_shell_1,   //if the shell is being shot
    input[4:0] i_valid_shell_2,

    input[5:0] shell_1_0_pos_x,     //i_valid_shell_1[0], o_shell_vanish_1[0]
    input[5:0] shell_1_0_pos_y,
    input[5:0] shell_1_1_pos_x,     //i_valid_shell_1[1], o_shell_vanish_1[1]
    input[5:0] shell_1_1_pos_y,
    input[5:0] shell_1_2_pos_x,     //i_valid_shell_1[2], o_shell_vanish_1[2]
    input[5:0] shell_1_2_pos_y,
    input[5:0] shell_1_3_pos_x,     //i_valid_shell_1[3], o_shell_vanish_1[3]
    input[5:0] shell_1_3_pos_y, 
    input[5:0] shell_1_4_pos_x,     //i_valid_shell_1[4], o_shell_vanish_1[4]
    input[5:0] shell_1_4_pos_y,

    input[5:0] shell_2_0_pos_x,     //i_valid_shell_2[0], o_shell_vanish_2[0]
    input[5:0] shell_2_0_pos_y,
    input[5:0] shell_2_1_pos_x,     //i_valid_shell_2[1], o_shell_vanish_2[1]
    input[5:0] shell_2_1_pos_y,     
    input[5:0] shell_2_2_pos_x,     //i_valid_shell_2[2], o_shell_vanish_2[2]
    input[5:0] shell_2_2_pos_y,
    input[5:0] shell_2_3_pos_x,     //i_valid_shell_2[3], o_shell_vanish_2[3]
    input[5:0] shell_2_3_pos_y,
    input[5:0] shell_2_4_pos_x,     //i_valid_shell_2[4], o_shell_vanish_2[4]
    input[5:0] shell_2_4_pos_y,
    
    output[4:0] o_shell_vanish_1,     //if the shell hit the block
    output[4:0] o_shell_vanish_2,

    output      o_valid_frame_1,  //i_busy==0, tell direction, there is shell, valid==1
    output      o_valid_frame_2,
    output[2:0] o_dir_1,      //000-->up, 001-->down, 010-->left, 011-->right, 100-->none
    output[2:0] o_dir_2,      //000-->up, 001-->down, 010-->left, 011-->right, 100-->none
                            //if collision, no direction
                            //for tank
    output o_fire_1,
    output o_fire_2,          //for shell

    //VGA
    input[5:0]  i_x_pos,  //VGA ask me if there is a block(map)
    input[5:0]  i_y_pos, 
    input       i_busy,    //decide when tank can move, busy 1->0(one frame) tell Ting direction
    output      o_is_map,     //there is block
    output[1:0] o_state,     //0->start, 1->game, 2->end
    output[1:0] o_who_wins    //0-->no ones, 1-->first one, 2-->second
);

    //parameter====================================================================================
    parameter START = 2'b00;
    parameter GAME = 2'b01;
    parameter END = 2'b10;

    //logic declaration============================================================================
    //for map
    reg   [63:0]   map_mem    [0:43];
    //for object
    logic          valid_frame_1, next_valid_frame_1;
    logic          valid_frame_2, next_valid_frame_2;
    logic [2:0]    dir_1, next_dir_1;
    logic [2:0]    dir_2, next_dir_2;
    logic          fire_1, next_fire_1;
    logic          fire_2, next_fire_2;
    logic          save_fire_1, save_next_fire_1;
    logic          save_fire_2, save_next_fire_2;
    logic [4:0]    shell_vanish_1, next_shell_vanish_1;
    logic [4:0]    shell_vanish_2, next_shell_vanish_2;
    logic [4:0]    shell_hit_1, next_shell_hit_1;
    logic [4:0]    shell_hit_2, next_shell_hit_2;
    logic          next_tank_1_hurt, next_tank_2_hurt;
    //for VGA
    logic          is_map, next_is_map;
    logic [1:0]    state, next_state;
    logic [1:0]    who_wins, next_who_wins;

    //assign output==================================================================================
    //for object
    assign o_init_tank_1_pos_y = 6'd38;
    assign o_init_tank_1_pos_x = 6'd6;
    assign o_init_tank_2_pos_y = 6'd6;
    assign o_init_tank_2_pos_x = 6'd57;
    assign o_valid_frame_1 = valid_frame_1;
    assign o_valid_frame_2 = valid_frame_2;
    assign o_dir_1 = dir_1;
    assign o_dir_2 = dir_2;
    assign o_fire_1 = fire_1;
    assign o_fire_2 = fire_2;
    assign o_shell_vanish_1 = shell_vanish_1;
    assign o_shell_vanish_2 = shell_vanish_2;
    //for VGA
    assign o_is_map = is_map;
    assign o_state = state;
    assign o_who_wins = who_wins;

    //read from map====================================================================================
    `ifdef COMPILE_MULTIPLE_MAPS
    logic [64*44-1 : 0] map;
    RandomMap randomMap(.clk(clk), .rst_n(rst_n), .i_top_state(o_state), .o_map(map));

    genvar idx;
    generate
        for (idx = 0; idx < 44; idx = idx +1) begin : decode
            assign map_mem[idx] = map[64*idx +: 64];
        end
    endgenerate

    `else 
    initial $readmemb (`MAP,  map_mem);    
    `endif

    //combinational part===============================================================================
    always_comb begin
        next_tank_1_hurt = 1'b0;
        next_tank_2_hurt = 1'b0;

        case(state)
            default: begin
                next_state = state;
                next_valid_frame_1 = valid_frame_1;
                next_valid_frame_2 = valid_frame_2;
                next_dir_1 = dir_1;
                next_dir_2 = dir_2;
                next_fire_1 = fire_1;
                next_fire_2 = fire_2;
                next_shell_vanish_1 = shell_vanish_1;
                next_shell_vanish_2 = shell_vanish_2;
                next_shell_hit_1 = shell_hit_1;
                next_shell_hit_2 = shell_hit_2;
                next_is_map = is_map;
                next_who_wins = who_wins;
            end
            START: begin
                if( (~press_left_1)& (~press_left_2) ) next_state = GAME;
                else next_state = state;

                //others
                //object
                next_valid_frame_1  = 5'b0;
                next_valid_frame_2  = 5'b0;
                next_dir_1          = 3'b100;
                next_dir_2          = 3'b100;
                next_fire_1         = 1'b0;
                next_fire_2         = 1'b0;
                next_shell_vanish_1 = 5'b0;
                next_shell_vanish_2 = 5'b0;
                next_shell_hit_1    = 5'b0;
                next_shell_hit_2    = 5'b0;
                //VGA
                next_is_map         = 1'b0;
                next_who_wins       = 2'b00;
            end
            GAME: begin
                //frame====================================================================
                if( ~i_busy ) begin
                    next_valid_frame_1 = 1'b1;
                    next_valid_frame_2 = 1'b1;
                end
                else begin
                    next_valid_frame_1 = 1'b0;
                    next_valid_frame_2 = 1'b0;
                end

                //press--> fire, direction===============================================
                //output next_fire_1,2, next_dir_1,2
                //use    i_busy, map_mem 
                //----------------------------tank_1-------------------------------------
                //shoot
                if( ~fire_1 ) next_fire_1 = ~press_fire_1;
                else next_fire_1 = ~valid_frame_1;



                if( ~press_up_1 ) begin
                    if(tank_1_dir != 2'd0)next_dir_1 = 3'd0;
                    else if( map_mem[tank_1_pos_y - 3][63 - (tank_1_pos_x - 2)] 
                      | map_mem[tank_1_pos_y - 3][63 - (tank_1_pos_x - 1)]
                      | map_mem[tank_1_pos_y - 3][63 - (tank_1_pos_x)]
                      | map_mem[tank_1_pos_y - 3][63 - (tank_1_pos_x + 1)]
                      | map_mem[tank_1_pos_y - 3][63 - (tank_1_pos_x + 2)]     //collision with wall
                      | (( tank_1_pos_y < 7 + tank_2_pos_y )&&(tank_2_pos_y < tank_1_pos_y)
                        &&((tank_2_pos_x + 6 > tank_1_pos_x) && (tank_2_pos_x < tank_1_pos_x + 6))) )    
                            //collision with tank
                        next_dir_1 = 3'b100;
                    else next_dir_1 = 3'b000;
                end
                else if( ~press_down_1 ) begin
                    if(tank_1_dir != 2'd1)next_dir_1 = 3'd1;
                    else if( map_mem[tank_1_pos_y + 3][63 - (tank_1_pos_x - 2)] 
                      | map_mem[tank_1_pos_y + 3][63 - (tank_1_pos_x - 1)]
                      | map_mem[tank_1_pos_y + 3][63 - (tank_1_pos_x)]
                      | map_mem[tank_1_pos_y + 3][63 - (tank_1_pos_x + 1)]
                      | map_mem[tank_1_pos_y + 3][63 - (tank_1_pos_x + 2)]     //collision
                      | (( tank_2_pos_y < 7 + tank_1_pos_y)&&(tank_1_pos_y < tank_2_pos_y)
                     &&((tank_2_pos_x + 6> tank_1_pos_x) && (tank_2_pos_x < tank_1_pos_x + 6))) )    
                            //collision with tank
                        next_dir_1 = 3'b100;
                    else next_dir_1 = 3'b001;
                end
                else if( ~press_left_1 ) begin
                    if(tank_1_dir != 2'd2)next_dir_1 = 3'd2;
                    else if( map_mem[tank_1_pos_y - 2][63 - (tank_1_pos_x - 3)]
                      | map_mem[tank_1_pos_y - 1][63 - (tank_1_pos_x - 3)]
                      | map_mem[tank_1_pos_y][63 - (tank_1_pos_x - 3)]
                      | map_mem[tank_1_pos_y + 1][63 - (tank_1_pos_x - 3)]
                      | map_mem[tank_1_pos_y + 2][63 - (tank_1_pos_x - 3)]    //collision
                      | (( tank_1_pos_x < 7 + tank_2_pos_x )&&(tank_2_pos_x < tank_1_pos_x)
                        &&((tank_2_pos_y < tank_1_pos_y + 6) && (tank_2_pos_y + 6 > tank_1_pos_y))) )    
                            //collision with tank
                        next_dir_1 = 3'b100;
                    else next_dir_1 = 3'b010;
                end
                else if( ~press_right_1 ) begin
                    if(tank_1_dir != 2'd3)next_dir_1 = 3'd3;
                    else if( map_mem[tank_1_pos_y - 2][63 - (tank_1_pos_x + 3)]
                      | map_mem[tank_1_pos_y - 1][63 - (tank_1_pos_x + 3)]
                      | map_mem[tank_1_pos_y][63 - (tank_1_pos_x + 3)]
                      | map_mem[tank_1_pos_y + 1][63 - (tank_1_pos_x + 3)]
                      | map_mem[tank_1_pos_y + 2][63 - (tank_1_pos_x + 3)]    //collision
                      | (( tank_2_pos_x < 7 + tank_1_pos_x)&&(tank_1_pos_x < tank_2_pos_x)
                        &&((tank_2_pos_y < tank_1_pos_y + 6) && (tank_2_pos_y + 6 > tank_1_pos_y))) )    
                            //collision with tank
                        next_dir_1 = 3'b100;
                    else next_dir_1 = 3'b011;
                end
                else begin
                    next_dir_1 = 3'b100;
                end

                //----------------------------tank_2------------------------------------
                 //shoot
                if( ~fire_2 ) next_fire_2 = ~press_fire_2;
                else next_fire_2 = ~valid_frame_2;

                if( ~press_up_2 ) begin
                    if(tank_2_dir != 2'd0)next_dir_2 = 3'd0;
                    else if( map_mem[tank_2_pos_y - 3][63 - (tank_2_pos_x - 2)] 
                      | map_mem[tank_2_pos_y - 3][63 - (tank_2_pos_x - 1)]
                      | map_mem[tank_2_pos_y - 3][63 - (tank_2_pos_x)]
                      | map_mem[tank_2_pos_y - 3][63 - (tank_2_pos_x + 1)]
                      | map_mem[tank_2_pos_y - 3][63 - (tank_2_pos_x + 2)]    //collision
                      | (( tank_2_pos_y  < 7 + tank_1_pos_y)&&(tank_1_pos_y < tank_2_pos_y)
                        &&((tank_1_pos_x +6 > tank_2_pos_x ) && (tank_1_pos_x < tank_2_pos_x + 6))) )    
                            //collision with tank
                        next_dir_2 = 3'b100;
                    else next_dir_2 = 3'b000;
                end
                else if( ~press_down_2 ) begin
                    if(tank_2_dir != 2'd1)next_dir_2 = 3'd1;
                    else if( map_mem[tank_2_pos_y + 3][63 - (tank_2_pos_x - 2)] 
                      | map_mem[tank_2_pos_y + 3][63 - (tank_2_pos_x - 1)]
                      | map_mem[tank_2_pos_y + 3][63 - (tank_2_pos_x)]
                      | map_mem[tank_2_pos_y + 3][63 - (tank_2_pos_x + 1)]
                      | map_mem[tank_2_pos_y + 3][63 - (tank_2_pos_x + 2)]    //collision
                      | (( tank_1_pos_y < 7 + tank_2_pos_y)&&(tank_2_pos_y < tank_1_pos_y)
                        &&((tank_1_pos_x +6 > tank_2_pos_x) && (tank_1_pos_x < tank_2_pos_x + 6))) )    
                            //collision with tank
                        next_dir_2 = 3'b100;
                    else next_dir_2 = 3'b001;
                end
                else if( ~press_left_2 ) begin
                    if(tank_2_dir != 2'd2)next_dir_2 = 3'd2;
                    else if( map_mem[tank_2_pos_y - 2][63 - (tank_2_pos_x - 3)]
                      | map_mem[tank_2_pos_y - 1][63 - (tank_2_pos_x - 3)]
                      | map_mem[tank_2_pos_y][63 - (tank_2_pos_x - 3)]
                      | map_mem[tank_2_pos_y + 1][63 - (tank_2_pos_x - 3)]
                      | map_mem[tank_2_pos_y + 2][63 - (tank_2_pos_x - 3)]   //collision
                      | (( tank_2_pos_x < 7 + tank_1_pos_x)&&(tank_1_pos_x < tank_2_pos_x)
                        &&((tank_1_pos_y < tank_2_pos_y + 6) && (tank_1_pos_y + 6 > tank_2_pos_y))) )    
                            //collision with tank
                        next_dir_2 = 3'b100;
                    else next_dir_2 = 3'b010;
                end
                else if( ~press_right_2 ) begin
                    if(tank_2_dir != 2'd3)next_dir_2 = 3'd3;
                    else if( map_mem[tank_2_pos_y - 2][63 - (tank_2_pos_x + 3)]
                      | map_mem[tank_2_pos_y - 1][63 - (tank_2_pos_x + 3)]
                      | map_mem[tank_2_pos_y][63 - (tank_2_pos_x + 3)]
                      | map_mem[tank_2_pos_y + 1][63 - (tank_2_pos_x + 3)]
                      | map_mem[tank_2_pos_y + 2][63 - (tank_2_pos_x + 3)]    //collision
                      | (( tank_1_pos_x < 7 + tank_2_pos_x)&&(tank_2_pos_x < tank_1_pos_x)
                        &&((tank_1_pos_y < tank_2_pos_y + 6) && (tank_1_pos_y + 6 > tank_2_pos_y))) )    
                            //collision with tank
                        next_dir_2 = 3'b100;
                    else next_dir_2 = 3'b011;
                end
                else begin
                    next_dir_2 = 3'b100;
                end

                //collision with shell--> shell_vanish, state, who_wins====================
                //output next_shell_vanish_1[0:4], next_shell_vanish_2[0:4], next_state, next_who_wins
                //use    i_valid_shell_1, i_valid_shell_2
                //----------------------------tank_1, shell_0---------------------------------
                if( ~i_valid_shell_1[0] & ~shell_vanish_1[0]) begin
                    //shell hit wall
                    if( map_mem[shell_1_0_pos_y][63 - shell_1_0_pos_x] ) next_shell_vanish_1[0] = 1'b1;
                    else next_shell_vanish_1[0] = 1'b0;
                    //shell hit car
                    if(( shell_1_0_pos_x >= (tank_2_pos_x - 2)
                      & shell_1_0_pos_x <= (tank_2_pos_x + 2)
                      & shell_1_0_pos_y >= tank_2_pos_y - 2
                      & shell_1_0_pos_y <= tank_2_pos_y + 2 )) begin
                        next_shell_hit_1[0] = 1'b1;
                        next_shell_vanish_1[0] = 1'b1;
                    end
                    else begin
                        next_shell_hit_1[0] = 1'b0;
                    end
                end
                else begin
                    next_shell_vanish_1[0] = 1'b0;
                    next_shell_hit_1[0] = 1'b0;
                end
                //----------------------------tank_1, shell_1---------------------------------
                if( ~i_valid_shell_1[1] & ~shell_vanish_1[1]) begin
                    //shell hit wall
                    if( map_mem[shell_1_1_pos_y][63 - shell_1_1_pos_x] ) next_shell_vanish_1[1] = 1'b1;
                    else next_shell_vanish_1[1] = 1'b0;
                    //shell hit car
                    if(( shell_1_1_pos_x >= (tank_2_pos_x - 2)
                      & shell_1_1_pos_x <= (tank_2_pos_x + 2)
                      & shell_1_1_pos_y >= tank_2_pos_y - 2
                      & shell_1_1_pos_y <= tank_2_pos_y + 2 )) begin
                        next_shell_hit_1[1] = 1'b1;
                        next_shell_vanish_1[1] = 1'b1;
                    end
                    else begin
                        next_shell_hit_1[1] = 1'b0;
                    end
                end
                else begin
                    next_shell_vanish_1[1] = 1'b0;
                    next_shell_hit_1[1] = 1'b0;
                end
                //----------------------------tank_1, shell_2---------------------------------
                if( ~i_valid_shell_1[2] & ~shell_vanish_1[2]) begin
                    //shell hit wall
                    if( map_mem[shell_1_2_pos_y][63 - shell_1_2_pos_x] ) next_shell_vanish_1[2] = 1'b1;
                    else next_shell_vanish_1[2] = 1'b0;
                    //shell hit car
                    if(( shell_1_2_pos_x >= (tank_2_pos_x - 2)
                      & shell_1_2_pos_x <= (tank_2_pos_x + 2)
                      & shell_1_2_pos_y >= tank_2_pos_y - 2
                      & shell_1_2_pos_y <= tank_2_pos_y + 2 )) begin
                        next_shell_hit_1[2] = 1'b1;
                        next_shell_vanish_1[2] = 1'b1;
                    end
                    else begin
                        next_shell_hit_1[2] = 1'b0;
                    end
                end
                else begin
                    next_shell_vanish_1[2] = 1'b0;
                    next_shell_hit_1[2] = 1'b0;
                end
                //----------------------------tank_1, shell_3---------------------------------
                if( ~i_valid_shell_1[3] & ~shell_vanish_1[3]) begin
                    //shell hit wall
                    if( map_mem[shell_1_3_pos_y][63 - shell_1_3_pos_x] ) next_shell_vanish_1[3] = 1'b1;
                    else next_shell_vanish_1[3] = 1'b0;
                    //shell hit car
                    if(( shell_1_3_pos_x >= (tank_2_pos_x - 2)
                      & shell_1_3_pos_x <= (tank_2_pos_x + 2)
                      & shell_1_3_pos_y >= tank_2_pos_y - 2
                      & shell_1_3_pos_y <= tank_2_pos_y + 2 )) begin
                        next_shell_hit_1[3] = 1'b1;
                        next_shell_vanish_1[3] = 1'b1;
                    end
                    else begin
                        next_shell_hit_1[3] = 1'b0;
                    end
                end
                else begin
                    next_shell_vanish_1[3] = 1'b0;
                    next_shell_hit_1[3] = 1'b0;
                end
                //----------------------------tank_1, shell_4---------------------------------
                if( ~i_valid_shell_1[4] & ~shell_vanish_1[4]) begin
                    //shell hit wall
                    if( map_mem[shell_1_4_pos_y][63 - shell_1_4_pos_x] ) next_shell_vanish_1[4] = 1'b1;
                    else next_shell_vanish_1[4] = 1'b0;
                    //shell hit car
                    if(( shell_1_4_pos_x >= (tank_2_pos_x - 2)
                      & shell_1_4_pos_x <= (tank_2_pos_x + 2)
                      & shell_1_4_pos_y >= tank_2_pos_y - 2
                      & shell_1_4_pos_y <= tank_2_pos_y + 2 )) begin
                        next_shell_hit_1[4] = 1'b1;
                        next_shell_vanish_1[4] = 1'b1;
                    end
                    else begin
                        next_shell_hit_1[4] = 1'b0;
                    end
                end
                else begin
                    next_shell_vanish_1[4] = 1'b0;
                    next_shell_hit_1[4] = 1'b0;
                end
                //----------------------------tank_2, shell_0---------------------------------
                if( ~i_valid_shell_2[0] & ~shell_vanish_2[0]) begin
                    //shell hit wall
                    if( map_mem[shell_2_0_pos_y][63 - shell_2_0_pos_x] ) next_shell_vanish_2[0] = 1'b1;
                    else next_shell_vanish_2[0] = 1'b0;
                    //shell hit car
                    if(( shell_2_0_pos_x >= (tank_1_pos_x - 2) 
                      & shell_2_0_pos_x <= (tank_1_pos_x + 2)  
                      & shell_2_0_pos_y >= tank_1_pos_y - 2
                      & shell_2_0_pos_y <= tank_1_pos_y + 2 )) begin
                        next_shell_hit_2[0] = 1'b1;
                        next_shell_vanish_2[0] = 1'b1;
                    end
                    else begin
                        next_shell_hit_2[0] = 1'b0;
                    end
                end
                else begin
                    next_shell_vanish_2[0] = 1'b0;
                    next_shell_hit_2[0] = 1'b0;
                end
                //----------------------------tank_2, shell_1---------------------------------
                if( ~i_valid_shell_2[1] & ~shell_vanish_2[1]) begin
                    //shell hit wall
                    if( map_mem[shell_2_1_pos_y][63 - shell_2_1_pos_x] ) next_shell_vanish_2[1] = 1'b1;
                    else next_shell_vanish_2[1] = 1'b0;
                    //shell hit car
                    if(( shell_2_1_pos_x >= (tank_1_pos_x - 2) 
                      & shell_2_1_pos_x <= (tank_1_pos_x + 2)  
                      & shell_2_1_pos_y >= tank_1_pos_y - 2
                      & shell_2_1_pos_y <= tank_1_pos_y + 2 )) begin
                        next_shell_hit_2[1] = 1'b1;
                        next_shell_vanish_2[1] = 1'b1;
                    end
                    else begin
                        next_shell_hit_2[1] = 1'b0;
                    end
                end
                else begin
                    next_shell_vanish_2[1] = 1'b0;
                    next_shell_hit_2[1] = 1'b0;
                end
                //----------------------------tank_2, shell_2---------------------------------
                if( ~i_valid_shell_2[2] & ~shell_vanish_2[2]) begin
                    //shell hit wall
                    if( map_mem[shell_2_2_pos_y][63 - shell_2_2_pos_x] ) next_shell_vanish_2[2] = 1'b1;
                    else next_shell_vanish_2[2] = 1'b0;
                    //shell hit car
                    if(( shell_2_2_pos_x >= (tank_1_pos_x - 2) 
                      & shell_2_2_pos_x <= (tank_1_pos_x + 2)  
                      & shell_2_2_pos_y >= tank_1_pos_y - 2
                      & shell_2_2_pos_y <= tank_1_pos_y + 2 )) begin
                        next_shell_hit_2[2] = 1'b1;
                        next_shell_vanish_2[2] = 1'b1;
                    end
                    else begin
                        next_shell_hit_2[2] = 1'b0;
                    end
                end
                else begin
                    next_shell_vanish_2[2] = 1'b0;
                    next_shell_hit_2[2] = 1'b0;
                end
                //----------------------------tank_2, shell_3---------------------------------
                if( ~i_valid_shell_2[3] & ~shell_vanish_2[3]) begin
                    //shell hit wall
                    if( map_mem[shell_2_3_pos_y][63 - shell_2_3_pos_x] ) next_shell_vanish_2[3] = 1'b1;
                    else next_shell_vanish_2[3] = 1'b0;
                    //shell hit car
                    if(( shell_2_3_pos_x >= (tank_1_pos_x - 2) 
                      & shell_2_3_pos_x <= (tank_1_pos_x + 2)  
                      & shell_2_3_pos_y >= tank_1_pos_y - 2
                      & shell_2_3_pos_y <= tank_1_pos_y + 2 )) begin
                        next_shell_hit_2[3] = 1'b1;
                        next_shell_vanish_2[3] = 1'b1;
                    end
                    else begin
                        next_shell_hit_2[3] = 1'b0;
                    end
                end
                else begin
                    next_shell_vanish_2[3] = 1'b0;
                    next_shell_hit_2[3] = 1'b0;
                end
                //----------------------------tank_2, shell_4---------------------------------
                if( ~i_valid_shell_2[4] & ~shell_vanish_2[4]) begin
                    //shell hit wall
                    if( map_mem[shell_2_4_pos_y][63 - shell_2_4_pos_x] ) next_shell_vanish_2[4] = 1'b1;
                    else next_shell_vanish_2[4] = 1'b0;
                    //shell hit car
                    if(( shell_2_4_pos_x >= (tank_1_pos_x - 2) 
                      & shell_2_4_pos_x <= (tank_1_pos_x + 2)  
                      & shell_2_4_pos_y >= tank_1_pos_y - 2
                      & shell_2_4_pos_y <= tank_1_pos_y + 2 )) begin
                        next_shell_hit_2[4] = 1'b1;
                        next_shell_vanish_2[4] = 1'b1;
                    end
                    else begin
                        next_shell_hit_2[4] = 1'b0;
                    end
                end
                else begin
                    next_shell_vanish_2[4] = 1'b0;
                    next_shell_hit_2[4] = 1'b0;
                end

                next_state = state;
                next_who_wins = 2'b00;

                if( shell_hit_1 ) begin
                    if(tank_2_life > 3'd1) next_tank_2_hurt = 1'b1;
                    else begin
                        next_state = END;
                        next_who_wins = 2'b01;
                    end
                    
                end
                
                if( shell_hit_2 ) begin 
                    if(tank_1_life > 3'd1) next_tank_1_hurt = 1'b1;
                    else begin
                        next_state = END;
                        next_who_wins = 2'b10;
                    end
                end
                    


                //draw map--> next_is_map==================================================
                //output o_is_map
                //use    i_x_pos, i_y_pos
                if( map_mem[i_y_pos][63 - i_x_pos] ) next_is_map = 1'b1;
                else next_is_map = 1'b0;
                
            end
            END: begin
                if( ~press_left_1 & ~press_left_2 ) next_state = GAME;
                else next_state = state;
                //others
                //object
                next_valid_frame_1  = 5'b0;
                next_valid_frame_2  = 5'b0;
                next_dir_1          = 3'b100;
                next_dir_2          = 3'b100;
                next_fire_1         = 1'b0;
                next_fire_2         = 1'b0;
                next_shell_vanish_1 = 5'b0;
                next_shell_vanish_2 = 5'b0;
                next_shell_hit_1    = 5'b0;
                next_shell_hit_2    = 5'b0;
                //VGA
                next_is_map         = 1'b0;
                next_who_wins       = who_wins;
            end
        endcase
    end

    //sequential part===================================================================================
    always_ff@(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            //object
            valid_frame_1      <= 1'b0;
            valid_frame_2      <= 1'b0;
            dir_1            <= 3'b100;
            dir_2            <= 3'b100;
            fire_1           <= 1'b0;
            fire_2           <= 1'b0;
            shell_vanish_1   <= 5'b0;
            shell_vanish_2   <= 5'b0;
            shell_hit_1      <= 5'b0;
            shell_hit_2      <= 5'b0;
            o_tank_1_hurt    <= 1'b0;
            o_tank_2_hurt    <= 1'b0;
            //VGA
            is_map    <= 1'b0;
            state     <= START;
            who_wins  <= 2'b00;	
		end
		else begin
            //object
            valid_frame_1    <= next_valid_frame_1;
            valid_frame_2    <= next_valid_frame_2;
            dir_1          <= next_dir_1;
            dir_2          <= next_dir_2;
            fire_1         <= next_fire_1;
            fire_2         <= next_fire_2;
            shell_vanish_1 <= next_shell_vanish_1;
            shell_vanish_2 <= next_shell_vanish_2;
            shell_hit_1    <= next_shell_hit_1;
            shell_hit_2    <= next_shell_hit_2;
            o_tank_1_hurt    <= next_tank_1_hurt;
            o_tank_2_hurt    <= next_tank_2_hurt;
            //VGA
            is_map    <= next_is_map;
            state     <= next_state;
            who_wins  <= next_who_wins;		
		end
    end


endmodule
