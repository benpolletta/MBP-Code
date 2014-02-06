function IE_movie(data, A_bands, P_bands)

if isempty(data)
    
    [listname,listpath]=uigetfile('','Choose an MI time series to make a video from.');
    
    data=load([listpath,listname]);
    
    filename=listname(1:end-4);
    
end

noamps=length(A_bands);
nophases=length(P_bands);

[no_windows,~]=size(data);
max_MI=max(max(data));

% Movie(no_windows)=struct('cdata',[],'colormap',[]);  
vidobj=VideoWriter([filename,'_movie.avi']);
open(vidobj);
% aviobj = avifile([listname(1:end-5), '_MI/', filename(1:end-4),'_theta_', amp_title, '_movie.avi'],'compression','None');

for k=1:no_windows

    MI=reshape(data(k,:),noamps,nophases);
    
%     figure('visible','off');
    fft_inv_entropy_plotter_Jan(MI,filename,round(10*A_bands)/10,round(10*P_bands)/10,[],[],'Hz',0); %no save
    caxis([0 max_MI]);
    
%     Movie(k)=getframe(gcf);
    writeVideo(vidobj,getframe(gcf));
%     aviobj = addframe(aviobj,Movie(k));
    close(gcf);

end

% axes('Position', [0 0 1 1]);
% movie(Movie, 1);
% save([filename,'_movie.mat'],'Movie');
% aviobj=close(aviobj);
close(vidobj);
