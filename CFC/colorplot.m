function colorplot(M)

[r,c]=size(M);
M_ext=zeros(r+1,c+1);
M_ext(1:r,1:c)=M;
h=pcolor(M_ext);
set(h,'EdgeColor','none');
axis ij;
colorbar;