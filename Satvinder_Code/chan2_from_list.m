function chan2_from_list(listname)

listname=char(listname);

outlistname=[listname(1:end-5),'_chan2.list'];
fid_list=fopen(outlistname,'w');

filenames=textread(listname,'%s');
filenum=length(filenames);

for i=1:filenum
    
    filename=char(filenames(i));
    
    data=load(filename);
    chan2=data(:,3);
    
    filename=[filename(1:end-4),'_chan2.txt'];
    fid=fopen(filename,'w');
    fprintf(fid,'%f\n',chan2);
    fclose(fid);
    
    fprintf(fid_list,'%s\n',filename);
    
    clear data
    
end

fclose(fid_list);