clear;
7777
% dane wej�ciowe binarne
%data_in = [1,1,1,1,0,0,0,0,1,0,1,0,0,0,0,1,1,0,0,1];
data_in = [1,1,1,1,0,0,0,0,0,1,0,1];
%data_in = 1:20;
% liczba no�nych = liczba na ile rozdzielamy dane r�wnolegle
N = 4;

%TODO : PADDING DO WIELOKROTNO�CI N

% serial to parallel
for i=1:length(data_in)/N
    for j=1:N
        data_parallel(j,i)=data_in((i-1)*N+j);       
    end
end

% modulation mapping preparation - LUT
% BPSK LUT
%bpsk_0 = [0,1,0,-1];
%bpsk_1 = [0,-1,0,1];

%create BPSK LUT in variable sampling freq
f=1;
fs = 16; %cz�stotliwo�� unormowana sygna�u cyfrowego
t=linspace(0,1,fs);
for k=1:fs
    bpsk_0(k)=sin(2*pi*f*t(k));
    bpsk_1(k)=cos(2*pi*f*t(k));
end

% modulation mapping
for i=1:length(data_in)/N
    for j=1:N

        if data_parallel(j,i)==1
            current_simbol = bpsk_1;
        else
            current_simbol = bpsk_0;
        end
        
        data_mapped(j,(i-1)*fs+1:(i-1)*fs+fs)=current_simbol;
        
    end
end

%parallel to serial
for ii=1:fs*length(data_in)/N
    for jj=1:N
        data_serialized((ii-1)*N+jj)=data_mapped(jj,ii);
    end
end

step=fs*N;
for i=1:length(data_in)/N
    data_modulated((i-1)*step+1:(i-1)*step+step)=ifft(data_serialized((i-1)*step+1:(i-1)*step+step));
end

%ifft(data_serialized(1:step))

%data_modulated=ifft(data_mapped,fs,2);

%data_mapped(1,:)
%data_mapped(:,1)
%ifft(data_mapped,4)
%%%data_modulated = ifft(data_mapped);
%%ifft(data_mapped,4,2)
%(ifft(data_mapped'))'


