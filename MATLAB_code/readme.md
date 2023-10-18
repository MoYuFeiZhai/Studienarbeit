This folder contains MATLAB code for arithmetic coding, dataset processing, dpcm tests\
Platform: MATLAB 2020a

### AC_codec.m:            
- Top level code, official AC codec developed in this study, binary codeword output, 
* saves codeword in .txt file for decoder's input, returns codeword length and CR anaylsis, preset/statistic distribution can be choosed 
* Note: to use other preset distribution / input data, code in *dataset setting* part should be updated
- parameters preset must be done before activation:
> - distribution_mode = 0;          % mode 0==preset 1==statistical(semi-adaptive)
> - input_mode = 2;                 % mode 0==raw 1==dpcm1 2==dpcm2 3==dpcm3
> - spikes_mode = 0;                % mode 0==LL data 1==NLL
> - preset_calc_mode = 0;           % mode 0==read former distribution file 1==recaluculate distribution from daatsets
> - batch_mode = 0;                 % mode 0==single file compression 1==batch compression & verification
> - encode_save = 0;                % mode 0==no file saved, program does verification directly after decode(operatess faster) 1==save encoded sequence to a .txt file for comparison with HW result, meanwhile decoder read the .txt file for decoding(operates slower, but provides methods for comparison with HW result)


### dataset-process.m:     
- Function of processing datasets, with 1-3 order DPCM, called by AC-binary-output.m
### preset_cal_C_16b.m:    
- Function of dataset analysis (all C_Easy) calculation of average distribution, generates frequencies of each symbol
### preset_cal_d.m:        
- Function of dataset analysis (all d5)
### spikes_extraction.m:   
- Function of extracting spikes part from C_Easy datasets, used in NLL mode

### AC_encoder_decimal_output.m:   
- *(only for reference)*Encoder of AC, used for illustraing the principles of AC, with decimal codeword output
