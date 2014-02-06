function wavelet_mouse_eeg_HAP(sampling_freq,challenge_list)

close('all')

listnames=textread(challenge_list,'%s%*[^\n]');
no_challenges=length(listnames);

bands_lo=1:.25:12;
bands_hi=20:5:200;

present_dir=pwd;

for j=1:no_challenges
    
    listname=char(listnames(j));
    filenames=textread(listname,'%s%*[^\n]');
    filenum=length(filenames);
    
    dirname=listname(1:end-5);
    mkdir (dirname)
    
    parfor k=1:filenum

        filename=char(filenames(k));

        CFC_Jan_wav_HAP(filename(1:end),sampling_freq,bands_lo,bands_hi,dirname);
        
    end
    
    fclose('all');
    
    cd (present_dir)

end