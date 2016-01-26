%wchodz¹ nam dane rzeczywiste szeregowo
8888

N=4;
fs=16;

%rozdzielamy zespolone 
data_received_I=real(data_modulated);
data_received_Q=imag(data_modulated.*i);

data_received=data_received_I+data_received_Q;

figure(10)
plot(data_received,'g');




%liczymy fft porcjami po step punktów

step=fs*N;

for i=1:length(data_in)/N
    data_demodulated((i-1)*step+1:(i-1)*step+step)=fft(data_received((i-1)*step+1:(i-1)*step+step));
end

% serial to parallel
for i=1:fs*length(data_in)/N
    for j=1:N
        data_demodulated_parallel(j,i)=data_demodulated((i-1)*N+j);       
    end
end



%{
figure(6)
plot(real(data_demodulated_parallel(1,:)),'r');

figure(7)
plot(imag(data_demodulated_parallel(1,:)),'g');

figure(8)
plot(real(data_demodulated_parallel(1,:))+imag(data_demodulated_parallel(1,:)),'b');

figure(9)
plot(real(data_demodulated_parallel(1,:)).*imag(data_demodulated_parallel(1,:)),'b');
%}


%demapping
%bierzemy kolejne 16 symboli z ka¿dego oczepu sumujemy je i jeszcze raz
%liczymy jeddno punktow¹ fft
%nie ma to ¿adnego uzasadnienia naukowego
for i=1:length(data_in)/N
    for j=1:N
        data_demapped(j,i)=sum(data_demodulated_parallel(j,(i-1)*fs+1:(i-1)*fs+fs));
    end
end

%serializacja odebranych danych
%parallel to serial
for i=1:length(data_in)/N
    for j=1:N
        data_out_complex((i-1)*N+j)=data_demapped(j,i);
    end
end

%trzeba wyci¹gn¹æ czêœæ rzeczywist¹ i ustaliæ jakiœ próg decyzyjny ¿eby
%uodporniæ na szumy


%demodulacja, ka¿de 16 próbek powinno teraz zostaæ potraktowane jako symbol
%i zdekodowane jako 1 lub 0




%figure(5)
%hold on;
%plot(real(data_demodulated),'r');
%plot(imag(data_demodulated),'b');