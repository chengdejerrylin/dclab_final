module I2Csender (
    input i_start,
    input [23:0] i_data,
    input i_clk,
    input i_rst,
    output o_finished,
    output o_scl,
    inout o_sda 
);

    localparam S_START = 0;
    localparam S_TX = 1;
    localparam S_ACK = 2;
    localparam S_FIN = 3;

    logic  [1:0] state_r, state_w;
    logic  [1:0] clk_cnt_r, clk_cnt_w;
    logic  [3:0] bit_cnt_r, bit_cnt_w;
    logic  [1:0] byte_cnt_r, byte_cnt_w;
    logic        scl_r, scl_w;
    logic        oe_r, oe_w;
    logic [23:0] i_data_r, i_data_w;
    logic        o_bit_r, o_bit_w;
    logic        o_finished_r, o_finished_w;

    assign o_finished = o_finished_r;
    assign o_scl = scl_r;
    assign o_sda = oe_r ? o_bit_r : 1'bz;

    always_comb begin
        state_w      = state_r;
        clk_cnt_w    = clk_cnt_r;
        bit_cnt_w    = bit_cnt_r;
        byte_cnt_w   = byte_cnt_r;
        scl_w        = scl_r;
        oe_w         = oe_r;
        i_data_w     = i_data_r;
        o_bit_w      = o_bit_r;
        o_finished_w = o_finished_r;

        case (state_r)
            S_START:
            begin
                if (i_start) begin
                    o_bit_w = 0;
                    clk_cnt_w = 0;
                    bit_cnt_w = 0;
                    byte_cnt_w = 0;
                    state_w = S_TX;
                    o_finished_w = 0;
                    i_data_w = i_data;
                end
            end
            S_TX:
            begin
                scl_w = 0;
                if (!scl_r) begin
                    state_w = S_ACK;
                    o_bit_w = i_data_r[23];
                    i_data_w = i_data_r << 1;
                end
            end
            S_ACK:
            begin
                if (clk_cnt_r == 0) begin
                    clk_cnt_w = clk_cnt_r + 1;
                    scl_w = 1;
                end else if (clk_cnt_r == 1) begin
                    clk_cnt_w = clk_cnt_r + 1;
                    scl_w = 0;
                end else if (clk_cnt_r == 2) begin
                    clk_cnt_w = 0;
                    bit_cnt_w = bit_cnt_r + 1;

                    if (bit_cnt_r < 7) begin
                        o_bit_w = i_data_r[23];
                        i_data_w = i_data_r << 1;
                    end else if (bit_cnt_r == 7) begin
                        oe_w = 0;
                    end else if (bit_cnt_r == 8 && byte_cnt_r != 2) begin
                        byte_cnt_w = byte_cnt_r + 1;
                        oe_w = 1;
                        bit_cnt_w = 0;
                        i_data_w = i_data_r << 1;
                        o_bit_w = i_data_r[23];
                    end else if (bit_cnt_r == 8 && byte_cnt_r == 2) begin
                        oe_w = 1;
                        o_bit_w = 0;
                        state_w = S_FIN;
                    end
                end
            end
            S_FIN:
            begin
                scl_w = 1;
                if (scl_r) begin
                    state_w = S_START;
                    o_bit_w = 1;
                    o_finished_w = 1;
                end
            end
        endcase
    end
    
    always_ff @(posedge i_clk or negedge i_rst) begin
        if (~i_rst) begin
            state_r      <= S_START;
            o_bit_r      <= 1;
            o_finished_r <= 0;
            scl_r        <= 1;
            oe_r         <= 1;
            bit_cnt_r    <= 0;
            byte_cnt_r   <= 0;
            clk_cnt_r    <= 0;
            i_data_r     <= 24'b0011_0100_000_1111_0_0000_0000; //reset
        end
        else begin
            state_r      <= state_w;
            o_bit_r      <= o_bit_w;
            o_finished_r <= o_finished_w;
            scl_r        <= scl_w;
            oe_r         <= oe_w;
            bit_cnt_r    <= bit_cnt_w;
            byte_cnt_r   <= byte_cnt_w;
            clk_cnt_r    <= clk_cnt_w;
            i_data_r     <= i_data_w;
            
        end
    end

endmodule
