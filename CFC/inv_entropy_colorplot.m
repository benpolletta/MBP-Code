function [MI_p_thresh,MI_z_thresh,MI_log_z_thresh]=inv_entropy_colorplot(MI,MI_p_vals,MI_z_pvals,MI_log_z_pvals,threshold,filename,A_bands,P_bands,units)

% Last four arguments are optional, giving information for axes labels. If threshold=0, colorplots MI,
% MI_p_vals, MI_z_pvals, and MI_log_z_pvals in the same figure. If
% threshold>0, thresholds MI according to MI_p_vals, MI_z_pvals, and
% MI_log_z_pvals, and colorplots the thresholded MI. Also colorplots
% MI_pvals, MI_z_pvals, and MI_log_z_pvals with color axes set to
% [threshold, max. p-val].

[noamps,nophases]=size(MI);

% MI=triu(MI,1);
% MI_p_vals=triu(MI_p_vals,1);
% MI_z_scores=triu(MI_z_scores,1);

% MI=fliplr(triu(MI,1));
% MI_p_vals=fliplr(triu(MI_p_vals,1));
% P_bands=flipud(bands);
% A_bands=bands;

figure();

subplot(2,2,1)
colorplot(MI)
axis ij
title('Modulation Index for Phase-Amplitude Curve')

if nargin>7
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

subplot(2,2,2)
colorplot(MI_p_vals)
axis ij
title('Empirical p-Value for MI')

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

subplot(2,2,3)
colorplot(MI_z_pvals)
axis ij
title('Normal p-Value for MI')

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

subplot(2,2,4)
colorplot(MI_log_z_pvals)
axis ij
title('Lognormal p-Value for MI')

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

if nargin>6
    saveas(gcf,[filename,'_inv_entropy.fig']);
end

MI_p_thresh=MI;
MI_z_thresh=MI;
MI_log_z_thresh=MI;

if threshold>0
    
    threshold=threshold/nchoosek(nophases,2);
    MI_p_thresh(MI_p_vals<1-threshold)=0;
    MI_z_thresh(MI_z_pvals<1-threshold)=0;
    MI_log_z_thresh(MI_log_z_pvals<1-threshold)=0;
    
    figure();
    
    subplot(2,3,1)
    colorplot(MI_p_thresh)
    axis ij
    title(['MI with Empirical p-Value Above ',num2str(1-threshold)])

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
    
    subplot(2,3,2)
    colorplot(MI_z_thresh)
    axis ij
    title(['MI with Normal p-Value Above ',num2str(1-threshold)])

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

    subplot(2,3,3)
    colorplot(MI_log_z_thresh)
    axis ij
    title(['MI with Lognormal p-Value Above ',num2str(1-threshold)])

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

    subplot(2,3,4)
    colorplot(max(0,MI_p_vals-threshold))
    axis ij
    title(['Amt. of Empirical p-Value Above ',num2str(1-threshold)])

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
    
    subplot(2,3,5)
    colorplot(max(0,MI_z_pvals-threshold))
    axis ij
    title(['Amt. of Normal p-Value Above Threshold'])

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
    
    subplot(2,3,6)
    colorplot(max(0,MI_log_z_pvals-threshold))
    axis ij
    title(['Amt. of Lognormal p-Value Above Threshold'])

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
    
    if nargin>6
        saveas(gcf,[filename,'_inv_entropy_threshold.fig']);
    end
end