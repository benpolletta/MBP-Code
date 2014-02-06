function [epochs,MI_thresh_all]=collect_MI_stats(prefix,suffix)

front_skip=length(char(prefix));
end_skip=length(char(suffix));

[listname,listpath]=uigetfile('*list','Choose list of data files.');

thresh_labels={'p','z','lz'};

for i=1:3
    
    fid_vec(i)=fopen([listname(1:end-5),'_',thresh_labels{i},'_thresh.txt'],'w');
    fprintf(fid_vec(i),'%s\t','epoch');

end

band_labels={'hg';'lg';'ab';'t'};

line_format='%d\t'; index=0;

for l=1:3
    for m=l+1:4
           
        index=index+1;
        
        band_pair_labels{index}=[band_labels{m},' on ',band_labels{l}];
        
%         for n=1:3
%             fprintf(fid_vec(n),'%s\t',[band_labels{m},'_on_',band_labels{l}]);
%         end
        
        line_format=[line_format,'%f\t'];
        
    end
end

for l=1:3
    fprintf(fid_vec(l),'%s\n','');
end

line_format=[line_format(1:end-1),'n'];

filenames=textread([listpath,listname],'%s');
filenum=length(filenames);

epochs=zeros(filenum,1);
MI_thresh_all=zeros(6,filenum,3);

for i=1:filenum
    
    filename=char(filenames(i));
    filename=filename(1:end-4);
    epochs(i)=str2num(filename(front_skip+1:end-end_skip));
    
    thresh_name=[filename,'_inv_entropy_threshold.fig'];
    
    if exist(thresh_name)==2
        
        open(thresh_name);
        thresh_axes=findall(gcf,'Type','axes');
        
        for j=1:3
            
            chitlins=get(thresh_axes(end-j+1),'Children');
            
            MI_thresh=get(chitlins,'CData');
            
            MI_thresh_vec=[MI_thresh(1,2) MI_thresh(1,3) MI_thresh(1,4) MI_thresh(2,3) MI_thresh(2,4) MI_thresh(3,4)];
            
%             for l=1:3
% 
%                 for m=l+1:4
% 
%                     MI_thresh_vec=(MI_thresh_vec MI_thresh(l,m));
% 
%                 end
% 
%             end
            
            MI_thresh_all(:,i,j)=MI_thresh_vec';
            
            fprintf(fid_vec(j),line_format,[epochs(i) MI_thresh_vec]);

        end
                 
        close(gcf);
    
    else
        
        for j=1:3
            
            MI_thresh_all(:,i,j)=0;
        
            fprintf(fid_vec(j),line_format,[epochs(i) zeros(1,6)]);
            
        end
    
    end
    
end

fclose('all')

for i=1:3
    
    figure()
    
    stem(epochs,MI_thresh_all(:,:,i)','o')
    legend(band_pair_labels)
    title(['Thresholded MI by Epoch Number for ',listname])
    xlabel('Epoch')
    ylabel('Amt. of MI Above Threshold')
    saveas(gcf,[listname(1:end-5),'_',thresh_labels{i},'_thresh.fig']);
    
    figure()
    
    boxplot(MI_thresh_all(:,:,i)')
    title(['Thresholded MI by Epoch Number for ',listname])
    xlabel('Band Pair')
    ylabel('Amt. of MI Above Threshold')
    set(gca,'XTickLabel',band_pair_labels)
    saveas(gcf,[listname(1:end-5),'_',thresh_labels{i},'_thresh_boxplot.fig']);
    
end