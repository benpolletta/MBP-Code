function [period_labels,pd_corder,long_period_labels]=make_period_labels(hrs_pre,hrs_post,format)

if strcmp(format,'hrs')
    
    no_periods=hrs_pre+hrs_post;
    
    period_labels=cell(1,no_periods);
    
    long_period_labels=cell(1,no_periods);
    
    pd_corder=nan(no_periods,3);
    
    index=1;
    
    for p=hrs_pre:-1:1
        
        period_labels{index}=['pre',num2str(p)];
        
        long_period_labels{index}=['Hour ',num2str(p),' Preinjection'];
        
        pd_corder(index,:)=(index-1)*[1 1 1]/(2*hrs_pre);
        
        index=index+1;
        
    end
    
    for p=1:hrs_post
        
        period_labels{index}=['post',num2str(p)];
    
        long_period_labels{index}=['Hour ',num2str(p),' Postinjection'];
        
        pd_corder(index,:)=(p-1)*[0 1 1]/hrs_post+(hrs_post-p)*[1 0 1]/hrs_post;
        
        index=index+1;
    
    end
    
elseif strcmp(format,'4hrs')
    
    no_periods=(ceil(hrs_pre+hrs_post)/4);
    
    period_labels=cell(1,no_periods);
    
    long_period_labels=cell(1,no_periods);
    
    pd_corder=nan(no_periods,3);
    
    index=1;
    
    for p=hrs_pre:-4:4
        
        period_labels{index}=['pre',num2str(p),'to',num2str(p-3)];
        
        long_period_labels{index}=['Hours ',num2str(p),' to ',num2str(p-3),' Preinjection'];
        
        pd_corder(index,:)=(index-1)*[1 1 1]/(2*(hrs_pre/4));
        
        index=index+1;
    
    end
    
    for p=4:4:hrs_post
    
        period_labels{index}=['post',num2str(p-3),'to',num2str(p)];
    
        long_period_labels{index}=['Hours ',num2str(p-3),' to ',num2str(p),' Postinjection'];
        
        pd_corder(index,:)=(p/4-1)*[0 1 1]/(hrs_post/4)+(hrs_post-p)*[1 0 1]/hrs_post;
        
        index=index+1;
    
    end
        
elseif strcmp(format,'6mins')
    
    no_periods=(ceil(hrs_pre+hrs_post)*10);
    
    period_labels=cell(1,no_periods);
    
    pd_corder=nan(no_periods,3);
    
    index=1;
    
    for p=10*hrs_pre:-1:1
        
        period_labels{index}=num2str(-6*p+3);
        
        pd_corder(index,:)=(index-1)*[1 1 1]/(2*10*hrs_pre);
        
        index=index+1;
        
    end
    
    for p=1:10*hrs_post
        
        period_labels{index}=num2str(6*p-3);
        
        pd_corder(index,:)=(p-1)*[0 1 1]/(10*hrs_post)+(10*hrs_post-p)*[1 0 1]/(10*hrs_post);
        
        index=index+1;
    
    end
    
    long_period_labels=period_labels;
        
end