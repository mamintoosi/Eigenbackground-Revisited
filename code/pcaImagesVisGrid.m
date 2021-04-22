%% Embed the digit 3 into 2D and sample from the space
% Reproduce fig 14.23 from Hastie's book p489
%%
% Modified by: M.Amintoosi
% This file is from pmtk3.googlecode.com
%         load('BGSamplePixels');
addpath('utils')
videoFileName = 'highway'
load(['input/BGSamplePixels_' videoFileName]);
X = B';
XOrig = X;
X = XOrig(:,1:16:1600);
h = 10; w = 10;


% Hastie's book p489 recommends computing quantiles of ui1, ui2
% to compute the grid location to sample represenative images in latent space
mu = mean(X);
XC = X-repmat(mu,size(X,1),1);
[U,S,V] = svd(XC,0);
% pc1No = 91;
% pc2No = 92;
for pc1No = 1:4:size(U,2)-1%99
    pc2No = pc1No+1;
    pc = [-U(:,pc1No) -U(:,pc2No)]; % to match fig 14.23 of HTF
    % pc = U*S; pc = [pc(:,pc1No) pc(:,pc2No)];
    
    gridForm = {'uniformPoints'};%,'quantilePoints'};
    for gf = 1:numel(gridForm)
        masirImg = sprintf('output/%s/%s/%d_%d',videoFileName, gridForm{gf},pc1No,pc2No);
        mkdir(masirImg);
        masir = sprintf('output/%s/%s',videoFileName, gridForm{gf});
        mkdir(masir);
        dataFileName = sprintf('%s/%d_%d.txt',masir,pc1No,pc2No);
        fid = fopen(dataFileName,'wt');
        fprintf(fid,'x \t y \t label \n');
        
        if gf==1
            pct1 = linspace(min(pc(:,1)),max(pc(:,1)), 5)';
            pct2 = linspace(min(pc(:,2)),max(pc(:,2)), 5)';
        else
            pct1 = quantilePMTK(pc(:,1), [0.05 0.25 0.5 0.75 0.95]);
            pct2 = quantilePMTK(pc(:,2), [0.05 0.25 0.5 0.75 0.95]);
        end
        
        fig1 = figure(1);clf
        fig2 = figure(2);clf
        
        figure(fig1);
        hold on
        %     plot(pc(:,1), pc(:,2), '.');
        %     xlabel('First Principal Component');
        %     ylabel('Second Principal Component');
        xlabel(sprintf('Principal Component #%d',pc1No));
        ylabel(sprintf('Principal Component #%d',pc2No))
        for i=1:5
            line([pct1(i) pct1(i)], [pct2(1) pct2(end)]);
            line([pct1(1) pct1(end)], [pct2(i) pct2(i)]);
        end
        pct2r = flipud(pct2); % top left image corresponds to +ve Z2
        for i=1:5
            for j=1:5
                figure(fig1);
                x1 = pct1(j); x2 = pct2r(i);
                plot(x1, x2, 'rx');
                %         dst = sqdist([x1 x2]', pc'); M.Amintoosi
                dst = sqDistance([x1 x2], pc);
                k = argmin(dst);
                plot(pc(k,1), pc(k,2), 'ro');
                fprintf(fid,'%f \t %f \t O \n',pc(k,1), pc(k,2));
                
                %         text(pc(k,1), pc(k,2), sprintf('(%d,%d)',i,j));
                figure(fig2); subplot2(5,5,i,j); hold on
                imshow(uint8(reshape(XOrig(k,:),[40 40])))
                imwrite(uint8(reshape(XOrig(k,:),[40 40])),sprintf('%s/im%d%d.png',masirImg,i,j));
%                 imshow(uint8(reshape(X(k,:),[h w])));
            end
        end
        figure(fig1);
        plot(pc(B_indices,1), pc(B_indices,2), '+b');
        plot(pc(F_indices,1), pc(F_indices,2), '.g'); %% Incorrect
        hold off
        
        fprintf(fid,'%f \t %f \t B \n',[pc(B_indices,1)'; pc(B_indices,2)']);
        fprintf(fid,'%f \t %f \t F \n',[pc(F_indices,1)'; pc(F_indices,2)']);
        
        fclose(fid);
        %%
        figure(fig1)
        %     plot(pc(:,1), pc(:,2), '.');
        printPmtkFigure(sprintf('%02d_%02d_gridDots',pc1No,pc2No),'png',masir);
        % printPmtkFigure(sprintf('gridDots','png',masir);
        figure(fig2)
        printPmtkFigure(sprintf('%02d_%02d_gridImages',pc1No,pc2No),'png',masir);
        %         printPmtkFigure('gridImages','png',masir);
    end % end gf
    pause(.2)
end
% figure(3);imagesc(reshape(X(73,:),16,16));colormap(gray)
%%
% figure(3);
% for i=1:4
%     subplot(2,2,i);
% %     {i} = U(:,i);
%     imagesc(flipud(reshape(U(:,i),[h w])));
%     axis off square; colormap(gray);
% end
%%
% [W, Z, evals, Xrecon, mu] = pcaPmtk(X, 2);
% figure(3);
% hold on
% plot(Xrecon(nF+1:end,1), Xrecon(nF+1:end,2), '.b');
% plot(Xrecon(1:nF,1), Xrecon(1:nF,2), '.g'); %% Incorrect
% hold off
% figure(3)
% k=1;
% for i=nF-5:nF+5
%     subplot(3,4,k);
%     imshow(uint8((reshape(XOrig(k,:),[40 40])))); axis off square
%     title(sprintf('%d',any(B_indices==k)));
%     k = k+1;
% end