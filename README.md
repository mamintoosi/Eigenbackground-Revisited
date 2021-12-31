# Eigenbackground-Revisited
==========
 [![repo size](https://img.shields.io/github/repo-size/mamintoosi/Eigenbackground-Revisited.svg)](https://github.com/mamintoosi/Eigenbackground-Revisited/archive/master.zip)
 [![GitHub forks](https://img.shields.io/github/forks/mamintoosi/Eigenbackground-Revisited)](https://github.com/mamintoosi/Eigenbackground-Revisited/network)
[![GitHub issues](https://img.shields.io/github/issues/mamintoosi/Eigenbackground-Revisited)](https://github.com/mamintoosi/Eigenbackground-Revisited/issues)
[![GitHub license](https://img.shields.io/github/license/mamintoosi/Eigenbackground-Revisited)](https://github.com/mamintoosi/Eigenbackground-Revisited/blob/main/LICENSE)

MATLAB code for the main results of the following paper:<br>
*Eigenbackground Revisited: Can We Model the Background with Eigenvectors?* 

<a href="http://arxiv.org/abs/2104.11379" target="_blank">arxiv link</a>
, <a href="https://github.com/mamintoosi/Eigenbackground-Revisited/raw/master/Eigenbackground_Revisited_Supplementary.pdf" target="_blank">Supp</a>

### Abstract

<p align="justify">
A popular research topic in Graph Convolutional Networks (GCNs) is to speedup
the training time of the network. The main bottleneck in training GCN is the
exponentially growing of computations.  In Cluster-GCN based on this fact that each
node and its neighbors are usually grouped in the same cluster, considers the
clustering structure of the graph, and expand each node’s neighborhood within
each cluster when training GCN. The main assumption of Cluster-GCN is the
weak relation between clusters; which is not correct at all graphs. Here we extend their approach by overlapped clustering, instead of crisp clustering which
is used in Cluster-GCN. This is achieved by allowing the marginal nodes to
contribute to training in more than one cluster. The evaluation of the proposed
method is investigated through the experiments on several benchmark datasets.
The experimental results show that the proposed method is more efficient than
Cluster-GCN, in average.
</p>

## Requirements
The codes are tested on MATLAB 2017 & 2018 in Win10, but should work for other versions, too.

The most codes in folder *code* are related to ['Highway'](./code/input/highway.avi) video, which is used for many experimental results in the paper.

![](./code/input/highway.avi)

## Codes review:

### Eigen_BGDetection.m
This script compute the eigenbackground of the aforementioned 'Highway' video with eigenvectors related to the largest and the weakest eigenvalues. The default number of the eigenvectors is 10, which may be changed by variable *r* in the script.
'Highway' video is 320x240, here the eigenbackground is computed in 40x40 non-overlapping blocks. For testing other block size, it is sufficient to change *winSize* variable. The block size can be considered to the height of the video, if the video frames are square. If you like to runthe program with block size, equal to the frame height, it is sufficient to resize the input video, by uncomment the appropriate command: *avi(k).cdata = im(1:240,1:240)*.

By running this script, the background models will be computed and saved in the folder *code/output/highway*, with the following file names: <br>
*StrongEigenVectors_BG.jpg*  : Background model computed according to the eigenvectors corresponding to the largest eigenvalues<br>
*WeakEigenVectors_BG.jpg*  : Background model computed according to the eigenvectors corresponding to the largest eigenvalues<br>

Also the threshold-ed difference of an specified frame (default 16) with the computed backgrounds is saved, as the foregrounds. These images are also saved in the above folder with the following names:
*16_StrongEigenVectors_FG.jpg*  : Foreground model computed according to the eigenvectors corresponding to the largest eigenvalues<br>
*16_WeakEigenVectors_FG.jpg*  : Foreground model computed according to the eigenvectors corresponding to the largest eigenvalues<br>

The test frame number (16) and the threshold can be changed.
The following table shows the result:

<table>
  <tr>
    <td> Frame No. 16</td>
    <td> B/F using 10 most strong eigenvectors</td>
    <td>B/F using 10 weak eigenvectors</td>
   </tr> 
  <tr>
    <td> <img src="./code/output/highway/16.jpg"  alt="Frame 16" width = 240px ></td>
    <td><img src="./code/output/highway/StrongEigenVectors_BG.jpg" alt="Background - strong vectors" width = 240px ></td>
    <td><img src="./code/output/highway/WeakEigenVectors_BG.jpg" alt="Background - weak vectors" width = 240px ></td>
   </tr> 
   <tr>
    <td> <img src="./code/output/highway/16.jpg"  alt="Frame 16" width = 240px ></td>
    <td><img src="./code/output/highway/16_StrongEigenVectors_FG.png" alt="Foreground - strong vectors" width = 240px ></td>
    <td><img src="./code/output/highway/16_WeakEigenVectors_FG.png" alt="Foreground - weak vectors" width = 240px ></td>
  </tr>
</table>


A 40x40 block demonstrated with a yellow square, shown in the following image, is selected for further investigation:

<img src="./code/tmp/16-40x40.jpg"  alt="Block 40x40 in x=y=5" width = 240px >

### pcaImagesVisGrid.m
This file is used to show the effect of different principal components sub-spaces, figures 12-14 of the paper and their animated versions in supplementary material.
For 'Highway' video, the results are saved in folder 'code/output/highway/uniformPoints'.
For each combination of two successive principal components, such as 97 and 98, an image file (97_98_gridImages.png) is created to show the spread of the frames in that space:

<img src="./code/output/highway/uniformPoints/97_98_gridImages.png"  alt="PC 97 & 98" width = 240px >

Also, a folder named 97_98 is created in the above folder that each image is saved separately for inserting in the paper. The images in each folder is numbered as matrix elements, that can be used later in LaTeX. For example, the following image in the paper is produced by appropriate LaTeX code and the images in the above folder:

<img src="./code/tmp/highway_97_98_images.jpg"  alt="PC 97 & 98" width = 240px >

Demonstration of the background/foreground instances as scatter plots, are also used by MATLAB plot and TikZ commands, which makes the following images; note that some required information are saved as text files.


<img src="./code/output/highway/uniformPoints/97_98_gridDots.png"  alt="PC 97 & 98" width = 290px >  <img src="./code/tmp/highway_97_98_scatter.png"  alt="PC 97 & 98" width = 200px >

For above diagrams, it is necessary to know which frame belongs to background and which frame belongs to foreground. For the aforementioned 40x40 block of 'Highway' video, these classes were marked manually and the results were saved in *code/input/BGSamplePixels_highway.mat*. The script *code/tmp/show_block.m* load and shows this block. In addition the 2 green dots shown in figure 3, were saved in 
*code/input/BGSamplePixels_highway_3pointsBGDetection.mat*.

## pcaDemo2d_BG_rnd.m

This script produce figure 5. Although the MATLAB plot output can be saved in folder , but *code/output/PCA_vector_rnd*, but for achievement better quality, the TikZ data files are saved by this script in the mentioned folder, and in later with LaTeX codes, the plots of figure 5 are created:

<img src="./code/tmp/PCABGRnd.png"  alt="Figure 5" width = 240px >

## WelfordAlg_Plot_norms.m

This script produce figure 8. As the previous script, this code produce both MATLAB plot and data for TikZ plot:

<img src="./code/tmp/v_vp.png"  alt="Figure 9" width = 240px >

## ev_sort_highway_err.m

This script produce images used in figures 9-11.  The following figure (fig 9 in paper) shows the error of eigenbackground for 30 first frames of highway video. First row shows the reconstruction error, and second row shows the error for background estimation.

<img src="./code/tmp/RMSE_FGs.png"  alt="Figure 9" width = 240px >


## eigenbackground_the_most_vs_the_least.m

This script produce figures of section *Eigenbackground in various sizes of foregrounds*.  

<img src="./code/tmp/256_558_blocks.png"  alt="Figure 9" width = 240px >


## In the case of the following error, install [these codecs:](https://files3.codecguide.com/K-Lite_Codec_Pack_1612_Basic.exe)

    Error using VideoReader/init (line 601)
    The file requires the following codec(s) to be installed
    on your system:
	    cvid
