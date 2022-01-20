% Mahmood AminToosi, HSU, 2021
% Foreground Detection
% EigenBackground, using the first and the last eigenvectors

clear all
% loading only one 40x40 block of shoppingMall video
load('input/BGSamplePixels_shoppingMall.mat')

blk_sz = 40;

true_bg = mean(B(:,B_indices),2);
true_bg_im = uint8(reshape(true_bg, blk_sz,blk_sz));

n_frames = 31; % Number of PCs will be n_frames-1
% B(:,n_frames+1:end) = [];

%
% Background modeling
[pc,score,v,tsquare,ex,mu] = pca(B(:,1:n_frames)');

ev_list = {...
    [1],...
    [1:7],...
    [1:30],...
    [24:30],...
    [30],...
    %     [1 ,29,30]
    };
xlabels = {'1','1-7','1-30','24-30','30'};
% for i = 1:numel(ev_list)
%     xlabels{i} = num2str(ev_list{i});
% end

frames_list = 1:200;%n_frames-1;%[9,16];
Rec_errors = zeros(numel(ev_list),numel(frames_list));
BG_errors = Rec_errors;

figNo = 2;
for sample_frame_no = frames_list
    im = uint8(B(:,sample_frame_no));
    sample_frame = reshape(im,blk_sz,blk_sz);
    sample_frame_col = B(:,sample_frame_no);
    rec_error = zeros(numel(ev_list),1);
    bg_error = rec_error;
    
%    figure(1); clf
    if any(B_indices==sample_frame_no)
        bg_or_fg = ' is Background';
    else
        bg_or_fg = ' is Foreground';
    end
%     subplot(5,3,1); imshow(sample_frame);title(['Frame No. ', num2str(sample_frame_no), bg_or_fg]);
    threshold = 25;
    FG_REAL = abs(double(true_bg_im)-double(sample_frame))>threshold;
%     subplot(5,3,4);imagesc(uint8(FG_REAL));
%     title('|Frame-GT BG|'); axis equal; axis off;
    for evs_idx = 1:numel(ev_list)
        eigen_vectors = ev_list{evs_idx};
        phi=pc(:,eigen_vectors);
        
        %         rec_im = mu+score(sample_frame_no,eigen_vectors)*phi';
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
        
%         subplot(5,3,(evs_idx-1)*3+2);imshow(uint8(BG_EV));%title('EigenBackground')
%         title(['Recon. by EVs: ', xlabels{evs_idx}])
%         subplot(5,3,(evs_idx-1)*3+3);imagesc(uint8(FG_EV));
%         title('EV Foreground'); axis equal; axis off;
%         
%         %     subplot(2,3,4); imshow(sample_frame);title('Current Frame');
%         %     subplot(2,3,5);imshow(uint8(BG_WEV));title('EigenBackground-WeakEigenVectors')
%         %     subplot(2,3,6);imagesc(uint8(FG_WEV));
%         %     title('Detected Foreground'); axis equal; axis off;
%         
%         if any([5,9,15,17] == sample_frame_no)
%                 output_path = ['output/shoppingMall/ev_frames_1_' num2str(n_frames)];
%                 mkdir(output_path)
%                 file_name = sprintf('%s/%d_ev-%s', output_path,sample_frame_no,xlabels{evs_idx});
%                 imwrite(uint8(BG_EV),[file_name '_BG_EV.jpg']);
%                 imwrite(FG_EV,[file_name '_FG_EV.jpg']);
%                 imwrite(FG_REAL,sprintf('%s/%d_GT.jpg', output_path,sample_frame_no));
%                 imwrite(sample_frame,sprintf('%s/%d.jpg', output_path,sample_frame_no));
%         end
    end
    
    %     figure(figNo)
    %
    %     subplot(2,1,1)
    %     plot(rec_error), ylabel('Recon Error')
    %     xticks(1:numel(ev_list))
    %     xticklabels(xlabels)
    %     xtickangle(90)
    %     if any(B_indices == sample_frame_no), title('a background frame')
    %     else, title('a foreground frame'),    end
    %
    %     subplot(2,1,2)
    %     plot(bg_error), ylabel('True BG Error')
    %     xticks(1:numel(ev_list))
    %     xticklabels(xlabels)
    %     xtickangle(90)
    %     figNo = figNo+1;
    %     if any(B_indices == sample_frame_no), title('a background frame')
    %     else, title('a foreground frame'),    end
    %     break
%     pause
end


%%
figNo = 2;
figure(figNo), clf
% cmap = colormap(gray(100));
frames_lst = intersect(frames_list,B_indices);
mean_Rec_errors = mean(Rec_errors(:,frames_lst),2);
[v,idx] = min(mean_Rec_errors);
ax1 = subplot(2,1,1);
plot(Rec_errors(:,frames_lst),'Color','b'), ylabel('RMSE($\widehat{BG}-Im$)','interpreter','latex')
hold on
% set(gca,'ColorOrder',cmap)
% plot(mean_Rec_errors,'Color','k','LineWidth',2)
% plot(idx,v,'gp','MarkerSize',10)
xticks(1:numel(ev_list))
xticklabels(xlabels)
xtickangle(90)
title('Errors')
% hold off

mean_BG_errors = mean(BG_errors(:,frames_lst),2);
[v,idx] = min(mean_BG_errors);
subplot(2,1,2)
plot(BG_errors(:,frames_lst),'Color','b'), ylabel('RMSE($\widehat{BG}-GT$)','interpreter','latex')
hold on
% plot(mean_BG_errors,'Color','k','LineWidth',2)
% plot(idx,v,'gp','MarkerSize',10)
xticks(1:numel(ev_list))
xticklabels(xlabels)
xtickangle(90)
% hold off

output_path = ['output/shoppingMall/ev_frames_1_' num2str(n_frames)];
mkdir(output_path)
% file_name = sprintf('%s/RMSE_BGs.png', output_path);
% print(gcf,'-dpng',file_name);

% figNo = figNo+1;
% figure(figNo), clf
frames_lst = intersect(frames_list,F_indices);
mean_Rec_errors = mean(Rec_errors(:,frames_lst),2);
[v,idx] = min(mean_Rec_errors);
subplot(2,1,1)
plot(Rec_errors(:,frames_lst),'Color','r')%, ylabel('RMSE(RecIm-Im)')
hold on
% set(gca,'ColorOrder',cmap)
% plot(mean_Rec_errors,'Color','k','LineWidth',2)
% plot(idx,v,'gp','MarkerSize',10)
xticks(1:numel(ev_list))
xticklabels(xlabels)
xtickangle(90)
% title('Foreground frames')

b = plot(Rec_errors(:,B_indices(1)),'Color','b');
% hold on
f = plot(Rec_errors(:,F_indices(1)),'Color','r');
legend(ax1,[b,f] ,'Backgrounds','Foregrounds')
hold off

mean_BG_errors = mean(BG_errors(:,frames_lst),2);
[v,idx] = min(mean_BG_errors);
ax2 = subplot(2,1,2);
plot(BG_errors(:,frames_lst),'Color','r'),% ylabel('RMSE(RecIm-GT)')
hold on
% plot(mean_BG_errors,'Color','k','LineWidth',2)
% plot(idx,v,'gp','MarkerSize',10)
xticks(1:numel(ev_list))
xticklabels(xlabels)
xtickangle(90)

% Find the foregrounds with minimum BG_errors
frames_lst = intersect(frames_list,F_indices);
evs_idx = 3; %All frames

[v,idx] = max(BG_errors(evs_idx,frames_lst));
max_f = plot(evs_idx,v,'ms','MarkerSize',10); %text(evs_idx,v,'Forground Frame with max err')
file_name = sprintf('%s/max_F_%d-%s.jpg', output_path,F_indices(idx),xlabels{evs_idx});
imwrite(uint8(reshape(B(:,F_indices(idx)),blk_sz,blk_sz)),file_name);

[v,idx] = min(BG_errors(evs_idx,frames_lst));
min_f = plot(evs_idx,v,'g<','MarkerSize',10); %text(evs_idx,v,'Forground Frame with min err')
file_name = sprintf('%s/min_F_%d-%s.jpg', output_path,F_indices(idx),xlabels{evs_idx});
imwrite(uint8(reshape(B(:,F_indices(idx)),blk_sz,blk_sz)),file_name);

b = plot(BG_errors(:,B_indices(1)),'Color','b');
f = plot(BG_errors(:,F_indices(1)),'Color','r');
legend(ax2,[b,f,max_f,min_f] ,'Backgrounds','Foregrounds','FG with max err','FG with min err')


hold off

file_name = sprintf('%s/RMSE_rec_bg.png', output_path);
print(gcf,'-dpng',file_name);

% figNo = figNo+1;
% figure(figNo), clf
% frames_lst = 1:n_frames-1;
% % frames_lst = intersect(frames_list,F_indices);
% mean_Rec_errors = mean(Rec_errors(:,frames_lst),2);
% [v,idx] = min(mean_Rec_errors);
% subplot(2,1,1)
% plot(Rec_errors(:,frames_lst),'Color','r'), ylabel('RMSE(RecIm-Im)')
% hold on
% % set(gca,'ColorOrder',cmap)
% plot(mean_Rec_errors,'Color','k','LineWidth',2)
% plot(idx,v,'gp','MarkerSize',10)
% xticks(1:numel(ev_list))
% xticklabels(xlabels)
% xtickangle(90)
% title('Foreground frames')
% hold off
% 
% mean_BG_errors = mean(BG_errors(:,frames_lst),2);
% [v,idx] = min(mean_BG_errors);
% subplot(2,1,2)
% plot(BG_errors(:,frames_lst),'Color','r'), ylabel('RMSE(RecIm-GT)')
% hold on
% plot(mean_BG_errors,'Color','k','LineWidth',2)
% plot(idx,v,'gp','MarkerSize',10)
% xticks(1:numel(ev_list))
% xticklabels(xlabels)
% xtickangle(90)
% hold off
% 
% file_name = sprintf('%s/RMSE_All.png', output_path);
% print(gcf,'-dpng',file_name);


%
% bg_frame_no = 20;
%
% sample_frame_no = 15;
% im = uint8(B(:,sample_frame_no));
% sample_frame = reshape(im,blk_sz,blk_sz);
%
%
% figure(2);
% subplot(2,2,1)
% bg_frame = reshape(uint8(B(:,bg_frame_no)),blk_sz,blk_sz);
% imshow(bg_frame);title('Current Frame');
%
% im_rec = mu+score(bg_frame_no,:)*pc';
% subplot(2,2,2)
% imshow(reshape(uint8(im_rec),blk_sz,blk_sz));title('Rec');
% subplot(2,1,2)
% bar(score(bg_frame_no,:))
%
% % bar(abs([score(bg_frame_no,:)', score(sample_frame_no,:)']))
%
% figure(3);
% subplot(2,2,1)
% imshow(sample_frame);title('Current Frame');
%
% im_rec = mu+score(sample_frame_no,:)*pc';
% subplot(2,2,2)
% imshow(reshape(uint8(im_rec),blk_sz,blk_sz));title('Rec');
% subplot(2,1,2)
% bar(score(sample_frame_no,:))
%
%
% % bar(log(abs([score(bg_frame_no,:)', score(sample_frame_no,:)'])))
