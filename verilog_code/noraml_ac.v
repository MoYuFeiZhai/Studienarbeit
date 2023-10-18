// Company           :   tud
// Author            :   zhuowang
// E-Mail            :   <$ICPRO_EMAIL not set - insert email address>
//
// Filename          :   normal_ac.v
// Project Name      :   p_eval
// Subproject Name   :   s_iic
// Description       :   <normal arithmetic coding module>
//
// Create Date       :   Tue Jun  7 19:29:32 2022
// Last Change       :   $Date: 2022-06-07 21:29:35 +0200 (Tue, 07 Jun 2022) $
// by                :   $Author: zhuowang $
//------------------------------------------------------------
module normal_ac (clk_i,
                    reset_n_i,
                    data_in_i,
                    data_in_vld_i,
                    freq_in_i,
                    freq_in_rdy_n_i,
                    //freq_update_i,
                    encode_start_i,
                    encode_end_i,
                    //nll_sel_i,
                    freq_rq_o,
                    freq_addr_o,
                    symbol_done_o,
                    data_out_o,
                    data_out_vld_o,
                    encode_finish_o
);

//params
parameter NO_OF_SYMBOLS         =   513;    // 512 + EOF
parameter CODE_VALUE_BITS       =   16;
parameter DATA_WIDTH            =   9;
parameter ADDR_WIDTH            =   8;
parameter DIVISOR_CUM_FREQ      =   2**(CODE_VALUE_BITS-2)-1;

//local params
localparam VALUE_TOP            =   2**CODE_VALUE_BITS-1;
localparam VALUE_BOT            =   0;
localparam FIRST_QTR            =   VALUE_TOP/4+1;
localparam HALF                 =   FIRST_QTR*2;
localparam THIRD_QTR            =   FIRST_QTR*3;

//sm
localparam IDLE                 =   17'b00000000000000001; //0001
localparam CAL_RANGE            =   17'b00000000000000010; //0002
localparam RD_CHECK             =   17'b00000000000000100; //0004
localparam RD_MEM_HL            =   17'b00000000000001000; //0008
localparam RD_MEM_L             =   17'b00000000000010000; //0010
localparam RD_MEM_H             =   17'b00000000000100000; //0020
localparam CAL_MUL              =   17'b00000000001000000; //0040
localparam CAL_DIV              =   17'b00000000010000000; //0080
localparam MUL_DELAY            =   17'b00000000100000000; //0100
localparam DIV_DELAY            =   17'b00000001000000000; //0200
localparam RESCALE              =   17'b00000010000000000; //0400
localparam OUTPUT_1             =   17'b00000100000000000; //0800
localparam OUTPUT_0             =   17'b00001000000000000; //1000
localparam OUTPUT_HOLD          =   17'b00010000000000000; //2000
localparam CAL_HL               =   17'b00100000000000000; //4000
localparam EOF_CHECK            =   17'b01000000000000000; //8000
localparam FINISH               =   17'b10000000000000000; //10000


//ports
input                           clk_i;
input                           reset_n_i;
input   [DATA_WIDTH-1:0]        data_in_i;
input                           data_in_vld_i;
input   [31:0]                  freq_in_i;
input                           freq_in_rdy_n_i;
//input                           freq_update_i;
input                           encode_start_i;
input                           encode_end_i;
output                          freq_rq_o;
output  [ADDR_WIDTH-1:0]        freq_addr_o;
output                          symbol_done_o;
output                          data_out_o;
output                          data_out_vld_o;
output                          encode_finish_o;

//regs
reg                             freq_rq_o;
reg     [ADDR_WIDTH-1:0]        freq_addr_o;
reg                             symbol_done_o;
reg                             data_out_o;
reg                             data_out_vld_o;
reg                             encode_finish_o;

reg     [16:0]                  current_state;
reg     [16:0]                  next_state;

