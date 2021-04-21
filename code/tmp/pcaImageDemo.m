%% PCA Image Demo
% Based on code by Mark Girolami, but uses eig instead of svd to save memory
%% Modified by M.Amintoosi

% This file is from pmtk3.googlecode.com
addpath('utils')
setSeed(0);
%         videoFileName = 'highway'
videoFileName = 'highway_3pointsBGDetection'
load(['input/BGSamplePixels_' videoFileName]);
X = B';
%         XOrig = X;
%         X = XOrig(:,1:16:1600);
[n d] = size(X)
h = 40; w = 40;
name = 'Background'

% X(125,2000:2200) = 0;

% Visualize a random subset of the data as a single image
rng('default')
rng(7)
perm = randperm(n);
figure(1); clf
%K = 24; %XX = reshape(X(perm(1:K),:)', [h w 1 K]); montage(XX)
%title(sprintf('%d random training images', K))
for i=1:100
    subplot(10,10,i)
    f = reshape(X(perm(i),:), [h w]);
    imagesc(f);  axis off; colormap gray
end
masir = sprintf('output/%s',videoFileName);
mkdir(masir)
printPmtkFigure(sprintf('pcaImages-%s-images',name),'png',masir);
%%
mu = mean(X);
XC = X-repmat(mu,size(X,1),1);
sprintf('Performing PCA.... stay tuned\n');
%[U,S,V] = svd(XC,0);
%evals = (1/n)*diag(S).^2;
[V, Z, evals] = pcaPmtk(X);

% visualize basis functions (eigenfaces)
figure(2);clf
subplot(2,2,1)
imshow(uint8(reshape(mu,[h w]))); colormap(gray); axis off;
title('mean')
pcNos = 1:100;%[1 2 90];
for i=1:99
    subplot(10,10,i+1)
    pcNo = pcNos(i);
    imagesc((reshape(V(:,pcNo),[h w]))); colormap(gray); axis off square;
    %     imshow(uint8(reshape(V(:,pcNo),[h w]))); colormap(gray); axis off square;
    %title(sprintf('principal basis %d', pcNo))
end
% printPmtkFigure(sprintf('pcaImages-%s-basis',name),'png',masir);
%%

% Plot reconstruction error
figure(3); clf
n = size(X,1);
Ks = [1:10 10:5:50 50:25:rank(X)];
clear mse
for ki=1:length(Ks)
    k = Ks(ki);
    %Xrecon = U(:,1:k) * S(1:k,1:k) * V(:,1:k)' + repmat(mu, n, 1);
    Xrecon = Z(:,1:k)*V(:,1:k)' + repmat(mu, n, 1);
    err = (Xrecon - X);
    mse(ki) = sqrt(mean(err(:).^2));
end
plot(Ks, mse, '-o')
ylabel('mse'); xlabel('K'); title('reconstruction error');
printPmtkFigure(sprintf('pcaImages-%s-recon', name),'png',masir);

% Scree plot
figure(4);clf
plot(cumsum(evals)/sum(evals), 'ko-')
ylabel('proportion of variance')
xlabel('K')
printPmtkFigure(sprintf('pcaImages-%s-scree', name),'png',masir);

%%
% Plot reconstructed image
ndx = 25; % selected face
Ks = [2 10 100 rank(X)];
figure(6);clf
for ki=1:length(Ks)
    k = Ks(ki);
    %Xrecon = U(ndx,1:K) * S(1:K,1:K) * V(:,1:K)' + mu;
    Xrecon = Z(ndx,1:k)*V(:,1:k)' + mu;
    subplot(2,2,ki);
    imagesc(reshape(Xrecon', h, w)); axis off; colormap(gray)
    title(sprintf('reconstructed with %d bases', k))
end
printPmtkFigure(sprintf('pcaImages-%s-reconImages', name),'png',masir);

