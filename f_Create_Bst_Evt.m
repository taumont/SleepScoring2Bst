function sEvents = f_Create_Bst_Evt(sEvents,evt_label,evt_time)
% SYNOPSIS: CreateEvent()
%
% INPUTS:
%	sEvents   - Array of Brainstorm event structures. Can be empty [].
%	evt_label - Cell array of name of event to create.
%	evt_time  - Cell array of time occurence of each <evt_label>.
%
% OUTPUTS:
%	sEvents - Array of Brainstorm event structures containing the new event categories.
% 
% Required files:
%
% EXAMPLES:
%
% REMARKS:
%
% See also db_template
%
% Copyright Tomy Aumont

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created with:
%   MATLAB ver.: 9.6.0.1099231 (R2019a) Update 1 on
%    Microsoft Windows 10 Home Version 10.0 (Build 17763)
%
% Author:     Tomy Aumont
% Work:       Center for Advance Research in Sleep Medicine
% Email:      tomy.aumont@umontreal.ca
% Website:    
% Created on: 19-Jun-2019
% Revised on:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ===== CREATE NEW EVENTS =====
% Create event structure if not already existing
if isempty(sEvents)
    sEvents = repmat(db_template('event'), 0);
end

% Process each event separately
for iType = 1:length(evt_label)
    % Get the event to create
    iEvt = find(strcmpi({sEvents.label}, evt_label{iType}));
    % Existing event: reset it
    if ~isempty(iEvt)
        newEvent = sEvents(iEvt);
        newEvent.epochs     = [];
        newEvent.times      = [];
        newEvent.reactTimes = [];
    % Else: create new event
    else
        % Initialize new event
        iEvt = length(sEvents) + 1;
        newEvent = db_template('event');
        newEvent.label = evt_label{iType};
        % Get the default color for this new event
        newEvent.color = sf_GetNewEventColor(iEvt, sEvents);
    end
    % times (in seconds) [2 x n_events]
    if size(evt_time{iType},1) == 2
        newEvent.times = evt_time{iType};
    elseif size(evt_time{iType},2) == 2
        newEvent.times = evt_time{iType}';
    else
        continue
    end
    newEvent.epochs   = ones(1, size(newEvent.times,2));
    newEvent.channels = cell(1, size(newEvent.times, 2));
    newEvent.notes    = cell(1, size(newEvent.times, 2));
    % Add to events structure
    sEvents(iEvt) = newEvent;
end
end

%% ===== GET NEW EVENT COLOR =====
function newColor = sf_GetNewEventColor(iEvt, AllEvents)
    % Get events color table
    ColorTable = sf_GetEventColorTable();
    % Attribute the first color that of the colortable that is not in the existing events
    for iColor = 1:length(ColorTable)
        if isempty(AllEvents) || ~isstruct(AllEvents) || ~any(cellfun(@(c)isequal(c, ColorTable(iColor,:)), {AllEvents.color}))
            break;
        end
    end
    % If all the colors of the color table are taken: attribute colors cyclically
    if (iColor == length(ColorTable))
        iColor = mod(iEvt-1, length(ColorTable)) + 1;
    end
    newColor = ColorTable(iColor,:);
end

%% ===== GET EVENT COLOR TABLE =====
function ColorTable = sf_GetEventColorTable()
    ColorTable = [0     1    0   
                 .4    .4    1   
                  1    .6    0
                  0     1    1  
                 .56   .01  .91
                  0    .5    0 
                 .4     0    0   
                  1     0    1  
                 .02   .02   1
                 .5    .5   .5];
end