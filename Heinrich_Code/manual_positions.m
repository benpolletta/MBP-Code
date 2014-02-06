function Pos=manual_positions(subplot_rows,subplot_cols)

Pos=zeros(subplot_rows,4,subplot_cols);

left_edges=.1:.85/subplot_cols:(.95-.85/subplot_cols);
bottom_edges=(.95-.9/subplot_rows):-.9/subplot_rows:.05;
width=.8*.85/subplot_cols;
height=.8*.9/subplot_rows;

for i=1:subplot_rows
    for j=1:subplot_cols
        Pos(i,:,j)=[left_edges(j) bottom_edges(i) width height];
    end
end