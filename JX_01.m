%This script imports coregistration EEGs and synchronizes them with the
%eyetrack. Furthermore it loads the IA file (generated through Dataviewer)
%and codes the wordnum into the file. 
clear all;
eeglab;
%;'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29'
subject_list = {'37'}; %list all of the subjects you want to process, in the order you want them to be processed.
num_subj = length(subject_list); %counts how many subjects
parent_folder = 'g:\\JX\\'; %the folder that contains the coordinates file as well as the individual subjects subfolders
erp_folder = 'g:\\JX\\ERPs\\';
all_epochs_folder = 'g:\\JX\\all_epochs\\';
reports_folder = 'X:\J\JX\Data';


for s=1:num_subj %creates variable s, which will increase up to the number of subjects
     %Create the folder if it doesn't exist already.
subject = subject_list{s};
    if ~exist([parent_folder subject], 'dir')
      mkdir([parent_folder subject]);
    end
    % Files that need to be loaded
      subjectfolder = [parent_folder subject '\'];
%       eye_asci = [reports_folder 'JX_' subject '.asc'];
%       outputMatFile = [subjectfolder subject '.mat'];       
%       subjectIA = [reports_folder 'JX_' subject '_IA.txt'];
%       subjectMSG = [reports_folder 'JX_' subject '_MSG.txt'];
      
      
      %Load the BDF and create EEG set
      %then add channel information, remove two extra electrodes and
      %re-reference
   
      fprintf('n\n\n processing subject (%s)',subject);
      
    EEG = pop_readbdf([parent_folder 'JX_' subject '.bdf'], [] ,41,[33 34] );
    EEG = eeg_checkset( EEG );
    EEG = pop_editset(EEG, 'setname',['JX_' subject]);
    EEG = pop_editset(EEG, 'subject', subject, 'comments', 'This is the co-registration experiment!', 'chanlocs', 'g:\\Admin\\gordon_lab_32+6.elp');
    EEG = pop_select( EEG,'nochannel',{'EXG7' 'EXG8'});
    EEG = pop_editset(EEG, 'chanlocs', 'g:\\Admin\\gordon_lab_32+4.elp');
    EEG = eeg_checkset( EEG );
    EEG = pop_reref( EEG, [33 34] );
    EEG = pop_saveset( EEG, 'filename',['JX_' subject '.set'],'filepath', [parent_folder subject]);
   %I now apply the high-pass filter. This helps with the ICA
    EEG  = pop_basicfilter( EEG,  1:36 , 'Boundary', 'boundary', 'Cutoff',  0.2, 'Design', 'butter', 'Filter', 'highpass', 'Order',  4 ); % GUI: 17-May-2015 15:23:20
    EEG = eeg_checkset( EEG );
	EEG.setname= ['JX_' subject '_filt'];
    %Unfortunately this part requires user input. 
    eeglab redraw
    pop_processMARA ( ALLEEG,EEG,CURRENTSET )
   
      
end