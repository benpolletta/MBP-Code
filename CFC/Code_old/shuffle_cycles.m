function [Data_shuffles]=shuffle_cycles(data,cycle_bounds,n)
% function [Cycle_shuffles,Data_shuffles]=shuffle_cycles(data,cycle_bounds,n)

[r,c]=size(data);
Shuffles=zeros(r,c,n);

for i=1:length(cycle_bounds)
    current_bounds=cycle_bounds{i};
    if ~isempty(current_bounds)
        current_bounds(current_bounds(:,1)>1,1)=current_bounds(current_bounds(:,1)>1,1)+1;
    %     cycle_shuf_mat=[];
        for j=1:n
            cycle_bounds_shuf=shuffle(current_bounds);
    %         cycle_shuf_mat(:,j)=reshape(cycle_bounds_shuf,2*length(cycle_bounds_shuf),1);
            cycle_lengths_shuf=diff(cycle_bounds_shuf,1,2)+1;
            current_length=0;
            for k=1:length(cycle_lengths_shuf)
                data_shuf(current_length+1:current_length+cycle_lengths_shuf(k))=data(cycle_bounds_shuf(k,1):cycle_bounds_shuf(k,2),i);
                current_length=current_length+cycle_lengths_shuf(k);
            end
            Data_shuffles(:,i,j)=data_shuf;
        end
    %     Cycle_shuffles{i}=cycle_shuf_mat;
    else
        Data_shuffles(:,i,j)=data(:,i);
    end
end            