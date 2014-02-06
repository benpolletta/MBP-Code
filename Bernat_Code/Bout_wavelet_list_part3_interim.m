function Bout_wavelet_list_part3_interim(data, no_amps, band_range, P_theta, P_bands, listname, filename, amp_title)

window_size=1501;
step_size=5;

fid=fopen([listname(1:end-5), '_MI/', filename(1:end-4),'_theta_', amp_title, '.txt'], 'w');

[A_bands, ~, A, ~]=filter_wavelet_Jan(data, 'fs', 1000, 'nobands', no_amps, 'bandrange', band_range);

A_bands=A_bands(:,2);

no_amp_bands=length(A_bands);
nophases=length(P_bands);

format=make_format(no_amps*nophases, 'f');

%no_windows=floor((data_length-window_size)/step_size);     
no_windows=1000;
Movie(no_windows) = struct('cdata',[],'colormap',[]);  
vidobj=VideoWriter([listname(1:end-5), '_MI/', filename(1:end-4),'_theta_', amp_title, '_movie.avi']);
open(vidobj);
% aviobj = avifile([listname(1:end-5), '_MI/', filename(1:end-4),'_theta_', amp_title, '_movie.avi'],'compression','None');

for k=1:no_windows

    P_temp=P_theta([1:window_size+1]+k*step_size,:);
    A_temp=A([1:window_size+1]+k*step_size,:);
    
    [~,M]=amp_v_phase_Jan(20,A_temp,P_temp);
    MI=inv_entropy_no_save(M);

    fft_inv_entropy_plotter_Jan(MI,filename,round(10*A_bands)/10,round(10*P_bands)/10,[],[],'Hz',0); %no save

%     h=gcf;
%     movegui(h);
    Movie(k)=getframe(gcf);
    writeVideo(vidobj,Movie(k));
%     aviobj = addframe(aviobj,Movie(k));
    close(gcf);

    MI=reshape(MI,1,no_amp_bands*nophases);
    fprintf(fid,format,MI);

end

axes('Position', [0 0 1 1]);
% movie(Movie, 1);
save([listname(1:end-5), '_MI/', filename(1:end-4),'_theta_', amp_title, '_movie.mat'],'Movie');
% aviobj=close(aviobj);
close(vidobj);

%movie2avi([listpath, listname, 'MI_movie'], 'compression', 'none');
