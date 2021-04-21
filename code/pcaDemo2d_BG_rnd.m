%% Visualize projection onto the principal components
%
%% Modified by M.Amintoosi

% This file is from pmtk3.googlecode.com

% setSeed(0);
% nF = 5; % Number of Background Samples
% nB = 5; % Number of Foreground Samples
% n = nF + nB;
% sB = .2; % Sigma of Background
% X=[randn(nF,2)+2.*ones(nF,2);sB.*randn(nB,2)-1.*ones(nB,2)];
%%
addpath('utils')
load('input/BGSamplePixels_highway_3pointsBGDetection.mat')
X3ta = X;
%%
X(:,2) = [];
XOrig = X;%/256;
% X(1:10,:) = [];
% nF = nF-10;
N = size(X,1);
fIdx = 1:nF;
bIdx = nF+1:N;
rng(7)%'default') % For producing the same result
rndIdx = randperm(N);
for nb = [10,50,90:30:N]%[6,16,51,101]
    indices = 1:nb;
    rndIndices = rndIdx(indices);
    X = XOrig(rndIndices,:);
%     X(nb+1:end,:) = [];
    ffIdx = intersect(rndIndices,F_indices,'stable')
    bbIdx = intersect(rndIndices,B_indices,'stable')
    %%
    [n d] = size(X);
    cov(X(end,:)',1)
    [W, Z, evals, Xrecon, mu] = pcaPmtk(X, 1);
    
    figure(3); clf
    plot(mu(1), mu(2), '*', 'markersize', 20, 'color', 'r');
    hold on
    plot(XOrig(ffIdx,1), XOrig(ffIdx,2), 'ro', 'markersize', 10);
    plot(XOrig(bbIdx,1), XOrig(bbIdx,2), 'bx', 'markersize', 10);
    plot(Xrecon(:,1), Xrecon(:,2), 'g.', 'markersize', 20, 'linewidth',2);
    for i=1:n
        h=line([Xrecon(i,1) X(i,1)], [Xrecon(i,2) X(i,2)], 'color', 'b');
    end
    % plot the linear subspace
    Z2 = [-360;350]; % 2 ``extreme'' points in latent space
    Xrecon2 = Z2*W' + repmat(mu, 2,1);
    h=line([Xrecon2(1,1) Xrecon2(2,1)], [Xrecon2(1,2) Xrecon2(2,2)], 'color', 'm');
    axis equal
    axis([0 250 0 250])
    %     axis([0 1 0 1])
    
%     fileName = sprintf('pca2D_BG_rnd_%d',nb-1);
%     printPmtkFigure(fileName,'png','output');
%     pause
    % Produce LaTeX data
    masir = sprintf('output/PCA_vector_rnd');
    mkdir(masir);
    
    dataFileName = sprintf('%s/%d_data.txt',masir,nb);
    fid = fopen(dataFileName,'wt');
    fprintf(fid,'x \t y \t label \n');
    fprintf(fid,'%d \t %d \t F \n',[XOrig(ffIdx,1)'; XOrig(ffIdx,2)']);
    fprintf(fid,'%d \t %d \t B \n',[XOrig(bbIdx,1)'; XOrig(bbIdx,2)']);
    fprintf(fid,'%6.2f \t %6.2f \t R \n',[Xrecon(:,1)'; Xrecon(:,2)']);
    fclose(fid);
    
    dataFileName = sprintf('%s/%d_lines.txt',masir,nb);
    fid = fopen(dataFileName,'wt');
    fprintf(fid,'\\draw [green,line width=1.4pt] (%6.2f,%6.2f)--(%6.2f,%6.2f); \n',...
            Xrecon2(1,1),Xrecon2(1,2), Xrecon2(2,1), Xrecon2(2,2));
    for i=1:n
        fprintf(fid,'\\draw [black,dotted] (%6.2f,%6.2f)--(%6.2f,%6.2f); \n',...
            Xrecon(i,1), Xrecon(i,2), X(i,1),X(i,2));
    end
    fclose(fid);
%     pause
end
%ll = ppcaLogprob(X, W, mu, sigma2, evecs, evals)

%%
% page 25 Eigen Value Analysis in Pattern Recognition-Tutorial by Dr Asmat
% e=||X-Xrec|| = .5* sum_{k+1}^n lambda_i
% e=0; for i=1:n, e=e+norm(X(i,:)-Xrecon(i,:)); end
% e
% evals(2)/2
% %%
% figure(10)
% h = 40; w = 40;
% rndIdx = 1:121;
% X = B(:,rndIdx);
% fFrame = X(:,1);
% B_indices = [1];
% F_indices = []
% for i=2:121
%     subplot(10,12,i-1)
%     cFrame = X(:,i);
%     f = reshape(cFrame, [h w]);
%     imagesc(f);  axis off; colormap gray
%     nbRndIdx = rndIdx(i);
% %     if nbRndIdx<=nF,  title('ForeGround'), end
%     norm(cFrame-fFrame)
%     if norm(cFrame-fFrame)>200, 
%         title(num2str(i)), 
%         F_indices = [F_indices,i];
%     else
%         B_indices = [B_indices,i];
%     end
% end
% nB = numel(B_indices);
% nF = numel(F_indices);
% X = X3ta;
% % save('BGSamplePixels_highway_3pointsBGDetection_2020.mat',...
% %     'X','nB','nF','B_indices','F_indices','B')
