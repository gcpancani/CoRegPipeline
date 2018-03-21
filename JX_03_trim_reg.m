
%This script imports coregistration EEGs and synchronizes them with the
%eyetrack. Furthermore it loads the IA file (generated through Dataviewer)
%and codes the wordnum into the file.
%'02';'04';'05';'07';'08';'09';'10';'12';'13';'14';'15';'16';'17';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30';'31';'32';'33';'34';'35';'36';'37'
clear all;
eeglab;
subject_list = {'11'}; %list all of the subjects you want to process, in the order you want them to be processed.
num_subj = length(subject_list); %counts how many subjects
parent_folder = 'g:\\JX\\'; %the folder that contains the coordinates file as well as the individual subjects subfolders
erp_folder = 'g:\\JX\\ERPs\\';
all_epochs_folder = 'g:\\JX\\all_epochs\\';
reports_folder = 'X:\J\JX\Data';
for s=1:num_subj %creates variable s, which will increase up to the number of subjects
    %Create the folder if it doesn't exist already.
    subject = subject_list{s};
    %Files that need to be loaded
    subjectfolder = [parent_folder subject '\'];
    subjectIA = [reports_folder '\JX_' subject '_IA_expanded.txt'];
    subjectMSG = [reports_folder '\JX_' subject '_MSG.txt'];
    subjectnumeric=str2double(subject);
    
    EEG = pop_loadset('filename',['JX_' subject '_03_eyeinfoadded.set'],'filepath',subjectfolder);
    EEG = eeg_checkset( EEG );
    
    secondlastevent = (length(EEG.event))-1;
    trialdone=0;
    secondfix=0;
    for i=1:secondlastevent
        stridentifier = EEG.event(i).identifier;
        trial=EEG.event(i).trial;
        
        
        if length(stridentifier)>3
%             targetpos =  str2double(stridentifier(6));
%             %this next section gets rid of targets that are followed by a
%             %regressive saccade. It does so by locating the next event that
%             %is a fixation on a word (up to 4 events later) and checking to
%             %see whether the wordnum is larger or smaller than the target
%             %position.
%             nexteventtype = EEG.event(i+1).type;
%             if nexteventtype > 11
%                 nexteventtype = EEG.event(i+2).type;
%                 if nexteventtype > 11
%                     nexteventtype = EEG.event(i+3).type;
%                     if nexteventtype > 11
%                         nexteventtype = EEG.event(i+4).type;
%                     end
%                     
%                 end
%             end
%             if nexteventtype > targetpos
                %this section recodes target fixations for selection based
                %on whether they are longer or shorter than the subject's
                %median Target GZD (which is computed in SPSS excluding
                %outliers)
                %now I'm selecting events that have already been identified as being progressive saccades and unselecting them based on a few criteria
                
                    if strcmp(EEG.event(i).type,'IDfast')||strcmp(EEG.event(i).type,'IDslow')|| strcmp(EEG.event(i).type,'Unrfast')||strcmp(EEG.event(i).type,'Unrslow')|| strcmp(EEG.event(i).type,'Degfast')||strcmp(EEG.event(i).type,'Degslow')
                       if str2double(EEG.event(i).IA_GZD) > 130 && str2double(EEG.event(i).IA_GZD)< 600
                            %if str2double(EEG.event(i).IA_FPNfix) ==1
                               EEG.event(i).type = strcat(EEG.event(i).type,'trim');
                           
                            
                        
                        end
                    end
             
%             else
%          
%             end
%             
            
            
        end
        
        
    end
    
      
    
    
    
    
    
    EEG  = pop_editeventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99}, 'BoundaryString', { 'boundary' }, 'ExportEL', [subjectfolder 'JX_' subject '_elist.txt'], 'List', 'G:\JX\JX_EventListTrimnoregr.txt', 'SendEL2', 'EEG&Text', 'UpdateEEG', 'off', 'Warning', 'off' );
    % save events as Numeric labels
    EEG.setname=['JX_' subject '_04_cleaned_elist'];
    %now low-pass filter
    EEG  = pop_basicfilter( EEG,  1:36 , 'Boundary', 'boundary', 'Cutoff',  30, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  4 ); % GUI: 17-May-2015 15:43:23
    EEG.setname=['JX_' subject '_04_filt_cleaned'];
    %Epoching
    EEG = eeg_checkset( EEG );
    EEG  = pop_binlister( EEG , 'BDF', 'G:\JX\JX_bins_split_noreg.txt', 'ExportEL', [subjectfolder 'JX_' subject '_cleaned_elist2.txt'], 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'UpdateEEG', 'on', 'Voutput', 'EEG' ); % GUI: 17-May-2015 15:44:09
    EEG = eeg_checkset( EEG );
    
    EEG = pop_editset(EEG, 'setname',['JX_' subject '_05_cleaned_bins']);
    EEG = pop_saveset( EEG, 'filename',['JX_' subject '_05_trim_bins_reg.set'],'filepath', subjectfolder);
    EEG = pop_epochbin( EEG , [-100.0  700.0],  'pre'); % GUI: 10-Jun-2015 13:42:25
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 1 );
    EEG = pop_saveset( EEG, 'filename',['JX_' subject '_06_trim_binned_reg.set'],'filepath', subjectfolder);
    EEG  = pop_artmwppth( EEG , 'Channel',  1:32, 'Flag',  1, 'Threshold',  120, 'Twindow', [ -99.6 400], 'Windowsize',  200, 'Windowstep',  120 ); % GUI: 22-Jun-2015 11:37:05
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 2 );
    EEG = pop_saveset( EEG, 'filename',['JX_' subject '_07_trim_artflagged_reg.set'],'filepath', subjectfolder);
    ERP = pop_averager( ALLEEG , 'Criterion', 'good', 'DSindex',2, 'ExcludeBoundary', 'on', 'SEM', 'on' );
    ERP = pop_savemyerp(ERP, 'erpname', ['JX_' subject '_trim_erp'], 'filename', ['JX_' subject '_trim_erp_reg4.erp'], 'filepath', erp_folder , 'Warning', 'off');% GUI: 10-Jun-2015 13:43:39
    
    ERP = pop_binoperator( ERP, { 'b19 = wavgbin(1,4,7) label = valid slow',  'b20 = wavgbin(2,5,8) label = unrelated slow',  'b21 = wavgbin(3,6,7) label = degraded slow',  'b22 = wavgbin(10,13,16) label = valid fast',  'b23 = wavgbin(11,14,17) label = unrelated fast',  'b24 = wavgbin(12,15,18) label = degraded fast'});
    
    ERP = pop_binoperator( ERP, {'b25 = wavgbin(19,22) label = identical'});
    ERP = pop_binoperator( ERP, {'b26 = wavgbin(b20,b23) label = unrelated'});
    ERP = pop_binoperator( ERP, {'b27 = wavgbin(b21,b24) label = degraded'});
    ERP = pop_binoperator( ERP, {'b28 = b20-b19 label Unrelated-Identity Slow'});
    ERP = pop_binoperator( ERP, {'b29 = b21-b19 label Degraded-Identity Slow'});
    ERP = pop_binoperator( ERP, {'b30 = b21-b20 label Degraded-Unrelated Slow'});
    ERP = pop_binoperator( ERP, {'b31 = b23-b22 label Unrelated-Identity Fast'});
    ERP = pop_binoperator( ERP, {'b32 = b24-b22 label Degraded-Identity Fast'});
    ERP = pop_binoperator( ERP, {'b33 = b24-b23 label Degraded-Unrelated Fast'});
    ERP = pop_binoperator( ERP, {'b34 = b26-b25 label Unrelated-Identity'});
    ERP = pop_binoperator( ERP, {'b35 = b27-b25 label Degraded-Identity'});
    ERP = pop_binoperator( ERP, {'b36 = b27-b26 label Degraded-Unrelated'});
    
    ERP = pop_savemyerp(ERP, 'erpname', ['JX_' subject '_trim_erp'], 'filename', ['JX_' subject '_trim_erp_reg4.erp'], 'filepath', erp_folder , 'Warning', 'off');% GUI: 10-Jun-2015 13:43:39
            
    
end











