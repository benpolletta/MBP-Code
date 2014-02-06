function Bout_wavelet_list_part1_parfor_BP

sampling_freq=1000;

no_bands=[61 101 121 81 141];
no_freqs=length(no_bands);
band_ranges=[4 10; 35 60; 60 90; 90 110; 110 180];
freq_titles={'theta','low_gamma','medium_gamma','high_gamma', 'HFO'};
time_resol{1}=[];
for f=2:no_freqs
    time_resol{f}=200*ones(no_bands(f),1);
end

[listname,listpath]=uigetfile('*bouts.list','Choose a bout list to run REM power & frequency analysis.');
filenames=textread([listpath, listname],'%s%*[^\n]');
dirname=[listpath, '/', listname(1:end-5), '_POW'];
mkdir(dirname);

parfor i=1:length(filenames)

    filename=char(filenames(i));
    data=load(filename);
        
    for f=1:no_freqs
        
        max_freq(data,sampling_freq,filename,dirname,nobands(f),band_ranges(f,:),time_resol{f})

    end
    
end