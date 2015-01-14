function textvec = text2vecNEW(text, inriaPBA, opt)
% extract individual image vector from test set:

%% text == tagwords{i}{dic} , w 
vecdim = 7*opt.tdim;
tmp_wordvec = [];%zeros(opt.dim * opt.maxwords,1);
        
        if length(text) < 1
            tmp_wordvec = zeros(1,vecdim);
%             pd(dic) = 0;
        else
%             pd(dic) = prior(dic);
            
            %             for w = 1 : min(opt.maxwords, length(text) )
            w = 1;
            mir = 0;
            while w <= min(opt.maxwords + mir, length(text))
                
                % enter this while loop only if there are >=1 word, assume
                % added this one first word: so w = 1 already
                
                % simple 1-word search !
%                 ind = find( ismember(dictionary_inriaPBA, text{w}) );
                idx_w = find( ismember(inriaPBA.word, text{w}) );

                if ~ isempty(idx_w)
                        tmp_wordvec = [tmp_wordvec, inriaPBA.vector{idx_w}];
                end
                w = w + 1;
                if opt.window2
                    if w  <= min(opt.maxwords, length(text))
                        if ismember([text{w-1},'_',text{w}], inriaPBA.word)
                            idx_w = find( ismember(inriaPBA.word,[text{w-1},'_',text{w}]) );
                            if ~ isempty(idx_w)
                                if length(tmp_wordvec) >= opt.tdim
                                tmp_wordvec(end-opt.tdim+1 : end) = inriaPBA.vector{idx_w};
                                else
                                    tmp_wordvec = inriaPBA.vector{idx_w};
                                end
                                w = w + 1;
                                mir = mir + 1;
                            end
                        end
                    end
                end
                
            end
            % end of simple 1-word search - to be replaced by : 1-2-window search: 10 jan 2015 -
            wlen = length(tmp_wordvec);
            if ~ opt.periodic
            dlen = vecdim - wlen;
            tmpvv = [tmp_wordvec, zeros(1,dlen)];
            else
             zoom = ceil(vecdim / wlen);
             tmpvv = []; 
             for z = 1 : zoom
               tmpvv = [tmpvv, tmp_wordvec];
             end
            end
        end

textvec = tmpvv(1:vecdim);

end