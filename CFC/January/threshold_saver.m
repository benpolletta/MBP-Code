function MI_thresh=threshold_saver(MI,MI_stats,filename,dirname)

for l=1:3
            
    MI_thresh(:,:,l)=max(0,MI-MI_stats(:,:,3*(l-1)+1));
    
end

MI_thresh(:,:,4)=(MI-MI_stats(:,:,2))./MI_stats(:,:,3);
MI_thresh(:,:,5)=(MI-exp(MI_stats(:,:,5)))./exp(MI_stats(:,:,6));

if nargin>2
    
    save([dirname,'/',filename,'_thresh.mat'],'MI_thresh')

end