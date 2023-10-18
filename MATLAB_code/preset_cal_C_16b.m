% real datasets analysis, calculation of average distribution
% input C_Easy1... datasets (8)
% output freq (average of 5th column) dpcm2

% max 16-bit codeblock, max freq cnt = 2^14-1 = 16383

function [freq_ave]=preset_cal_C_16b(input_mode,spikes_mode,code_value_bits)
    max_freq_cnt = 2^(code_value_bits - 2) - 1;
    switch spikes_mode
        case 0  %LL mode -- full compression
            statistic_ave = zeros(512,7);   %col_1=index col_23=raw col_45=dpcm1 col67=dpcm2
            bias = 257;
            kk = 1:512;
            statistic_ave(kk,1) = kk - bias;
            load('C_Easy1_noise005.mat','data');
            [~,statistic,~,statistic_dpcm1,~,statistic_dpcm2,~,~] = dataset_process(data);
            statistic_ave(kk,2) = statistic_ave(kk,2) + statistic(kk,2);
            statistic_ave(kk,4) = statistic_ave(kk,4) + statistic_dpcm1(kk,2);
            statistic_ave(kk,6) = statistic_ave(kk,6) + statistic_dpcm2(kk,2);
            load('C_Easy1_noise01.mat','data');
            [~,statistic,~,statistic_dpcm1,~,statistic_dpcm2,~,~] = dataset_process(data);
            statistic_ave(kk,2) = statistic_ave(kk,2) + statistic(kk,2);
            statistic_ave(kk,4) = statistic_ave(kk,4) + statistic_dpcm1(kk,2);
            statistic_ave(kk,6) = statistic_ave(kk,6) + statistic_dpcm2(kk,2);
            load('C_Easy1_noise015.mat','data');
            [~,statistic,~,statistic_dpcm1,~,statistic_dpcm2,~,~] = dataset_process(data);
            statistic_ave(kk,2) = statistic_ave(kk,2) + statistic(kk,2);
            statistic_ave(kk,4) = statistic_ave(kk,4) + statistic_dpcm1(kk,2);
            statistic_ave(kk,6) = statistic_ave(kk,6) + statistic_dpcm2(kk,2);
            load('C_Easy1_noise02.mat','data');
            [~,statistic,~,statistic_dpcm1,~,statistic_dpcm2,~,~] = dataset_process(data);
            statistic_ave(kk,2) = statistic_ave(kk,2) + statistic(kk,2);
            statistic_ave(kk,4) = statistic_ave(kk,4) + statistic_dpcm1(kk,2);
            statistic_ave(kk,6) = statistic_ave(kk,6) + statistic_dpcm2(kk,2);
            load('C_Easy1_noise025.mat','data');
            [~,statistic,~,statistic_dpcm1,~,statistic_dpcm2,~,~] = dataset_process(data);
            statistic_ave(kk,2) = statistic_ave(kk,2) + statistic(kk,2);
            statistic_ave(kk,4) = statistic_ave(kk,4) + statistic_dpcm1(kk,2);
            statistic_ave(kk,6) = statistic_ave(kk,6) + statistic_dpcm2(kk,2);
            load('C_Easy1_noise03.mat','data');
            [~,statistic,~,statistic_dpcm1,~,statistic_dpcm2,~,~] = dataset_process(data);
            statistic_ave(kk,2) = statistic_ave(kk,2) + statistic(kk,2);
            statistic_ave(kk,4) = statistic_ave(kk,4) + statistic_dpcm1(kk,2);
            statistic_ave(kk,6) = statistic_ave(kk,6) + statistic_dpcm2(kk,2);
            load('C_Easy1_noise035.mat','data');
            [~,statistic,~,statistic_dpcm1,~,statistic_dpcm2,~,~] = dataset_process(data);
            statistic_ave(kk,2) = statistic_ave(kk,2) + statistic(kk,2);
            statistic_ave(kk,4) = statistic_ave(kk,4) + statistic_dpcm1(kk,2);
            statistic_ave(kk,6) = statistic_ave(kk,6) + statistic_dpcm2(kk,2);
            load('C_Easy1_noise04.mat','data');
            [~,statistic,~,statistic_dpcm1,~,statistic_dpcm2,~,~] = dataset_process(data);
            statistic_ave(kk,2) = statistic_ave(kk,2) + statistic(kk,2);
            statistic_ave(kk,4) = statistic_ave(kk,4) + statistic_dpcm1(kk,2);
            statistic_ave(kk,6) = statistic_ave(kk,6) + statistic_dpcm2(kk,2);
            % average
            statistic_ave(kk,3) = statistic_ave(kk,2) / (4*length(data));
            statistic_ave(kk,5) = statistic_ave(kk,4) / (4*length(data));
            statistic_ave(kk,7) = statistic_ave(kk,6) / (4*length(data));
            %do manual redistribution for 0 frequencies
            switch input_mode
                case 0
                    cnt_0=0;
                    cnt_dpcm0 = statistic_ave(:,2).';
                    for mm=1:512
                        if cnt_dpcm0(mm) == 0
                            cnt_dpcm0(mm) = 1;
                        end
                        cnt_0 = cnt_0 + cnt_dpcm0(mm);
                    end
                    if max_freq_cnt < cnt_0                 % 16bit limit
                        cnt_dpcm0_limited = cnt_dpcm0;
                        div_array = 0:(1/(max_freq_cnt-512)):1;
                        for i = 1:512
                            for j = 1:(max_freq_cnt - 512)
                                if cnt_dpcm0(i)/cnt_0 > div_array(j) && cnt_dpcm0(i)/cnt_0 <= div_array(j+1)
                                    cnt_dpcm0_limited(i) = j;
                                    break
                                end
                            end
                        end
                    end
                    freq_ave = cnt_dpcm0_limited;
                case 1
                    cnt_0=0;
                    cnt_dpcm1 = statistic_ave(:,4).';
                    for mm=1:512
                        if cnt_dpcm1(mm) == 0
                            cnt_dpcm1(mm) = 1;
                        end
                        cnt_0 = cnt_0 + cnt_dpcm1(mm);
                    end
                    if max_freq_cnt < cnt_0                 % 16bit limit
                        cnt_dpcm1_limited = cnt_dpcm1;
                        div_array = 0:(1/(max_freq_cnt-512)):1;
                        for i = 1:512
                            for j = 1:(max_freq_cnt - 512)
                                if cnt_dpcm1(i)/cnt_0 > div_array(j) && cnt_dpcm1(i)/cnt_0 <= div_array(j+1)
                                    cnt_dpcm1_limited(i) = j;
                                    break
                                end
                            end
                        end
                    end
                    freq_ave = cnt_dpcm1_limited;
                case {2,3}
                    cnt_0=0;
                    cnt_dpcm2 = statistic_ave(:,4).';
                    for mm=1:512
                        if cnt_dpcm2(mm) == 0
                            cnt_dpcm2(mm) = 1;
                        end
                        cnt_0 = cnt_0 + cnt_dpcm2(mm);
                    end
                    if max_freq_cnt < cnt_0                 % 16bit limit
                        cnt_dpcm2_limited = cnt_dpcm2;
                        div_array = 0:(1/(max_freq_cnt-512)):1;
                        for i = 1:512
                            for j = 1:(max_freq_cnt - 512)
                                if cnt_dpcm2(i)/cnt_0 > div_array(j) && cnt_dpcm2(i)/cnt_0 <= div_array(j+1)
                                    cnt_dpcm2_limited(i) = j;
                                    break
                                end
                            end
                        end
                    end
                    freq_ave = cnt_dpcm2_limited;
            end
            
        case 1  %NLL mode -- only compress spikes
            statistic_ave = zeros(512,7);   %col_1=index col_23=raw col_45=dpcm1 col67=dpcm2
            bias = 257;
            for m = 1:8
                kk = 1:512;
                statistic_ave(kk,1) = kk - bias;
                data = spikes_extraction(m);
                [~,statistic,~,statistic_dpcm1,~,statistic_dpcm2,~,~] = dataset_process(data);
                statistic_ave(kk,2) = statistic_ave(kk,2) + statistic(kk,2);
                statistic_ave(kk,4) = statistic_ave(kk,4) + statistic_dpcm1(kk,2);
                statistic_ave(kk,6) = statistic_ave(kk,6) + statistic_dpcm2(kk,2);
            end
            % average
            statistic_ave(kk,3) = statistic_ave(kk,2) / (4*length(data));
            statistic_ave(kk,5) = statistic_ave(kk,4) / (4*length(data));
            statistic_ave(kk,7) = statistic_ave(kk,6) / (4*length(data));
            %do manual redistribution for 0 frequencies
            switch input_mode
                case 0
                    cnt_0=0;
                    cnt_dpcm0 = statistic_ave(:,2).';
                    for mm=1:512
                        if cnt_dpcm0(mm) == 0
                            cnt_dpcm0(mm) = 1;
                        end
                        cnt_0 = cnt_0 + cnt_dpcm0(mm);
                    end
                    if max_freq_cnt < cnt_0                 % 16bit limit
                        cnt_dpcm0_limited = cnt_dpcm0;
                        div_array = 0:(1/(max_freq_cnt-512)):1;
                        for i = 1:512
                            for j = 1:(max_freq_cnt - 512)
                                if cnt_dpcm0(i)/cnt_0 > div_array(j) && cnt_dpcm0(i)/cnt_0 <= div_array(j+1)
                                    cnt_dpcm0_limited(i) = j;
                                    break
                                end
                            end
                        end
                    end
                    freq_ave = cnt_dpcm0_limited;
                case 1
                    cnt_0=0;
                    cnt_dpcm1 = statistic_ave(:,4).';
                    for mm=1:512
                        if cnt_dpcm1(mm) == 0
                            cnt_dpcm1(mm) = 1;
                        end
                        cnt_0 = cnt_0 + cnt_dpcm1(mm);
                    end
                    if max_freq_cnt < cnt_0                 % 16bit limit
                        cnt_dpcm1_limited = cnt_dpcm1;
                        div_array = 0:(1/(max_freq_cnt-512)):1;
                        for i = 1:512
                            for j = 1:(max_freq_cnt - 512)
                                if cnt_dpcm1(i)/cnt_0 > div_array(j) && cnt_dpcm1(i)/cnt_0 <= div_array(j+1)
                                    cnt_dpcm1_limited(i) = j;
                                    break
                                end
                            end
                        end
                    end
                    freq_ave = cnt_dpcm1_limited;
                case {2,3}
                    cnt_0=0;
                    cnt_dpcm2 = statistic_ave(:,4).';
                    for mm=1:512
                        if cnt_dpcm2(mm) == 0
                            cnt_dpcm2(mm) = 1;
                        end
                        cnt_0 = cnt_0 + cnt_dpcm2(mm);
                    end
                    if max_freq_cnt < cnt_0                 % 16bit limit
                        cnt_dpcm2_limited = cnt_dpcm2;
                        div_array = 0:(1/(max_freq_cnt-512)):1;
                        for i = 1:512
                            for j = 1:(max_freq_cnt - 512)
                                if cnt_dpcm2(i)/cnt_0 > div_array(j) && cnt_dpcm2(i)/cnt_0 <= div_array(j+1)
                                    cnt_dpcm2_limited(i) = j;
                                    break
                                end
                            end
                        end
                    end
                    freq_ave = cnt_dpcm2_limited;
            end
            
           
    
    

end
