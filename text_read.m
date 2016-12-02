function [varargout] = text_read(filename,format)

fid = fopen(filename,'r');

text = textscan(fid,format);

fclose(fid);

for n = 1:nargout
   
    varargout{n} = char(text{n});
    
end

if nargout~=length(text)
    
    display('Unreturned variables have been read.')
    
end