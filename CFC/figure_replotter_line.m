function [X_all,Y_all]=figure_replotter_line(datalength,numbers,rows,cols,labels,x_lims)

no_figs=length(numbers);

X_all=nan(datalength,rows*cols);
Y_all=nan(datalength,rows*cols);

for i=1:no_figs
    
    figure(numbers(i))
    axxes=findall(gcf,'Type','axes');
    Chilluns=get(axxes(end),'Children');
%     X=cell2mat(get(Chilluns,'XData'));
%     Y=cell2mat(get(Chilluns,'YData'));
    X=get(Chilluns,'XData');
    Y=get(Chilluns,'YData');
    
    if iscell(X)
        
        X=cell2mat(X(2));
        
    end
    
    if iscell(Y)

        Y=cell2mat(Y(2));

    end
    
    X_all(1:length(X),i)=X(1,:)';
    Y_all(1:length(Y),i)=Y(1,:)';
    
end

if ~isempty(x_lims)

    indices=find(X_all(:,1)<x_lims(2) & X_all(:,1)>x_lims(1));
    
    X_all=X_all(indices,:);
    Y_all=Y_all(indices,:);
    
end

max_X=max(max(X_all));
min_X=min(min(X_all));
max_Y=max(max(Y_all));
min_Y=min(min(Y_all));

% bullshit_stupid_problem_indices=[1:4,6:12];
% 
% max_X=max(max(X_all(:,bullshit_stupid_problem_indices)));
% min_X=min(min(X_all(:,bullshit_stupid_problem_indices)));
% max_Y=max(max(Y_all(:,bullshit_stupid_problem_indices)));
% min_Y=min(min(Y_all(:,bullshit_stupid_problem_indices)));

figure()

for i=1:no_figs
    
    subplot(rows,cols,i)
    semilogy(X_all(:,i),Y_all(:,i))
    xlim([min_X max_X])
    ylim([min_Y max_Y])
    title(char(labels(i)))
    
    if mod(i,cols)==1
        ylabel('Power')
    end
    
    if ceil(i/cols)==rows
        xlabel('Freq. (Hz)')
    end
    
end
    
    