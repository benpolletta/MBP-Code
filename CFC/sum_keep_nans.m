function NS=sum_keep_nans(M,k);

if nargin>1
    nos_count=sum(~isnan(M),k);
    vals=nanmean(M,k);
else
    nos_count=sum(~isnan(M));
    vals=nanmean(M);
end

NS=nos_count.*vals;