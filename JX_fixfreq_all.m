
%%%This script changes the event type to account for the following
%%%scenarios: 
% there was only one fixation
% there were two fixations
        %if so whether it was the first or second fixation
%it then assigns these different types of fixations to bins and creates
%averaged FRPs. 
%%%%%%%%%%%%note: these fixations are on ALL words (except target words),
%%%%%%%%%%%%both function and content


clear
clc
eeglab

%preparing subjects and folders
%subject_list={'04','05','07','08','09','10','12','13','14','15','17','16','19','20','21','22','23','24','25','26','27','28','29','31','33','34','35','36','37'};
subject_list={'33','34','35','36','37'};
numsubjects=length(subject_list);
parent_folder= 'F:\SMART\JX';
ALLERP = buildERPstruct([]);
CURRENTERP = 0;

%%%starting loop through subject list%%%
for s=1:numsubjects
subject = subject_list{s};
subjectfolder = [parent_folder subject '/'];
fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);

%load the dataset with all the appended information
EEG = pop_loadset('filename',[subject '_fixnum.set'],'filepath',[parent_folder '\' subject '\']);
[ALLEEG, EEG, ~] = eeg_store( ALLEEG, EEG, 0 );


%% here we change the event type to account for 'one and only' fixations
%%and 'first of two' and 'second of two' fixations. 

%this is so that we can distribute these events into bins and generate 
%appropriate fixation related potentials

fprintf('\n\n\n*** Changing events.type for subject %d (%s) ***\n\n\n', s, subject);

secondlastevent=length(EEG.event)-1;

for c=1:secondlastevent;
        if EEG.event(c).sumfix==1;
            EEG.event(c).type=10000;
        elseif EEG.event(c).sumfix==2;
            if EEG.event(c).fixnum==1;
                EEG.event(c).type=11000;
            elseif EEG.event(c).fixnum==2;
                EEG.event(c).type=20000;
            end
        end
end

%% now creating eventlist, saving
EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist', ['C:\Users\aknada96\Desktop\SMART\JX\' subject '\JX_' subject '_fixfreq_all_elist.txt'] ); % GUI: 22-Jun-2017 16:36:43
[ALLEEG,EEG,CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',[parent_folder '\' subject '\' 'JX_' subject '_fixfreq_all.set'],'gui','off'); 

%% now applying low pass filter (since original set has high pass filter and ICA both applied) 
EEG = pop_eegfiltnew(EEG, [],30,226,0,[],1);
[ALLEEG,EEG,CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 

%%now running binlister 
%%(assigning bins)
EEG.setname=['JJ_' subject '_new_binned'];
EEG  = pop_binlister( EEG , 'BDF', 'F:\SMART\JX\fixation_bins.txt', 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' ); % GUI: 22-Jun-2017 16:43:22
[ALLEEG,EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

%%now extracting bin-based epochs
%%(range is the same as previous analyses with JJ)
EEG = pop_epochbin( EEG , [-100.0  700.0],  'pre'); % GUI: 22-Jun-2017 16:47:14
EEG.setname=[ subject '_epoched'];

%just to check the dataset index 
eeglab redraw


%%now computing averaged ERPs
ERP = pop_averager( ALLEEG , 'Criterion', 'good', 'DSindex',3, 'ExcludeBoundary', 'on', 'SEM', 'on' );
ERP = pop_savemyerp(ERP, 'erpname', ['JX_' subject] , 'filename', ['JX_' subject '_fixfreq_all.erp'], 'filepath', 'F:\SMART\JX\ERPs', 'Warning', 'on');% GUI: 26-Jun-2017 10:45:59                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                


STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         


fprintf('\n\n\n**** FINISHED ****\n\n\n');



