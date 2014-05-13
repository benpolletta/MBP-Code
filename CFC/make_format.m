function [format]=make_format(no_entries,entry_format)

format=[];
for i=1:no_entries
    format=[format,'%',entry_format,'\t'];
end
format=[format(1:end-1),'n'];