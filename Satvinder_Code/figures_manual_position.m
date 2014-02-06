function figures_manual_position(prefix,suffix)

[listname,listpath]=uigetfile('*list','Choose list of data files');

filenames=textread([listpath,listname],'%s');
filenum=length(filenames);

lefts=.1:.085:(.95-.085);
bots=.86:-.09:.05;
wd=.8*.085;
ht=.8*.09;

for i=1:floor(filenum/100)
    figure()
    for j=1:10
        for k=1:10
            filename=char(filenames((i-1)*100+(j-1)*10+k));
            data=load(filename);
            t=[1:length(data)]/600;
            %         subplot(10,10,j)
            subplot('Position',[lefts(k) bots(j) wd ht])
%             plot(t,data(:,4),':k',t,data(:,3))
%             plot(t,data)
            plot(t,data)
            axis('tight')
            ylim([-8191,8191])
            set(gca,'XTickLabel','','YTickLabel','')
            title(filename(length(prefix)+1:end-(length(suffix))))
        end
    end
    saveas(gcf,[listname(1:end-5),'_',num2str(i),'.fig'])
    saveas(gcf,[listname(1:end-5),'_',num2str(i)],'pdf')
end

leftover_num=mod(filenum,100);
subplot_cols=floor(sqrt(leftover_num));
subplot_rows=ceil(leftover_num/subplot_cols);

left_edges=.1:.85/subplot_cols:(.95-.85/subplot_cols);
bottom_edges=(.95-.9/subplot_rows):-.9/subplot_rows:.5;
width=.8*.85/subplot_cols;
height=.8*.9/subplot_rows;

figure()
for j=1:leftover_num
    filename=char(filenames(floor(filenum/100)*100+j));
    data=load(filename);
    t=[1:length(data)]/600;
    subplot(subplot_rows,subplot_cols,j)
%     plot(t,data(:,4),':k',t,data(:,3))
    plot(t,data)
    axis('tight')
    set(gca,'XTickLabel','','YTickLabel','')
    title(filename(length(prefix)+1:end-(length(suffix))))
end
saveas(gcf,[listname(1:end-5),'_',num2str(floor(filenum/100)+1),'.fig'])