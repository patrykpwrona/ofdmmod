clear;
999
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
bpsk_0 = [0,1,0,-1];
bpsk_1 = [0,-1,0,1];

% modulation mapping
for i=1:length(data_in)/N
    for j=1:N

        if data_parallel(j,i)==1
            current_simbol = bpsk_1;
        else
            current_simbol = bpsk_0;
        end
        
        data_mapped(j,(i-1)*4+1:(i-1)*4+4)=current_simbol;
        
    end
end

%data_mapped(1,:)
%data_mapped(:,1)
%ifft(data_mapped,4)
data_modulated = ifft(data_mapped,4,2);
ifft(data_mapped,4,1)
ifft(data_mapped,4,2)
%(ifft(data_mapped'))'


