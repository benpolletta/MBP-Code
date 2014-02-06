function [MI_p_thresh,MI_z_thresh]=inv_entropy_colorplot(MI,MI_p_vals,MI_z_scores,p_threshold,z_threshold,filename,A_bands,P_bands,units)

[noamps,nophases]=size(MI);

% MI=triu(MI,1);
% MI_p_vals=triu(MI_p_vals,1);
% MI_z_scores=triu(MI_z_scores,1);

% MI=fliplr(triu(MI,1));
% MI_p_vals=fliplr(triu(MI_p_vals,1));
% P_bands=flipud(bands);
% A_bands=bands;

figure();

subplot(1,3,1)
colorplot(MI)
axis ij
title('Inverse Entropy for Phase-Amplitude Curve')

if nargin>8
    xlabel(['Phase-Modulating (',char(units),')']);
    ylabel(['Amplitude-Modulated (',char(units),')']);
else
    xlabel('Phase-Modulating');
    ylabel('Amplitude-Modulated');
end

if nargin>6
    for i=1:noamps
        A_labels{i}=num2str(A_bands(i,2));
        P_labels{i}=num2str(P_bands(i,2));
    end
    set(gca,'XTick',[1.5:(nophases+1.5)],'YTick',[1.5:(noamps+1.5)],'XTickLabel',P_labels,'YTickLabel',A_labels);
end

subplot(1,3,2)
colorplot(MI_p_vals)
axis ij
title('Inverse Entropy p-Value for Phase-Amplitude Curve')

if nargin>8
    xlabel(['Phase-Modulating (',char(units),')']);
    ylabel(['Amplitude-Modulated (',char(units),')']);
else
    xlabel('Phase-Modulating');
    ylabel('Amplitude-Modulated');
end

if nargin>6
    for i=1:noamps
        A_labels{i}=num2str(A_bands(i,2));
        P_labels{i}=num2str(P_bands(i,2));
    end
    set(gca,'XTick',[1.5:(nophases+1.5)],'YTick',[1.5:(noamps+1.5)],'XTickLabel',P_labels,'YTickLabel',A_labels);
end

subplot(1,3,3)
colorplot(MI_z_scores)
axis ij
title('Inverse Entropy z-Score for Phase-Amplitude Curve')

if nargin>8
    xlabel(['Phase-Modulating (',char(units),')']);
    ylabel(['Amplitude-Modulated (',char(units),')']);
else
    xlabel('Phase-Modulating');
    ylabel('Amplitude-Modulated');
end

if nargin>6
    for i=1:noamps
        A_labels{i}=num2str(A_bands(i,2));
        P_labels{i}=num2str(P_bands(i,2));
    end
    set(gca,'XTick',[1.5:(nophases+1.5)],'YTick',[1.5:(noamps+1.5)],'XTickLabel',P_labels,'YTickLabel',A_labels);
end

if nargin>5
    saveas(gcf,[filename,'_inv_entropy.fig']);
end

MI_p_thresh=MI;
MI_z_thresh=MI;

if p_threshold>0 & z_threshold>0
    
    p_threshold=p_threshold/nchoosek(nophases,2);
    MI_p_thresh(MI_p_vals<1-p_threshold)=0;
    
    z_threshold=z_threshold/nchoosek(nophases,2);
    MI_z_thresh(normcdf(MI_z_scores,0,1)<1-z_threshold)=0;

    figure();
    
    subplot(1,2,1)
    colorplot(MI_p_thresh)
    axis ij
    title(['Inverse Entropy for Phase-Amplitude Curves with Bootstrapped p-Value Above ',num2str(1-p_threshold)])

    if nargin>8
        xlabel(['Phase-Modulating (',char(units),')']);
        ylabel(['Amplitude-Modulated (',char(units),')']);
    else
        xlabel('Phase-Modulating');
        ylabel('Amplitude-Modulated');
    end

    if nargin>6
        for i=1:noamps
            A_labels{i}=num2str(A_bands(i,2));
            P_labels{i}=num2str(P_bands(i,2));
        end
        set(gca,'XTick',[1.5:(nophases+1.5)],'YTick',[1.5:(noamps+1.5)],'XTickLabel',P_labels,'YTickLabel',A_labels);
    end
    
    subplot(1,2,2)
    colorplot(MI_z_thresh)
    axis ij
    title(['Inverse Entropy for Phase-Amplitude Curves with Standard Normal p-Value Above ',num2str(1-z_threshold)])

    if nargin>8
        xlabel(['Phase-Modulating (',char(units),')']);
        ylabel(['Amplitude-Modulated (',char(units),')']);
    else
        xlabel('Phase-Modulating');
        ylabel('Amplitude-Modulated');
    end

    if nargin>6
        for i=1:noamps
            A_labels{i}=num2str(A_bands(i,2));
            P_labels{i}=num2str(P_bands(i,2));
        end
        set(gca,'XTick',[1.5:(nophases+1.5)],'YTick',[1.5:(noamps+1.5)],'XTickLabel',P_labels,'YTickLabel',A_labels);
    end

    if nargin>5
        saveas(gcf,[filename,'_inv_entropy_threshold.fig']);
    end
end