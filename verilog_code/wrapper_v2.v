`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/13 15:47:42
// Design Name: 
// Module Name: wrapper_v2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module wrapper_v2(
    clk_i,
    reset_n_i,
    data_bit_in_i,
    data_bit_in_vld_i,
    encode_finish_i,
    data_byte_out_o,
    data_byte_out_vld_o
    );
    
    input           clk_i;
    input           reset_n_i;
    input           data_bit_in_i;
    input           data_bit_in_vld_i;
    input           encode_finish_i;
    output [7:0]    data_byte_out_o;
    output          data_byte_out_vld_o;
    
    reg [7:0]       data_byte_out_o;
    reg             data_byte_out_vld_o;
    reg [7:0]       data_buffer;
	reg [7:0]       encode_end_buffer;
	reg [7:0]       last_buffer;
    reg [2:0]       bit_cnt;
    reg             data_bit_in_vld;
	reg				encode_finish;
//    reg [4:0]       encode_end_cnt;
//	reg				encode_end_curr;
//	reg				encode_end_last;
//	reg				encode_end_curr_zero;
//	reg				encode_end_last_zero;
    
//    wire            encode_end_flag_zero;
//    wire            encode_end_flag;
    wire            buffer_update_flag;
//	wire			second_last_buffer_done;
    
//always @ (posedge clk_i)//can be modified / eliminated
//begin
//    encode_end_curr_zero <= encode_finish_i;
//    encode_end_last_zero <= encode_end_curr_zero;
//    end

always @ (posedge clk_i or negedge reset_n_i)
begin
	if (!reset_n_i) begin
		encode_finish <= 1'b0;

	end
	else if(encode_finish_i)begin
		encode_finish <= 1'b1;
	end
end

    
always @ (posedge clk_i or negedge reset_n_i)
begin
	if (!reset_n_i) begin
		bit_cnt <= 3'b0;
		data_buffer <= {8{1'b0}};
		data_bit_in_vld <= 1'b0;
	end
	else if (data_bit_in_vld_i) begin
		bit_cnt <= bit_cnt + 1;
		data_buffer[bit_cnt] <= data_bit_in_i;
		data_bit_in_vld <= 1'b1;
	end
	else begin
		bit_cnt <= bit_cnt;
		data_buffer[bit_cnt] <= data_buffer[bit_cnt];
		data_bit_in_vld <= 1'b0;
	end
end

//always @ (posedge clk_i or negedge reset_n_i)
//begin
//	if (!reset_n_i) begin
//		encode_end_cnt <= 5'b0;
//		encode_end_buffer <= 8'b0;
//	end
//	else if (encode_end_flag_zero == 1'b1 && bit_cnt == 3'b000)begin
//	    encode_end_cnt <= 5'b01111;
//	    encode_end_buffer <= 8'b00000000;
//	end
//	else if (encode_finish == 1'b1 && encode_end_cnt < 5'b01111) begin
//		encode_end_cnt <= encode_end_cnt + 1;
//		encode_end_buffer[encode_end_cnt[2:0]] <= 1'b0;
//	end
//	else if (encode_finish == 1'b1 && encode_end_cnt == 5'b01111) begin
//		encode_end_cnt <= encode_end_cnt + 1;
//		encode_end_buffer <= encode_end_buffer;
//	end
//	else if (encode_finish == 1'b1 && encode_end_cnt == 5'b10000) begin
//		encode_end_cnt <= encode_end_cnt;
//		encode_end_buffer <= encode_end_buffer;
//	end
//	else begin
//	    encode_end_cnt[2:0] <= bit_cnt;
//		encode_end_buffer <= data_buffer;
//	end
//end

//always @ (posedge clk_i or negedge reset_n_i)
//begin
//	if (!reset_n_i)begin
//		last_buffer <= 8'b0;
//	end
//	else if (encode_end_cnt == 5'b01111 && bit_cnt != 3'b0)begin
//		last_buffer[2:0] <= bit_cnt;
//		last_buffer[7:3] <= 5'b0;
//	end
//	else if (encode_end_cnt == 5'b01111 && bit_cnt == 3'b0)begin
//		last_buffer <= 8'b00001000;
//	end
//	else begin
//		last_buffer <= last_buffer;
//	end
//end

//always @ (posedge clk_i or negedge reset_n_i)
//begin
//	if (!reset_n_i)begin
//		encode_end_curr <= 1'b0;
//		encode_end_last <= 1'b0;
//	end
//	else if (encode_end_cnt == 5'b10000)begin
//		encode_end_curr <= 1'b1;
//		encode_end_last <= encode_end_curr;
//    end
//	else begin
//		encode_end_curr <= 1'b0;
//		encode_end_last <= encode_end_curr;
//    end
//end

//assign encode_end_flag_zero = encode_end_curr_zero & ~encode_end_last_zero;
//assign encode_end_flag = encode_end_curr & ~encode_end_last;
//assign second_last_buffer_done = (encode_finish && (encode_end_cnt == 5'b00111)) ? 1'b1 : 1'b0;
assign buffer_update_flag = (bit_cnt==3'b000 && data_bit_in_vld==1'b1) ? 1'b1 : 1'b0;


always @ (posedge clk_i or negedge reset_n_i)
begin
    if (!reset_n_i) begin
        data_byte_out_vld_o <= 1'b0;
        data_byte_out_o <= {8{1'b0}};
	end
	else if (buffer_update_flag)begin
	    data_byte_out_vld_o <= 1'b1;   
	    data_byte_out_o <= data_buffer;
	end
	else if (encode_finish)begin
	    data_byte_out_vld_o <= 1'b0;   
	    data_byte_out_o <= {8{1'b0}};
	end
	else
	    data_byte_out_vld_o <= 1'b0;
	    
end

endmodule
