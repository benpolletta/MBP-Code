[filename,pathname]=uigetfile('*bad_epochs.list','Choose file containing bad epoch numbers');

bad_epochs=load([pathname,filename]);
fid_commands=fopen([filename(1:end-4),'_commands.sh'],'w');
fprintf(fid_commands,'%s\n','mkdir No_Good');

for i=1:length(bad_epochs)
    
    fprintf(fid_commands,'%s\n',['mv *epoch',num2str(bad_epochs(i)),'_* No_Good']);
    
end

fclose(fid_commands)