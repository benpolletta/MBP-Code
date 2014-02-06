function reflect_ends(datalist)

filenames=textread(datalist,'%s%*[^\n]');
filenum=length(filenames);

for f=1:filenum
   
    filename=char(filenames(f));
    
    data=textread(filename,'%f%*[^\n]');
    [r,c]=size(data);
    if c~=1
        if r==1
            data=data';
        else
            display('Data files must contain data in vector format.')
            return
        end
    end
    
    datalength=length(data);
    halflength=floor(datalength/2);
    
    reflected=zeros(datalength+2*halflength,1);
    reflected(1:halflength)=flipud(data(1:halflength));
    reflected(halflength+(1:datalength))=data;
    reflected(halflength+datalength+(1:halflength))=flipud(data((end-halflength+1):end));
    
    outfilename=[filename(1:end-4),'_reflected.txt'];
    
    fid_outfile=fopen(outfilename,'w');
    fprintf(fid_outfile,'%f\n',reflected);
    fclose(fid_outfile);
    
end