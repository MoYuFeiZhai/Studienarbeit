// Company           :   tud
// Author            :   zhuowang
// E-Mail            :   <$ICPRO_EMAIL not set - insert email address>
//
// Filename          :   mul.v
// Project Name      :   p_eval
// Subproject Name   :   s_iic
// Description       :   <17 * 14 multiplier module>
//
// Create Date       :   Tue Jun  7 19:29:32 2022
// Last Change       :   $Date: 2022-06-07 21:29:35 +0200 (Tue, 07 Jun 2022) $
// by                :   $Author: zhuowang $
//------------------------------------------------------------
module mul (
    clk_i,
    reset_n_i,
    mul_a_i,
    mul_b_i,
    mul_en_i,
    mul_out_o,
    mul_done_o 
); //17 x 14 
    input               clk_i,reset_n_i;
    input   [16:0]      mul_a_i;
    input   [13:0]      mul_b_i;
    input               mul_en_i;
    output  [30:0]      mul_out_o;
    output              mul_done_o;
    
    reg     [30:0]      mul_out_o;
    reg     [31:0]      mul_out_l;
    reg     [32:0]      mul_out_h;
//    wire    [32:0]      mul_res;
    reg                 mul_done_o;
    reg     [31:0]      store15,store14,store13,store12,store11,store10,store9,store8,
                        store7,store6,store5,store4,store3,store2,store1,store0;    
    reg     [31:0]      add01,add23,add45,add67,add89,add1011,add1213,add1415;
    reg     [31:0]      add0123,add4567,add891011,add12131415;
    reg     [31:0]      add01234567,add89101112131415;
    reg     [3:0]       delay;
    reg                 cnt_start;

//    assign  mul_res = mul_out_l + mul_out_h;
    always @ (posedge clk_i or negedge reset_n_i)
    begin
        if(!reset_n_i)
            begin
                store15 <= 32'b0;
                store14 <= 32'b0;
                store13 <= 32'b0;
                store12 <= 32'b0;
                store11 <= 32'b0;
                store10 <= 32'b0;
                store9 <= 32'b0;
                store8 <= 32'b0;
                store7 <= 32'b0;
                store6 <= 32'b0;
                store5 <= 32'b0;
                store4 <= 32'b0;
                store3 <= 32'b0;
                store2 <= 32'b0;
                store1 <= 32'b0;
                store0 <= 32'b0;
                add01  <= 32'b0;
                add23  <= 32'b0;
                add45  <= 32'b0;
                add67  <= 32'b0;
                add89  <= 32'b0;
                add1011  <= 32'b0;
                add1213  <= 32'b0;
                add1415  <= 32'b0;
                add0123  <= 32'b0;
                add4567  <= 32'b0;
                add891011  <= 32'b0;
                add12131415  <= 32'b0;
                add01234567  <= 32'b0;
                add89101112131415  <= 32'b0;
                delay <= 4'b0;
                mul_out_l <= 32'b0;
                mul_out_h <= 33'b0;
                mul_done_o <=1'b0;
                mul_out_o <= 32'b0;
                cnt_start <= 1'b0;
            end
        else
            begin
                if (mul_en_i)begin
                    mul_done_o <=1'b0;
                    cnt_start <= 1'b1;
                    store15 <= 0;
                    store14 <= 0;
                    store13 <= mul_b_i[13] ? {3'b0,mul_a_i[15:0],13'b0}:32'b0;
                    store12 <= mul_b_i[12] ? {4'b0,mul_a_i[15:0],12'b0}:32'b0;
                    store11 <= mul_b_i[11] ? {5'b0,mul_a_i[15:0],11'b0}:32'b0;
                    store10 <= mul_b_i[10] ? {6'b0,mul_a_i[15:0],10'b0}:32'b0;
                    store9 <= mul_b_i[9] ? {7'b0,mul_a_i[15:0],9'b0}:32'b0;
                    store8 <= mul_b_i[8] ? {8'b0,mul_a_i[15:0],8'b0}:32'b0;
                    store7 <= mul_b_i[7] ? {9'b0,mul_a_i[15:0],7'b0}:32'b0;
                    store6 <= mul_b_i[6] ? {10'b0,mul_a_i[15:0],6'b0}:32'b0;
                    store5 <= mul_b_i[5] ? {11'b0,mul_a_i[15:0],5'b0}:32'b0;
                    store4 <= mul_b_i[4] ? {12'b0,mul_a_i[15:0],4'b0}:32'b0;
                    store3 <= mul_b_i[3] ? {13'b0,mul_a_i[15:0],3'b0}:32'b0;
                    store2 <= mul_b_i[2] ? {14'b0,mul_a_i[15:0],2'b0}:32'b0;
                    store1 <= mul_b_i[1] ? {15'b0,mul_a_i[15:0],1'b0}:32'b0;
                    store0 <= mul_b_i[0] ? {16'b0,mul_a_i[15:0]}:32'b0;
                end
                

                add1415  <= store15 + store14;
                add1213  <= store13 + store12;
                add1011  <= store11 + store10;
                add89  <= store9 + store8;
                add67  <= store7 + store6;
                add45  <= store5 + store4;
                add23  <= store3 + store2;
                add01  <= store1 + store0;

                add0123  <= add01 + add23;
                add4567  <= add45 + add67;
                add891011  <= add89 + add1011;
                add12131415  <= add1213 + add1415;

                add01234567 <= add0123 + add4567;
                add89101112131415 <= add891011 + add12131415;

                mul_out_l <= add01234567 + add89101112131415;
                mul_out_h <= (mul_a_i[16]) ? (mul_b_i << 16) : 33'b0;

                

                if(cnt_start) begin
                    delay <= delay + 1;       
                end
                if (delay == 5)begin
                    mul_done_o <= 1'b1;
                    cnt_start <= 1'b0;
                    delay <= 0;
                    mul_out_o <= mul_out_l + mul_out_h;
                end
                     
            end
    end
endmodule
