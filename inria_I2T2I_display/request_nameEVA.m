
function [requestname, absline] = request_nameEVA(nsst,inria_imgdir,inria_objfi, opt)

    cl_request = opt.cl;
    
    
    
    
    
    
    
    
    
    
    for k = 1 : length( nsst{ opt.cl + 1 } )
    
    im_intra = inria_objfi( nsst{ opt.cl + 1}(k) , 2 );     %opt.imreq;
    requestname{k} = ['query_',int2str( cl_request ),'_document_',int2str(im_intra),'_imagethumb.jpg'];
    
    absline(k) = nsst{ opt.cl + 1 }(k);
    end

end
