// Company           :   tud
// Author            :   liyuanguo
// E-Mail            :   <$ICPRO_EMAIL not set - insert email address>
//
// Filename          :   nac_sram.v
// Project Name      :   p_eval
// Subproject Name   :   s_compress
// Description       :   <short description>
//
// Create Date       :   Fri Jan 18 15:09:44 2019
// Last Change       :   $Date$
// by                :   $Author$
//------------------------------------------------------------


//Fill in testcase specific pattern generation

initial begin

        clk_i = 1'b1;
        reset_n_i = 1'b0;
        encode_start_i = 1'b0;
        encode_end_i = 1'b0;
        raw_data_vld_i = 1'b0;
        mem_stall_i = 1'b1;
        # 40
        reset_n_i = 1'b1;
//        freq_r = $fopen("E:/Class/project/Verilog_code/freq_sram.txt", "r");
        data_r = $fopen("data_in_sample_raw.txt", "r");
//        data_w = $fopen("E:/Class/project/Verilog_code/data_out_sample.txt", "w");
        # 20

        //freq: use SW result (distribution_mode_0 input_mode_2 spikes_mode_0 )
        encode_start_i = 1'b1;
        # 20
        $readmemh("freq_sram.txt",mem);
        # 100 
        mem_stall_i = 1'b0;
        
        while(cnt_data < 1000)begin
            flag = $fscanf(data_r, "%d", raw_data_i);
            raw_data_vld_i = 1'b1;
            cnt_data = cnt_data + 1;
            # 20 
            raw_data_vld_i = 1'b0;
            # 1500;
            
        end
	
	flag = $fscanf(data_r, "%d", raw_data_i);
        raw_data_vld_i = 1'b1;
        cnt_data = cnt_data + 1;
        # 20 
        raw_data_vld_i = 1'b0;
        # 60
        
        encode_end_i = 1'b1;
        # 1500

    $stop;
end
