# Equations of light 

2 systems of equations and solve it (one with light supposed in one direction, the other in the other direction...)

# Image Editing Forensics

Traces left by image editing
- resampling detection
- detection of contrast enhancement
- ...

## Resampling

$y = H x$

so $h_2 = 0.25h_1 + 1.5h_3 - h_4 + 0.25h_5$
so $y_2 = 0.25y_1 + 1.5y_3 - y_4 + 0.25y_5$

this repeat periodically...

### Resampling factor estimation

we make some assumption on H and we calculate the probability for this assumption and then we calculate error and try to minimise error

Not too complex to solve because a lot of 0 in $H$ !!

Consequences: probability map has some periodicity property => easy to see in Fourrier domain !!!


Resampling introduce some periodicity that can be detected in Fourrier domain on the probability image computed !!!

Downsampling is not easy to detect because we have small number of input vs high number of output !!! => not enough equations

Usually, we have combination of different cases...


if rotation, fourrier transform rotated and a little sampled... If upscaling, picks will be far away from center...

## Contrast enhancement

increase dynamic range of pixel values within images to have more good results...

- increase in energy
- energy related to intrinsic fingerprint
- expected image DFT are to be strongly low-pass signal
- presence of energy in high frequency is indicative of contrast enhancement
- contrast enhancement will cause isolated peaks and gaps in the histogram

So more picks in high frequencies in Fourrier domain
and some gaps in histogram 

Saturation -> oscillations in Fourrier domain...

If there is some contrast manipulations, we need to analyse fourrier representation and histogram of the image.

Low-pass filtering kill theses traces or decrease it drastically !!!

## Application of local contrast enhancement

Can identify cut and paste forgeries

To detect it, the image is divided into smaller blocks and the global technique is applied to the blocks

Blocks of different size... With bigger blocks, more informations to compute equations => better results...

Smaller blocks => can more separate added image to original.

If we are speaking about some tests, we need to evaluate quality of the tests...


We train a system to have threshold and probability of modified and not modified image  and then we apply on new image, and we hope that the new image will have the same behaviour to detect modifications...

Analysis repeated in each color domain...

They take different blocks size, and then they fusion results...=> more good results !!


(not in cc1) ## Histogram equalization

- increase dynamic range
- compute uniformity of the histogram
- blabla
