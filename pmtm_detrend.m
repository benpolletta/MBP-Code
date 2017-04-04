function varargout = pmtm_detrend(data, varargin)

    data = detrend(data);
    
    [varargout{1:nargout}] = pmtm(data, varargin{:});
    
end