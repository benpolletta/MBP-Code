channels=[1 3 4];

drugs={'MK801','NVP','Ro25','saline'}; 
no_drugs=length(drugs);

inj_epochs=[733 1293 1125 813];
total_epochs=[4782 5703 5107 5449];

secs_per_epoch=4.096*4;
epochs_per_hour=round(60*60/secs_per_epoch);

% hours=cell(no_drugs,1);
% hour_labels=cell(no_drugs,1);

for d=1:length(drugs)
    
    pds_pre=ceil(inj_epochs(d)/(4*epochs_per_hour));
    pds_post=ceil((total_epochs(d)-inj_epochs(d))/(4*epochs_per_hour));
    
    drug_hours=zeros(pds_pre+pds_post,2);
    drug_hour_labels=cell(pds_pre+pds_post,1);
    
    for k=-pds_pre:pds_post-1
        
        drug_hours(k+pds_pre+1,:)=inj_epochs(d)+[k:k+1]*4*epochs_per_hour+[1 0];
        
        if k<0
            drug_hour_labels{k+pds_pre+1}=['pre',num2str(-4*k),'to',num2str(-4*(k+1)+1)];
        else
            drug_hour_labels{k+pds_pre+1}=['post',num2str(4*k+1),'to',num2str(4*k)];
        end
        
    end
    
%     hours{d}=drug_hours;
%     hour_labels{d}=drug_hour_labels;
    
    write_lists_Bernat_Aug('A103',channels,'4hrs_by_state','drugs',drugs{d},'periods',drug_hours,'pd_labels',drug_hour_labels)
    write_bouts_Bernat('A103',channels,'4hrs_by_state','drugs',drugs{d},'periods',drug_hours,'pd_labels',drug_hour_labels)
    
end