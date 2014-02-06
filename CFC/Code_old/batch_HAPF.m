function batch_HAPF(datalist,sampling_freq,min_cycles,units,dirname)

mkdir (dirname);

filenames=textread(datalist,'%s%*[^\n]');
filenum=length(filenames);

for i=1:filenum
    
    dataname=char(filenames(i));
    dataname=dataname(1:end-8);
    
    hhtdata=load(char(filenames(i)));

    [signal_length,nomodes]=size(hhtdata);
    if signal_length<nomodes
        hhtdata=hhtdata';
    end

    % Excluding modes with very low cycle numbers, calculating Hilbert transform, 
    % amplitudes, phases, frequencies, and cycles, and saving all but the cycles.

    [H,A,P,F,cycle_bounds,bands]=makeHAPF(hhtdata,sampling_freq,min_cycles,dataname,char(dirname));

    % Plotting signals, amplitudes, and frequencies.
    
    HAF_plotter(H,A,F,bands,sampling_freq,units,dataname,char(dirname))
    
end