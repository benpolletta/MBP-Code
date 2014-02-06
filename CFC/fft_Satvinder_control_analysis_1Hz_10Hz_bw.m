function fft_Satvinder_control_analysis_1Hz_10Hz_bw

orders=[-1 3];

challenge_list='sk50_REM_chan1_preinj_hr1_clean_list.list';
challenge_name='sk50_REM_chan1_preinj_hr1';
challenge_descriptor='Mouse EEG';
% challenge_params=[0 1 2];
challenge_labels={'REM'};

no_files=360;

band_centers_hi=20:5:110;
bands_hi=[band_centers_hi'-5 band_centers_hi' band_centers_hi'+5];
no_bands_hi=length(band_centers_hi);

band_centers_lo=4:.25:12;
bands_lo=[band_centers_lo'-1 band_centers_lo' band_centers_lo'+1];
no_bands_lo=length(band_centers_lo);

present_dir=pwd;

% if nargin<6
%     for p=1:length(challenge_params)
%         challenge_labels{p}=num2str(challenge_params(p));
%     end
% end
 
H_format='';
for p=1:length(challenge_labels)-1
    H_format=[H_format,'%f\t'];
end
H_format=[H_format,'%f\n'];

for m=1:length(orders)
    
    order=orders(m);
    
    if order==-1
        order_folder='He_BW_order_3';
        pct_pass=1;
    elseif order==0
        order_folder='Matlab_BW_optimal';
        pct_pass=.9;
    else
        order_folder=['Matlab_BW_order_',num2str(order)];
        pct_pass=1;
    end
    
    order_dir=['FFT/',order_folder,'/Aggregate'];
    mkdir (order_dir);
    
    dirnames{1}=['FFT/',order_folder,'/HAF_Data_Plots'];
    dirnames{2}=['FFT/',order_folder,'/AVP_Data'];
    dirnames{3}=['FFT/',order_folder,'/AVP_Plots'];
    dirnames{4}=['FFT/',order_folder,'/MI_Data_Plots'];
    for i=1:4
        mkdir (dirnames{i});
    end

    graph_titles{1}='MI';
    graph_titles{2}='MI p-Value';
    graph_titles{3}='MI z-Score';
    graph_titles{4}='Thresholded MI (Empirical p-Value)';
    graph_titles{5}='Thresholded MI (Normal p-Value)';

    graph_labels{1}='MI';
    graph_labels{2}='PV';
    graph_labels{3}='ZS';
    graph_labels{4}='MI_pt';
    graph_labels{5}='MI_zt';

    listnames=textread(challenge_list,'%s%*[^\n]');
    listnum=length(listnames);
    
    max_bands=zeros(no_files,5,2,listnum);
    
    for j=1:1

        filenames=textread(char(listnames(j)),'%s%*[^\n]');
        filenum=length(filenames);
                
        MI=zeros(no_bands_hi,no_bands_lo,filenum,5);
        
%         max_bands=zeros(filenum,5,2,listnum);

        parfor k=1:filenum

%             tic;

            temp_MI=zeros(no_bands_hi,no_bands_lo,1,5);
            
            [~,~,temp_MI(:,:,:,1),temp_MI(:,:,:,2),temp_MI(:,:,:,3),temp_MI(:,:,:,4),temp_MI(:,:,:,5)]=CFC_April_fft_10_2013(char(filenames(k)),600,20,100,.05,.05,[4 12],no_bands_lo,[20 110],no_bands_hi,order,pct_pass,'Hz',dirnames,bands_lo,bands_hi);
            
            MI(:,:,k,:)=temp_MI;
            
%             times(k,j)=toc;

            close('all')
            fclose('all');
            
        end

        cd (order_dir);

%         fid3=fopen(['fft_times_',challenge_name,'_',challenge_labels{j},'.txt'],'w');
%         fprintf(fid3,'%f\n',times(:,j));

        for p=1:no_bands_hi
            A_labels{p}=num2str(bands_hi(p,2));
        end
        
        for p=1:no_bands_lo
            P_labels{p}=num2str(bands_lo(p,2));
        end

        avgMI=mean(MI,3);

        for p=1:filenum
            for n=1:5
                mi=MI(:,:,p,n);
                maxmi=max(max(mi));
                if maxmi~=0
                    [r,c]=find(mi==maxmi);
                    max_bands(p,n,1,j)=mean(bands_hi(r,2));
                    max_bands(p,n,2,j)=mean(bands_lo(c,2));
                else
                    max_bands(p,n,1,j)=nan;
                    max_bands(p,n,2,j)=nan;
                end
            end
        end

        fid1=fopen(['hist_hi_bin_',challenge_name,'_',challenge_labels{j},'.txt'],'w');
        fid2=fopen(['hist_lo_bin_',challenge_name,'_',challenge_labels{j},'.txt'],'w');

        for l=1:5
            fid=fopen(['avg_',graph_labels{l},'_',challenge_name,'_',challenge_labels{j},'.txt'],'w');
            [r,c,~,~]=size(avgMI(:,:,:,l));
            format='';
            for i=1:c-1
                format=[format,'%f\t'];
            end
            format=[format,'%f\n'];
            fprintf(fid,format,reshape(avgMI(:,:,:,l),r,c)');

            if l~=4
                fprintf(fid1,'%s\t',graph_labels{l});
                fprintf(fid2,'%s\t',graph_labels{l});
            else
                fprintf(fid1,'%s\n',graph_labels{l});
                fprintf(fid2,'%s\n',graph_labels{l});
            end

            figure()
            colorplot(avgMI(:,:,:,l))
            title(['Mean ',graph_titles{l},', ',challenge_descriptor,' ',challenge_labels{j},' Hz'],'FontSize',30)
            axis xy
            set(gca,'XTick',[1.5:(no_bands_lo+.5)],'YTick',[1.5:(no_bands_hi+.5)],'XTickLabel',P_labels,'YTickLabel',A_labels,'FontSize',16)
            xlabel('Phase-Modulating Frequency (Hz)','FontSize',24)
            ylabel('Amplitude-Modulated Frequency (Hz)','FontSize',24)
            saveas(gcf,['avg_',graph_labels{l},'_',challenge_name,'_',challenge_labels{j},'.fig'])
                        
            figure()
            colormap('gray')
            colorplot(avgMI(:,:,:,l))
            axis xy
            set(gca,'XTick',[1.5:6:(no_bands_lo+.5)],'YTick',[1.5:6:(no_bands_hi+.5)],'XTickLabel',P_labels([1:6:no_bands_lo]),'YTickLabel',A_labels([1:6:no_bands_hi]),'FontSize',16)
            saveas(gcf,['avg_',graph_labels{l},'_',challenge_name,'_',challenge_labels{j},'_minimal.fig'])

            figure()
            subplot(2,1,1)
            hist(max_bands(:,l,1,j),bands_hi(:,2))
            title(['Histogram of Max. ',graph_titles{l},' Amplitude Bin, ',challenge_descriptor,' ',challenge_labels{j},' Hz'],'FontSize',30)
%             set(gca,'XTick',1.5:33.5,'XTickLabel',A_labels)
            xlabel('Center Frequency (Hz)')

            subplot(2,1,2)
            hist(max_bands(:,l,2,j),bands_lo(:,2))
            title(['Histogram of Max. ',graph_titles{l},' Phase Bin, ',challenge_descriptor,' ',challenge_labels{j},' Hz'],'FontSize',30)
%             set(gca,'XTick',1.5:33.5,'XTickLabel',P_labels)
            xlabel('Center Frequency (Hz)')
            saveas(gcf,['hist_',graph_labels{l},'_bin_',challenge_name,'_',challenge_labels{j},'.fig'])
        end

        fprintf(fid1,'%f\t%f\t%f\t%f\n',max_bands(:,:,1,j)');
        fprintf(fid2,'%f\t%f\t%f\t%f\n',max_bands(:,:,2,j)');

        close('all')
        
        cd (present_dir);
    
    end

    if listnum>1
        
        cd (order_dir);
        
        for l=1:5
            
            H(:,:,l,1)=hist(reshape(max_bands(:,l,1,:),no_files,listnum),bands_hi(:,2));
            
            fid4=fopen([challenge_name,'_',graph_labels{l},'_hists_hi_','.txt'],'w');
            fprintf(fid4,H_format,H(:,:,l,1)');
            
            H(:,:,l,2)=hist(reshape(max_bands(:,l,2,:),no_files,listnum),bands_lo(:,2));
            
            fid6=fopen([challenge_name,'_',graph_labels{l},'_hists_lo_','.txt'],'w');
            fprintf(fid6,H_format,H(:,:,l,2)');
            
            figure()
            subplot(2,1,1)
            colorplot(H(:,:,l,1))
            axis xy
            title(['Histogram of Max. Bin for ',graph_titles{l},' ',challenge_descriptor],'FontSize',30)
            set(gca,'YTick',1.5:(no_bands_hi+.5),'YTickLabel',A_labels,'XTick',1.5:(listnum+.5),'XTickLabel',challenge_labels,'FontSize',16)
            ylabel({'Amp. Bin';'Center Freq. (Hz)'},'FontSize',24)
            %             xlabel('3rd Osc. Freq. Range')
            
            subplot(2,1,2)
            colorplot(H(:,:,l,2))
            axis xy
            %             title(['Histogram of Max. Bin for ',graph_titles{l},' ',challenge_descriptor,' ',challenge_labels{j},' Hz'],'FontSize',30)
            set(gca,'YTick',1.5:(no_bands_lo+.5),'YTickLabel',P_labels,'XTick',1.5:(listnum+.5),'XTickLabel',challenge_labels,'FontSize',16)
            ylabel({'Phase Bin';'Center Freq. (Hz)'},'FontSize',24)
            xlabel('Freq. Range, Low Freq. Osc.','FontSize',24)
            saveas(gcf,['hist_',graph_labels{l},'_',challenge_name,'.fig'])
            
            figure()
            colormap('gray')
            subplot(2,1,1)
            colorplot(H(:,:,l,1))
            caxis([0 no_files])
            colorbar
            axis xy
            set(gca,'YTick',[1.5:6:(no_bands_hi+.5)],'YTickLabel',bands_hi([1:6:no_bands_hi],2),'XTick',[],'FontSize',16)
            
            subplot(2,1,2)
            colorplot(H(:,:,l,2))
            caxis([0 no_files])
            colorbar
            axis xy
            set(gca,'YTick',[1.5:6:(no_bands_lo+.5)],'YTickLabel',bands_lo([1:6:no_bands_lo],2),'XTick',[],'FontSize',16)
            saveas(gcf,['hist_',graph_labels{l},'_',challenge_name,'_minimal.fig'])
            
        end
        
        cd (present_dir);
    
    end
        
end