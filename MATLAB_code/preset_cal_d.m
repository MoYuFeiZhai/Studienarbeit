% real datasets analysis, calculation of average distribution
% input d5... datasets (4)
% output freq (average of 5th column)

function [freq_ave]=preset_cal_d()
    statistic_ave = zeros(512,7);   %col_1=index col_23=raw col_45=dpcm1 col67=dpcm2
    bias = 257;
    kk = 1:512;
    statistic_ave(kk,1) = kk - bias;
    load d533101_20KHz.mat data
    [~,statistic,~,statistic_dpcm1,~,statistic_dpcm2,~,~] = dataset_process(data);
    statistic_ave(kk,2) = statistic_ave(kk,2) + statistic(kk,2);
    statistic_ave(kk,4) = statistic_ave(kk,4) + statistic_dpcm1(kk,2);
    statistic_ave(kk,6) = statistic_ave(kk,6) + statistic_dpcm2(kk,2);
    load d533102_20KHz.mat data
    [~,statistic,~,statistic_dpcm1,~,statistic_dpcm2,~,~] = dataset_process(data);
    statistic_ave(kk,2) = statistic_ave(kk,2) + statistic(kk,2);
    statistic_ave(kk,4) = statistic_ave(kk,4) + statistic_dpcm1(kk,2);
    statistic_ave(kk,6) = statistic_ave(kk,6) + statistic_dpcm2(kk,2);
    load d561102_20KHz.mat data
    [~,statistic,~,statistic_dpcm1,~,statistic_dpcm2,~,~] = dataset_process(data);
    statistic_ave(kk,2) = statistic_ave(kk,2) + statistic(kk,2);
    statistic_ave(kk,4) = statistic_ave(kk,4) + statistic_dpcm1(kk,2);
    statistic_ave(kk,6) = statistic_ave(kk,6) + statistic_dpcm2(kk,2);
    load d561105_20KHz.mat data
    [~,statistic,~,statistic_dpcm1,~,statistic_dpcm2,~,~] = dataset_process(data);
    statistic_ave(kk,2) = statistic_ave(kk,2) + statistic(kk,2);
    statistic_ave(kk,4) = statistic_ave(kk,4) + statistic_dpcm1(kk,2);
    statistic_ave(kk,6) = statistic_ave(kk,6) + statistic_dpcm2(kk,2);
    
    statistic_ave(kk,3) = statistic_ave(kk,2) / (4*length(data));
    statistic_ave(kk,5) = statistic_ave(kk,4) / (4*length(data));
    statistic_ave(kk,7) = statistic_ave(kk,6) / (4*length(data));
%     freq_ave=statistic_ave;     %from dpcm1 result we see that '0' can be replaced by a 0.25 interval to save multipliers
    
    %do manual redistribution
    cnt_0=0;
    cnt_dpcm1 = statistic_ave(:,4).';
    freq_dpcm1_altered = zeros(1,512);
    for mm=1:512
        if cnt_dpcm1(mm) == 0
            cnt_dpcm1(mm) = 1;
        end
        cnt_0 = cnt_0 + cnt_dpcm1(mm);
    end
    for mm=1:512
        freq_dpcm1_altered(mm) = cnt_dpcm1(mm) / cnt_0;
    end
    freq_0_original = freq_dpcm1_altered(bias);
    freq_altered = freq_dpcm1_altered * (1 - (0.25 - freq_0_original) / (1 - freq_0_original));
    freq_altered(bias) = 0.25;
    freq_ave = freq_altered;
    

end
