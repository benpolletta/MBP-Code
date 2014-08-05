function [rs_hrs,rs_4hrs]=run_stats_Bernat(channel_name,measure)

name=sprintf('ALL_%s',channel_name);

drug_list=text_read([name,'/',name,'_',measure,'_drugs.txt'],'%s');
subject_list=text_read([name,'/',name,'_',measure,'_subjects.txt'],'%s');
hrs_list=text_read([name,'/',name,'_',measure,'_hr_periods.txt'],'%s');
fourhrs_list=text_read([name,'/',name,'_',measure,'_4hr_periods.txt'],'%s');
state_list=text_read([name,'/',name,'_',measure,'_states.txt'],'%s');

load('channels.mat')
channel_index = find(strcmp(channel_names, channel_name));
channels = location_channels{channel_index};

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

rs_hrs=nan(no_f_pairs,no_hrs,no_drugs,no_subs);
rs_4hrs=nan(no_f_pairs,no_4hrs,no_drugs,no_states,no_subs);

for s=1:no_subs
    
    subject=subjects{s};
    
    for d=1:no_drugs
        
        drug=drugs{d};
        
        record_name = [subject, '_', drug];
        
        channel_name = [record_name, '_chan', num2str(channels(s)), '_epochs'];
        
        for h=1:no_hrs
            
            hour=hrs{h};
            
            test_data = ALL_hr_MI(strcmp(subject_list,subject) & strcmp(drug_list,drug) & strcmp(hrs_list,hour), :);
            
            if sum(~isnan(test_data))>0
                
                shuf_data = nan(1000, no_f_pairs);
                
                shuf_prompt = [record_name, '/', channel_name, '/FILE_SHUFFLE_', subject, '_', drug, '_chan', num2str(channels(s)), '_', hour, '_*'];
                
                shuf_dir = dir(shuf_prompt);
                
                if ~isempty(shuf_dir)
                    
                    shuf_dir = shuf_dir.name;
                    
                    present_dir = pwd;
                    
                    cd ([record_name, '/', channel_name, '/', shuf_dir])
                    
                    shuf_list = dir('Shuf*');
                    
                    noshufs = length(shuf_list);
                    
                    clear shuf_list
                    
                    for sh = 1:noshufs
                        
                        shuf_file = dir(['Shuf',num2str(sh),'_*']);
                        
                        shuf_file = shuf_file.name;
                        
                        MI_struct = load(shuf_file);
                        
                        MI = MI_struct.MI;
                        
                        shuf_data(sh, :) = reshape(MI, 1, no_f_pairs);
                        
                    end
                    
                    save([subject,'_',drug,'_chan',num2str(channels(s)),'_',hour,'_shufs.mat'])
                    
                    cd (present_dir)
                    
                    parfor f=1:no_f_pairs
                        
                        p = ranksum(test_data(:, f), shuf_data(:, f));
                        
                        rs_hrs(f,h,d,s) = p;
                        
                    end
                    
                end
                
            end
            
        end
        
        for st=1:no_states
            
            state=states{st};
            
            for h=1:no_4hrs
                
                hour=fourhrs{h};
                
                test_data = ALL_hr_MI(strcmp(subject_list,subject) & strcmp(drug_list,drug) & strcmp(fourhrs_list,hour) & strcmp(state_list,state), :);
                
                if sum(~isnan(test_data))>0
                    
                    shuf_data = nan(1000, no_f_pairs);
                    
                    shuf_prompt = [record_name, '/', channel_name, '/FILE_SHUFFLE_', subject, '_', drug, '_chan', num2str(channels(s)), '_', state, '_', hour, '_*'];
                    
                    shuf_dir = dir(shuf_prompt);
                    
                    if ~isempty(shuf_dir)
                        
                        shuf_dir = shuf_dir.name;
                        
                        present_dir = pwd;
                        
                        cd ([record_name, '/', channel_name, '/', shuf_dir])
                        
                        shuf_list = dir('Shuf*');
                        
                        noshufs = length(shuf_list);
                        
                        clear shuf_list
                        
                        parfor sh = 1:noshufs
                            
                            shuf_file = dir(['Shuf',num2str(sh),'_*']); 
                            
                            shuf_file = shuf_file.name;
                            
                            MI_struct = load(shuf_file);
                            
                            MI = MI_struct.MI;
                            
                            shuf_data(sh, :) = reshape(MI, 1, no_f_pairs);
                            
                        end
                        
                        save([subject,'_',drug,'_chan',num2str(channels(s)),'_',state,'_',hour,'_shufs.mat'])
                        
                        cd (present_dir)
                        
                        parfor f=1:no_f_pairs
                            
                            p = ranksum(test_data(:, f), shuf_data(:, f));
                            
                            rs_4hrs(f,h,st,d,s)=p;
                            
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
    end

end
    
save([name,'/',name,'_',measure,'_rs.mat'],'rs_hrs','rs_4hrs')

