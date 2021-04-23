% M. Amintoosi

load('BGSamplePixels_highway.mat')
figure(5)

for i = 1:100
    Im=uint8(reshape(B(:,i),40,40));
    subplot(10,10,i)
    imshow(Im)
end