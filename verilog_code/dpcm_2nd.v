// Company           :   tud
// Author            :   zhuowang
// E-Mail            :   <$ICPRO_EMAIL not set - insert email address>
//
// Filename          :   dpcm_2nd.v
// Project Name      :   p_eval
// Subproject Name   :   s_iic
// Description       :   <2nd order DPCM module>
//
// Create Date       :   Tue Jun  7 19:29:32 2022
// Last Change       :   $Date: 2022-06-07 21:29:35 +0200 (Tue, 07 Jun 2022) $
// by                :   $Author: zhuowang $
//------------------------------------------------------------
module dpcm_2nd (clk_i,
			 reset_n_i,
			 raw_data_i,
			 raw_data_vld_i,
			 dpcm_data_o,
			 dpcm_data_vld_o
);
//2nd order dpcm
//input stream A B C D ...
//expect out: C-2B+A D-2C+B ...

//params
parameter DATA_WIDTH = 9;
//ports
input					 clk_i;
input					 reset_n_i;
input	[DATA_WIDTH-1:0] raw_data_i;
input					 raw_data_vld_i;
output	[DATA_WIDTH-1:0] dpcm_data_o;
output					 dpcm_data_vld_o;
//regs
reg		[DATA_WIDTH-1:0] dpcm_data_o;
reg						 dpcm_data_vld_o;
reg	    [DATA_WIDTH-1:0] raw_data;
wire    [DATA_WIDTH-1:0] dpcm_data;
reg                      raw_data_vld;
reg	    [DATA_WIDTH-1:0] data_buffer_1;
reg	    [DATA_WIDTH-1:0] data_buffer_2;
reg	    [DATA_WIDTH-1:0] data_buffer_3;

		
//output
always @ (posedge clk_i or negedge reset_n_i)
	begin
		if (!reset_n_i) begin
			dpcm_data_vld_o <= 1'b0;
			dpcm_data_o <= {DATA_WIDTH{1'b0}};
		end
		else begin
			dpcm_data_vld_o <= raw_data_vld;
			dpcm_data_o <= dpcm_data;
		end
	end

//input
always @ (posedge clk_i or negedge reset_n_i)
	begin
		if (!reset_n_i)begin
			raw_data <= 0;
            raw_data_vld <= 1'b0;
			end
		else if (raw_data_vld_i)begin
            raw_data <= raw_data_i;
            raw_data_vld <= raw_data_vld_i;
			end
		else begin
		    raw_data <= raw_data;
            raw_data_vld <= 1'b0;
			end
	end

//data buffer
always @ (posedge clk_i or negedge reset_n_i)
    begin
        if (!reset_n_i)begin
            data_buffer_1 <= 0;
            data_buffer_2 <= 0;
            data_buffer_3 <= 0;
        end
        else if (raw_data_vld_i)begin
            data_buffer_1 <= raw_data_i;
            data_buffer_2 <= data_buffer_1;
            data_buffer_3 <= data_buffer_2;
        end
        else begin
            data_buffer_1 <= data_buffer_1;
            data_buffer_2 <= data_buffer_2;
            data_buffer_3 <= data_buffer_3;
        end
    end


	assign dpcm_data = data_buffer_1 + data_buffer_3 - (data_buffer_2 << 1) + 256;
	
	
endmodule






