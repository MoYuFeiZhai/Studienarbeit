// Company           :   tud
// Author            :   zhuowang
// E-Mail            :   <$ICPRO_EMAIL not set - insert email address>
//
// Filename          :   nac_sram.v
// Project Name      :   p_eval
// Subproject Name   :   s_iic
// Description       :   <short description>
//
// Create Date       :   Tue Jun  7 19:29:32 2022
// Last Change       :   $Date: 2022-07-07 11:30:04 +0200 (Thu, 07 Jul 2022) $
// by                :   $Author: zhuowang $
//------------------------------------------------------------

module nac_sram(
    input clk_i,
    input reset_n_i,
    input [8:0] raw_data_i,
    input raw_data_vld_i,
    input [31:0] mem_rd_data_i,
    input mem_stall_i,
    input encode_start_i,
    input encode_end_i,
    output mem_rd_en_o,
    output [7:0] mem_addr_o,
    output [7:0] comp_data_o,
    output comp_data_vld_o,
    output nac_ready_o
    );
    
    wire [8:0]  dpcm_data;
    wire        dpcm_data_vld;
    wire        bit_out;
    wire        bit_out_vld;
    wire        encode_finish;
    
    normal_ac normal_ac_i( .clk_i(clk_i),
                           .reset_n_i(reset_n_i),
                           .data_in_i(dpcm_data),
                           .data_in_vld_i(dpcm_data_vld),
                           .freq_in_i(mem_rd_data_i),
                           .freq_in_rdy_n_i(mem_stall_i),
                           .encode_start_i(encode_start_i),
                           .encode_end_i(encode_end_i),
                           .freq_rq_o(mem_rd_en_o),
                           .freq_addr_o(mem_addr_o),
                           .symbol_done_o(nac_ready_o),
                           .data_out_o(bit_out),
                           .data_out_vld_o(bit_out_vld),
                           .encode_finish_o(encode_finish)
                           );
    dpcm_2nd dpcm_2nd_i          ( .clk_i(clk_i),
                           .reset_n_i(reset_n_i),
                           .raw_data_i(raw_data_i),
                           .raw_data_vld_i(raw_data_vld_i),
                           .dpcm_data_o(dpcm_data),
                           .dpcm_data_vld_o(dpcm_data_vld)
                           );
    wrapper_v2 wrapper_i(.clk_i(clk_i),
                                          .reset_n_i(reset_n_i),
                                          .data_bit_in_i(bit_out),
                                          .data_bit_in_vld_i(bit_out_vld),
                                          .encode_finish_i(encode_finish),
                                          .data_byte_out_o(comp_data_o),
                                          .data_byte_out_vld_o(comp_data_vld_o)
                                          );
    
    
endmodule
