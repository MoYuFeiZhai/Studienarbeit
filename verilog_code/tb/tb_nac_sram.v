// Company           :   tud
// Author            :   zhuowang
// E-Mail            :   <$ICPRO_EMAIL not set - insert email address>
//
// Filename          :   tb_normal_ac.v
// Project Name      :   p_eval
// Subproject Name   :   s_iic
// Description       :   <short description>
//
// Create Date       :   Wed May 18 18:35:29 2022
// Last Change       :   $Date: 2022-05-30 17:37:29 +0200 (Mon, 30 May 2022) $
// by                :   $Author: zhuowang $
//------------------------------------------------------------

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: tud
// Engineer: zhuowang
// 
// Create Date: 2022/05/16 12:32:15
// Design Name: 
// Module Name: top_normal_ac_tb
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

`define clock_period 20
module tb_nac_sram(
);

    reg         clk_i;
    reg         reset_n_i;
    reg [8:0]   raw_data_i;
    reg         raw_data_vld_i;
    reg  [31:0]  mem_rd_data_i;
//    wire  [31:0]  mem_rd_data_i;
    reg         mem_stall_i;
    reg         encode_start_i;
    reg         encode_end_i;
    wire        mem_rd_en_o;
    wire [7:0]  mem_addr_o;
    wire [7:0]  comp_data_o;
    wire        comp_data_vld_o;
    wire	nac_ready_o;
    
    integer         freq_r;
    integer         data_r;
//    integer         data_w;
    integer         flag;

    reg [15:0]      cnt = 0;
    reg [18:0]      cnt_data = 0;
    reg [31:0]      mem [0:256];
    reg [127:0]      state_name;
    
always #(`clock_period/2) clk_i = ~clk_i; //50M

initial begin
        reset_n_i = 1'b0;
	#40;
	reset_n_i = 1'b1;
end

//assign mem_rd_data_i = (mem_rd_en_o) ? mem[mem_addr_o]:{32'b0};
always @ (posedge clk_i or negedge reset_n_i)
begin
    if (!reset_n_i)begin
        mem_rd_data_i <= 'b0;
    end
    else if (mem_rd_en_o)
        mem_rd_data_i <= mem[mem_addr_o]; //mem_rd_data_i;
end

always @ (*)begin
    case (nac_sram_i.normal_ac_i.current_state)
         0001 :  state_name = "        IDLE";
         0002 :  state_name = "   CAL_RANGE";
         0004 :  state_name = "    RD_CHECK";
         0008 :  state_name = "   RD_MEM_HL";
         0010 :  state_name = "    RD_MEM_L";
         0020 :  state_name = "    RD_MEM_H";
         0040 :  state_name = "     CAL_MUL";
         0080 :  state_name = "     CAL_DIV";
         0100 :  state_name = "   MUL_DELAY";
         0200 :  state_name = "   DIV_DELAY";
         0400 :  state_name = "     RESCALE";
         0800 :  state_name = "    OUTPUT_1";
         1000 :  state_name = "    OUTPUT_0";
         2000 :  state_name = " OUTPUT_HOLD";
         4000 :  state_name = "      CAL_HL";
         8000 :  state_name = "   EOF_CHECK";
         10000:  state_name = "      FINISH";
         default     :  state_name = " IDLE";      
     endcase
end


nac_sram nac_sram_i(
    clk_i,
    reset_n_i,
    raw_data_i,
    raw_data_vld_i,
    mem_rd_data_i,
    mem_stall_i,
    encode_start_i,
    encode_end_i,
    mem_rd_en_o,
    mem_addr_o,
    comp_data_o,
    comp_data_vld_o,
    nac_ready_o
    );

    `include "testcase.v"

endmodule
