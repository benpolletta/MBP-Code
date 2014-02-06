[listname,listpath]=uigetfile('*list','Choose list of data files');

filenames=textread([listpath,listname],'%s');
filenum=length(filenames);

for i=1:floor(filenum/100)
    figure()
    for j=1:100
        filename=char(filenames((i-1)*100+j));
        data=load(filename);
        t=[1:length(data)]/600;
        subplot(10,10,j)
        plot(t,data,'k')
        set(gca,'XTickLabel','','YTickLabel','')
        title(filename)
    end
    saveas(gcf,[listname(1:end-5),'_',num2str(i),'.fig'])
end

leftover_num=mod(filenum,100);
subplot_cols=floor(sqrt(leftover_num));
subplot_rows=ceil(leftover_num/subplot_cols);

figure()
for j=1:leftover_num
    filename=char(filenames(floor(filenum/100)*100+j));
    data=load(filename);
    t=[1:length(data)]/600;
    subplot(subplot_rows,subplot_cols,j)
    plot(t,data,'k')
    set(gca,'XTickLabel','','YTickLabel','')
    title(filename)
end
saveas(gcf,[listname(1:end-5),'_',num2str(floor(filenum/100)+1),'.fig'])