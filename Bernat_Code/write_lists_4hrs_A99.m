channels=[1 2 5 6 7];

drugs={'MK801','NVP','Ro25','saline'}; 
no_drugs=length(drugs);

secs_per_epoch=4.096*4;
epochs_per_min=60/secs_per_epoch;
epochs_per_hour=round(60*60/secs_per_epoch);

inj_epochs=floor([5*60+7 2*60+35 5*60+7 3*60]*epochs_per_min);
total_epochs=[5236 4881 7354 4938];

% hours=cell(no_drugs,1);
% hour_labels=cell(no_drugs,1);

for d=1:length(drugs)
    
    hrs_pre=ceil(inj_epochs(d)/(4*epochs_per_hour));
    hrs_post=ceil((total_epochs(d)-inj_epochs(d))/(4*epochs_per_hour));
    
    drug_hours=zeros(hrs_pre+hrs_post,2);
    drug_hour_labels=cell(hrs_pre+hrs_post,1);
    
    for k=-hrs_pre:hrs_post-1
        
        drug_hours(k+hrs_pre+1,:)=inj_epochs(d)+[k k+1]*4*epochs_per_hour+[1 0];
        
        if k<0
            drug_hour_labels{k+hrs_pre+1}=['pre',num2str(-4*k),'to',num2str(-4*(k+1)+1)];
        else
            drug_hour_labels{k+hrs_pre+1}=['post',num2str(4*k+1),'to',num2str(4*(k+1))];
        end
        
    end
    
%     hours{d}=drug_hours;
%     hour_labels{d}=drug_hour_labels;
    
    write_lists_Bernat_Aug('A99',channels,'4hrs_by_state','drugs',drugs{d},'periods',drug_hours,'pd_labels',drug_hour_labels)
    
end

