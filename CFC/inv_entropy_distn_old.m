function [MI_p_vals,MI_z_scores]=inv_entropy_distn(noshufs,nobins,A,P,cycle_bounds_A,cycle_bounds_P,MI,filename,A_bands,P_bands)

% function [MI_p_vals,MIvals,Mvals]=inv_entropy_distn(noshufs,nobins,A,P,cycle_bounds,M,MI)

% Finding p-values.

[data_length,noamps]=size(A);
[data_length,nophases]=size(P);

MIvals=zeros(noshufs,noamps,nophases);
A_shuf=zeros(data_length,noamps);
P_shuf=zeros(data_length,nophases);
M_shuf=zeros(noamps,nophases);
L_shuf=zeros(data_length,nophases);

if nargin>7
    mkdir ([filename,'_inv_entropy'])
    shuf_name=[filename,'_inv_entropy\',filename,'_',num2str(noshufs),'_shufs.txt'];
else
    shuf_name=[num2str(noshufs),'_shufs_p_',num2str(threshold),'.txt'];
end

fid=fopen(shuf_name,'w');

params=[];
for i=1:noamps*nophases
    params=[params,'%f\t'];
end
params=[params(1:end-1),'n'];

% figure();
for i=1:noshufs
    A_shuf=shuffle_cycles(A,cycle_bounds_A,1);
    P_shuf=shuffle_cycles(P,cycle_bounds_P,1);
    [bincenters,M_shuf,L_shuf]=amp_v_phase_no_save(nobins,A_shuf,P_shuf);
%     Mvals(i,:,:,:)=M_shuf;
%     for l=1:nophases
%         for m=1:noamps
%             subplot(noamps,nophases,noamps*(l-1)+m);
%             plot(bincenters,M(:,m,l),'k');
%             hold on;
%         end
%     end
    MI=inv_entropy_no_save(M_shuf);
    MIvals(i,:,:)=MI;
    fprintf(fid,params,reshape(MI,1,nophases*noamps));
%     clear bincenters M_shuf N_shuf L_shuf
end

fclose(fid);

for i=1:noamps 
    for j=1:nophases 
        MI_p_vals(i,j)=sum(MIvals(:,i,j)<=MI(i,j))/noshufs;
    end
end

MImeans(:,:)=mean(MIvals);
MIstds(:,:)=std(MIvals);
MI_z_scores=(MI-MImeans)./MIstds;

% Computing skewness.

for i=1:noshufs
    Mn(i,:,:)=MImeans;
end

multiplier=sqrt(noshufs-1)/(sqrt(noshufs)*(noshufs-2));
MI_skews(:,:)=multiplier*sum((MIvals-Mn).^3)./(std(MIvals,1).^(1.5));

% Saving p-values and z-scores.

params=[];

if nargin>6

    % fid=fopen([filename,'_',bandslabel,'_inv_entropy.txt'],'w');
    fid1=fopen([filename,'_inv_entropy_pvals.txt'],'w');
    fid2=fopen([filename,'_inv_entropy_zscores.txt'],'w');
    fid3=fopen([filename,'_inv_entropy_skewness.txt'],'w');
    
    if nargin>7
        
        Abandslabel=['a_',num2str(length(A_bands)),'_from_',num2str(min(A_bands(1,:))),'_to_',num2str(max(A_bands(end,:)))];
        Pbandslabel=['p_',num2str(length(P_bands)),'_from_',num2str(min(P_bands(1,:))),'_to_',num2str(max(P_bands(end,:)))];
        bandslabel=[Abandslabel,'_v_',Pbandslabel];

        for i=1:nophases
            params=[params,'%f\t'];
        end
        params=[params,'%f\n'];
        
        fprintf(fid1,params,[NaN P_bands(:,2)' ; A_bands(:,2) MI_p_vals]');
        fprintf(fid2,params,[NaN P_bands(:,2)' ; A_bands(:,2) MI_z_scores]');
        fprintf(fid3,params,[NaN P_bands(:,2)' ; A_bands(:,2) MI_skews]');
        fclose('all');
        
    else

        for i=1:nophases-1
            params=[params,'%f\t'];
        end
        params=[params,'%f\n'];
        
        fprintf(fid1,params,MI_p_vals');
        fprintf(fid2,params,MI_z_scores');
        fprintf(fid3,params,MI_skews');
        fclose('all');

    end
    
end

% Plotting and saving histograms.

figure();
for k=1:nophases
    for j=1:noamps
        subplot(noamps,nophases,noamps*(k-1)+j);
        hist(MIvals(:,j,k));
        if nargin>7
            title([num2str(noshufs),' Shuffles, Phase ',num2str(A_bands(k,2)),' Hz vs. Amp. ',num2str(A_bands(j,2)),' Hz'])
        else
            title([num2str(noshufs),' Shuffles'])
        end
    end
end

if nargin>6
    saveas(gcf,[filename,'_inv_entropy_distns.fig'])
end

figure();
for k=1:nophases
    for j=1:noamps
        subplot(noamps,nophases,noamps*(k-1)+j);
        hist(log(MIvals(:,j,k)));
        if nargin>7
            title([num2str(noshufs),' Shuffles, Phase ',num2str(A_bands(k,2)),' Hz vs. Amp. ',num2str(A_bands(j,2)),' Hz'])
        else
            title([num2str(noshufs),' Shuffles'])
        end
    end
end

Skew=mean(MIvals);

if nargin>6
    saveas(gcf,[filename,'_ln_inv_entropy_distns.fig'])
end
    
% figure();
% for k=1:nophases
%     for j=1:noamps
%         subplot(noamps,nophases,noamps*(k-1)+j);
%         Quartiles=prctile(Mvals(:,:,j,k),[25 50 75]);
%         errorbar(bincenters,Quartiles(2,:),Quartiles(1,:),Quartiles(3,:));
%         hold on;
%         plot(bincenters,M(:,j,k),'r');
%     end
% end
% 
% MImeans(:,:)=mean(MIvals);
% MIstds(:,:)=std(MIvals);

% figure();
% subplot(1,2,1); colorplot(MI); colorbar; subplot(1,2,2); colorplot(MI_p_vals); colorbar;

% MI_p_val_colors=round(1000*MI_p_vals/max(max(MI_p_vals)));
% cmap=jet(1000);
% 
% figure();
% for k=1:nophases
%     for j=1:noamps
% %         figure();
% %         subplot(noamps,nophases,noamps*(k-1)+j);
% %         whitebg(cmap(MI_p_val_colors(j,k),:));
%         Mmeans=mean(Mvals(:,:,j,k));
%         Mstds=std(Mvals(:,:,j,k));
%         errorbar(bincenters,Mmeans,Mstds,Mstds);
%         hold on;
%         plot(bincenters,M(:,j,k),'r');
%     end
% end