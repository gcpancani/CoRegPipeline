%This script imports coregistration EEGs and synchronizes them with the
%eyetrack. Furthermore it loads the IA file (generated through Dataviewer)
%and codes the wordnum into the file. 
clear all;
eeglab;
subject_list = {'37'}; %list all of the subjects you want to process, in the order you want them to be processed.
num_subj = length(subject_list); %counts how many subjects
parent_folder = 'g:\\JX\\'; %the folder that contains the coordinates file as well as the individual subjects subfolders
erp_folder = 'g:\\JX\\ERPs\\';%the folder that contains just ERPs (easier to have them all together if you're planning on combining/running a MUT
all_epochs_folder = 'g:\\JX\\all_epochs\\';
reports_folder = 'X:\J\JX\Data'; %folder containing EyeTracking reports
expcode: 'JX_'; %experiment code to add to all filenames so they are not ambiguous
channellocationfile: 'g:\\Admin\\gordon_lab_32+6.elp'% path to channel location file. Note that I'm using ELP here
for s=1:num_subj %creates variable s, which will increase up to the number of subjects
     %Create the subject folder if it doesn't exist already.
subject = subject_list{s};
    if ~exist([parent_folder subject], 'dir')
      mkdir([parent_folder subject]);
    end
    % Files that need to be loaded
      subjectfolder = [parent_folder subject '\'];
      
      %Enter the folder and filename and for the eye-asci file, the subject.mat eyetrack file, the IA report and the message report below.
      
      eye_asci = [reports_folder 'JX_' subject '.asc'];
      outputMatFile = [subjectfolder subject '.mat'];       
      subjectIA = [reports_folder 'JX_' subject '_IA.txt'];
      subjectMSG = [reports_folder 'JX_' subject '_MSG.txt'];
      
      
      %Load the BDF and create EEG set
      %then add channel information (standard is 32 electrodes but you can change it to your array below), remove two extra electrodes and
      %re-reference
   
      fprintf('n\n\n processing subject (%s)',subject);
      
    EEG = pop_readbdf([parent_folder expcode subject '.bdf'], [] ,41,[33 34] );
    EEG = eeg_checkset( EEG );
    EEG = pop_editset(EEG, 'setname',[expcode subject]);
    EEG = pop_editset(EEG, 'subject', subject, 'comments', 'This is the co-registration experiment!', 'chanlocs', channellocationfile);
    EEG = pop_select( EEG,'nochannel',{'EXG7' 'EXG8'}); %we don't record these channels
    EEG = pop_editset(EEG, 'chanlocs', channellocationfile);
    EEG = eeg_checkset( EEG );
    EEG = pop_reref( EEG, [33 34] );
    EEG = pop_saveset( EEG, 'filename',[expcode subject '.set'],'filepath', [parent_folder subject]);
   %I now apply the high-pass filter. This helps with the ICA
    EEG  = pop_basicfilter( EEG,  1:36 , 'Boundary', 'boundary', 'Cutoff',  0.2, 'Design', 'butter', 'Filter', 'highpass', 'Order',  4 ); % This is easy to change to your preferred specs. Check GUI for instructions
    EEG = eeg_checkset( EEG );
	EEG.setname= [expcode subject '_filt'];
    %Unfortunately this part requires user input. 
    eeglab redraw
    pop_processMARA ( ALLEEG,EEG,CURRENTSET ) %calls in the plugin MARA which identifies sources of variance (we use it to pull out oculomotor noise)
   
      
end
