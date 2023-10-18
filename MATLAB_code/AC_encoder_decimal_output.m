% input 0-511 DEC array
% output DEC codeword array
% with efficiency issues and precision limits, thus abandoned
clear,clc;
format long g;

%9-bit symbol(0-511 DEC)
%equal probability(1/512)
input=[0 1 2 3 4 8 16 32 64 128 256];
len=length(input);
high=zeros(1,512);
low=zeros(1,512);
for k=1:512
    low(k)=1/512*(k-1);
    high(k)=1/512*k;
end

%sort & calc probability                                    %remain to be implemented

%init
low_value=0;
high_value=1;
range=1;
codeword=[];
n=0;

for i=1:len
    m=input(i);
    high_value=low_value+range*high(m+1)
    low_value=low_value+range*low(m+1)
    range=high_value-low_value;
    temp_1=floor((high_value+eps(high_value))*10);          %eps func : accuracy up
    temp_2=floor((low_value+eps(low_value))*10);
    codeword
    
    %shift out 1 bit
    while temp_1==temp_2
        n=n+1;
        codeword=[codeword temp_1];
        high_value = high_value*10 - temp_1
        low_value = low_value*10 - temp_2
        range=high_value-low_value;
        temp_1=floor((high_value+eps(high_value))*10);
        temp_2=floor((low_value+eps(low_value))*10);
        m=0;
        tempt=0;
    end
    
     %shift out 2 bits -- solution to underflow
%   while (floor((high_value+eps(high_value))*10)-floor((low_value+eps(low_value))*10)==1)&&...
%          (floor((low_value+eps(low_value))*100)-floor((low_value+eps(low_value))*10)*10==9)&&...
%          (floor((high_value+eps(high_value))*100)-floor((high_value+eps(high_value))*10)*10==0)
%          m = m+1;
%          k=k+1;
%          tempt = tempt * 10+floor((low_value+eps(low_value)) * 100-floor((low_value+eps(low_value))*10)*10); 
%          low_value = (low_value*100-floor((low_value+eps(low_value))*100))/10+floor((low_value+eps(low_value))*10)/10;
%          high_value = (high_value*100-floor((high_value+eps(high_value))*100))/10+floor((high_value+eps(high_value))*10)/10;
%          range = high_value-low_value;   
%     end


    if i==len
        ave_value=(high_value+low_value)/2;
        aa=floor(10*ave_value);
        bb=floor(10&low_value);
        for ii=1:4
            if aa(ii)~=bb(ii)
                codeword=[codeword aa(ii)];
                break;
            end
            ii=ii+1;
        end
        codeword
    end
    
    
    
end
