function [inds, xx, ranknames] = display_t2i_imgranks(sims,tmppT,inria_objf, opt)
    % discard 'NaN':
    ninds = find( isnan(sims) );
    sims(ninds) = - Inf(1,length(ninds));
    [~, inds] = sort(sims,'descend');
    opt.i2iN = 36;
    
    xx = tmppT(inds(1: opt.i2iN),end); % absolute line values!
    %inria_objf{xx(1:20)}
    for r = 1  : opt.i2iN
        ranknames{r} = inria_objf{ xx(r) }.img_file;
    end
    
end
