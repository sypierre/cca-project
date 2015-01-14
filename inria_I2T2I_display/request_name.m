
function requestname = request_name(nsst,inria_imgdir,inria_objfi, opt)

random = opt.randomi2t;
if random
    cl_request = opt.cl;
    
    %     im_request = randi(length(T_class{cl_request})); %nss{cl_request} %69;
    im_request = randi(length(nsst{cl_request + 1}));
    if  inria_objfi( nsst{cl_request + 1}(im_request), 1 ) == cl_request
        disp( ' OK ...');
    else
        disp(' Erorr in nss/nsst...');
    end
    id_intra = inria_objfi( nsst{cl_request + 1}(im_request), 2);
    
    requestname = ['query_',int2str( cl_request ),'_document_',int2str(id_intra),'_imagethumb.jpg'];
    
    while ~exist([inria_imgdir, requestname],'file')
        disp('take another image randomly...');
        im_request = randi(length(nsst{cl_request + 1 }));
        if  inria_objfi( nsst{cl_request + 1 }(im_request), 1 ) == cl_request
            disp( ' OK ...');
        else
            disp(' Erorr in nss/nsst...');
        end
        id_intra = inria_objfi( nsst{cl_request+1}(im_request), 2);
        requestname = ['query_',int2str( cl_request ),'_document_',int2str(id_intra),'_imagethumb.jpg'];
        
    end
    
else
    cl_request = opt.cl;  im_intra = opt.imreq;
    requestname = ['query_',int2str( cl_request ),'_document_',int2str(im_intra),'_imagethumb.jpg'];
    %requestname = inria_objf{}
end

end
