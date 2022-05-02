function export_to_excel(varargin)
    
    t= table(varargin{1},varargin{2:nargin-2},'VariableNames', varargin{nargin});
    filename = string(varargin{nargin-1})+".xlsx";
    writetable(t,filename,'Sheet',1);
end