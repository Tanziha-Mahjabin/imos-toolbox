function sample_data = inWaterQC( sample_data, cal_data )
%INWATERQC Removes samples which were taken before the instrument was placed
% in the water.
%
% Removes all samples from the data set which have a time that is before the 
% in water time. Assumes that these samples will be at the beginning of the
% data set.
%
% Inputs:
%   sample_data - struct containing a vector of parameter structs, which in
%                 turn contain the data.
%
%   cal_data    - struct which contains the in water time.
%
% Outputs:
%   sample_data - same as input, with in water samples removed.
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

error(nargchk(2, 2, nargin));
if ~isstruct(sample_data), error('sample_data must be a struct'); end
if ~isstruct(cal_data),    error('cal_data must be a struct');    end

% index of first sample which was taken in water
start = 0;

% step through the start of the data set until we find a sample 
% which has a time greater than or equal to the in water time
for k = 1:length(sample_data.dimensions.time)
  
  if sample_data.dimensions.time(k) >= cal_data.in_water_time
    
    start = k;
    break;
    
  end
end

% remove all of those samples
sample_data.dimensions.time = sample_data.dimensions.time(start:end);
for k = 1:length(sample_data.parameters)
  
  sample_data.parameters(k).data = sample_data.parameters(k).data(start:end);
  
end