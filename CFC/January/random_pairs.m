function [amp_indices,phase_indices]=random_pairs(in_noshufs,filenum)

if isempty(in_noshufs)
    
    amp_indices=randperm(filenum);
    phase_indices=randperm(filenum);
    
elseif 2*nchoosek(filenum,2)<in_noshufs
    
    noshufs=2*nchoosek(filenum,2);
    
    display(['There are not enough data files to create ',num2str(in_noshufs),' independent shuffles; there are only ',num2str(filenum),' data files, so ',num2str(noshufs),' shuffles will be created instead.'])
    
    shuf_indices=nchoosek(1:filenum,2);
    shuf_indices=[shuf_indices; fliplr(shuf_indices)];
    
    amp_indices=shuf_indices(:,2);
    phase_indices=shuf_indices(:,1);
    
else
    
    noshufs=in_noshufs;
    
    pairs=nchoosek(1:filenum,2);
    pairs=[pairs; fliplr(pairs)];
    choices=randperm(length(pairs));
    choices=choices(1:noshufs);
    shuf_indices=pairs(choices,:);
    
    %             shuf_indices=ceil(rand(2,noshufs)*filenum);
    %             shuf_indices(:,diff(shuf_indices)==0)=[];
    %
    %             while length(shuf_indices)<noshufs
    %
    %                 shuf_indices(:,end+1:noshufs)=ceil(rand(2,noshufs-length(shuf_indices))*filenum);
    %                 shuf_indices(:,diff(shuf_indices)==0)=[];
    %
    %             end
    
    amp_indices=shuf_indices(:,2);
    phase_indices=shuf_indices(:,1);
    
end