% Mahmood AminToosi, HSU, 2021
% Foreground Detection
% EigenBackground, using the most and the least eigenvectors

r = VideoReader('video/ShoppingMall.mp4');
n_frames = min([r.NumberOfFrames,558]);
sample_frame_no = n_frames; %eq 558;

% Different block sizes
block_sizes = [32, 64, 128, 256];
mkdir('output/ShoppingMall/vs/');
threshold = 30;

x_center = r.Width / 2;
y_center = r.Height / 2;
for i_blk = 1:numel(block_sizes)
    blk_sz = block_sizes(i_blk);
    x1 = x_center-blk_sz/2+1;
    x2 = x_center+blk_sz/2;
    y1 = y_center-blk_sz/2+1;
    y2 = y_center+blk_sz/2;
    k = 1;
    r = VideoReader('video/ShoppingMall.mp4');
    % Preallocate movie structure.
    avi(1:n_frames) = ...
        struct('cdata', zeros(blk_sz, blk_sz, 1, 'uint8'),...
        'colormap', []);
    B=zeros(blk_sz*blk_sz,n_frames);
    while (r.hasFrame())
        video = readFrame(r);
        im = rgb2gray(video(y1:y2,x1:x2,:));
        avi(k).cdata = im;
        B(:,k)=im(:);
        k= k+1;
        if k>n_frames, break, end
    end
    
    BG_ImPCA=double(im);
    BG_ImNonPCA=BG_ImPCA;
    Bg_ImMean=BG_ImPCA;
    Bg_Princomp=BG_ImPCA;
    
    % Background modeling
    [pc,score,v,tsquare] = pca(B');
    mu = mean(B,2);
    n_eigen_vectors=10;
    phi=pc(:,1:n_eigen_vectors);
    phiNonPCA=pc(:,end-n_eigen_vectors+1:end);
    
    sample_frame = avi(sample_frame_no).cdata;
    sample_frame_col = B(:,sample_frame_no);
    Xi = sample_frame_col - mu;
    Bi = phi'*Xi;    % Project onto Strongest EigenVectors
    BG_SEV = phi*Bi+mu;  % Reconstruct from projection
    BG_SEV = reshape(BG_SEV,blk_sz,blk_sz);
    
    BiNonPCA = phiNonPCA'*Xi;    % Project onto Weakest EigenVectors
    BG_WEV = phiNonPCA*BiNonPCA+mu;  % Reconstruct from projection
    BG_WEV = reshape(BG_WEV,blk_sz,blk_sz);
    
    FG_SEV = abs(BG_SEV-double(sample_frame))>threshold;
    FG_WEV = abs(BG_WEV-double(sample_frame))>threshold;
    
    figure(1);
    subplot(2,3,1); imshow(sample_frame);title('Current Frame');
    subplot(2,3,2);imshow(uint8(BG_SEV));title('EigenBackground-StrongEigenVectors')
    subplot(2,3,3);imagesc(uint8(FG_SEV));
    title('Detected Foreground'); axis equal; axis off;
    subplot(2,3,4); imshow(sample_frame);title('Current Frame');
    subplot(2,3,5);imshow(uint8(BG_WEV));title('EigenBackground-WeakEigenVectors')
    subplot(2,3,6);imagesc(uint8(FG_WEV));
    title('Detected Foreground'); axis equal; axis off;
    
    file_name = sprintf('output/ShoppingMall/vs/%d_%d', blk_sz,sample_frame_no);
    imwrite(sample_frame,[file_name '.jpg']);
    imwrite(uint8(BG_SEV),[file_name '_StrongEigenVectors_BG.jpg']);
    imwrite(FG_SEV,[file_name '_StrongEigenVectors_FG.png']);
    imwrite(uint8(BG_WEV),[file_name '_WeakEigenVectors_BG.jpg']);
    imwrite(FG_WEV,[file_name '_WeakEigenVectors_FG.png']);
%     pause
end