reg                             data_out;
reg                             data_out_valid;
reg     [DATA_WIDTH-1:0]        data_in;
reg     [CODE_VALUE_BITS-3:0]   cum_freq_l; 
reg     [CODE_VALUE_BITS-3:0]   cum_freq_h; 
reg     [CODE_VALUE_BITS-1:0]   high_value;
reg     [CODE_VALUE_BITS-1:0]   low_value;
reg     [CODE_VALUE_BITS:0]     range_value; 
reg                             range_cal;
reg                             rd_freq_hl;
reg                             rd_freq_h;
reg                             rd_freq_l;
reg                             rd_low_done;
reg                             rd_high_done;
reg                             freq_rq_en; 
reg                             mul_en;
reg                             div_en;
reg                             bit_out;
reg                             low_half_en;
reg                             low_qtr_en;
reg                             low_update_en;
reg                             high_half_en;
reg                             high_qtr_en;
reg                             high_update_en;
reg                             data_out_vld;
reg                             out_inver;
reg                             out_inver_en;
reg                             out_inver_da;
reg     [CODE_VALUE_BITS:0]     div_out_h;     
reg     [CODE_VALUE_BITS:0]     div_out_l;
reg                             div_done_h;
reg                             div_done_l;
reg     [7:0]                   tail_cnt;
reg                             tail_inc_en;
reg                             tail_dec_en;
reg                             one_last_jump;
reg                             one_last_jump_follow;
reg                             symbol_done;
reg                             finish_done;
reg                             encode_end;
reg                             encode_en_s;
reg     [9:0]                   j;
reg 	[3:0]			unused_freq;


//wires
wire    [2*CODE_VALUE_BITS-2:0] mul_out_h;     
wire    [2*CODE_VALUE_BITS-2:0] mul_out_l;
wire                            mul_done_h;
wire                            mul_done_l;
wire                            finish_first_bit;
wire    [CODE_VALUE_BITS-1:0]   new_high;
wire    [CODE_VALUE_BITS-1:0]   new_low;


//sm part 1
always @ (posedge clk_i or negedge reset_n_i)
	begin
		if (!reset_n_i)
			current_state <= IDLE;
		else
			current_state <= next_state;
	end
