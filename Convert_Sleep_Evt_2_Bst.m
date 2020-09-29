% function Convert_Sleep_Evt_2_Bst()
%CONVERT_SLEEP_EVT_2_BST - Convert RemLogic or CSV event files to MAT-file.
% SYNOPSIS: Convert_Sleep_Evt_2_Bst()
%
%
% Required files:
%   Recordings: All recordings must be in EDF/REC format.
%   Events:     Supported event format are:
%                   - CSV as exported by Gaetan's tool
%                   - TXT as exported by RemLogic (*_Events.txt || *_Artifacts.txt). If Events AND
%                       Artifacts are desired, they need to be in the same directory.
%
% REMARKS:
%   IF used for SAM project, combine sleep socring and artifacts together.
%   Column names in the event files must be previously verified not to contain accents.
%   Recording year is assumed to be 20XX. To change it, see variable <CENTURY>
%
% See also f_GetPath,edfread,f_Convert_Evt_2_Bst,AskYesNo
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
clear;clc;

addpath('edfreadZip/')
CENTURY             = 2000; % Since years are save as only 2 digits in EDF files, add this number to it.
SUBJ_ID_LENGTH      = 8;
SUBJ_TO_ANALYZE     = {'SAM003n2','SAM030n1','SAM034n1','SAM037n2','SAM039n1','SAM041n1'};

% ===== GET RECORDING FILES =====
disp('Select recording directory')
file_list       = f_GetPath(dir(uigetdir('','Select recording directory')));
recFiles        = file_list(endsWith(file_list,{'.edf','.rec'},'IgnoreCase',true));
recDir          = fileparts(file_list{1});

% ===== GET MARKER FILES =====
resp = f_AskYesNo({'  Use same directory for scoring files and recordings?\n\t--> "%s"',recDir});
switch resp
    case 'yes'
        mrkFiles    = file_list(endsWith(file_list,{'.csv','txt'},'IgnoreCase',true));
        
    case 'no'
        mrkFiles    = f_GetPath(dir(uigetdir('','Select marker files directory')));
        mrkFiles    = mrkFiles(endsWith(mrkFiles,{'.csv','txt'},'IgnoreCase',true));
end

% ===== GET RECORDING-MARKER FILES PAIRS =====
[~,mrkFileName]     = cellfun(@fileparts, mrkFiles, 'UniformOutput', false);
[~,recFileName]     = cellfun(@fileparts, recFiles, 'UniformOutput', false);
iKeep               = cellfun(@(c) find(strncmpi(c,mrkFileName,SUBJ_ID_LENGTH)),recFileName,'UniformOutput',false);

recFiles            = recFiles(~cellfun(@isempty,iKeep));
mrkFiles            = cellfun(@(c) cat(2,mrkFiles(c)),iKeep,'UniformOutput',false);

% Select only subject to process
if ~isempty(SUBJ_TO_ANALYZE)
    recFiles    = recFiles(contains(recFiles,SUBJ_TO_ANALYZE));
    mrkFiles    = cellfun(@(c) c(contains(c,SUBJ_TO_ANALYZE)),mrkFiles,'UniformOutput',false);
end

mrkFiles            = mrkFiles(~cellfun(@isempty, mrkFiles));

% Get subject names
[~,fn,~]            = cellfun(@fileparts,recFiles,'UniformOutput',false);
sId                 = cellfun(@(n)n{1},cellfun(@(c)strsplit(c,'_'),fn,'UniformOutput',false),'UniformOutput',false);

