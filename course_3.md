# 

Analysis of structure of image give information that image has been modified because when recompress image, the structure is a little modified and perhaps the added object is not syncronised with the structure of the image.

Analysis of the recurrent patterns give informations that image has been modified

Analysis of the light can give informations that image has been modified.

## Second lecture

# Forensic analysis of JPEG images

JPEG preserve good quality

lossless compression: original can be retrieved when taking compressed image
lossy: can't retrieve image after compression because loss of informations during compression.

difference between previous pixels give image of kind laplacian

Medical -> lossless compression

## General compression scheme

- T: transform input data to be more amenable to compression
- Q: lossy compression by performing a many to one mapping data into symbols
- C: codeword to each symbol produced by the quantizer, lossless compression is achieved

### Lossless compression

- T
- C

JPEG compression is pretty simple

DCT vs fourier: DCT (discrete cosinus transform) gives only 1 number to represent data whereas fourier give 2 because of complex image....

Quantization is the main error source for JPEG compression because we loose informations...

Idea: quantize more high frequencies, and less low frequencies...
Quality factor is more simple to understand what happens with our image....

Conclusion

Quantization matrix different for different channels (luminance, color)

Quantization matrix -> smaller is the number, more conservated are the datas.

We conservate more luminance than colors because human vision is more sensitive to edges than to colors...

If we redo compression, what's happens ???
