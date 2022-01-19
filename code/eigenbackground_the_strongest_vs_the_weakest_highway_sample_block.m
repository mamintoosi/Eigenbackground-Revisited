% Mahmood AminToosi, HSU, 2021
% Foreground Detection
% EigenBackground, using the first and the last eigenvectors

% loading only one 40x40 block of highway video
load('input/BGSamplePixels_voigtclip_short_3pointsBGDetection.mat')
n_frames = 60;
sample_frame_no = 16;%n_frames; %eq 558;

im = uint8(B(:,sample_frame_no));
% Different block sizes
blk_sz = 40; %[32, 64, 128, 256];

BG_ImPCA=double(im);
BG_ImNonPCA=BG_ImPCA;
Bg_ImMean=BG_ImPCA;
Bg_Princomp=BG_ImPCA;

% Background modeling
[pc,score,v,tsquare] = pca(B');
mu = mean(B,2);

for n_eigen_vectors=1:n_frames
    
    phi=pc(:,n_eigen_vectors);
    phiNonPCA=pc(:,end-n_eigen_vectors+1);
    
    sample_frame = reshape(im,blk_sz,blk_sz);
    sample_frame_col = B(:,sample_frame_no);
    Xi = sample_frame_col - mu;
    Bi = phi'*Xi;    % Project onto Strongest EigenVectors
    BG_SEV = phi*Bi+mu;  % Reconstruct from projection
    bg_err = rec_im - true_bg;
    
    
    BG_SEV = reshape(BG_SEV,blk_sz,blk_sz);
    
    BiNonPCA = phiNonPCA'*Xi;    % Project onto Weakest EigenVectors
    BG_WEV = phiNonPCA*BiNonPCA+mu;  % Reconstruct from projection
    BG_WEV = reshape(BG_WEV,blk_sz,blk_sz);
    
    threshold = 30;
    FG_SEV = abs(BG_SEV-double(sample_frame))>threshold;
    FG_WEV = abs(BG_WEV-double(sample_frame))>threshold;
    
%     figure(1);
%     subplot(2,3,1); imshow(sample_frame);title('Current Frame');
%     subplot(2,3,2);imshow(uint8(BG_SEV));title('EigenBackground-StrongEigenVectors')
%     subplot(2,3,3);imagesc(uint8(FG_SEV));
%     title('Detected Foreground'); axis equal; axis off;
%     subplot(2,3,4); imshow(sample_frame);title('Current Frame');
%     subplot(2,3,5);imshow(uint8(BG_WEV));title('EigenBackground-WeakEigenVectors')
%     subplot(2,3,6);imagesc(uint8(FG_WEV));
%     title('Detected Foreground'); axis equal; axis off;
    
    output_path = ['output/highway/ev_frames_1_' num2str(n_frames)];
    mkdir(output_path)
    file_name = sprintf('%s/%d_r-%d_%d', output_path,blk_sz,n_eigen_vectors,sample_frame_no);
%     imwrite(sample_frame,[file_name '.jpg']);
%     imwrite(uint8(BG_SEV),[file_name '_StrongEigenVectors_BG.jpg']);
%     imwrite(histeq(uint8(BG_SEV)),[file_name '_StrongEigenVectors_BG_heq.jpg']);
%     imwrite(FG_SEV,[file_name '_StrongEigenVectors_FG.png']);
    x = phi;
    x = (x-min(x))/(max(x)-min(x))*255;
    imwrite(uint8(reshape(x,blk_sz,blk_sz)),[file_name '_StrongEigenVectors_raw.png']);
%     
%     
%     imwrite(uint8(BG_WEV),[file_name '_WeakEigenVectors_BG.jpg']);
%     imwrite(histeq(uint8(BG_WEV)),[file_name '_WeakEigenVectors_BG_heq.jpg']);
%     imwrite(FG_WEV,[file_name '_WeakEigenVectors_FG.png']);
%     x = phiNonPCA;
%     x = (x-min(x))/(max(x)-min(x))*255;
%     imwrite(uint8(reshape(x,blk_sz,blk_sz)),[file_name '_WeakEigenVectors_raw.png']);
    
end


