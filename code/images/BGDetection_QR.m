%Mahmood Amintoosi, m.amintoosi@gmail.com , HSU
%Background Detection

avi=VideoReader('video/highway.avi');
Im1 = rgb2gray(avi(1).cdata);
% figure(1)
% imshow(Im1);
winSize=40;
Im=Im1(1:winSize,1:winSize);    
% figure(2);
% imshow(Im);
tic
%Highway
% firstFrameNo=115;
% lastFrameNo=195;
%Moeen
firstFrameNo=1;
lastFrameNo=64;
nBlock=floor([size(Im1,1)/winSize size(Im1,2)/winSize]);%Number of blocks in each axes
BgIm=zeros(nBlock*winSize);%size(Im));
x=3;y=3;

% for x=1:nBlock(2)
%     for y=1:nBlock(1)
%         A=zeros(2*length(diag(Im)),lastFrameNo-firstFrameNo+1);
        A=zeros(winSize^2,lastFrameNo-firstFrameNo+1);
        i=1;
        for frameNo=firstFrameNo:lastFrameNo%length(avi)
            Im1 = rgb2gray(avi(frameNo).cdata);
            x1=(x-1)*winSize+1; y1=(y-1)*winSize+1;
            x2=x1+winSize-1; y2=y1+winSize-1;
            Im=Im1(y1:y2,x1:x2);    
%             imshow(Im); drawnow;
%             A(:,i)=[diag(Im);diag(fliplr(Im))];
            A(:,i)=Im(:);
            i=i+1;
        end
        
%         [Q,R,E,r]=mat_QR(A);
        [Q,R,E]=qr(A);        
        %%%%%%%%% size(A,2) or rankA
%         f=find(E(:,size(A,2))==1);
%         r=rank(A);
%         if r==size(A,2), f=find(E(:,size(A,2))==1);
%         else f=find(E(:,r)==1);
%         end
        f=find(E(:,size(A,2))==1);
%         f=find(E(:,1)==1);
        frameNo=firstFrameNo-1+f;
        Im1 = rgb2gray(avi(frameNo).cdata);
        BgIm(y1:y2,x1:x2)=Im1(y1:y2,x1:x2);
%     end
% end
toc
figure(3);clf
imshow(uint8(BgIm));
% 
figure(2);clf
% % x=floor(nBlock(2)/2);y=floor(nBlock(1)/2);
% Current E is coressponds to tha last block

% x=nBlock(2);y=nBlock(1);

nRow=ceil(sqrt(size(A,2)));
nCol=ceil(sqrt(size(A,2)));
x1=(x-1)*winSize+1; y1=(y-1)*winSize+1;
x2=x1+winSize-1; y2=y1+winSize-1;
for i=1:size(A,2)
    f=find(E(:,i)==1);
    frameNo=firstFrameNo-1+f;
    Im1 = rgb2gray(avi(frameNo).cdata);
    Im=Im1(y1:y2,x1:x2);    
    subplot(nRow,nCol,i)
    imshow(Im); 
%     title(num2str(f));
    drawnow;%pause;
end
% % % save 'BGQR.mat' A E Q R
