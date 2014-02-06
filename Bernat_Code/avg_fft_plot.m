f=500*[1:length(all_avg_fft)]/length(all_avg_ff);

all_avg_fft(:,f>=59 && f<=61)=nan;
all_avg_fft(:,f>=119 && f<=121)=nan;

all_se_fft(:,f>=59 && f<=61)=nan;
all_se_fft(:,f>=119 && f<=121)=nan;

avg_linestyles={'k','m','c'};

for i=1:4
    
    subplot(4,1,i) 
    
    for j=1:3 

        plot(f(f<=200), all_avg_fft((i-1)*3+j,f<=200),avg_linestyles{j});
        
        hold on
        
    end
    
end