//sm part 2
always @ (current_state or encode_en_s or freq_in_rdy_n_i or rd_high_done or mul_done_h or data_in or mul_done_l or high_value or low_value or tail_cnt or encode_end or data_in_vld_i or finish_done)
    begin
        case (current_state)
        IDLE:
            if (encode_en_s && data_in_vld_i)   
                next_state = CAL_RANGE;
            else
                next_state = IDLE;
        CAL_RANGE:
            next_state = RD_CHECK;        
        RD_CHECK:
            if (!freq_in_rdy_n_i && data_in[0] == 1'b1)
                next_state = RD_MEM_HL;
            else if (!freq_in_rdy_n_i && data_in[0] == 1'b0 & !rd_high_done)
                next_state = RD_MEM_H;
            else if (!freq_in_rdy_n_i && data_in[0] == 1'b0 & rd_high_done)
                next_state = RD_MEM_L;
            else
                next_state = RD_CHECK;
        RD_MEM_HL:
            next_state = CAL_MUL;
        RD_MEM_L:
            next_state = CAL_MUL;
        RD_MEM_H:
            next_state = RD_CHECK;
        CAL_MUL:
            next_state = MUL_DELAY;
        CAL_DIV:
            next_state = DIV_DELAY;
//            next_state = RESCALE;
        MUL_DELAY:
            if (mul_done_h && mul_done_l)
                next_state = CAL_DIV;
//                next_state = RESCALE;
            else
                next_state = MUL_DELAY;
        DIV_DELAY:
//            if (div_done_h && div_done_l)
                next_state = RESCALE;
//            else
//                next_state = DIV_DELAY;
        CAL_HL:
            next_state = RESCALE;
        RESCALE:
            if (high_value < HALF)begin
                next_state = OUTPUT_0;
            end
            else if (low_value >= HALF)begin
                next_state = OUTPUT_1;
            end
            else if (low_value >= FIRST_QTR && high_value < THIRD_QTR)begin
                next_state = OUTPUT_HOLD;
            end
            else 
                next_state = EOF_CHECK;
        OUTPUT_0:
            if (tail_cnt == 0)
                next_state = CAL_HL;
            else
                next_state = OUTPUT_0;
        OUTPUT_1:
            if (tail_cnt == 0)
                next_state = CAL_HL;
            else
                next_state = OUTPUT_1;
        OUTPUT_HOLD:
            next_state = CAL_HL;
        EOF_CHECK:
            if (encode_end)
                next_state = FINISH;
            else if(data_in_vld_i)
                next_state = CAL_RANGE;
            else
                next_state = EOF_CHECK;
        FINISH:
            if(finish_done)
                next_state = IDLE;
            else 
                next_state = FINISH;
        default:
            next_state = IDLE;
        endcase
    end
//sm part 3
always @ (current_state or tail_cnt or out_inver or finish_first_bit or low_value)
    begin
        //init
//        high_value                  = {CODE_VALUE_BITS{1'b1}};
//        low_value                   = {CODE_VALUE_BITS{1'b0}};
//        range                       = {(CODE_VALUE_BITS+1){1'b0}};
        range_cal                   = 1'b0;
        mul_en                      = 1'b0;
        div_en                      = 1'b0;
        tail_dec_en                 = 1'b0;
        tail_inc_en                 = 1'b0;
        out_inver_en                = 1'b0;
        out_inver_da                = 1'b0;
        high_half_en                = 1'b0;
        low_half_en                 = 1'b0;
        high_update_en              = 1'b0;
        low_update_en               = 1'b0;
        high_qtr_en                 = 1'b0;
        low_qtr_en                  = 1'b0;
        one_last_jump               = 1'b0;
        data_out_vld                = 1'b0;
        bit_out                     = 1'b0;
        freq_rq_en                  = 1'b0;
//        rd_high_done                = 1'b0;
//        rd_low_done                 = 1'b0;
        rd_freq_hl                  = 1'b0;
        rd_freq_l                   = 1'b0;
        rd_freq_h                   = 1'b0;
        symbol_done                 = 1'b0;
    
        case (current_state)
        IDLE:
            begin
            symbol_done = 1'b1;
            end
        CAL_RANGE:
            begin
                range_cal = 1'b1;
            end
        RD_CHECK:
            begin
                freq_rq_en = 1'b1;
            end
        RD_MEM_HL:
            begin
                rd_freq_hl = 1'b1;
//                rd_high_done = 1'b1;
//                rd_low_done  = 1'b1;
            end
        RD_MEM_H:
            begin
                rd_freq_h = 1'b1;
//                rd_high_done = 1'b1;
            end
        RD_MEM_L:
            begin
                rd_freq_l = 1'b1;
//                rd_low_done = 1'b1;
            end
        CAL_MUL:
            begin
                mul_en = 1'b1;
            end
        MUL_DELAY:
            begin
            end
        CAL_DIV:
            begin
                div_en = 1'b1;
            end
        DIV_DELAY:
            begin
            end
        CAL_HL:
            begin
                high_update_en = 1'b1;
                low_update_en = 1'b1;
            end
        RESCALE:
            begin
            end
        OUTPUT_0:
            begin
                if (tail_cnt != 0) begin
					tail_dec_en = 1'b1;
					out_inver_en = 1'b1;
					out_inver_da = 1'b0;
				end
				else begin
				    tail_dec_en = 1'b0;
					out_inver_en = 1'b0;
					out_inver_da = 1'b1;
				end
				data_out_vld = 1'b1;
				if (out_inver) begin
					bit_out = 1'b1;
				end
				else begin
					bit_out = 1'b0;
				end
            end
        OUTPUT_1:
            begin
                if (tail_cnt != 0) begin
					tail_dec_en = 1'b1;
					out_inver_en = 1'b1;
				end
				else begin
                    high_half_en = 1'b1;
                    low_half_en = 1'b1;
					out_inver_da = 1'b1;
				end
				data_out_vld = 1'b1;
				if (out_inver) begin
					bit_out = 1'b0;
				end
				else begin
					bit_out = 1'b1;
				end
            end
        OUTPUT_HOLD:
            begin
                tail_inc_en = 1'b1;
                high_qtr_en = 1'b1;
                low_qtr_en = 1'b1;
            end
        EOF_CHECK:
            begin
                symbol_done = 1'b1;
            end
        FINISH:
            begin
                one_last_jump = 1'b1;
                if(finish_first_bit)begin
                    data_out_vld = 1'b1;
                    tail_inc_en = 1'b1;
                    if (low_value < FIRST_QTR)
                        bit_out = 1'b0;
                    else
                        bit_out = 1'b1;
                end
                else if (tail_cnt != 8'b0)begin
                    tail_dec_en = 1'b1;
                    data_out_vld = 1'b1;
                    if (low_value < FIRST_QTR)
                        bit_out = 1'b1;
                    else
                        bit_out = 1'b0;
                end
            end
        default:
            begin
            end
        endcase
    end

assign new_high = low_value + div_out_h - 1;
assign new_low  = low_value + div_out_l;
assign finish_first_bit = (one_last_jump && (!one_last_jump_follow)) ? 1'b1 : 1'b0;


always @ (posedge clk_i or negedge reset_n_i)
    begin
        if (!reset_n_i)begin
                encode_en_s <= 1'b0;
            end
            else if (encode_start_i)begin
                encode_en_s <= 1'b1;
            end
            else if (encode_end_i)begin
                encode_en_s <= 1'b0;
            end
    end
                
                 
//freq update out
//always @ (posedge clk_i or negedge reset_n_i)
//    begin
//        if (!reset_n_i)begin
//                freq_addr_o <= {ADDR_WIDTH{1'b0}};
//                freq_rq_o <= 1'b0; 
//            end
//        else if (freq_rq_en && data_in[0] == 1'b1)begin
//                freq_addr_o <= (data_in >> 1);
//                freq_rq_o <= 1'b1;
//            end
//        else if (freq_rq_en && !rd_high_done && data_in[0] == 1'b0)begin
//                freq_addr_o <= (data_in >> 1) - 1;
//                freq_rq_o <= 1'b1;
//            end
//        else if (freq_rq_en && rd_high_done && data_in[0] == 1'b0)begin
//                freq_addr_o <= (data_in >> 1);
//                freq_rq_o <= 1'b1;
//            end
//        else begin
//            freq_addr_o <= freq_addr_o;
//            freq_rq_o <= freq_rq_o;
//        end
//    end
always @ (*)
    begin
    if (freq_rq_en)begin
        freq_rq_o = 1'b1;
        if(freq_rq_en && !rd_high_done && data_in[0] == 1'b0) begin
            freq_addr_o = (data_in >> 1) - 1;
            end
        else begin
            freq_addr_o = (data_in >> 1);
            end
    end
    else begin
        freq_rq_o = 1'b0;
        freq_addr_o = {ADDR_WIDTH{1'b0}};
        end
    end

//freq update in
always @ (posedge clk_i or negedge reset_n_i)
    begin
        if (!reset_n_i)begin
            cum_freq_h <= {(CODE_VALUE_BITS-2){1'b0}};
            cum_freq_l <= {(CODE_VALUE_BITS-2){1'b0}};
             rd_high_done <= 1'b0;
             rd_low_done  <= 1'b0;
        end
        else if (rd_freq_hl)begin
            cum_freq_l <= freq_in_i[29:16];
            cum_freq_h <= freq_in_i[13:0];
             rd_high_done <= 1'b1;
             rd_low_done  <= 1'b1;
        end
        else if (rd_freq_h && data_in != 9'b0)begin
            cum_freq_h <= freq_in_i[29:16];
            cum_freq_l <= cum_freq_l;
             rd_high_done <= 1'b1;
             rd_low_done  <= rd_low_done;
        end
        else if (rd_freq_h && data_in == 9'b0)begin              //first symbol '0': high = 14h'3FFF
            cum_freq_h <= {(CODE_VALUE_BITS-2){1'b1}};
            cum_freq_l <= cum_freq_l;
             rd_high_done <= 1'b1;
             rd_low_done  <= rd_low_done;
        end                
        else if (rd_freq_l)begin
            cum_freq_h <= cum_freq_h;
            cum_freq_l <= freq_in_i[13:0];
             rd_high_done <= rd_high_done;
             rd_low_done  <= 1'b1;
        end
        else if (range_cal)begin
            cum_freq_h <= {(CODE_VALUE_BITS-2){1'b0}};
            cum_freq_l <= {(CODE_VALUE_BITS-2){1'b0}};
             rd_high_done <= 1'b0;
             rd_low_done  <= 1'b0;
             end
        else begin
            cum_freq_h <= cum_freq_h;
            cum_freq_l <= cum_freq_l;
             rd_high_done <= rd_high_done;
             rd_low_done  <= rd_low_done;
        end
    end

always @ (*)
    begin
    	unused_freq[3:2] = freq_in_i[31:30];
	    unused_freq[1:0] = freq_in_i[15:14];
    end
        

//read data_in
always @ (posedge clk_i or negedge reset_n_i)
	begin
		if (!reset_n_i)
			data_in <= {DATA_WIDTH{1'b0}};
		else if (data_in_vld_i)
			data_in <= data_in_i;
		else
			data_in <= data_in;
	end

//read encode_end
always @ (posedge clk_i or negedge reset_n_i)
	begin
		if (!reset_n_i)
			encode_end <= 1'b0;
		else if (encode_end_i)
			encode_end <= 1'b1;
		else
			encode_end <= encode_end;
	end

//cal range
always @ (posedge clk_i or negedge reset_n_i)
	begin
		if (!reset_n_i)
			range_value <= {(CODE_VALUE_BITS+1){1'b0}};
		else if (range_cal)
			range_value <= high_value - low_value + 1;
		else
		    range_value <= range_value;
	end

//tail bits change
always @ (posedge clk_i or negedge reset_n_i)
	begin
		if (!reset_n_i)
			tail_cnt <= 8'b0;
		else if (tail_inc_en)
			tail_cnt <= tail_cnt + 1;
		else if (tail_dec_en)
			tail_cnt <= tail_cnt - 1;
		else
			tail_cnt <= tail_cnt;
	end

//out inverter
always @ (posedge clk_i or negedge reset_n_i)
	begin
		if (!reset_n_i)
			out_inver <= 1'b0;
		else if (out_inver_en)
			out_inver <= 1'b1;
		else if (out_inver_da)
			out_inver <= 1'b0;
		else
			out_inver <= out_inver;
	end

//low update
always @ (posedge clk_i or negedge reset_n_i)
	begin
		if (!reset_n_i)
			low_value <= {CODE_VALUE_BITS{1'b0}};
		else if (div_done_l)              //                
			low_value <= new_low;
		else if (low_half_en)
			low_value <= low_value - HALF;
		else if (low_qtr_en)
			low_value <= low_value - FIRST_QTR;
		else if (low_update_en)
			low_value <= (low_value << 1);
	    else
			low_value <= low_value;
	end

//high update
always @ (posedge clk_i or negedge reset_n_i)
	begin
		if (!reset_n_i)
			high_value <= {CODE_VALUE_BITS{1'b1}};
		else if (div_done_h)              //
			high_value <= new_high;
		else if (high_half_en)
			high_value <= high_value - HALF;
		else if (high_qtr_en)
			high_value <= high_value - FIRST_QTR;
		else if (high_update_en)
			high_value <= (high_value << 1) + 1;
	    else
			high_value <= high_value;
	end

//output
always @ (posedge clk_i or negedge reset_n_i)
	begin
		if (!reset_n_i) begin
			data_out_o <= 1'b0;
			data_out_vld_o <= 1'b0;
            encode_finish_o <= 1'b0;
            symbol_done_o <= 1'b1;
		end
		else begin
			data_out_o <= bit_out;
			data_out_vld_o <= data_out_vld;
            encode_finish_o <= finish_done;
            symbol_done_o <= symbol_done;
		end
	end

//end tail flag
always @ (posedge clk_i or negedge reset_n_i)
	begin
		if (!reset_n_i)
            finish_done <= 1'b0;
		else if ((current_state==FINISH) && (one_last_jump_follow) && (tail_cnt==8'b0))
			finish_done <= 1'b1;
		else
			finish_done <= 1'b0;
	end

always @ (posedge clk_i or negedge reset_n_i)
	begin
		if (!reset_n_i)
			one_last_jump_follow <= 1'b0;
		else
			one_last_jump_follow <= one_last_jump;
	end

//mul module
mul mul_h (.clk_i(clk_i),
                    .reset_n_i(reset_n_i),
                    .mul_a_i(range_value),
                    .mul_b_i(cum_freq_h),
                    .mul_en_i(mul_en),
                    .mul_out_o(mul_out_h),
                    .mul_done_o(mul_done_h)
    );

mul mul_l (.clk_i(clk_i),
                    .reset_n_i(reset_n_i),
                    .mul_a_i(range_value),
                    .mul_b_i(cum_freq_l),
                    .mul_en_i(mul_en),
                    .mul_out_o(mul_out_l),
                    .mul_done_o(mul_done_l)
    );

//fixed div module
always @ (posedge clk_i or negedge reset_n_i)
	begin
		if (!reset_n_i)begin
			div_out_h <= {(CODE_VALUE_BITS+1){1'b0}};
            div_out_l <= {(CODE_VALUE_BITS+1){1'b0}};
            div_done_h <= 1'b0;
            div_done_l <= 1'b0;
        end
		else if (div_en == 1'b1)begin
			div_out_h <= mul_out_h >> 14;
            div_out_l <= mul_out_l >> 14;
            div_done_h <= 1'b1;
            div_done_l <= 1'b1;
        end
        else begin
            div_out_h <= div_out_h;
            div_out_l <= div_out_l;
            div_done_h <= 1'b0;
            div_done_l <= 1'b0;
        end
	end


//div module
//div_16b div_16b_h_i (.clk(clk_i),
//                    .rstn(reset_n_i),
//                    .data_rdy(div_en),
//                    .dividend(mul_out_h),
//                    .divisor(cum_freq[0]),
//                    .res_rdy(div_done_h),
//                    .merchant(div_out_h)//,
////                    .remainder(remainder_h)
//    );

//div_16b div_16b_l_i (.clk(clk_i),
//                    .rstn(reset_n_i),
//                    .data_rdy(div_en),
//                    .dividend(mul_out_l),
//                    .divisor(cum_freq[0]),
//                    .res_rdy(div_done_l),
//                    .merchant(div_out_l)//,
//                    .remainder(remainder_l)
//    );
endmodule
