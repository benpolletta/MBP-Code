[listname,listpath]=uigetfile('*list','Choose list of files for epoch length test.');

filenames=textread([listpath,listname],'%s');
filenum=length(filenames);

amt_data=6000*filenum;
all_data=zeros(amt_data,1);

for i=1:filenum
    current_data=load(char(filenames(i)));
    all_data((i-1)*6000+1:i*6000)=current_data;
end

epoch_lengths=[.5 1 2 3 5 10 20 30 60];

cd Epoch_Length_Test

fid2=fopen([listname(1:end-5),'_lists.list'],'w');

for j=1:length(epoch_lengths)
    
    clear data_vec
    epoch_length=epoch_lengths(j)*600;
    no_epochs=floor(amt_data/epoch_length);
    
    epoch_listname=[listname(1:end-5),'_',num2str(epoch_lengths(j)),'s_epochs.list'];
    fprintf(fid2,'%s\n',epoch_listname);
    fid=fopen(epoch_listname,'w');
    
    for k=1:no_epochs
        
        epoch_name=[listname(1:end-5),'_',num2str(epoch_lengths(j)),'s_epoch_',num2str(k),'.txt'];
        fprintf(fid,'%s\n',epoch_name);
        fid1=fopen(epoch_name,'w');
        
        fprintf(fid1,'%f\n',all_data((k-1)*epoch_length+1:k*epoch_length));
        fclose(fid1);
    
    end
    
    epoch_name=[listname(1:end-5),'_',num2str(epoch_lengths(j)),'s_epoch_',num2str(no_epochs+1),'.txt'];
    fprintf(fid,'%s\n',epoch_name);
    fid1=fopen(epoch_name,'w');
    
    fprintf(fid1,'%f\n',all_data(no_epochs*epoch_length+1:end));
    fclose(fid1);

end
    
largest_epoch_list=[listname(1:end-5),'_',num2str(filenum*10),'s_epoch.list'];
fprintf(fid2,'%s\n',largest_epoch_list);
fid3=fopen(largest_epoch_list,'w');
largest_epoch_name=[listname(1:end-5),'_',num2str(filenum*10),'s_epoch.txt'];
fprintf(fid3,'%s\n',largest_epoch_name);
fid4=fopen(largest_epoch_name,'w');
fprintf(fid4,'%f\n',all_data);

fclose('all')

cd ..