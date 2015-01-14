%% demo that combines 3 classes/topics and corresponding images/texts


%clear; close all;

% addpath('./data');
% load vectors_word2vecs

% load('cnn_features_class.mat');


% load('4class_vfeatures.mat');

% 4class_namelist; 4class_btaglist
% 4class_vfeatures % contains CNN visual vectors and text_tagnames

% load('4class_dictionary_inria.mat');

classes{1} = 'arc_de_triomphe';
classes{2} = 'taj_mahal';
classes{3} = 'nba';
%classes{4} = 'background';
thm{1} = 'b';
thm{2} = 'a';
thm{3} = 'p';
root_textvectors = './text_vectors/'; % dictionary of word2vec vectors
root_texttags = './text_tags/inria_tagbtexts/'; % tags of images with <tagname> id
% feature extraction : V and T
word_pos = @(n) (n-3)/201;

if 0
    % used <v_features> in [4class_vfeatures.mat]
    if 0
        V_class_features = CNN_features_class;
    else
        
        for i = 1 : length(v_features)
            V_class_features{i} = [];
            for j = 1 : length(v_features{i})
                disp('concatenating features...');
                V_class_features{i} = [V_class_features{i},   v_features{i}{j}.vector'];
                % (T): T_class / copied to <train_visual_inria.m> / 10jan
                % 2015
                T_class{i}{j}.tagname = v_features{i}{j}.tagname;
                % (1) extract phrases/words in tagname files
                disp('extracting text tags...');
                
                tmp = textread([root_texttags,v_features{i}{j}.tagname],'%s');
%                 T_class{i}{j}.tagwords = textread([root_texttags,v_features{i}{j}.tagname],'%s');
                %     T_class_{i}{j}.atagwords = textread([root_texttags,v_features{i}{j}.tagname],'%s');
                %     T_class_{i}{j}.ptagwords = textread([root_texttags,v_features{i}{j}.tagname],'%s');
                 T_class{i}{j}.tagwords = tmp(2:end-1); % without '<ptitle>', '</ptitle>'!
                % (2)search in the 3 txt files and
                % ----- end of (T): T_class
                disp('finished one image...');
            end
        end
    end
    save('cca_Vclass.mat', 'v_features');%originally for V_class_features % newly modified 18dec
      save('cca_Vclasss.mat' ,'V_class_features'); % newly modified 18dec

    save('cca_Tclass.mat' ,'T_class');  
else
    disp('loading class features..');
    load('cca_Tclass.mat' );
    load('cca_Vclass.mat');
end
opt.maxwords = 9;
opt.dim = 200; % word2vec setted

% thm not used for now : 10 jan 2015
opt.thm = {thm{1:end}}; %'bap' here
opt.choix = 'b';
dict = inria{find(ismember(opt.thm, opt.choix)) };

T_class_features = wordvec2class(T_class,dict,opt);

save('cca_Tclasss.mat','T_class_features');


