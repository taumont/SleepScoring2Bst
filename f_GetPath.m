function p = f_GetPath(sDir)
% Convert a directory structure returned by dir() to cell array of full path,
% ignoring '.' and '..'

if length(sDir) > 1
    sDir = sDir(~(strcmp({sDir.name}, '.') | strcmp({sDir.name}, '..')));
    p = arrayfun(@(a) fullfile(a.folder,a.name),sDir,'UniformOutput',false);
else
    if strcmp(sDir.name,'.') || strcmp(sDir.name,'..')
        p = '';
    else
        p = fullfile(sDir.folder,sDir.name);
    end
end

end
