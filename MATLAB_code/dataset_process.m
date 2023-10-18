% process dataset, quantization and dpcm, output figures of distribution,
% input data, return statistics (data after quantization/dpcm, statistics)

function [data_quantized,statistic,data_dpcm1,statistic_dpcm1,data_dpcm2,statistic_dpcm2,data_dpcm3,statistic_dpcm3]=dataset_process(data)
bias=257;
max_positive=double(max(data));
max_negative=double(min(data));
xp=255/max_positive;
xn=-256/max_negative;
if xp>xn
    xf=xn;
else 
    xf=xp;
end
data_quantized=zeros(1,length(data));
for i=1:length(data)
    data_quantized(i)=round(double(data(i))*xf);
end
statistic=zeros(512,5);     %statistics of symbols (symbol,frequnency,probability,frequncy_altered,probability_altered)
for kk=1:512
    statistic(kk,1)=kk-bias;
end
for ii=1:length(data)
    for jj=1:512
        if data_quantized(ii)==jj-bias
            statistic(jj,2)=statistic(jj,2)+1;
        end
    end
end
for mm=1:512
    statistic(mm,3)=statistic(mm,2)/length(data);
end
freq=statistic(:,3).';
x=-256:255;
i=1:length(data);
figure(1)
plot(i,data_quantized)
title('data raw')       %raw data

%DPCM 1
data_dpcm1=zeros(1,length(data));
data_dpcm1(1)=data_quantized(1);
for k=2:length(data)
    data_dpcm1(k)=data_quantized(k)-data_quantized(k-1);
    if data_dpcm1(k)<-256           % in real_dataset_1 dpcm1 last sample(i=2000000) go beyond -256-255
        data_dpcm1(k)=data_dpcm1(k)+512;         % here's to limit the sample within the bounds
    elseif data_dpcm1(k)>255
        data_dpcm1(k)=data_dpcm1(k)-512;
    end
end
statistic_dpcm1=zeros(512,5);
for kk=1:512
    statistic_dpcm1(kk,1)=kk-bias;
end
for ii=1:length(data)
    for jj=1:512
        if data_dpcm1(ii)==jj-bias
            statistic_dpcm1(jj,2)=statistic_dpcm1(jj,2)+1;
        end
    end
end
for mm=1:512
    statistic_dpcm1(mm,3)=statistic_dpcm1(mm,2)/length(data);
end
freq_dpcm1=statistic_dpcm1(:,3).';

%DPCM 2
data_dpcm2=zeros(1,length(data));
data_dpcm2(1)=data_dpcm1(1);
for k=2:length(data)
    data_dpcm2(k)=data_dpcm1(k)-data_dpcm1(k-1);
    if data_dpcm2(k)<-256           % in real_dataset_1 dpcm1 last sample(i=2000000) go beyond -256-255
        data_dpcm2(k)=data_dpcm2(k)+512;         % here's to limit the sample within the bounds
    elseif data_dpcm2(k)>255
        data_dpcm2(k)=data_dpcm2(k)-512;
    end
end
statistic_dpcm2=zeros(512,5);
for kk=1:512
    statistic_dpcm2(kk,1)=kk-bias;
end
for ii=1:length(data)
    for jj=1:512
        if data_dpcm2(ii)==jj-bias
            statistic_dpcm2(jj,2)=statistic_dpcm2(jj,2)+1;
        end
    end
end
for mm=1:512
    statistic_dpcm2(mm,3)=statistic_dpcm2(mm,2)/length(data);
end
freq_dpcm2=statistic_dpcm2(:,3).';

%DPCM 3
data_dpcm3=zeros(1,length(data));
data_dpcm3(1)=data_dpcm1(1);
for k=2:length(data)
    data_dpcm3(k)=data_dpcm2(k)-data_dpcm2(k-1);
    if data_dpcm3(k)<-256           % in real_dataset_1 dpcm1 last sample(i=2000000) go beyond -256-255
        data_dpcm3(k)=data_dpcm3(k)+512;         % here's to limit the sample within the bounds
    elseif data_dpcm3(k)>255
        data_dpcm3(k)=data_dpcm3(k)-512;
    end
end
statistic_dpcm3=zeros(512,5);
for kk=1:512
    statistic_dpcm3(kk,1)=kk-bias;
end
for ii=1:length(data)
    for jj=1:512
        if data_dpcm3(ii)==jj-bias
            statistic_dpcm3(jj,2)=statistic_dpcm3(jj,2)+1;
        end
    end
end
for mm=1:512
    statistic_dpcm3(mm,3)=statistic_dpcm3(mm,2)/length(data);
end
freq_dpcm3=statistic_dpcm3(:,3).';


figure (2)      %Distribution plot
plot(x,freq,'DisplayName','RAW','linewidth',2),axis([-256,255,0,0.3]);hold on;
xlabel('symbol')
ylabel('probability')   %distribution of symbols after quantization
plot(x,freq_dpcm1,'DisplayName','DPCM1','linewidth',2,'LineStyle','--')
plot(x,freq_dpcm2,'DisplayName','DPCM2','linewidth',2,'LineStyle',':')
plot(x,freq_dpcm3,'DisplayName','DPCM3','linewidth',2,'LineStyle','-.')
legend
hold off

%process one dataset to avoid zero probability symbol
cnt_0=0;cnt_1=0;cnt_2=0;cnt_3=0;    %altered data count in raw,dpcm1,dpcm2,dpcm3
for mm=1:512
    statistic(mm,4)=statistic(mm,2);
    if statistic(mm,2)==0
        statistic(mm,4)=1;
    end
    cnt_0=cnt_0+statistic(mm,4);
end
for mm=1:512
    statistic(mm,5)=statistic(mm,4)/cnt_0;
end
for mm=1:512
    statistic_dpcm1(mm,4)=statistic_dpcm1(mm,2);
    if statistic_dpcm1(mm,2)==0
        statistic_dpcm1(mm,4)=1;
    end
    cnt_1=cnt_1+statistic_dpcm1(mm,4);
end
for mm=1:512
    statistic_dpcm1(mm,5)=statistic_dpcm1(mm,4)/cnt_1;
end
for mm=1:512
    statistic_dpcm2(mm,4)=statistic_dpcm2(mm,2);
    if statistic_dpcm2(mm,2)==0
        statistic_dpcm2(mm,4)=1;
    end
    cnt_2=cnt_2+statistic_dpcm2(mm,4);
end
for mm=1:512
    statistic_dpcm2(mm,5)=statistic_dpcm2(mm,4)/cnt_2;
end
for mm=1:512
    statistic_dpcm3(mm,4)=statistic_dpcm3(mm,2);
    if statistic_dpcm3(mm,2)==0
        statistic_dpcm3(mm,4)=1;
    end
    cnt_3=cnt_3+statistic_dpcm3(mm,4);
end
for mm=1:512
    statistic_dpcm3(mm,5)=statistic_dpcm3(mm,4)/cnt_3;
end
end
