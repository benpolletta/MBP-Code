function varargout = pmtm_plus(data, varargin)

    data = detrend(data);
    
    [varargout{1:nargout}] = pmtm(data, varargin{:});
    
end