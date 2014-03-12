channels=[1 3 4 5 6];

drugs={'MK801','NVP','Ro25','saline'}; 
no_drugs=length(drugs);

inj_epochs=[733 1293 1125 813];
total_epochs=[4782 5703 5107 5449];

secs_per_epoch=4.096*4;
epochs_per_minute=round(60/secs_per_epoch);

% hours=cell(no_drugs,1);
% hour_labels=cell(no_drugs,1);

for d=1:length(drugs)
    
    mins_pre=ceil(inj_epochs(d)/(6*epochs_per_minute));
    mins_post=ceil((total_epochs(d)-inj_epochs(d))/(6*epochs_per_minute));
    
    drug_mins=zeros(mins_pre+mins_post,2);
    drug_min_labels=cell(mins_pre+mins_post,1);
    
    for k=-mins_pre:mins_post-1
        
        drug_mins(k+mins_pre+1,:)=inj_epochs(d)+[k:k+1]*6*epochs_per_minute+[1 0];
        
        drug_min_labels{k+mins_pre+1}=num2str(6*k+3);
 
    end
    
%     hours{d}=drug_hours;
%     hour_labels{d}=drug_hour_labels;
    
    write_lists_Bernat_Aug('A103',channels,'5mins','drugs',drugs{d},'periods',drug_mins,'pd_labels',drug_min_labels,'states',[])
    
end

