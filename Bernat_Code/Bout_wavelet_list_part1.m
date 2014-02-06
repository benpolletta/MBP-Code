function Bout_wavelet_list_part1

% listpath=['C:\Bernats Data', subj, '_', drug, '_individual_channels'];
% listname=[subj, '_', drug, '_channels.list'];
% Pass list as an argument (listname), and then use:

[listname,listpath]=uigetfile('*.list','Choose a list to run phasic REM analysis.');

present_dir=pwd;

cd (listpath)

filenames=textread(listname,'%s%*[^\n]');
mkdir(listpath, listname(1:end-5));

% myFolder = ['C:\Bernats Data\', subj, '_chan', num2str(chan), '_R', '\', drug, '_bouts'];

% filePattern2 = fullfile(myFolder,[subj, '_', 'chan', num2str(chan), '_', drug, '_', 'Bout_*_R', '.txt']);
% Bouts = dir(filePattern2);
% prefix=[subj, '_', drug, '_chan', num2str(chan), '_bout_'];
% suffix='.list';

%Bout_number=Bouts(length(prefix)+1:end-length(suffix));
  
total_bout_length=0;

sampling_freq=1000;
signal_length=16384;

max_amp=zeros(signal_length, 1);
freq_for_max=zeros(signal_length, 1);



for i=1:length(filenames)
    files =char( filenames(i));
    loader=textread(files);

    Bout_wavelet_list_part1_interim(loader, listpath, listname, files);
    
    %         % Computing amplitude vs. phase curves.
    %
    %         [bincenters,M]=amp_v_phase_Jan(nobins,A_gamma,P_theta);
    %
    %         % Finding inverse entropy measure for each pair of modes.
    %
    %         MI=inv_entropy_no_save(M);

    % MI=reshape(MI,1,noamps*nophases);
    %
    % format=make_format(noamps*nophases,'f');
    % fprintf(fid,format,MI);

    fclose('all')

end

cd (present_dir)

end

