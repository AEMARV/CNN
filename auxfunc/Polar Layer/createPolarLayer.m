    function  layer  = createPolarLayer(opts)
%% function  layer  = createPolarLayer(opts)
% creates a polar layer with the following fields
% ========================================================================
%
% Fields:
% ------------------------------------------------------------------------
% opts : contains options about the polar transform
% opts is a struct (
%
%   'type' :  'log' or 'lin' or 'square'
%
%   'upSampleRate',UP,
%
%   'filterSigma',FS , 
%
%   'extrapval' , extrapval,
%
%   'kernel',k     ;;  There are constraints on size of the kernel and sigma
%
%   OPTIONAL: rmin ,rmax
%
% ------------------------------------------------------------------------
% type : 'custom'  this is fixed and does not depend on input
% ------------------------------------------------------------------------
% centers : the default value is [] if it remains [] during training it
% will throw error
% one should update centers which is a 2*2*1*N matrix for every batch

%layer.opts = opts;

layer.kernel = opts.kernel;
layer.extrapval = opts.extrapval;
layer.upSampleRate = opts.upSampleRate;
layer.DownSampleRate = opts.DownSampleRate;
layer.typePolar = opts.type;
layer.filterSigma = opts.filterSigma;
layer.randomRotate = opts.randomRotate;
layer.rotatePix = 0;
if isfield(opts,'rmin')
    layer.rmin = opts.rmin;
    layer.rmax = opts.rmax;
end
layer.type  = 'custom';
layer.forward = @pol_transform_wrapper_forward;
layer.backward = @pol_transform_wrapper_backward;
layer.centers = [];

end
function resip1 =  pol_transform_wrapper_forward(layer,resi,resip1)

    
    centers = layer.centers;
    if isempty(centers)
        error('centers are empty matrix');
    end
    if ndims(centers) == 4
    centers = centers(1,:,1,:);
    centers = squeeze(centers)';
    end
    resip1.x = pol_transform(resi.x,centers,layer);
    if layer.randomRotate
    shiftAmount = rand(1);
    shiftAmount = floor(shiftAmount * size(resi.x,2));
    layer.rotatePix = shiftAmount;
    end
    resip1.x = shiftAll(resip1.x,layer.rotatePix);
end
function resi = pol_transform_wrapper_backward(layer,resi,resip1)
%    opts = layer.opts;
    
    centers = layer.centers;
    if isempty(centers)
        error('centers are empty matrix');
    end
    dzdpol = resip1.dzdx;
    if layer.randomRotate
       dzdpol = shiftAll(dzdpol,-layer.rotatePix); 
    end
    [dzdrow,dzdcol] = calcGradCenter(dzdpol,resi.x,centers,layer);
    resi.dzdrow = dzdrow;
    resi.dzdcol = dzdcol;
end
function shifted = shiftAll(x,shiftAmount)
colNum = size(x,2);
shifted = x;
ind = 0: colNum-1; % 0 15
indNew = mod((ind + shiftAmount),colNum) +1 ;% SA : 15+SA -> SA : 15 : 0: SA -1
shifted(:,ind+1,:,:) = x(:,indNew,:,:);
end
