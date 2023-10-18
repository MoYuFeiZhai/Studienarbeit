% spikes extration function, only in NLL mode 
% input dataset_select (1-8)
% output NLL mode sequence

function [data_nll] = spikes_extraction(dataset_select)
    switch dataset_select
        case 1
            load C_Easy1_noise005
            current_input = 'noise 005'
        case 2
            load C_Easy1_noise01
            current_input = 'noise 01 easy'
        case 3
            load C_Easy1_noise015
            current_input = 'noise 015'
        case 4
            load C_Easy1_noise02
            current_input = 'noise 02'
        case 5
            load C_Easy1_noise025
            current_input = 'noise 025'
        case 6
            load C_Easy1_noise03
            current_input = 'noise 03'
        case 7
            load C_Easy1_noise035
            current_input = 'noise 035'
        case 8
            load C_Easy1_noise04
            current_input = 'noise 04'
    end
    spike_timing = cell2mat(spike_times);
    spike_count = length(spike_timing);
    data_nll = zeros(1,64*spike_count);     % each spike 64 bit length
    for m = 1:spike_count
        n = 1:64;
        data_nll(64*(m-1)+n) = data(n+spike_timing(m)-1);
    end
    
    
    
end
