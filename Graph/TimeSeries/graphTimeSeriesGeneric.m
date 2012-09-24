function [h labels] = graphTimeSeriesGeneric( ax, sample_data, var )
%GRAPHTIMESERIESGENERIC Plots the given variable as normal, single dimensional, 
% time series data. If the data are multi-dimensional, multiple lines will be
% plotted and returned.
%
% Inputs:
%   ax          - Parent axis.
%   sample_data - The data set.
%   var         - The variable to plot.
%
% Outputs:
%   h           - Handle(s) to the line(s)  which was/were plotted.
%   labels      - Cell array containing x/y labels to use.
%
% Author:       Paul McCarthy <paul.mccarthy@csiro.au>
% Contributor:  Guillaume Galibert <guillaume.galibert@utas.edu.au>
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
error(nargchk(3,3,nargin));

if ~ishandle(ax),          error('ax must be a graphics handle'); end
if ~isstruct(sample_data), error('sample_data must be a struct'); end
if ~isnumeric(var),        error('var must be a numeric');        end

time = getVar(sample_data.dimensions, 'TIME');
time = sample_data.dimensions{time};
var  = sample_data.variables {var};

h    = line(time.data, var.data, 'Parent', ax);
set(ax, 'Tag', 'axis1D');

% test for climatology display
mWh = findobj('Tag', 'mainWindow');
sMh = findobj('Tag', 'samplePopUpMenu');
iSample = get(sMh, 'Value');
climatologyRange = get(mWh, 'UserData');
if ~isempty(climatologyRange)
    if isfield(climatologyRange, ['rangeMin' var.name])
        hRMin = line(time.data, climatologyRange(iSample).(['rangeMin' var.name]), 'Parent', ax, 'Color', 'r', 'LineStyle', '-');
        hRMax = line(time.data, climatologyRange(iSample).(['rangeMax' var.name]), 'Parent', ax, 'Color', 'r', 'LineStyle', '-');
        set(ax, 'YLim', [min(climatologyRange(iSample).(['rangeMin' var.name])) - min(climatologyRange(iSample).(['rangeMin' var.name]))/10, ...
            max(climatologyRange(iSample).(['rangeMax' var.name])) + max(climatologyRange(iSample).(['rangeMax' var.name]))/10]);
    end
    if isfield(climatologyRange, ['range' var.name])
        hR = line(time.data, climatologyRange(iSample).(['range' var.name]), 'Parent', ax, 'Color', 'k', 'LineStyle', '--');
    end
end

% Set axis position so that 1D data and 2D data vertically matches on X axis
mainPanel = findobj('Tag', 'mainPanel');
last_pos_with_colorbar = get(mainPanel, 'UserData');
if isempty(last_pos_with_colorbar) % this is to avoid too many calls to colorbar()
    cb = colorbar();
    set(get(cb, 'YLabel'), 'String', 'TEST');
    pos_with_colorbar = get(ax, 'Position');
    last_pos_with_colorbar = pos_with_colorbar;
    colorbar(cb, 'off');
    set(mainPanel, 'UserData', last_pos_with_colorbar);
else
    pos_with_colorbar = get(ax, 'Position');
    
    if pos_with_colorbar(1) == last_pos_with_colorbar(1)
        pos_with_colorbar(3) = last_pos_with_colorbar(3);
    else
        cb = colorbar();
        set(get(cb, 'YLabel'), 'String', 'TEST');
        pos_with_colorbar = get(ax, 'Position');
        last_pos_with_colorbar = pos_with_colorbar;
        colorbar(cb, 'off');
        set(mainPanel, 'UserData', last_pos_with_colorbar);
    end
end
set(ax, 'Position', pos_with_colorbar);

if strncmp(var.name, 'DEPTH', 4)
    set(ax, 'YDir', 'reverse');
end

labels = {'TIME', var.name};
