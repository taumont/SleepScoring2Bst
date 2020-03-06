function sEvents = f_Convert_Evt_2_Bst(cEvts,recStart)
%F_CONVERT_EVT_2_BST - Convert events from Harmonie to Brainstorm format.
%
% SYNOPSIS: bst_evt = f_Convert_Evt_2_Bst(cEvts,recStart,srate)
%
% INPUTS:
%	cEvts - Cell array of data in the column order: time, event name, duration.
%               Columns content format are datetime, character array, numerical 
%	recStart - Date and time at the begining of recording as datatime format.
%
% OUTPUTS:
%	sEvents - Array of Brainstorm event structure contaning all events from <cEvts>.
%
% Required files:
%
% EXAMPLES:
%
% REMARKS:
%   cEvt must be in the following order of column: time, event label, duration
%
% See also f_Create_Bst_Evt
%
% Copyright Tomy Aumont

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created with:
%   MATLAB ver.: 9.7.0.1216025 (R2019b) Update 1 on
%    Linux 4.15.0-88-generic #88~16.04.1-Ubuntu SMP Wed Feb 12 04:19:15 UTC 2020 
%              x86_64
%
% Author:     Tomy Aumont
% Work:       Center for Advance Research in Sleep Medicine
% Email:      tomy.aumont@umontreal.ca
% Website:    www.ceams-carsm.ca
% Created on: 27-Feb-2020
% Revised on:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Fix event names
cEvts(:,2) = sf_Fix_Evt_Name_Format(cEvts(:,2));
% Compute time difference in seconds between begining of recording and events
cEvts(:,1) = num2cell(seconds(time(between(recStart,[cEvts{:,1}])))');

sEvents = [];
evt_groups = unique(cEvts(:,2));
for iEvtGr = 1:length(evt_groups)
    % Select only event corresponding to the current category
    evt_cat = cEvts(strcmpi(cEvts(:,2),evt_groups(iEvtGr)),:);
    times = [[evt_cat{:,1}];[evt_cat{:,1}]+[evt_cat{:,3}]];
    sEvents = f_Create_Bst_Evt(sEvents,evt_groups(iEvtGr),{times});
end

end

%% ===== APPLY STRING CORRECTION TO EVENT NAMES =====
function evt_out = sf_Fix_Evt_Name_Format(evt)
% evt: Cell array of strings
    % Remove spaces
    evt_out = strrep(evt,' ','');
    % Replace <.> by <_>
    evt_out = strrep(evt_out,'.','_');
    % Standardize sleep scoring event names: W,R,N1,N2,N3,N/A
    evt_out = strrep(evt_out,'SLEEP-S0','W');
    evt_out = strrep(evt_out,'SLEEP-REM','R');
    evt_out = strrep(evt_out,'SLEEP-S1','N1');
    evt_out = strrep(evt_out,'SLEEP-S2','N2');
    evt_out = strrep(evt_out,'SLEEP-S3','N3');
    evt_out = strrep(evt_out,'SLEEP-UNSCORED','N/A');

end
