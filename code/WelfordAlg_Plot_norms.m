% M.Amintoosi 
clear
addpath('utils')
load('input/BGSamplePixels_highway_3pointsBGDetection.mat')
X(:,2) = [];
[n d] = size(X);
% x = rand(5,2);
rng(7)%'default') % For producing the same result
% idx = randperm(n);
rndIdx = randperm(n);
% idx = 1:n
% fIdx = F_indices;% find(idx <= nF);
% bIdx = F_indices; %find(idx > nF);

[sharedvals,fIdx] = intersect(rndIdx,F_indices,'stable');
[sharedvals,bIdx] = intersect(rndIdx,B_indices,'stable');
x = X(rndIdx,:);
fIdx = fIdx';
bIdx = bIdx';
% Normalise x
% z = sum(x, 1);
% z(z==0) = 1;
% x = bsxfun(@rdivide, x, z);

% cov(x)
M{1} = x(1,:)'; S{1} = zeros(2) ;
[Vk_1,Dk_1] = svd(S{1});
lambda(1) = Dk_1(1);
Snorms = zeros(size(x,1),1);
dSnorms = Snorms;
spectroms = Snorms;
E{1} = zeros(size(x,2));
for k=2:size(x,1)
    M{k} = M{k-1}+ (x(k,:)' - M{k-1})/k;
    %     k
    %     ds = (x(k,:)' - M{k})*(x(k,:) - M{k}');
    E{k} = (x(k,:)' - M{k-1})*(x(k,:) - M{k}');
    S{k} = S{k-1} + E{k};
    %     S{k}
    %     S{k} = S{k-1} + (k-1)/k*(x(k,:)' - M{k-1})*(x(k,:) - M{k-1}');
    [Vk,Dk] = svd(S{k});
    lambda(k) = Dk(1);
    Snorms(k) = norm(Vk(:,1)-Vk_1(:,1));
    dSnorms(k) = norm((x(k,:)' - M{k}));
    spectroms(k) = ((x(k,:)' - M{k})'*(x(k,:)' - M{k}));
    Vk_1 = Vk; Dk_1 = Dk;
    alpha(k) = norm(inv(S{k-1}-lambda(k-1)*eye(d)));
    %     sprintf('||v''-v||=%f , beta=%f', Snorms(k), 2*alpha(k))
end
% s2 = S{k}/(k-1)
%%
figure(1);clf
subplot(311);
hold on
plot(log([Snorms]),'LineWidth',2); title('Eigenvectors Diff: ||v-v''||');
plot(fIdx,log(Snorms(fIdx)),'*g','LineWidth',2,'MarkerSize',10);
hold off
subplot(312);
hold on
plot(log(dSnorms),'LineWidth',2); title('norm(x_n-\mu)')
plot(fIdx,log(dSnorms(fIdx)),'*g','LineWidth',2,'MarkerSize',10);
hold off
subplot(313);
hold on
plot(log(spectroms),'LineWidth',2); title('(x_n-\mu)^T(x_n-\mu)')
plot(fIdx,log(spectroms(fIdx)),'*g','LineWidth',2,'MarkerSize',10);
hold off

masir = sprintf('output/PCA_vector_rnd');
mkdir(masir);

dataFileName = sprintf('%s/Snorms.txt',masir);
fid = fopen(dataFileName,'wt');
fprintf(fid,'%d \t %d \n',[(1:numel(Snorms)); Snorms']);
fclose(fid);
dataFileName = sprintf('%s/SnormsFs.txt',masir);
fid = fopen(dataFileName,'wt');
fprintf(fid,'x \t y \t label \n');
fprintf(fid,'%d \t %d \t F\n',[fIdx; Snorms(fIdx)']);
fprintf(fid,'%d \t %d \t B\n',[bIdx; Snorms(bIdx)']);
fclose(fid);

dataFileName = sprintf('%s/dSnorms.txt',masir);
fid = fopen(dataFileName,'wt');
fprintf(fid,'%d \t %d \n',[(1:numel(dSnorms)); dSnorms']);
fclose(fid);
dataFileName = sprintf('%s/dSnormsFs.txt',masir);
fid = fopen(dataFileName,'wt');
fprintf(fid,'x \t y \t label \n');
fprintf(fid,'%d \t %d \t F\n',[fIdx; dSnorms(fIdx)']);
fprintf(fid,'%d \t %d \t B\n',[bIdx; dSnorms(bIdx)']);
fclose(fid);

%%
mu_b = mean(x(bIdx,:))';
mu_f = mean(x(fIdx,:))';
C = mu_b'*mu_b - 2*mu_b'*mu_f + mu_f'*mu_f;
% E_b = zeros(size(x,2));
% nE_b = zeros(size(x,1),1); % nE: normE similar to spectroms
% for k=bIdx
%     E_b = E_b + E{k};
%     nE_b(k) = norm(E{k});
% end
% EnormE_b = sum(nE_b(bIdx))/numel(bIdx)
Sigma2b = sum(var(x(bIdx,:)))
sprintf('E(||v''-v||)=%f , Sigma2_b*C=%f, Sigma2_b = %f, C=%f', mean(Snorms(bIdx)), Sigma2b*C, Sigma2b , C)

Sigma2f = sum(var(x(fIdx,:)))
sprintf('E(||v''-v||)=%f , Sigma2_f*C=%f, Sigma2_f = %f, C=%f', mean(Snorms(fIdx)), Sigma2f*C, Sigma2f , C)
%% Correctness Checking
% SS = zeros(d);
% m = mean(x);
% for k=1:n
%     SS = SS + (x(k,:)-m)'*(x(k,:)-m);
% end
% SS