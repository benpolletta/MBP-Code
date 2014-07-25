function [ks_hrs,ks_4hrs]=run_ks_Bernat(channel_name,measure)

name=sprintf('ALL_%s',channel_name);

drug_list=textread([name,'/',name,'_',measure,'_drugs.txt'],'%s');
subject_list=textread([name,'/',name,'_',measure,'_subjects.txt'],'%s');
hrs_list=textread([name,'/',name,'_',measure,'_hr_periods.txt'],'%s');
fourhrs_list=textread([name,'/',name,'_',measure,'_4hr_periods.txt'],'%s');
state_list=textread([name,'/',name,'_',measure,'_states.txt'],'%s');

load('subjects.mat')
no_subs=length(subjects);
load('drugs.mat')
no_drugs=length(drugs);
load('states.mat')
no_states=length(states);
hrs=make_period_labels(8,16,'hrs');
no_hrs=length(hrs);
fourhrs=make_period_labels(8,16,'4hrs');
no_4hrs=length(fourhrs);

ALL_hr_MI=load([name,'/',name,'_',measure,'_hr_MI.txt']);
ALL_4hr_MI=load([name,'/',name,'_',measure,'_4hr_MI.txt']);

no_f_pairs=size(ALL_hr_MI,2);

ks_hrs=nan(no_f_pairs,no_hrs,no_drugs,no_subs);
ks_4hrs=nan(no_f_pairs,no_4hrs,no_drugs,no_states,no_subs);

for s=1:no_subs
    
    subject=subjects{s};
    
    for d=1:no_drugs
        
        drug=drugs{d};
        
        for h=1:no_hrs
            
            hour=hrs{h};
           
            for f=1:no_f_pairs
                
                test_data = ALL_hr_MI(strcmp(subject_list,subject) & strcmp(drug_list,drug) & strcmp(hrs_list,hour),f);
                
                if sum(~isnan(test_data))>0
                    
                    [~,p]=kstest(test_data);
            
                    ks_hrs(f,h,d,s)=p;
    
                end
                
            end
            
        end
        
        for st=1:no_states
            
            state=states{st};
            
            for h=1:no_4hrs
                
                hour=fourhrs{h};
                
                for f=1:no_f_pairs
                    
                    test_data = ALL_hr_MI(strcmp(subject_list,subject) & strcmp(drug_list,drug) & strcmp(fourhrs_list,hour) & strcmp(state_list,state),f);
                    
                    if sum(~isnan(test_data))>0
                        
                        [~,p]=kstest(test_data);
                        
                        ks_hrs(f,h,st,d,s)=p;
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
end

save([name,'/',name,'_',measure,'_ks.mat'],'ks_hrs','ks_4hrs')