% ===== PROCEED ON ONE FILE PAIR AT A TIME =====
for iSubj = 1:length(recFiles)
    OVERWRITE = true; % Overwrite marker file if already exist
    f_PrintSubjectHeader(sId{iSubj});
    for iFile = 1:length(mrkFiles{iSubj}) % normally 2 files, sleep scoring + artifacts
        fprintf('Processing file: %s\n',mrkFiles{iSubj}{iFile})
        % Read event file
        if endsWith(mrkFiles{iSubj}{iFile},'csv','IgnoreCase',true)
            cEvts                   = readcell(mrkFiles{iSubj}{iFile});
            [t_col,e_col,d_col]     = sf_Get_Evt_Related_Columns(cEvts(1,:),'harmonie');
            
        elseif endsWith(mrkFiles{iSubj}{iFile},'txt','IgnoreCase',true)
            tEvts                   = readtable(mrkFiles{iSubj}{iFile});
            colNames                = tEvts.Properties.VariableNames;
            cEvts                   = [colNames; table2cell(tEvts)];
            [t_col,e_col,d_col]     = sf_Get_Evt_Related_Columns(cEvts(1,:),'remlogic');
            
        end
        if isempty(t_col) || isempty(e_col) || isempty(d_col)
            fprintf('WARNING: Skipping this run !!!\n')
            continue
        end
        % Get recording date/time
        hdr         = edfread(recFiles{iSubj});
        dtV         = str2double(strsplit([hdr.startdate '.' hdr.starttime],'.'));
        recStart    = datetime([CENTURY+dtV(3),dtV(2),dtV(1),dtV(4:end)]);
        % Convert all events to Brainstorm event structure array
        if contains(recFiles{iSubj},'SAM028n1','IgnoreCase',true)
            % ===== FIX FOR SAM028 NIGHT 1 (manual export induce a time lag) =====
            evt_time    = cellfun(@(c) {c-(hours(1)+minutes(42)+seconds(30))},cEvts(2:end,t_col));
            
        elseif contains(recFiles{iSubj},'SAM028n2','IgnoreCase',true)
            % ===== FIX FOR SAM028 NIGHT 2 (manual export induce a time lag) =====
            evt_time    = cellfun(@(c) {c-(hours(1)+minutes(27)+seconds(45))},cEvts(2:end,t_col));
            
        else
            evt_time    = cEvts(2:end,t_col);
            
        end
        events      = f_Convert_Evt_2_Bst([evt_time,cEvts(2:end,[e_col,d_col])],recStart);
        
        % Makes sure no events are outside of recording duration. (Ex.: SAM015n2)
        for iEvt = 1:length(events)
            if events(iEvt).times>(hdr.records*hdr.duration)
                disp('Found some')
            end
            events(iEvt).times(events(iEvt).times>(hdr.records*hdr.duration)) = hdr.records;
        end
        
        % Ignore sleep stage scoring in artifact file
        if contains(mrkFiles{iSubj}{iFile},{'artifact'},'IgnoreCase',true)
            events      = events(~contains({events.label},{'R','W','N1','N2','N3','N/A'}));
        end
        if ~isempty(events)
            [fPath,fn,~]    = fileparts(recFiles{iSubj});
            evtFileName     = fullfile(fPath,[fn '_Bst_Events']);
            if exist([evtFileName '.mat'],'file') && ~OVERWRITE
                sEvt        = load(evtFileName);
                events      = [sEvt.events,events];
            end
            fprintf('Saving event file: %s\n',evtFileName)
            save(evtFileName,'-v6','events');
            OVERWRITE       = false;
        end
    end
end
fprintf('\nComplete\n')

%% GET RELEVANT COLUMNS FROM CSV FILE HEADER
function [t,e,d] = sf_Get_Evt_Related_Columns(c,informat)
    warning('off','backtrace')
    switch lower(informat)
        case 'harmonie'
            t = find(strcmpi(c,'heure'));
            if isempty(t)
                warning('No column "HEURE" found!')
            end
            e = find(strcmpi(c,'evenement'));
            if isempty(e)
                warning('No column "EVENEMENT" found!')
            end
            d = find(strcmpi(c,'duree'));
            if isempty(d)
                warning('No column "DUREE" found!')
            end
        case 'remlogic'
            t = find(strcmpi(c,'Time_hh_mm_ss_'));
            if isempty(t)
                warning('No column "Time_hh_mm_ss_" found!')
            end
            e = find(strcmpi(c,'event'));
            if isempty(e)
                warning('No column "event" found!')
            end
            d = find(strcmpi(c,'Duration_s_'));
            if isempty(d)
                warning('No column "Duration_s_" found!')
            end
    end
    warning('on','backtrace')
end

