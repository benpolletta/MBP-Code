function chop_ends(datalist)

datalength=1800;
halflength=floor(datalength/2);

filenames=textread(datalist,'%s%*[^\n]');
filenum=length(filenames);

for f=1:filenum
   
    filename=char(filenames(f));
    
    data=load(filename);
    [r,c]=size(data);
    if c>r
        data=data';
        [r,c]=size(data);
    end
    
    dataformat=make_format(c,'f');
    
    data=data((1:datalength)+halflength,:);
    
    outfilename=[filename,'_chopped.txt'];
    
    fid_outfile=fopen(outfilename,'w');
    fprintf(fid_outfile,dataformat,data);
    fclose(fid_outfile);
    
end