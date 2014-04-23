function colorplot(M,x_label,y_label,no_ticks)

[r,c]=size(M);
M_ext=zeros(r+1,c+1);
M_ext(1:r,1:c)=M;
h=pcolor(M_ext);
set(h,'EdgeColor','none');
axis xy;
colorbar;

if nargin > 1
    
    if nargin < 4
        
        no_ticks = 5;
        
    end
        
    set(gca,'XTick',(1:floor(c/no_ticks):c)+.5,'YTick',(1:floor(r/no_ticks):r)+.5,'XTickLabel',round(100*x_label(1:floor(c/no_ticks):c))/100,'YTickLabel',round(100*y_label(1:floor(r/no_ticks):r))/100)
    
end