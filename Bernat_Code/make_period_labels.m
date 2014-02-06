function period_labels=make_period_labels(hrs_pre,hrs_post,format)

if strcmp(format,'hrs')
    
    no_periods=hrs_pre+hrs_post;
    
    period_labels=cell(1,no_periods);
    
    index=1;
    
    for p=hrs_pre:-1:1
        
        period_labels{index}=['pre',num2str(p)];
        
        index=index+1;
        
    end
    
    for p=1:hrs_post
        
        period_labels{index}=['post',num2str(p)];
        
        index=index+1;
    
    end
    
elseif strcmp(format,'4hrs')
    
    no_periods=(ceil(hrs_pre+hrs_post)/4);
    
    period_labels=cell(1,no_periods);
    
    index=1;
    
    for p=hrs_pre:-4:4
        
        period_labels{index}=['pre',num2str(p),'to',num2str(p-3)];
        
        index=index+1;
    
    end
    
    for p=4:4:hrs_post
    
        period_labels{index}=['post',num2str(p-3),'to',num2str(p)];
        
        index=index+1;
    
    end
        
end