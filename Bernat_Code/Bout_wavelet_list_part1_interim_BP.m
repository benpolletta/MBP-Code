function Bout_wavelet_list_part1_interim(loader, listpath, listname, files)

%Takes each bout and does wavelets over 4-10Hz, 50 bands.

[bands,H,A,P]=filter_wavelet_Jan(loader,'fs', 1000, 'nobands', 61, 'bandrange', [4 10]);

high_theta_range=bands(:,2);
[max_amp_theta,index_for_max_freq_theta]=max(A');
freq_for_max_theta=high_theta_range(index_for_max_freq_theta);

save([listpath, listname(1:end-5), '\', files(1:end-4), '_HAP_theta'], 'H', 'A', 'P', 'max_amp_theta', 'freq_for_max_theta');

%Takes each bout and does wavelets over 35-60 Hz, 80 bands.

[bands,H,A,P]=filter_wavelet_Jan(loader,'fs', 1000, 'nobands', 101, 'bandrange', [35 60], 'time_resol', 200*ones(101,1));

low_gamma_range=bands(:,2);
[max_amp_low_gamma,index_for_max_freq_low_gamma]=max(A');
freq_for_max_low_gamma=low_gamma_range(index_for_max_freq_low_gamma);


save([listpath, listname(1:end-5), '\', files(1:end-4), '_HAP_low_gamma'], 'H', 'A', 'P', 'max_amp_low_gamma', 'freq_for_max_low_gamma');

%Takes each bout and does wavelests over 60-90 Hz, 80 bands.

[bands,H,A,P]=filter_wavelet_Jan(loader, 'fs', 1000, 'nobands', 121, 'bandrange', [60 90], 'time_resol', 200*ones(121,1));

medium_gamma_range=bands(:,2);
[max_amp_medium_gamma,index_for_max_freq_medium_gamma]=max(A');
freq_for_max_medium_gamma=medium_gamma_range(index_for_max_freq_medium_gamma);


save([listpath, listname(1:end-5), '\', files(1:end-4), '_HAP_medium_gamma'], 'H', 'A', 'P', 'max_amp_medium_gamma', 'freq_for_max_medium_gamma');

%Takes each bout and does wavelets over 90-110 Hz, 80 bands.

[bands,H,A,P]=filter_wavelet_Jan(loader,'fs', 1000, 'nobands', 81, 'bandrange', [90 110], 'time_resol', 200*ones(81,1));

high_gamma_range=bands(:,2);
[max_amp_high_gamma,index_for_max_freq_high_gamma]=max(A');
freq_for_max_high_gamma=high_gamma_range(index_for_max_freq_high_gamma);

save([listpath, listname(1:end-5), '\',  files(1:end-4), '_HAP_high_gamma'], 'H', 'A', 'P', 'max_amp_high_gamma', 'freq_for_max_high_gamma');

[bands,H,A,P]=filter_wavelet_Jan(loader,'fs', 1000, 'nobands', 141, 'bandrange', [110 180], 'time_resol', 200*ones(141,1));

HFO_range=bands(:,2);
[max_amp_HFO,index_for_max_freq_HFO]=max(A');
freq_for_max_HFO=HFO_range(index_for_max_freq_HFO);

save([listpath, listname(1:end-5), '\',  files(1:end-4), '_HAP_HFO'], 'H', 'A', 'P', 'max_amp_HFO', 'freq_for_max_HFO');
