function [pd_corder,period_labels]=make_period_labels(hrs_pre,hrs_post,format)

if strcmp(format,'hrs')
    
    no_periods=hrs_pre+hrs_post;
    
    period_labels=cell(1,no_periods);
    
    index=1;
    
    for p=hrs_pre:-1:1
        
        period_labels{index}=['pre',num2str(p)];
        
        pd_corder(index,:)=(index-1)*[1 1 1]/(2*hrs_pre);
        
        index=index+1;
        
    end
    
    for p=1:hrs_post
        
        period_labels{index}=['post',num2str(p)];
        
        pd_corder(index,:)=(p-1)*[0 1 1]/hrs_post+(hrs_post-p)*[1 0 1]/hrs_post;
        
        index=index+1;
    
    end
    
elseif strcmp(format,'4hrs')
    
    no_periods=(ceil(hrs_pre+hrs_post)/4);
    
    period_labels=cell(1,no_periods);
    
    index=1;
    
    for p=hrs_pre:-4:4
        
        period_labels{index}=['pre',num2str(p),'to',num2str(p-3)];
        
        pd_corder(index,:)=(index-1)*[1 1 1]/(2*(hrs_pre/4));
        
        index=index+1;
    
    end
    
    for p=4:4:hrs_post
    
        period_labels{index}=['post',num2str(p-3),'to',num2str(p)];
        
        pd_corder(index,:)=(p/4-1)*[0 1 1]/(hrs_post/4)+(hrs_post-p)*[1 0 1]/hrs_post;
        
        index=index+1;
    
    end
        
end