function [bands, H,A,P]= Bout_wavelet_list_part2

% listpath=['C:\Bernats Data', subj, '_', drug, '_individual_channels'];
% listname=[subj, '_', drug, '_channels.list'];
% Pass list as an argument (listname), and then use:

[listname,listpath]=uigetfile('*.list','Choose a bout list to run phasic REM analysis.');
filenames=textread([listpath, listname],'%s%*[^\n]');
mkdir(listpath, listname(1:end-5));

% myFolder = ['C:\Bernats Data\', subj, '_chan', num2str(chan), '_R', '\', drug, '_bouts'];

% filePattern2 = fullfile(myFolder,[subj, '_', 'chan', num2str(chan), '_', drug, '_', 'Bout_*_R', '.txt']);
% Bouts = dir(filePattern2);
% prefix=[subj, '_', drug, '_chan', num2str(chan), '_bout_'];
% suffix='.list';

%Bout_number=Bouts(length(prefix)+1:end-length(suffix));
  
total_bout_length=0;

for i=1:length(filenames)
    
    filename = char(filenames(i));
    
    loader=textread(filename);
    
    total_bout_length=length(loader)+total_bout_length;
    
end

sampling_freq=1000;
signal_length=16384;

all_max_amp=zeros(total_bout_length, 1);
all_freq=zeros(total_bout_length, 1);
length_previous_bouts=0;

for i=1:length(filenames)
    
    filename =char( filenames(i));
   
    load ([listpath, listname(1:end-5), '\', filename(1:end-4), '_HAP_theta'], 'H', 'A', 'P', 'max_amp_theta', 'freq_for_max_theta');
    
    all_max_amp_theta(length_previous_bouts+1:length(loader)+length_previous_bouts)=max_amp_theta;

    all_freq_theta(length_previous_bouts+1:length(loader)+length_previous_bouts)=freq_for_max_theta;
    
    %Takes each bout and does wavelets over 35-60 Hz, 80 bands.

    load([listpath, listname(1:end-5), '\', filename(1:end-4), '_HAP_low_gamma'], 'H', 'A', 'P', 'max_amp_low_gamma', 'freq_for_max_low_gamma');
    all_max_amp_low_gamma(length_previous_bouts+1:length(loader)+length_previous_bouts)=max_amp_low_gamma;

    all_freq_low_gamma(length_previous_bouts+1:length(loader)+length_previous_bouts)=freq_for_max_low_gamma;

    

    %Takes each bout and does wavelets over 60-90 Hz, 80 bands.

   load([listpath, listname(1:end-5), '\', filename(1:end-4), '_HAP_medium_gamma'], 'H', 'A', 'P', 'max_amp_medium_gamma', 'freq_for_max_medium_gamma');
    all_max_amp_medium_gamma(length_previous_bouts+1:length(loader)+length_previous_bouts)=max_amp_medium_gamma;

    all_freq_medium_gamma(length_previous_bouts+1:length(loader)+length_previous_bouts)=freq_for_max_medium_gamma;

    

    %Takes each bout and does wavelets over 90-110 Hz, 80 bands.

    load([listpath, listname(1:end-5), '\',  filename(1:end-4), '_HAP_high_gamma'], 'H', 'A', 'P', 'max_amp_high_gamma', 'freq_for_max_high_gamma');
    all_max_amp_high_gamma(length_previous_bouts+1:length(loader)+length_previous_bouts)=max_amp_high_gamma;

    all_freq_high_gamma(length_previous_bouts+1:length(loader)+length_previous_bouts)=freq_for_max_high_gamma;

    

    load([listpath, listname(1:end-5), '\',  filename(1:end-4), '_HAP_HFO'], 'H', 'A', 'P', 'max_amp_HFO', 'freq_for_max_HFO');
    all_max_amp_HFO(length_previous_bouts+1:length(loader)+length_previous_bouts)=max_amp_HFO;

    all_freq_HFO(length_previous_bouts+1:length(loader)+length_previous_bouts)=freq_for_max_HFO;

    

    length_previous_bouts=length(loader)+length_previous_bouts;

        
end
% save('All', 'all_max_amp_theta', 'all_freq_theta')
save([listpath, listname(1:end-5), '\',  filename(1:end-4), '_All'], 'all_max_amp_low_gamma', 'all_max_amp_medium_gamma', 'all_max_amp_high_gamma', 'all_freq_theta', 'all_freq_low_gamma', 'all_freq_medium_gamma', 'all_freq_high_gamma', 'all_max_amp_HFO', 'all_freq_HFO');



%Takes each bout and extracts the maximum power and the frequency for the
%maximum power, for each time point.


%Plots a histogram for the vectors containing max. power and max. power
%frequency for each bout. 


% hist(max_amp, 50);
% figure()
% hist(freq_for_max, 50);
% figure()
% hist(all_max_amp, 50);
% figure()
% hist(all_freq, 50);
