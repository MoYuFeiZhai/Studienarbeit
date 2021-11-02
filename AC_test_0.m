clear all;
clc;
 
format long;            %16bit
in='00000011111010101';          
pr=[0.5 0.5];           %probability of symbols
temp=[0.0 0.5 1.0];     %temp(1)=low & temp(3)=high
orignal=temp;           %orignal(1)=LowRange(0)=0.0 
                        %orignal(2)=HighRange(0)=LowRange(1)=0.5 
                        %orignal(3)=HighRange(1)=1.0
 
n=length(in);  
  
for i=1:n  
    width=temp(3)-temp(1);  %Range = OldHigh - OldHigh
    w=temp(1);  
    switch in(i)  
        case '0'  
            m=1;  
        case '1'  
            m=2;  
    end  
    temp(1)=w+orignal(m)*width;     %New Low := OldLow + LowRange(X) * Range
    temp(3)=w+orignal(m+1)*width;   %New High:= OldLow + HighRange(X)* Range
    low=temp(1);  
    high=temp(3);  
    fprintf('low=%.8f',low);  
    fprintf('    ');  
    fprintf('high=%.8f\n',high);  
end  
encode=(temp(1)+temp(3))/2
 

decode=['0'];  
for i=1:n  
    fprintf('tmp=%.8f\n',encode);  
    if(encode>=orignal(1)& encode<orignal(2))  
        decode(i)='0';  
        t=1;  
    elseif(encode>=orignal(2)& encode<orignal(3))  
        decode(i)='1';  
        t=2;  
    end  
    encode=(encode-orignal(t));  
    encode=encode/pr(t);  
end  
decode   
