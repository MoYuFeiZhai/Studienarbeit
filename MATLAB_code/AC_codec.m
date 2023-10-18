% AC codec for one input dataset, distribution according to statistics
% Input dataset_select(or batch processing), input_mode,
% distribution_mode(and preset distribution),spikes_mode(LL or NLL)
% Output bit current dataset, distribution figures, compression ratio

% Implementation for no precision loss ==>> [0,1] to [0,1), a more C-like
% realization, using 0-2^n-1 format interval

% 16-bit codeblock, tradeoff CR & hardware consumption

% tutorials:
% To implement this code, make sure you have put spikes_extraction.m, preset_cal_C_16b.m and dataset_process.m in the same folder
% Also, related datasets folder should be copied as well

clear,clc;
format long;

% use relative path
currentFile = mfilename( 'fullpath' );
[pathstr, name, ~] = fileparts(currentFile);
cd(pathstr);
cd('..');
cd('datasets');
addpath(fullfile(pathstr));

CR=zeros(1,8)';

% statics
No_of_symbols = 513;        %512symbols + 1EOF
code_value_bits = 16;       %max dataset size for LL-semi-adaptive = 2^24-1=16777215

% parameter preset, mode settings
distribution_mode = 0;          % mode 0==preset 1==statistical(semi-adaptive)
input_mode = 2;                 % mode 0==raw 1==dpcm1 2==dpcm2 3==dpcm3
spikes_mode = 0;                % mode 0==LL data 1==NLL
preset_calc_mode = 0;           % mode 0==read former distribution file 1==recaluculate distribution from daatsets
batch_mode = 0;                 % mode 0==single file compression 1==batch compression & verification
encode_save = 0;                % mode 0==no file saved, internal verification(fast) 1==save encoded sequence to a .txt file for comparison with HW result,meanwhile decoder read the .txt file for decoding(slow)

% preset distribution calc (!!NOTE: at least run mode 1 once to generate the distribution)
if preset_calc_mode == 0
    load ('preset_C.mat','preset_prep')
else 
    preset_prep = preset_cal_C_16b(input_mode,spikes_mode,code_value_bits);
    save('preset_C.mat','preset_prep');
end

% dataset setting (0=diff 1-8=easy_noise005-04 9-12=real_datasets)
if batch_mode == 0
    batch_nr = 1;
else
    batch_nr = 8;
end
for dataset_select = 1:batch_nr        % for batch processing of all input data sequencies

switch dataset_select
    case 0
        load C_Difficult1_noise01
        current_input = 'noise 01 difficult';
    case 1
        load C_Easy1_noise005
        current_input = 'noise 005';
    case 2
        load C_Easy1_noise01
        current_input = 'noise 01 easy';
    case 3
        load C_Easy1_noise015
        current_input = 'noise 015';
    case 4
        load C_Easy1_noise02
        current_input = 'noise 02';
    case 5
        load C_Easy1_noise025
        current_input = 'noise 025';
    case 6
        load C_Easy1_noise03
        current_input = 'noise 03';
    case 7
        load C_Easy1_noise035
        current_input = 'noise 035';
    case 8
        load C_Easy1_noise04
        current_input = 'noise 04';
    case 9
        load d533101_20KHz
        current_input = 'real_dataset_d533101_20KHz';
    case 10
        load d533102_20KHz
        current_input = 'real_dataset_d533102_20KHz'; 
    case 11
        load d561102_20KHz
        current_input = 'real_dataset_d561102_20KHz';   
    case 12
        load d561105_20KHz
        current_input = 'real_dataset_d561105_20KHz';
end
disp(['the input sequence is: ', current_input])

% only spikes or whole data
if spikes_mode == 1
    data = spikes_extraction(dataset_select);
end
        
% call dataset_process, return statistics and processed data, present raw data and distribution figures
[data_quantized,statistic,data_dpcm1,statistic_dpcm1,data_dpcm2,statistic_dpcm2,data_dpcm3,statistic_dpcm3]=dataset_process(data);

% input setting !!HERE CHANGED TO FREQ COUNT, INSTEAD OF FREQ PROPORTION
switch input_mode
    case 0
        input = data_quantized;
        freq = statistic(:,4).';
    case 1
        input=data_dpcm1;
        freq = statistic_dpcm1(:,4).';
    case 2
        input=data_dpcm2;
        freq = statistic_dpcm2(:,4).';
    case 3
        input=data_dpcm3;
        freq = statistic_dpcm3(:,4).';
end
input_temp = (input(1:500000)).'+256;
len=length(input);

