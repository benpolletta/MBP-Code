function chan2(start_epoch,stop_epoch,prefix,suffix,listname)

fid_list=fopen(char(listname),'w');

for i=start_epoch:stop_epoch
    
    filename=[char(prefix),num2str(i),char(suffix)];
    
    if exist(filename)~=0
    
        data=load(filename);
        chan2=data(:,3);
    
        filename=[filename(1:end-4),'_chan2.txt'];
        fid=fopen(filename,'w');
        fprintf(fid,'%f\n',chan2);
        fclose(fid);

        fprintf(fid_list,'%s\n',filename);
        
        clear data
        
    end
    
end

fclose(fid_list);