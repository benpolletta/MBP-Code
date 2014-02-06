function list_2_commands(dirname)

[filename,pathname]=uigetfile('*list','Choose list of lists to move.');

lists=textread([pathname,filename],'%s');
listnum=length(lists);

fid_commands=fopen([filename(1:end-5),'_commands.sh'],'w');
fprintf(fid_commands,'%s\n',['mkdir ',dirname]);

for i=1:listnum
    
    list=textread([pathname,char(lists(i))],'%s');
    
    for j=1:length(list)
    
        fprintf(fid_commands,'%s\n',['cp ',char(list(j)),' ',dirname]);
    
    end
end

fclose(fid_commands)