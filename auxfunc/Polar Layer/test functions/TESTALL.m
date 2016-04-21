function createVideos(varargin)
opts.dataBaseName = 'cifar';
opts.imdbPath = nan;
opts.netPath = nan;
opts.imagePath = nan;
opts.movieOutPathBase = nan;
opts.movieBaseName = nan;
opts.numEpoch = nan;
opts.videoRes = nan;
opts.numberofVideos= nan;
opts.BatchSize = 1024;
opts = vl_argparse(opts,varargin);
% loading imdb
imdb = load([opts.imdbPath,'imdb.mat']);
maxIndex = size(imdb.images.data,4);
TrainIndices = find(imdb.images.set == 1 | imdb.images.set ==2);
TrainIndexLimit = [min(TrainIndices),max(TrainIndices)];
TestIndices = find(imdb.images.set == 3);
TestIndexLimit = [min(TestIndices),max(TestIndices)];
% selecting indices
TrainIndices = generateIndex(opts.numberofVideos,TrainIndexLimit);
TestIndices = generateIndex(opts.numberofVideos,TestIndexLimit);
isTrain = [TrainIndices>0 , TestIndices < 0];
indices = [TrainIndices,TestIndices];
procImage = imdb.images.data(:,:,:,indices);
labels = imdb.images.labels(indices);
fn = getFetchImageFunc('cifar');
pureImage = fn(indices,opts.imagePath);
movie = detect_radial(pureImage,procImage,indices,isTrain,labels,opts);
end

function fn = getFetchImageFunc(dataBaseName)
    switch dataBaseName
        case {'cifar'}
    fn = @(x,y)cifarRet(x,y);
        otherwise
            error('DataBase fetch function is not implemented');
    end
end
function Image = cifarRet(indices,dataBasePath)
% retrieves original images from dataBasePath
    SampleIneachSubdb = 10000;
    FileNumber = 6;
    Train_indicesRelative = cell(1,FileNumber);
    TestBatchNum = 6;
    DataSetName = 'cifar';
    ImageSize = [32,32,3];
    
    ImageCount = numel(indices);
    Image = zeros([ImageSize,ImageCount]);
    Index = 1;
    for i = 1:FileNumber
        % 
        BaseIndex = (i-1)*SampleIneachSubdb;
        ImaginaryIndex = find(indices <= i*SampleIneachSubdb &...
            indices > (i-1)*SampleIneachSubdb);
        IthSubDb = indices(ImaginaryIndex);
        IthSubDb_relative = IthSubDb - BaseIndex;
           
        Train_indicesRelative{i} = IthSubDb_relative;
        if numel(IthSubDb) <1
            continue;
        end
        
    if i ~= TestBatchNum
    imdb = load([dataBasePath,'/data_batch_',int2str(i),'.mat']);
    else
    imdb = load([dataBasePath,'test_batch','.mat']);
    end
    data = imdb.data;
    selectData = data(IthSubDb_relative,:);
    EndIndex = Index + numel(IthSubDb) -1;
    Image(:,:,:,ImaginaryIndex) = flatImage(selectData,DataSetName);
    Index = EndIndex +1;
    end
end
function Image = flatImage(data,dataset)
        switch dataset
            case 'cifar'
        imagePure = data;
        imagePure = imagePure';
        imagePure = permute(reshape(imagePure,32,32,3,[]),[2,1,3,4]);
        imagePure = im2double(imagePure);
        Image = imagePure;
            otherwise
                error('dataSet no implemented');
        end
        
    
end
function Indices = generateIndex(count,Limit)
    RANDOMS = rand(count);
    scope = Limit(2) - Limit(1);
    if scope< 0,error('start index is bigger than end Index');end
    RANDOMS = RANDOMS * scope; % between 0 to scope
    Indices = RANDOMS +Limit(1); %between Limit1 to scope + Limit1 (Limit 2)
end
function pasteMovie(movie,opts)
assert(2*opts.numberOfVideos == size(movie,4),'matrix size does not match the number of videos');
    for i = 1 : size(movie,4)
        
    end
end