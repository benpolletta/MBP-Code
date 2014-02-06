[listname,listpath]=uigetfile('*list','Choose list of data files');

filenames=textread([listpath,listname],'%s');
filenum=length(filenames);

for i=1:filenum
    filename=char(filenames(i));
    data=load(filename);
    filename=filename(1:end-4);
    
    data_reflected=[fliplr(data(1:5*600)); data; flipud(data(5*600+1:end))];
   
    fid=fopen([filename,'_reflected_ends.txt'],'w');
    fprintf(fid,'%f\n',data_reflected);
    fclose(fid);
end