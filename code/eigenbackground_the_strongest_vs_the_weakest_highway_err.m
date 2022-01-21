% Mahmood AminToosi, HSU, 2022
% EigenBackground, using the first and the last eigenvectors

% loading only one 40x40 block of highway video
load('input/BGSamplePixels_highway_3pointsBGDetection.mat')
load('tmp/highway_GT.mat', 'true_bg')

n_frames = 120;
sample_frame_no = 16;

im = uint8(B(:,sample_frame_no));

blk_sz = 40; 

BG_ImPCA=double(im);
BG_ImNonPCA=BG_ImPCA;
Bg_ImMean=BG_ImPCA;
Bg_Princomp=BG_ImPCA;

% Background modeling
[pc,score,v,tsquare] = pca(B');
mu = mean(B,2);
print_list = [1, 3, 5, 7, 114, 116, 118, 120]; 
for n_eigen_vector=1:n_frames
    
    phi=pc(:,n_eigen_vector);
    
    sample_frame = reshape(im,blk_sz,blk_sz);
    sample_frame_col = B(:,sample_frame_no);
    Xi = sample_frame_col - mu;
    Bi = phi'*Xi;    % Project onto Strongest EigenVectors
    BG_EV = phi*Bi+mu;  % Reconstruct from projection
    bg_err = BG_EV - true_bg;
    bg_error(n_eigen_vector) = sqrt(mean(bg_err(:).^2));
    
    BG_EV = reshape(BG_EV,blk_sz,blk_sz);
        
    threshold = 30;
    FG_SEV = abs(BG_EV-double(sample_frame))>threshold;
    
    if any(n_eigen_vector==print_list)
    figure(1);
    subplot(1,2,1); imshow(sample_frame);title('Frame No. 16:  ')
    subplot(1,2,2);imshow(uint8(BG_EV));title(sprintf('Recon. BG of 16 on EV %d, RMSE=%4.2f',n_eigen_vector, bg_error(n_eigen_vector)));
    pause(1)
    
    output_path = ['output/highway/ev_frames_1_' num2str(n_frames)];
    mkdir(output_path)
    file_name = sprintf('%s/EV-%d_%d', output_path,n_eigen_vector,sample_frame_no);
    imwrite(uint8(BG_EV),[file_name '.jpg']);
    end
end

