% Mahmood AminToosi, HSU, 2021
% Foreground Detection
% EigenBackground, using the first and the last eigenvectors

clear all
% loading only one 40x40 block of highway video
load('input/BGSamplePixels_highway.mat')
% Indices of background and foreground frames are indicated manually 

blk_sz = 40;

true_bg = mean(B(:,B_indices),2);
true_bg_im = uint8(reshape(true_bg, blk_sz,blk_sz));

n_frames = 31; % Number of PCs will be n_frames-1
B(:,n_frames+1:end) = [];
%
% Background modeling
[pc,score,v,tsquare,ex,mu] = pca(B');

ev_list = {...
    [1],...
    [1:7],...
    [1:30],...
    [24:30],...
    [30],...
    };
xlabels = {'1','1-7','1-30','24-30','30'};

frames_list = 1:n_frames-1;
Rec_errors = zeros(numel(ev_list),numel(frames_list));
BG_errors = Rec_errors;


for sample_frame_no = frames_list
    im = uint8(B(:,sample_frame_no));
    sample_frame = reshape(im,blk_sz,blk_sz);
    sample_frame_col = B(:,sample_frame_no);
    rec_error = zeros(numel(ev_list),1);
    bg_error = rec_error;
    
    figure(1); clf
    if any(B_indices==sample_frame_no)
        bg_or_fg = ' is Background';
    else
        bg_or_fg = ' is Foreground';
    end
    subplot(5,3,1); imshow(sample_frame);title(['Frame No. ', num2str(sample_frame_no), bg_or_fg]);
    threshold = 25;
    FG_REAL = abs(double(true_bg_im)-double(sample_frame))>threshold;
    subplot(5,3,4);imagesc(uint8(FG_REAL));
    title('|Frame-GT BG|'); axis equal; axis off;
    for evs_idx = 1:numel(ev_list)
        eigen_vectors = ev_list{evs_idx};
        phi=pc(:,eigen_vectors);
        
        Xi = sample_frame_col - mu';
        Bi = phi'*Xi;    % Project onto Selected EigenVectors
        rec_im = phi*Bi+mu';
        
        rec_err = rec_im - sample_frame_col;
        rec_error(evs_idx) = sqrt(mean(rec_err(:).^2));
        bg_err = rec_im - true_bg;
        bg_error(evs_idx) = sqrt(mean(bg_err(:).^2));
        
        Rec_errors(:,sample_frame_no) = rec_error;
        BG_errors(:,sample_frame_no) = bg_error;
        
        BG_EV = reshape(rec_im,blk_sz,blk_sz);
        FG_EV = abs(BG_EV-double(sample_frame))>threshold;
        
        subplot(5,3,(evs_idx-1)*3+2);imshow(uint8(BG_EV));%title('EigenBackground')
        title(['Recon. by EVs: ', xlabels{evs_idx}])
        subplot(5,3,(evs_idx-1)*3+3);imagesc(uint8(FG_EV));
        title('EV Foreground'); axis equal; axis off;
                
        if any([5,9,15,17] == sample_frame_no)
                output_path = ['output/highway/ev_frames_1_' num2str(n_frames)];
                mkdir(output_path)
                file_name = sprintf('%s/%d_ev-%s', output_path,sample_frame_no,xlabels{evs_idx});
                imwrite(uint8(BG_EV),[file_name '_BG_EV.jpg']);
                imwrite(FG_EV,[file_name '_FG_EV.jpg']);
                imwrite(FG_REAL,sprintf('%s/%d_GT.jpg', output_path,sample_frame_no));
                imwrite(sample_frame,sprintf('%s/%d.jpg', output_path,sample_frame_no));
        end
    end
end


%%
figNo = 2;
figure(figNo), clf
frames_lst = intersect(frames_list,B_indices);
mean_Rec_errors = mean(Rec_errors(:,frames_lst),2);
[v,idx] = min(mean_Rec_errors);
subplot(2,1,1)
plot(Rec_errors(:,frames_lst),'Color','b'), ylabel('RMSE(RecIm-Im)')
hold on
plot(mean_Rec_errors,'Color','k','LineWidth',2)
plot(idx,v,'gp','MarkerSize',10)
xticks(1:numel(ev_list))
xticklabels(xlabels)
xtickangle(90)
title('Background frames')
hold off

mean_BG_errors = mean(BG_errors(:,frames_lst),2);
[v,idx] = min(mean_BG_errors);
subplot(2,1,2)
plot(BG_errors(:,frames_lst),'Color','b'), ylabel('RMSE(RecIm-GT)')
hold on
plot(mean_BG_errors,'Color','k','LineWidth',2)
plot(idx,v,'gp','MarkerSize',10)
xticks(1:numel(ev_list))
xticklabels(xlabels)
xtickangle(90)
hold off

output_path = ['output/highway/ev_frames_1_' num2str(n_frames)];
mkdir(output_path)
file_name = sprintf('%s/RMSE_BGs.png', output_path);
print(gcf,'-dpng',file_name);

figNo = 3;
figure(figNo), clf
frames_lst = intersect(frames_list,F_indices);
mean_Rec_errors = mean(Rec_errors(:,frames_lst),2);
[v,idx] = min(mean_Rec_errors);
subplot(2,1,1)
plot(Rec_errors(:,frames_lst),'Color','r'), ylabel('RMSE(RecIm-Im)')
hold on

plot(mean_Rec_errors,'Color','k','LineWidth',2)
plot(idx,v,'gp','MarkerSize',10)
xticks(1:numel(ev_list))
xticklabels(xlabels)
xtickangle(90)
title('Foreground frames')
hold off

mean_BG_errors = mean(BG_errors(:,frames_lst),2);
[v,idx] = min(mean_BG_errors);
subplot(2,1,2)
plot(BG_errors(:,frames_lst),'Color','r'), ylabel('RMSE(RecIm-GT)')
hold on
plot(mean_BG_errors,'Color','k','LineWidth',2)
plot(idx,v,'gp','MarkerSize',10)
xticks(1:numel(ev_list))
xticklabels(xlabels)
xtickangle(90)
hold off

file_name = sprintf('%s/RMSE_FGs.png', output_path);
print(gcf,'-dpng',file_name);
