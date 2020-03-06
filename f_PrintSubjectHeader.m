function f_PrintSubjectHeader(subjId)
%F_PRINTSUBJECTHEADER - Print a separation header with the subject identifier in it.
%
% SYNOPSIS: f_PrintSubjectHeader(subjId)
%
% Required files:
%
% EXAMPLES:
%   f_PrintSubjectHeader('projet_003')
%
% REMARKS:
%
% See also 
%
% Copyright Tomy Aumont

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created with:
%   MATLAB ver.: 9.6.0.1011450 (R2019a) Prerelease on
%    Linux 4.15.0-76-generic #86~16.04.1-Ubuntu SMP Mon Jan 20 11:02:50 UTC 2020 
%              x86_64
%
% Author:     Tomy Aumont
% Work:       Center for Advance Research in Sleep Medecine (CARSM)
% Email:      tomy.aumont@umontreal.ca
% Website:    
% Created on: 17-Feb-2020
% Revised on:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


headerWidth = 3*length(subjId);

fprintf('\n%s\n',repmat('=',1,headerWidth))
fprintf('%s%s\n',repmat(' ',1,headerWidth/3),subjId)
fprintf('%s\n',repmat('=',1,headerWidth))
