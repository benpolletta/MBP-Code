function [MI_p_vals,MI_p_thresh,MI_z_scores,MI_norm_pvals,MI_z_thresh,MI_log_z_scores,MI_lognorm_pvals,MI_lz_thresh]=inv_entropy_distn_thresh(noshufs,threshold,nobins,A,P,cycle_bounds_A,cycle_bounds_P,MI,filename,A_bands,P_bands)

% function [MI_p_vals,MIvals,Mvals]=inv_entropy_distn(noshufs,nobins,A,P,cycle_bounds,M,MI)

% Finding p-values.

[data_length,noamps]=size(A);
[data_length,nophases]=size(P);

MIvals=nan(noshufs,noamps,nophases);
A_shuf=nan(data_length,noamps);
P_shuf=nan(data_length,nophases);
M_shuf=nan(noamps,nophases);
L_shuf=nan(data_length,nophases);

MI_p_vals=nan(noamps,nophases);
MI_z_scores=nan(noamps,nophases);
MI_norm_pvals=nan(noamps,nophases);
MI_log_z_scores=nan(noamps,nophases);
MI_lognorm_pvals=nan(noamps,nophases);

if noshufs>0

    if nargin>8
        mkdir ([filename,'_inv_entropy'])
        shuf_name=[filename,'_inv_entropy\',filename,'_',num2str(noshufs),'_shufs_p_',num2str(threshold),'.txt'];
    else
        shuf_name=[num2str(noshufs),'_shufs_p_',num2str(threshold),'.txt'];
    end
    
    params=[];
    for i=1:(nophases*noamps-1)
        params=[params,'%f\t'];
    end
    params=[params, '%f\n'];
    
    fid=fopen(shuf_name,'w');
    
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
        %     clear bincenters M_shuf N_shuf L_shuf
        fprintf(fid,params,reshape(MI,1,nophases*noamps));
    end
    
    fclose(fid)

    for i=1:noamps
        for j=1:nophases
            below_MI_indices=MIvals(:,i,j)<=MI(i,j);
            MI_p_vals(i,j)=sum(below_MI_indices)/noshufs;
        end
    end
    MI_pthresh_vals=quantile(MIvals,threshold);
    MI_pthresh_vals=reshape(MI_pthresh_vals,size(MI));
    MI_p_thresh=MI-MI_pthresh_vals;
    MI_p_thresh(MI_p_thresh<=0)=nan;

    MImeans(:,:)=mean(MIvals);
    MIstds(:,:)=std(MIvals);
    MI_z_scores=(MI-MImeans)./MIstds;
    MI_norm_pvals=normcdf(MI_z_scores,0,1);
    MI_zthresh_vals=MImeans+norminv(threshold,0,1)*MIstds;
    MI_z_thresh=MI-MI_zthresh_vals;
    MI_z_thresh(MI_z_thresh<=0)=nan;
    
    MI_logmeans(:,:)=mean(log(MIvals));
    MI_logstds(:,:)=std(log(MIvals));
    MI_log_z_scores=(log(MI)-MI_logmeans)./MI_logstds;
    MI_lognorm_pvals=normcdf(MI_log_z_scores,0,1);
    MI_lzthresh_vals=exp(MI_logmeans+norminv(threshold,0,1)*MI_logstds);
    MI_lz_thresh=MI-MI_lzthresh_vals;
    MI_lz_thresh(MI_lz_thresh<=0)=nan;
    
    % Computing skewness.

    for i=1:noshufs
        Mn(i,:,:)=MImeans;
    end

    multiplier=sqrt(noshufs-1)/(sqrt(noshufs)*(noshufs-2));
    MI_skews(:,:)=multiplier*sum((MIvals-Mn).^3)./(std(MIvals,1).^(1.5));

    % Saving p-values and z-scores.

    params=[];

    if nargin>8
        
        present_dir = pwd;
        
        mkdir ([filename,'_inv_entropy'])
        
        cd ([filename,'_inv_entropy'])

        % fid=fopen([filename,'_',bandslabel,'_inv_entropy.txt'],'w');
        fid1=fopen([filename,'_pvals.txt'],'w');
        fid2=fopen([filename,'_zscores.txt'],'w');
        fid3=fopen([filename,'_skewness.txt'],'w');
        fid4=fopen([filename,'_ln_zscores.txt'],'w');
        fid5=fopen([filename,'_n_pvals.txt'],'w');
        fid6=fopen([filename,'_ln_pvals.txt'],'w');
        fid7=fopen([filename,'_n_thresh.txt'],'w');
        fid8=fopen([filename,'_ln_thresh.txt'],'w');
        fid9=fopen([filename,'_p_thresh.txt'],'w');
        fid10=fopen([filename,'_pt_cutoffs.txt'],'w');
        fid11=fopen([filename,'_z_means.txt'],'w');
        fid12=fopen([filename,'_z_stds.txt'],'w');
        fid13=fopen([filename,'_lz_means.txt'],'w');
        fid14=fopen([filename,'_lz_stds.txt'],'w');
                
        if nargin>9

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
            fprintf(fid4,params,[NaN P_bands(:,2)' ; A_bands(:,2) MI_log_z_scores]');
            fprintf(fid5,params,[NaN P_bands(:,2)' ; A_bands(:,2) MI_norm_pvals]');
            fprintf(fid6,params,[NaN P_bands(:,2)' ; A_bands(:,2) MI_lognorm_pvals]');
            fprintf(fid7,params,[NaN P_bands(:,2)' ; A_bands(:,2) MI_z_thresh]');
            fprintf(fid8,params,[NaN P_bands(:,2)' ; A_bands(:,2) MI_lz_thresh]');
            fprintf(fid9,params,[NaN P_bands(:,2)' ; A_bands(:,2) MI_p_thresh]');
            fprintf(fid10,params,[NaN P_bands(:,2)' ; A_bands(:,2) MI_pthresh_vals]');
            fprintf(fid11,params,[NaN P_bands(:,2)' ; A_bands(:,2) MImeans]');
            fprintf(fid12,params,[NaN P_bands(:,2)' ; A_bands(:,2) MIstds]');
            fprintf(fid13,params,[NaN P_bands(:,2)' ; A_bands(:,2) MI_logmeans]');
            fprintf(fid14,params,[NaN P_bands(:,2)' ; A_bands(:,2) MI_logstds]');
            
            fclose('all');

        else

            for i=1:nophases-1
                params=[params,'%f\t'];
            end
            params=[params,'%f\n'];

            fprintf(fid1,params,MI_p_vals');
            fprintf(fid2,params,MI_z_scores');
            fprintf(fid3,params,MI_skews');
            fprintf(fid4,params,MI_log_z_scores');
            fprintf(fid5,params,MI_norm_pvals');
            fprintf(fid6,params,MI_lognorm_pvals');
            fprintf(fid7,params,MI_z_thresh');
            fprintf(fid8,params,MI_lz_thresh');
            fprintf(fid9,params,MI_p_thresh');
            fprintf(fid10,params,MI_pthresh_vals');
            fprintf(fid11,params,MImeans');
            fprintf(fid12,params,MIstds');
            fprintf(fid13,params,MI_logmeans');
            fprintf(fid14,params,MI_logstds');
            
            fclose('all');

        end

        cd (present_dir)
        
    end

    % Plotting and saving histograms.

    figure();
    for k=1:nophases
        for j=1:noamps
            subplot(noamps,nophases,noamps*(k-1)+j);
            hist(MIvals(:,j,k));
            if nargin>9
                title([num2str(noshufs),' Shuffles, Phase ',num2str(A_bands(k,2)),' Hz vs. Amp. ',num2str(A_bands(j,2)),' Hz'])
            else
                title([num2str(noshufs),' Shuffles'])
            end
        end
    end

    if nargin>8
        saveas(gcf,[filename,'_inv_entropy_distns.fig'])
    end

    figure();
    for k=1:nophases
        for j=1:noamps
            subplot(noamps,nophases,noamps*(k-1)+j);
            hist(log(MIvals(:,j,k)));
            if nargin>9
                title([num2str(noshufs),' Shuffles, Phase ',num2str(A_bands(k,2)),' Hz vs. Amp. ',num2str(A_bands(j,2)),' Hz'])
            else
                title([num2str(noshufs),' Shuffles'])
            end
        end
    end

    % Skew=mean(MIvals);

    if nargin>8
        saveas(gcf,[filename,'_ln_inv_entropy_distns.fig'])
    end
    
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