% distribution setting 
switch distribution_mode
    case 0          %preset distribution: from C_Easy1 average
        freq = preset_prep;
    case 1          %statistical distribution
end


% cum_freq calc
freq_temp=freq;
freq=zeros(1,514);
freq(514)=1;
for i=1:512
    freq(i+1)=freq_temp(i);
end
cum_freq = zeros(1,No_of_symbols+1);        %cum_freq(1)=Sigma freq,cum_freq[i-1]=freq[i]+...+freq[512]. cum freq(514) = 0
for i = 1:No_of_symbols
    cum_freq(No_of_symbols-i+1)=cum_freq(No_of_symbols-i+1+1)+freq(No_of_symbols-i+1+1);
end

cum_freq(1) = 16383; % 2^14-1, the max value of cum_freq, this step is to fully occupy the distribution storage
input(1)=input(1)+256;
if (input(1)>=256) 
    input(1)=input(1)-512; end
input(2)=input(2)-256;
if (input(2)<-256) 
    input(2)=input(2)+512; end

% freq generation for sram
mem=reshape(cum_freq,2,257);
mem=mem.';
temp=mem(:,1);
mem(:,1)=mem(:,2);
mem(:,2)=temp;

% Encoder
%init
bias=256+1;                     % bias between symbol value(-256,255) and array index(1-512)
low_value=0;
high_value=2^code_value_bits-1;              % Using code_value_bits = 16, C-type datatype to represent the interval
range=2^code_value_bits-1;
First_qtr=2^(code_value_bits-2);
Half=2*First_qtr;
Third_qtr=3*First_qtr;
codeword=zeros(1,10000000);     % 20000000>max codeword length (2000000*9) %decreased to 10 million to save txt file space
bit_cnt=0;                      
temp_cnt=0; 
rs_cnt=0;
rs_oz_cnt=0;
rs_no_cnt=0;
rs_cnt_max = 0;

for i=1:len                
    if i == 1000
        stop =1;
    end
    m = input(i)+bias;           %m(1-512) == symbol(1-256) in c code
    range = high_value - low_value + 1;
    high_value = fix(low_value + range * cum_freq(m-1+1)/16384)-1;
    low_value = fix( low_value + range * cum_freq(m+1)/16384);
    
    % rescaling shifting
    while (low_value>=Half) || (high_value<Half) || (low_value>=First_qtr && high_value<Third_qtr)  
        if high_value < Half
            bit_cnt = bit_cnt + 1;
            codeword(bit_cnt) = 0;
            rs_oz_cnt = rs_oz_cnt+1;
            if temp_cnt~=0                                  %temp_cnt: pre saved bits to output
                for jj=1:temp_cnt
                    bit_cnt = bit_cnt + 1;
                    codeword(bit_cnt) = 1;
                end
                temp_cnt=0;
            end            
            low_value = (low_value) * 2 ;
            high_value = (high_value) * 2 + 1;
            
        elseif low_value >= Half
            bit_cnt = bit_cnt + 1;
            codeword(bit_cnt) = 1;
            rs_oz_cnt = rs_oz_cnt+1;
            if temp_cnt~=0
                for jj=1:temp_cnt
                    bit_cnt = bit_cnt + 1;
                    codeword(bit_cnt) = 0;
                end
                temp_cnt=0;
            end
            low_value = (low_value - Half) * 2 ;
            high_value = (high_value - Half) * 2 + 1;
        else
            temp_cnt = temp_cnt + 1;
            rs_no_cnt = rs_no_cnt + 1;
            low_value = (low_value - First_qtr) * 2 ;
            high_value = (high_value - First_qtr) * 2 + 1;
        end  
    end
    rs_cnt=rs_oz_cnt*3+rs_no_cnt;
    if(rs_cnt > rs_cnt_max) 
        rs_cnt_max = rs_cnt;
        rs_num = i;
    end
    rs_oz_cnt = 0;
    rs_no_cnt = 0;
 
    if i==len       % last symbol is reached, calculate last interval for tail bits output
        while (low_value>=Half) || (high_value<Half) || (low_value>=First_qtr && high_value<Third_qtr) 
            if high_value < Half
                low_value = (low_value) * 2;
                high_value = (high_value) * 2 + 1;
            elseif low_value >= Half
                low_value = (low_value - Half) * 2;
                high_value = (high_value - Half) * 2 + 1;
            else
                low_value = (low_value - First_qtr) * 2;
                high_value = (high_value - First_qtr) * 2 + 1;
                temp_cnt = temp_cnt + 1;
            end  
        end
        if low_value<First_qtr       %tail bits asignment
            bit_cnt = bit_cnt + 1;
            codeword(bit_cnt) = 0;
            temp_cnt=temp_cnt+1;
            if temp_cnt~=0
                for jj=1:temp_cnt
                    bit_cnt = bit_cnt + 1;
                    codeword(bit_cnt) = 1;
                end
            end
        else
            bit_cnt = bit_cnt + 1;
            codeword(bit_cnt) = 1;
            temp_cnt=temp_cnt+1;
            if temp_cnt~=0
                for jj=1:temp_cnt
                    bit_cnt = bit_cnt + 1;
                    codeword(bit_cnt) = 0;
                end
            end
        end
    end
