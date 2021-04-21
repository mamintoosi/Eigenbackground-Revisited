% Mahmood AminToosi, HSU

% EigenBackground, Revisited

addpath('utils')
videoFileName = 'highway';

xyloObj=VideoReader(['input/' videoFileName '.avi']);

nFrames = xyloObj.NumberOfFrames;
vidHeight = xyloObj.Height;
vidWidth = xyloObj.Width;

masir = ['output/' videoFileName '/'];
mkdir(masir)
% Preallocate movie structure.
avi(1:nFrames) = ...
    struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
    'colormap', []);

firstFrameNo=1;
lastFrameNo=100;%nFrames;
% Read one frame at a time.
step = 1;
k = 1;
for fNo = 1:step:lastFrameNo
    im = read(xyloObj, fNo);
    if strcmp(xyloObj.VideoFormat,'RGB24')==1
        im = rgb2gray(im);
    end
    avi(k).cdata = im;
    %     avi(k).cdata = im(1:240,1:240);
    %     avi(k).cdata = imresize(avi(k).cdata,[40,40]);
    k = k+1;
end
lastFrameNo = k-1;
%%
figure(1); clf;
MSE=[];
imSize=size(avi(firstFrameNo).cdata);

Im1 = avi(firstFrameNo).cdata;
winSize=40;
tic
%Highway
nBlock=floor([size(Im1,1)/winSize size(Im1,2)/winSize]);%Number of blocks in each axes
BG_ImPCA=double(Im1);
BG_ImNonPCA=BG_ImPCA;

for x=1:nBlock(2)
    for y=1:nBlock(1)
        B=zeros(winSize*winSize,lastFrameNo-firstFrameNo+1);
        i=1;
        for frameNo=firstFrameNo:lastFrameNo%length(avi)
            Im1 = avi(frameNo).cdata;
            x1=(x-1)*winSize+1; y1=(y-1)*winSize+1;
            x2=x1+winSize-1; y2=y1+winSize-1;
            Im=Im1(y1:y2,x1:x2);
            B(:,i)=[Im(:)];
            i=i+1;
        end
        
        [pc,score,v,tsquare] = pca(B');
        mu = mean(B,2);
        %         mu=reshape(mu,winSize,winSize);
        %         r=sum(v>0.01)s
        r=10;
        phi=pc(:,1:r);
        phiNonPCA=pc(:,end-r+1:end);
        EigenBack(y,x).mu=mu;
        EigenBack(y,x).phi=phi;             % Strong Eigen Vectors       
        EigenBack(y,x).phiNonPCA=phiNonPCA; % Weak Eigen Vectors       
        
        if (x==5 && y ==5)
            [Q,R,E]=qr(B);
            qr_oerder = zeros(1,size(B,2));
            for i = size(B,2):-1:1
                f=find(E(:,i)==1);
                qr_order(i) = f;
            end
            figure(3)
            subplot(141); imshow(uint8(B))
            imwrite(uint8(B),[masir 'columnized_frames.jpg']);
            subplot(142); imshow(uint8(B(:,qr_order)))
            imwrite(uint8(B(:,qr_order)),[masir 'columnized_frames_reordered.jpg']);
            subplot(222); bar(v)
            subplot(224); bar(abs(diag(R)))
            
            figure(4)
            i = 1;
            for frameNo=firstFrameNo:lastFrameNo%length(avi)
                Im1 = avi(frameNo).cdata;
                x1=(x-1)*winSize+1; y1=(y-1)*winSize+1;
                x2=x1+winSize-1; y2=y1+winSize-1;
                Im=Im1(y1:y2,x1:x2);
                subplot(10,10,i)
                imshow(Im)
                i=i+1;
            end
        end
    end%end for y
end%end for x
toc

%%
for frameNo=16%firstFrameNo:lastFrameNo%length(avi)
    Im1 = avi(frameNo).cdata;
    for x=1:nBlock(2)
        for y=1:nBlock(1)
            x1=(x-1)*winSize+1; y1=(y-1)*winSize+1;
            x2=x1+winSize-1; y2=y1+winSize-1;
            Img=Im1(y1:y2,x1:x2);
            Ii=double(Img(:));
            %             EigenBack(y,x).v=v;
            mu=EigenBack(y,x).mu;
            Xi=Ii - mu;
            
            phi=EigenBack(y,x).phi;
            Bi = phi'*Xi;    % Project onto r strong EigenVectors
            Reconstruction = phi*Bi+mu;  % Reconstruct from projection
            Reconstruction = reshape(Reconstruction,winSize,winSize);
            
            phiNonPCA=EigenBack(y,x).phiNonPCA;
            BiNonPCA = phiNonPCA'*Xi;    % Project onto r weak EigenVectors
            ReconstructionNonPCA = phiNonPCA*BiNonPCA+mu;  % Reconstruct from projection
            ReconstructionNonPCA = reshape(ReconstructionNonPCA,winSize,winSize);
            
            xx1=(x-1)*winSize+1; yy1=(y-1)*winSize+1;
            xx2=x*winSize; yy2=y*winSize;
            BG_ImPCA(yy1:yy2,xx1:xx2)=Reconstruction;
            BG_ImNonPCA(yy1:yy2,xx1:xx2)=ReconstructionNonPCA;
            BG_ImMean(yy1:yy2,xx1:xx2)=reshape(mu,winSize,winSize);
            
        end
    end
    
    threshold = 25;
    figure(1);
    subplot(3,2,1); imshow(Im1);title('Current Frame');
    subplot(3,2,3);imshow(uint8(BG_ImPCA));title('EigenBackground-StrongEigenVectors')
    subplot(3,2,5);imagesc(uint8(abs(BG_ImPCA-double(Im1))>threshold)); title('Detected Foreground')
    axis equal; axis off;
    subplot(3,2,4);imshow(uint8(BG_ImNonPCA));title('EigenBackground-WeakEigenVectors')
    subplot(3,2,6);imagesc(uint8(abs(BG_ImNonPCA-double(Im1))>threshold)); title('Detected Foreground')
    axis equal; axis off;
    

    imwrite(Im1,[masir num2str(frameNo) '.jpg']);
    imwrite(uint8(BG_ImPCA),[masir num2str(frameNo) '_StrongEigenVectors_BG'  '.jpg']);
    imwrite(abs(BG_ImPCA-double(Im1))>threshold,[masir num2str(frameNo) '_StrongEigenVectors_FG.png']);
    imwrite(uint8(BG_ImNonPCA),[masir num2str(frameNo) '_WeakEigenVectors_BG.jpg']);
    imwrite(abs(BG_ImNonPCA-double(Im1))>threshold,[masir num2str(frameNo) '_WeakEigenVectors_FG.png']);
    
    drawnow;
    %     pause(.1)
end

