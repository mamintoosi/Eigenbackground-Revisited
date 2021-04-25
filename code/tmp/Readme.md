

In the case of the following error:
Error using VideoReader/init (line 601)
The file requires the following codec(s) to be installed
on your system:
	cvid
	
Install: https://files3.codecguide.com/K-Lite_Codec_Pack_1612_Basic.exe	


| Frame No. 16 | B/F using 10 most strong eigenvectors |  B/F using 10 weak eigenvectors
| --- | --- | --- |
|  |![Backgound strong vectors](./code/output/voigtclipshort/16_EigenBG.jpg) |![Backgound weak vectors](./code/output/voigtclipshort/16_NonEigenBG.jpg)| 
| ![Frame 16](./code/output/voigtclipshort/16.jpg) |![Foregound strong vectors](./code/output/voigtclipshort/16_EigenFG.png) |![Foregound weak vectors](./code/output/voigtclipshort/16_NonEigenFG.png)| 


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

<table>
  <tr>
    <td> A 40x40 block demonstrated with a yellow square, shown in the following image, is selected for further investigation:
<img src="./code/tmp/16-40x40.jpg"  alt="Block 40x40 in x=y=5" width = 240px >

The temporal and QR order of columnized version of this block are produced with the mentioned script. The results , demonstrated here is saved in the following files:<br>
*columnized_frames.jpg* ,*columnized_frames_reordered.jpg*

These images are demonstrated at the right:
</td>
    <td> 
	<img src="./code/output/highway/columnized_frames.jpg" alt="columnized_frames" width = 200px height=400px >
	</td>
	<td>
	<img src="./code/output/highway/columnized_frames_reordered.jpg" alt="columnized_frames_reordered" width = 200px height=400px >
	</td>
  </tr>
</table>