%     end
end
if encode_save == 1 % save output in SRAM form, meanwhile read from saved file for decoding
    fid=fopen('codeword.txt','w');
    for i = 1:8:(length(codeword)-7)
    fprintf(fid,'%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n',codeword(i),codeword(i+1),codeword(i+2),codeword(i+3),codeword(i+4),codeword(i+5),codeword(i+6),codeword(i+7));
    end
    fclose(fid);

    fid=fopen('hw_out_backup.txt','r'); %codeword.txt
    codeword=fscanf(fid,'%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n').';
    fclose(fid);
end


% Decoder
% init
new_range_H=2^code_value_bits-1;
new_range_L=0;
new_range=2^code_value_bits;
decode=zeros(1,len);    % decode result
bit_cnt_dec=0;          % pointer of decoder's input
value=0;                % decimal expression of binary code from current decoding block [0,2^code_value_bits-1]

% first symbol decode
for k = 1:code_value_bits      
    value = value + codeword(k) * 2 ^ (code_value_bits-k);
end
pointer=code_value_bits;
cum = ((value - new_range_L + 1)*16384 - 1)/ new_range;
for jj = 1:512          
        if  cum_freq(jj+1)<cum
                new_range_H = fix( new_range_L + new_range * cum_freq(jj)/16384) - 1;
                new_range_L = fix( new_range_L + new_range * cum_freq(jj+1)/16384);
                new_range = new_range_H - new_range_L; 
                bit_cnt_dec = bit_cnt_dec + 1;
                decode(bit_cnt_dec) = jj-bias;
                break
        end
end

% following symbols decode
while 1         %rest of symbols decode
    while 1                             %rescale, use value(bin expression) to simulate hardware calc
        if new_range_H < Half           
            new_range_H = new_range_H * 2 + 1;
            new_range_L = new_range_L * 2; 
            new_range = new_range_H - new_range_L + 1;
            pointer = pointer + 1;
            value = value * 2 + codeword(pointer);
        elseif new_range_L >= Half
            new_range_H = (new_range_H - Half) * 2 + 1;
            new_range_L = (new_range_L - Half) * 2;
            new_range = new_range_H - new_range_L + 1;
            pointer = pointer + 1;
            value = (value - Half) * 2 + codeword(pointer);
        elseif new_range_L >= First_qtr && new_range_H < Third_qtr
            new_range_H = (new_range_H - First_qtr) * 2 + 1;
            new_range_L = (new_range_L - First_qtr) * 2;
            new_range = new_range_H - new_range_L + 1;
            pointer = pointer + 1;
            value = (value - First_qtr) * 2 + codeword(pointer);
        else
            break
        end
    end
%     decimal = value / 2^code_value_bits;
%     decimal_normalized = (decimal - new_range_L) / (new_range_H - new_range_L);
    cum = ((value - new_range_L + 1)*16384 - 1)/ new_range;
    for jj = 1:512
        if cum_freq(jj+1)<cum
                new_range_H = fix( new_range_L + new_range * cum_freq(jj)/16384) - 1;
                new_range_L = fix( new_range_L + new_range * cum_freq(jj+1)/16384);
                new_range = new_range_H - new_range_L;
                bit_cnt_dec = bit_cnt_dec + 1;
                decode(bit_cnt_dec) = jj-bias;        
                break
        end
    end
    if bit_cnt_dec == len      %cheat point -- EOF not set, endpoint of decoder set by element counter
        break
    end
end

% calculate CR
if spikes_mode == 0
    compression_ratio = 1 - bit_cnt / (len * 9);
else
    compression_ratio = 1 - bit_cnt / (1440000 * 9);
end
CR(dataset_select)=vpa(compression_ratio, 4);
format short
disp(['compression ratio is: ', num2str(compression_ratio)])

% check the decoder's result
for check = 1:len
    if input(check) ~= decode(check)
        disp(['Wrong, from input symbol nr.  ', check])
        break
    end
    if check == len
        disp('correct')
    end
end
end
