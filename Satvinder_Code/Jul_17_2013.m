mean_IE_thresh_zs=zeros(33,33,2);

state_indices=[0 2];

% for i=1:2, 
%     
%     DREADD_mean=reshape(mean_IE(:,:,4),1,1089); 
%     DREADD_std=reshape(std_IE(:,:,4),1,1089); 
% 
%     DREADD_mean_mat=repmat(DREADD_mean,length(find(states==state_indices(i))),1);
%         
%     IE_thresh_zs=(IE_thresh(states==state_indices(i),:)-DREADD_mean_mat)*diag(1./DREADD_std);    
%     
%     temp_IE=reshape(mean(IE_thresh_zs),33,33);
%     
%     figure(), imagesc(temp_IE)
%     
%     mean_IE_thresh_zs(:,:,i)=temp_IE;
%     
% end

% p=zeros(2,1089);
% h=zeros(2,1089);
% z=zeros(2,1089);
% 
% for i=1:2, 
%     
%     for j=1:1089
%         
%         [p(i,j),h(i,j),stats]=ranksum(IE_thresh(states==state_indices(i),j),IE_thresh(states==3,j),'alpha',0.01/1089);
%     
%         z(i,j)=stats.zval;
%         
%     end
% 
%     temp_IE=reshape(z(i,:),33,33);
%     
%     figure(), imagesc(temp_IE)
%     
% end
% 
% z_sig=z;
% z_sig(h==0)=nan;
% 
% for i=1:2
%     
%     figure(), colorplot(reshape(z_sig(i,:),33,33))
%     
% end

DREADD_epochs=find(states==3);
no_reps=1000000;

corr_vec=zeros(2,no_reps);

for i=1:2,  

    state_epochs=find(states==state_indices(i));

    DREADD_choices=randi(length(DREADD_epochs),1,no_reps);
    state_choices=randi(length(state_epochs),1,no_reps);
    
    parfor j=1:no_reps
        
        DREADD_IE=IE_thresh(DREADD_epochs(DREADD_choices(j)),:);
        DREADD_IE=reshape(DREADD_IE,33,33);
        state_IE=IE_thresh(state_epochs(state_choices(j)),:);
        state_IE=reshape(state_IE,33,33);
        corr_vec(i,j)=max(max(xcorr2(DREADD_IE,state_IE)));
        
    end
    
end