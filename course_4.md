With quality factor 100, we will have in our quantization matrix not only 1 but something else (we must perhaps round values) -> loss of informations

How to exploit redundancies using zig-zag ???

## Remarks 

- human not very sensible to high frequency data images
- more sensitive to brightness than color
- ...


### Artifacts

- blocking artifacts
- ringing artifacts
- graininess artifacts
- blurring artifacts
- ...


# Double jpeg compression

Stored 2 times -> perhaps something happens before second compression...

After first compression, we have our first quantization...

Image just one time quantize, no problems

Image twice quantized, we will have some bins that are empty if new quantization is bigger than first quantization

Image twice quantized, we will have some bins that are higher if new quantization is smaller than first quantization

If we are using same quantization matrix, it's not detectable....

To detect, we go in frequency domain and we detect pics in high frequencies....

If quality factor is different from less than 10, we have problems to detect double compression...

We can also detect by first significant digit (FSD) analysis that must follow a function...

=> model based approaches

But there are also Machine Learning models to detect....
(support vector machines or networks/neural networks/deep neural networks)

Can better detect double compression, but need a huge amount of data and the training is critical and extremely sensitive...
(quality of data, etc...)
