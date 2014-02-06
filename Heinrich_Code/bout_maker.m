function bout_maker(subject_prefix,stage_suffix)

[epoch_nos_filename, epoch_nos_pathname] = uigetfile('*.txt','Choose file containing epoch numbers.');

epoch_nos = load([epoch_nos_pathname, epoch_nos_filename]);

[epoch_list_filename, epoch_list_pathname] = uigetfile('*.list','Choose list of epoch files.');

epoch_filenames = textread([epoch_list_pathname, epoch_list_filename],'%s');

jumps = find(diff(epoch_nos)-1 > 0);

bout_starts = [epoch_nos(1); epoch_nos(jumps+1)];
bout_ends = [epoch_nos(jumps); epoch_nos(end)];
bout_lengths = bout_ends-bout_starts+1;

bouts = [bout_starts bout_ends bout_lengths];

fid = fopen([epoch_list_filename(1:end-5),'_bouts.txt'], 'w');
fprintf(fid,'%d\t%d\t%d\n',bouts');
fclose(fid);

for i = 1:length(bouts)
    
    bout=[];
    
    for j = bout_starts(i):bout_ends(i)
        
        epoch = load([char(subject_prefix),'_epoch',num2str(j),char(stage_suffix)]);
       
        bout = [bout; epoch];
    
    end
    
    fid=fopen([subject_prefix,'_bout',num2str(i),'_',num2str(10*bout_lengths(i)),'s',stage_suffix],'w');
    fprintf(fid,'%f\n',bout);
    fclose(fid);
    
    t=[1:length(bout)]/600;
    plot(t, bout)
    title([subject_prefix,' Bout ',num2str(i),', Epochs ',num2str(bout_starts(i)),' - ',num2str(bout_ends(i))])
    xlabel('Time (s)')
    saveas(gcf,[subject_prefix,'_bout',num2str(i),'_',num2str(10*bout_lengths(i)),'s',stage_suffix(1:end-4),'.fig'])
    close(gcf)
    
end
    