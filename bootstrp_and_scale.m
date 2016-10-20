

function data_bs = bootstrp_and_scale(varargin)
        % Generates bootstrap distribution from input
        % Scales this output so that the std of this distribution will be
        % the STD and not the STE! (assuming myfunc is taking a mean)
        % Note: Assumes input samples are in ROWS, like original bootstrp code
        % Output samples are also as rows
        
        N=varargin{1};
        myfunc=varargin{2};
        mydata=varargin(3:end);
        
        %mydata_trans = cellfunu(@(x) permute(x,[2,1]),mydata);

        data_bs = bootstrp(N,myfunc,mydata{:});

        
        data_bs = (data_bs - repmat(mean(data_bs,1),[N, 1]))*sqrt(N) + repmat(myfunc(mydata{1}),[N, 1]);     % Initially, std of data_bs is actually the ste of the mean; scale this back up so we can counteract later
        %data_bs = (data_bs - repmat(mean(data_bs,1),[N, 1]))*sqrt(N) + repmat(mean(data_bs,1),[N, 1]);     % Initially, std of data_bs is actually the ste of the mean; scale this back up so we can counteract later


end