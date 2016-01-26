clear;
7777
% dane wejœciowe binarne
%data_in = [1,1,1,1,0,0,0,0,1,0,1,0,0,0,0,1,1,0,0,1];
%data_in = [1,1,1,1,0,0,0,0,1,0,1,0,0,0,1,1];
data_in=[1,1,0,0];
%data_in = 1:20;
% N = liczba noœnych = liczba na ile rozdzielamy dane równolegle
N = 4;

%TODO : PADDING DO WIELOKROTNOŒCI N

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
fs = 16; %iloœæ próbek symbolu modulacji
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
for i=1:fs*length(data_in)/N
    for j=1:N
        data_serialized((i-1)*N+j)=data_mapped(j,i);
    end
end

%policzenie kawa³kami ifft
%ifft liczymy dla ka¿dych N symboli jednoczeœnie
%jest to N*fs punktów (N odczepów razy fs próbek symbolu modulacji)
step=fs*N;
for i=1:length(data_in)/N
    data_modulated((i-1)*step+1:(i-1)*step+step)=ifft(data_serialized((i-1)*step+1:(i-1)*step+step));
end

figure(1)
plot(data_in);

figure(2);
hold on;
plot(data_mapped(1,:));
plot(data_mapped(2,:),'g');
plot(data_mapped(3,:),'b');
plot(data_mapped(4,:),'r');

figure(3);
plot(data_serialized);

figure(4)
hold on;
plot(real(data_modulated),'r');
plot(imag(data_modulated),'b');

%ifft(data_serialized(1:step))

%data_modulated=ifft(data_mapped,fs,2);

%data_mapped(1,:)
%data_mapped(:,1)
%ifft(data_mapped,4)
%%%data_modulated = ifft(data_mapped);
%%ifft(data_mapped,4,2)
%(ifft(data_mapped'))'


