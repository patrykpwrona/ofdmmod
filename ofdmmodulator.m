clear;
%wczytuje double, zapisuje complex
FID2=fopen('sample_data_in.txt', 'r');
raw_data=textscan(FID2,'%s');
fclose(FID2);

char_data=char(raw_data{:,:});
data_in=str2num(char_data);

% N = ilosc nosnych = ilosc odczepow do zrownoleglania
N = 8;
% uzywamy modulacji BPSK
% fs = ilosc probek sygnalu analogowego w symbolu modulacji
fs = 16;
% f = czestotliwosc sygnalu w symbolu modulacji
% dla f = 1 w symbolu modulacji mamy jeden pelen okres sinusa (lub
% cosinusa)
f = 1;

% padding zerami jesli dane nie sa wielokrotnoscia N
if( mod(length(data_in),N)~=0 )
    data_in = [data_in, zeros(1,N-mod(length(data_in),N))];
end

% S/P (Serial to Parallel)
% zrownoleglamy dane wejsciowe do wyslania
for i=1:length(data_in)/N
    for j=1:N
        data_parallel(j,i)=data_in((i-1)*N+j);       
    end
end

% tworzenie LUT symboli modulacji
% probkowanie sinusa oraz cosinusa w fs punktach
t=linspace(0,1,fs);
for k=1:fs
    bpsk_0(k)=sin(2*pi*f*t(k));
    bpsk_1(k)=cos(2*pi*f*t(k));
end

% mapowanie modulacji - przypisanie danym poprzednio utworzonych symboli -
% fs probek sygnalu
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

% P / S (Parallel to Serial)
% serializujemy dane na potrzeby fft oraz pozniejszego wyslania w kanal
for i=1:fs*length(data_in)/N
    for j=1:N
        data_serialized((i-1)*N+j)=data_mapped(j,i);
    end
end

% IFFT
% ifft liczymy dla wszystkich N symboli jednoczesnie
% kazdy symbol to fs probek, wiec musimy policzyc naraz ifft z 
% fs (ilosc probek w symbolu) * N (ilosc odczepow rownoleglych = ilosc
% nosnych)
step=fs*N;
for i=1:length(data_in)/N
    data_modulated((i-1)*step+1:(i-1)*step+step)=ifft(data_serialized((i-1)*step+1:(i-1)*step+step));
end

figure(1)
plot(data_in);
title('dane wejsciowe');

figure(2);
hold on;
plot(data_mapped(1,:));
plot(data_mapped(2,:),'g');
plot(data_mapped(3,:),'k');
plot(data_mapped(4,:),'r');
title('zmodulowane dane na 4 pierwszych nosnych - probki sygnalu');

figure(3);
plot(data_serialized);
title('dane zmodulowane i zserializowane');

figure(4)
hold on;
plot(real(data_modulated),'r');
plot(imag(data_modulated),'b');
title('sygnal OFDM - skladowa I oraz Q');

dlmwrite('mod_output_rc.txt',data_modulated,'precision','%.8f');
