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
clear
addpath('utils')
load('input/BGSamplePixels_highway_3pointsBGDetection.mat')
X(:,2) = [];
XOrig = X;
% X(1:10,:) = [];
% nF = nF-10;
for nb = 30:30:120%[6,16,51,101] % 
    X = XOrig;
    X(nb:end,:) = [];
    %%
    [n d] = size(X);
    cov(X(end,:)',1)
    [W, Z, evals, Xrecon, mu] = pcaPmtk(X, 1);
    fIdices = ...
    figure(3); clf
    plot(mu(1), mu(2), '*', 'markersize', 20, 'color', 'r');
    hold on
    plot(X(1:nF,1), X(1:nF,2), 'ro', 'markersize', 10);
    plot(X(nF+1:end,1), X(nF+1:end,2), 'bs', 'markersize', 10);
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
    
    fileName = sprintf('pca2D_BG_%d',nb-1);
    printPmtkFigure(fileName,'png','output/PCA_vector');
    pause(0.5)
end
