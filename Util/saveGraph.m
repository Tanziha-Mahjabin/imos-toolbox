function return_types = saveGraph( ax )
%SAVEGRAPH Saves the given axis to an image file. Prompts the user to select 
% the location and file name.
%
% Inputs:
%   ax  - The axis to save.
%
% Author: Paul McCarthy <paul.mccarthy@csiro.au>
%

%
% Copyright (c) 2009, eMarine Information Infrastructure (eMII) and Integrated 
% Marine Observing System (IMOS).
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are met:
% 
%     * Redistributions of source code must retain the above copyright notice, 
%       this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in the 
%       documentation and/or other materials provided with the distribution.
%     * Neither the name of the eMII/IMOS nor the names of its contributors 
%       may be used to endorse or promote products derived from this software 
%       without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.
%

% supported export types and corresponding print function switches
fileTypes     = {'*.png'; '*.jpg' ; '*.bmp'   ; '*.pdf'};
printSwitches = {'-dpng'; '-djpeg'; '-dbmp16m'; '-dpdf'};


dateFmt = readToolboxProperty('toolbox.timeFormat');

try
  noPrompt = eval(readToolboxProperty('saveGraph.noPrompt'));
catch e
  noPrompt = false;
end

try 
  exportDir = readToolboxProperty('saveGraph.exportDir');
  if ~exist(exportDir, 'dir'), error(''); end
catch e
  exportDir = '.';
end

try
  imgType = ['*.' readToolboxProperty('saveGraph.imgType')];
  if ~ismember(imgType, fileTypes), error(''); end
  imgType = find(strcmp(imgType, fileTypes));
catch e
  imgType = 1;
end

fileName = ['graph_' datestr(now, dateFmt) '.' fileTypes{imgType}(3:end)];

if ~noPrompt
  
  while true

    % prompt user to select file type, name, save location
    [fileName exportDir imgType] = ...
      uiputfile(fileTypes, 'Save Graph', exportDir);

    % user cancelled dialog
    if fileName == 0, return; end

    [p name ext v] = fileparts(fileName);

    % Stupid matlab. The uiputfile function automatically adds an 'All Files' 
    % option to the list of file types. What purpose could this possibly 
    % serve? It's a fucking save dialog. I hate matlab. Anyway, if the user 
    % selects this option, we need to figure out if the user has provided a 
    % file extension, and if it is a supported type. I really despise matlab, 
    % and want it to die.
    if imgType > length(fileTypes)

      % if user hasn't provided an extension, just use the default
      if isempty(ext), imgType = 1;

      % if user has provided an unknown type, show an error, reprompt
      elseif ~ismember(['*' ext], fileTypes)
        
        e = errordlg(...
          'Please provide a file type', 'Unknown file type', 'modal');
        uiwait(e);
        
        continue;
      
      % otherwise extract the extension
      else imgType = find(strcmp(['*' ext], fileTypes));
      end
    end
    
    % if user hasn't provided the correct extension, add it
    if isempty(ext), fileName = [name '.' fileTypes{imgType}(3:end)];
    
    % if user has provided a different 
    % extension, append the correct extension
    elseif ~strcmp(['*' ext], fileTypes{imgType})
      
      fileName = [fileName '.' fileTypes{imgType}(3:end)];
    end
    
    % update toolbox properties for next time
    writeToolboxProperty('saveGraph.exportDir', exportDir);
    writeToolboxProperty('saveGraph.imgType',   fileTypes{imgType}(3:end));
    
    break;
  end
end

% Matlab can't save individual axes - it is only able to save complete
% figures. What we are doing, then, is copying the provided axis over to a 
% new, invisible figure, and saving that figure.
saveFig = figure('Visible', 'off');
copyobj(ax, saveFig);
print(saveFig, printSwitches{imgType}, fullfile(exportDir, fileName));
delete(saveFig);
