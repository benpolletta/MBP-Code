
t=[1:1800]/600;

randos=rand(1,10000);
rand_counter=1;

for i=1:20
    
    last_phase=0;
    
    phase_shift=randos(rand_counter)*2*pi;
    rand_counter=rand_counter+1;
    
    LF=i/((1+.1*randos(rand_counter))*5);
    rand_counter=rand_counter+1;
    
    LF2=i/(randos(rand_counter)*20);
    rand_counter=rand_counter+1;
    
    dp=i*(1+.25*sin(LF1*t)+.25*sin(LF2*t))/600;
    phases=cumsum(dp);
    
%     cycle_length=floor(1800/i);
%     no_cycles=ceil(1800/cycle_length);
%     
%     for j=1:no_cycles
%         
%         cycle_freq=randos(rand_counter)*.3*i+i-.3*i/2;
%         true_cycle_length=600/cycle_freq;
%         rand_counter=rand_counter+1;
%         
%         phases((j-1)*cycle_length+1:j*cycle_length)=2*pi*(1:cycle_length)/true_cycle_length+last_phase;
%         
%         last_phase=phases(end);
%     
%     end
    
%     phases=sin(2*pi*LF1*t)+sin(2*pi*LF2*t)+2*pi*t;

    S=sin(phases+phase_shift);

    S=S(1:1800);
    
    A=abs(hilbert(S));
    
    figure()
    plot(phases)
    
    figure()
    plot(t,S,'k',t,A,'r')
    
%     figure()
%     plot(abs(fft(A)))
    
end