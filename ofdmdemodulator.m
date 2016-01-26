clear;
%wczytuje complex, zapisuje double
file_in=fopen('mod_output_rc.txt', 'r');
raw_data=textscan(file_in,'%s','bufsize',40960);
fclose(file_in);

char_data=char(raw_data{:,:});
data_modulated_received=str2num(char_data);

% Ponizsze parametry musza byc takie same jak w modulatorze!
% N = ilosc nosnych = ilosc odczepow do zrownoleglania
N = 8;
% uzywamy modulacji BPSK
% fs = ilosc probek sygnalu analogowego w symbolu modulacji
fs = 16;

% na wejsciu mamy dane otrzymane z kanalu - data_modulated -> liczby
% zespolone

% rozdzielamy liczby zespolone na czesc rzeczywista i zespolona
% mnozenie przez i liczby zespolonej to to samo co przesuniecie w fazie o
% 90 stopni
data_received_I=real(data_modulated_received);
data_received_Q=imag(data_modulated_received*-1);

% sumujemy czesci zespolone i rzeczywiste 
data_received=data_received_I+data_received_Q;

% pomocnicza zmienna - dluosc odebranych danych (w bitach juz)
data_in_len=length(data_received)/fs;

% FFT
% liczymy je porcjami po N * fs punktow jak poprzednio
step=fs*N;
for i=1:data_in_len/N
    data_demodulated((i-1)*step+1:(i-1)*step+step)=fft(data_received((i-1)*step+1:(i-1)*step+step));
    %data_demodulated((i-1)*step+1:(i-1)*step+step)=(data_received((i-1)*step+1:(i-1)*step+step));
end

% S / P
for i=1:length(data_received)/N;
    for j=1:N
        data_demodulated_parallel(j,i)=data_demodulated((i-1)*N+j);       
    end
end

% Demapping
% bierzemy kolejne fs symboli z kazdego oczepu sumujemy je - otrzymujemy
% liczbe zespolona odpowiadajaca korelacji
 for i=1:data_in_len/N
    for j=1:N
        data_demapped(j,i)=sum(data_demodulated_parallel(j,(i-1)*fs+1:(i-1)*fs+fs));
        %data_demapped(j,i)=sum(fft(data_demodulated_parallel(j,(i-1)*fs+1:(i-1)*fs+fs),fs));
    end
 end


% P / S
% koncowa serializacja odebranych danych
for i=1:data_in_len/N
    for j=1:N
        data_out_complex((i-1)*N+j)=data_demapped(j,i);
    end
end

% detektor progowy

for n=1:length(data_out_complex)
   if(real(data_out_complex(n)))>0.6
       data_out(n)=1;
   elseif(real(data_out_complex(n)))<0.4
       data_out(n)=0;
   else
       if(imag(data_out_complex(n))>0)
           data_out(n)=1;
       else
           data_out(n)=0;
       end
   end
   
end

figure(5)
plot(data_received,'b');
title('probki odebranego sygnalu ofdm po obrobce kwadraturowej - polaczone skladowe I oraz Q');

figure(6)
hold on;
plot(real(data_demodulated),'r');
plot(imag(data_demodulated),'g');
title('dane odebrane po obliczeniu fft - liczby zespolone');

%Wczytanie data_in do celow porownawczych
FID2=fopen('sample_data_in.txt', 'r');
raw_data=textscan(FID2,'%s');
fclose(FID2);

char_data=char(raw_data{:,:});
data_in=str2num(char_data);

err=data_out-data_in;


dlmwrite('demodoutpusttest.txt',data_out,'precision','%.8f')
