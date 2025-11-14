// Main report file
#import "template.typ": make-report, report-footnote
#import "metadata.typ": my-report
#import "@preview/theofig:0.1.0": definition
// #import "@preview/codly:1.3.0": *
// #import "@preview/codly-languages:0.1.1": *
// #show: codly-init.with()

// Main content
#show: make-report.with(my-report)

= Introduction

Since the dawn of time, humans have tried to secretly transmit information.
For instance, Caesar used encrypted messages to his subordinates in order to prevent his plans being discovered by enemies.
Similarly, during the World War II, German transmitted coded messages to share instructions.
However, their encoded communications were discovered, which led, among other things, to the loss of the war.
Encryption is good, but it's visible and breakable: the others can see that there is an encrypted exchange of messages.
That is why people began to hide information in various ways, such as in messages, images, audio, etc, what is known as steganography.

In this work, some basic steganography methods will be implemented and tested.

#pagebreak()

= Methodology <methodology>

First of all, what is steganography and what are its advantages and disadvantages compared to cryptography?

#definition()["Steganography is the art of hiding information in ways that prevent the detection of hidden messages".@steg]<def>

== Steganography vs. Cryptography

Unlike the steganography, the cryptography is the art of securing a communication in the presence of hostile behavior. #report-footnote(link("https://en.wikipedia.org/wiki/Cryptography")[Wikipedia])
So it implies that the adversarial part can see the communication, but not the content of the communication.

At the difference, according to the @def, the steganography hide the communication in such a way the adversarial part don't see at all the communication.
This way, information can be conveyed without drawing attention to it.

So the main advantage of the cryptography lies in the fact that the adversarial part is unable to decrypt the communication.
However, if the adversarial part can decrypt the communication, this may result in loss of war, as shown by German during World War II with their encryption machine Enigma that was decrypted by British.
And the main advantage of the steganography lies in the fact that the adversarial part don't see at all the communication.
Nevertheless, if communication is discovered, this could also cause serious problems, like for cryptography.

== Steganography in images

To properly see an image on a computer, each pixel intensity of the image is encoded.
Then, the monitor activate each 'small led' according to the pixel intensity values in such a way the image is properly printed on the screen.
Depending on the image representation, pixel intensity can be encoded with more or less bits.
In our case, we will work with images encoded by only 8 bits, so with a range of possible intensity given by $[0, 255]$.
Due to the imperfection of the human visual system that is less sensitive to small details, LSB of the image (Least Significant Bit)
will be used to store the secret: the message will be coded in binary in the LSB of the image.
If you take a look at the @fig-bit_plate, you can easily see that most of image information are stored into Most Significant Bit (MSB: level 7) of the image.
On the contrary, only small details are stored in the LSB (level 0), that appears as some "noise".
In this way, the secret message will provoke only small intensity variations of pixels, which is undetectable for the human visual system.
And it could be easily retrieved by the knowledge of the existence and position of the message in the image.

Color images use 3 channels: channel R that represents all red colors of the image, channel G that represents all green colors of the image and channel B that represents all blue colors of the image.
Thanks to this channels and to the additive property of light colors, all colors can be represented.
For instance, taking maximum intensity of both channels will be white color.

All the color image channels are only matrix of pixel intensity values.
In this way, all channels can be used to hide some message into LSB.
Depending on the size of the message and on the channel chosen, human visual system could not see any difference between original image and image with hidden secret.
For instance, human visual system is less sensitive to blue color than to green color because it contains more cones sensitive to green than cones sensitive to blue. (40% vs 5%)
In this way, the blue channel can be used to encrypt some message to render the message more undetectable by human visual system.

So steganography can hide some message in an image in an undetectable way for human visual system.

#pagebreak()

= Implementation <impl>

An implementation of steganography method on image is implemented.
The documentation is given in @doc.

#figure(
  caption: [Documentation],
  [
    ```text
    usage: tp5.py [-h] [-i IMAGE] [-b] [-m MESSAGE] [-mi MESSAGE_IMAGE] [-msb MSB_NUMBER] [-g] [-k KEY]

    Steganography

    options:
      -h, --help            show this help message and exit
      -i, --image IMAGE     Path to base image
      -b, --bit_plane       Display each bit-plane of the image
      -m, --message MESSAGE
                            Message to hide
      -mi, --message_image MESSAGE_IMAGE
                            Image to hide
      -msb, --msb_number MSB_NUMBER
                            Store the x MSB of grayscale image into LSB of the RGB base image
      -g, --grayscale       Convert base image to grayscale
      -k, --key KEY         Key used to hide message in pseudo-random positions
    ```],
)<doc>

In this way, if you want to hide a string message to the image, simply execute the code like bellow:

```bash
python tp5.py -i "..\images\bg_image.jpg" -m "This is a secret message !"
```

And if you want to hide a binary image into the base image, execute the code like bellow:

```bash
python tp5.py -i "..\images\bg_image.jpg" -mi "..\images\test_image.jpg"
```

And finally, if you want to hide an image by conserving the 8 Most Significant Bit (MSB) of the image to hide, execute the code bellow:

```bash
python tp5.py -i "..\images\bg_image.jpg" -mi "..\images\test_image.jpg" -msb 8
```

For the implementation, some pseudo-random number generator are used to hide message in pseudo-random positions in the image.
This pseudo-random number generator take an initial number as initialization, and generate a sequence of pseudo-random numbers that will be always the same sequence if the same initial number is given.
In this way, an adversarial part can detect that there is a message in the image, but can't obtain the message unless he finds the encryption key that is used to generate pseudo-random positions.
And on top of that, as we work with pseudo-random numbers, we can encrypt and decrypt thanks to the same sequence generated by the same initial number.

In the implementation, positions are chosen pseudo-randomly according to the initialization of the random generator.
A position can't be chosen twice, and the sequence of positions chosen is dependent of the given list of index:
a smaller list of index will not make a choose of same index, even if the index chosen in the big list of index are present in the smaller list of index.
In this way, passing a smaller list of index result in a desynchronization of index pseudo-randomly chosen, which makes the message impossible to retrieve.
So a proper work has been made on pseudo-random choice of index.

= Results

== Bit-plane image

#figure(
  caption: "Bit-plane decomposition of an image",
  image("img/bit_plane.png", width: 125%),
)<fig-bit_plate>

== Binary image hidden in RGB image

#figure(
  grid(
    columns: 2,
    grid.cell(image("img/original_img.png", fit: "cover", width: 120%)),
    grid.cell(image("img/steg_img.png", fit: "cover", width: 120%)),
  ),
  caption: [Binary image hidden],
)<fig-rgb_img>

#figure(
  grid(
    columns: 2,
    grid.cell(image("img/msg.png", fit: "cover", width: 120%)),
    grid.cell(image("img/color_difference.png", fit: "cover", width: 120%)),
  ),
  caption: [Binary image hidden],
)<fig-color_difference>


#figure(
  caption: [Impact of hidden message on RGB image],
  grid(
    columns: 2,
    grid.cell(image("img/hist.png")),
    grid.cell(image("img/pixel_wise.png")),
  ),
)<fig-rgb_hist>

#figure(
  caption: "Output of the code",
  [#set text(size: 8pt)
    ```text
    -------------------------------------------------------------
    Image comparison between original image and image with secret
    -------------------------------------------------------------
    -------------------- OVERALL COMPARISON ---------------------
    -------------------------------------------------------------
    MSE: 0.041503
    PSNR: 61.950008705086894
    SSIM: 0.9995570668923494
    -------------------------------------------------------------
    ------------------------ CHANNEL R --------------------------
    -------------------------------------------------------------
    MSE: 0.0
    PSNR: inf
    SSIM: 1.0
    -------------------------------------------------------------
    ------------------------ CHANNEL G --------------------------
    -------------------------------------------------------------
    MSE: 0.0
    PSNR: inf
    SSIM: 1.0
    -------------------------------------------------------------
    ------------------------ CHANNEL B --------------------------
    -------------------------------------------------------------
    MSE: 0.124509
    PSNR: 57.178796157890275
    SSIM: 0.9986712006770483
    -------------------------------------------------------------
    ```],
)<fig-rgb_code>

== Binary image hidden in RGB image

#figure(
  caption: [Impact of hidden message on grayscale image],
  grid(
    columns: 2,
    grid.cell(image("img/hist_gray.png")),
    grid.cell(image("img/pixel_wise_gray.png")),
  ),
)<fig-gray_hist>


#figure(
  caption: "Output of the code",
  [#set text(size: 8pt)
    ```text
    -------------------------------------------------------------
    Image comparison between original image and image with secret
    -------------------------------------------------------------
    -------------------------------------------------------------
    MSE: 0.12483775
    PSNR: 57.16734428264796
    SSIM: 0.9986605071997674
    -------------------------------------------------------------
    ```],
)<fig-gray_code>



== Complete grayscale image hidden in RGB image

The method implemented consist to hide multiple bit-plane in LSB of each color channel of support image.
It works fine if the base image is much bigger than the image to hide, because more than 1 bit-plane are hidden in LSB of the base image.

#figure(
  grid(
    columns: 2,
    grid.cell(image("img/full_img_msg.png", width: 120%)), grid.cell(image("img/full_msg.png", width: 120%)),
  ),
  caption: [Grayscale image hidden],
)<fig-full>

#figure(
  grid(
    columns: 2,
    grid.cell(image("img/full_hist_R.png")), grid.cell(image("img/full_pixel_wise_R.png")),
    grid.cell(image("img/full_hist_G.png")), grid.cell(image("img/full_pixel_wise_G.png")),
  ),
  caption: [Grayscale image hidden],
)<fig-full_hist>

#figure(
  caption: "Output of the code",
  [#set text(size: 8pt)
    ```text
    -------------------------------------------------------------
    Image comparison between original image and image with secret
    -------------------------------------------------------------
    -------------------- OVERALL COMPARISON ---------------------
    -------------------------------------------------------------
    MSE: 0.08855482506790993
    PSNR: 58.658681313861024
    SSIM: 0.9991432550816931
    -------------------------------------------------------------
    ------------------------ CHANNEL R --------------------------
    -------------------------------------------------------------
    MSE: 0.1659685442900714
    PSNR: 55.93054576055208
    SSIM: 0.9984012127967222
    -------------------------------------------------------------
    ------------------------ CHANNEL G --------------------------
    -------------------------------------------------------------
    MSE: 0.09969593091365841
    PSNR: 58.14402927910395
    SSIM: 0.9990285524483571
    -------------------------------------------------------------
    ------------------------ CHANNEL B --------------------------
    -------------------------------------------------------------
    MSE: 0.0
    PSNR: inf
    SSIM: 1.0
    -------------------------------------------------------------
    ```],
)<fig-full_code>

== Robustness tests

=== RGB image

#figure(
  grid(
    columns: 2,
    grid.cell(image("img/msg.png")), grid.cell(image("img/robustness_rgb_compress.png")),
    grid.cell(image("img/robustness_rgb_noise.png")), grid.cell(image("img/robustness_rgb_crop.png")),
  ),
  caption: [Robustness tests on RGB image],
)<fig-robust_rgb>

=== Grayscale image

#figure(
  grid(
    columns: 2,
    grid.cell(image("img/msg.png", width: 120%)), grid.cell(image("img/robustness_gray_compress.png", width: 120%)),
    grid.cell(image("img/robustness_gray_noise.png", width: 120%)),
    grid.cell(image("img/robustness_gray_crop.png", width: 120%)),
  ),
  caption: [Robustness tests on grayscale image],
)<fig-robust_gray>

#pagebreak()

= Discussion

As explained in @methodology, each image can be decomposed into bit-planes.
The Most Significant Bit of the image contains a lot of useful informations, because we can easily see on @fig-bit_plate
that for level 7 (corresponding to MSB), it's possible to see what is the picture.
On the contrary, for level 0 that correspond to Least Significant Bit, only some noise appears except in smooth area.
This is due to the fact that small details are encoded in LSB of the image.
In this way, modifying the LSB of an image will have only a small impact on the visual quality of the image, especially since human visual system is less sensitive to small details.

== Binary image hidden

2 cases have been tested here:
- a test with RGB base image
- a test with grayscale base image.

In both case, we can't see visually in image with secret that there is some hidden informations inside.
For instance, image with hidden message seems to be normal in @fig-rgb_img.

=== Metrics

The results of the code metrics seem to confirm what we have been saying, as shown in @fig-rgb_code and @fig-gray_code.
Note that metrics of grayscale image are very similar to metrics of only a color channel (with message).
- The mean squared error (MSE#report-footnote[$"MSE" = sum_(i, j, k)^(M, N, C)[I_1(i, j, k)- I_2(i, j, k)]^2 / (M times N times C)$])
  measure the average squared distance between each pixel of the image.
  The difference between the distortion metric is that the MSE is normalized by the size of the image, but this two metrics are basically the same.
  We can note here that small values means that images are very similar, since average of squared distance between each pixel is small.

  For RGB image, the mean squared error of the channel B of the image where the binary image is hidden is similar to the mean squared error of the grayscale image.
  However, the mean squared error of the entire image is $3 times$ smaller than the mean squared error of the grayscale image.

  This is due to the presence of 3 channels for RGB image versus 1 channel for grayscale image.
  The factor $3$ is obtained because there is $3 times$ more data in RGB image due to the 3 channels, giving more space to hide data and better camouflage.

  That's why it's possible to hide more informations in RGB image thanks to the amount of data used to store each color channel.

- The Peak Signal Noise Ratio (PSNR#report-footnote[$"PSNR" = 10 dot log_10("MAX"_I^2 / "MSE")$]) is inversely proportional to the MSE.
  So big values means that images are very similar.
  However, this metric is quite different to the MSE in term of what is represented by this metric.
  The PSNR compares the maximum possible signal intensity to the noise introduced by image processing.
  The measure is in decibels (dB), and is easier to interpret in human point of view.

  If we compare the PSNR obtained when hiding message in both RGB and grayscale images, we can see that the overall PSNR for the RGB image is bigger than for the grayscale image whereas if we focus on channel where the secret is hidden, the PSNR are similar.
  It's exactly the result expected result.

- The Structural Similarly (SSIM) is a perceptual metric used to quantify similarity between two images, but in human vision point of view.
  This metric is more complex to compute due to the covariance matrix computation (depending of the size of the image used, the implemented code take some time to answer).
  However, it gives an overview of similarity based on human vision, which is interesting in steganography because the goal is that human don't detect that there is a hidden message.
  SSIM metric return a value in range $[0, 1]$ and when the two images are identical, the return value is $1$.

  In case of RGB base image, the overall similarity is more close to $1$ than for grayscale image ($0.999 "vs" 0.998$).
  However in both case, the values are very close to $1$, meaning that in human point of view, the image with and without hidden secret are very similar.
  And it is exactly what we expect because else people can see when we try to hide some message in the image which goes against the principle of the steganography.

- The color difference#report-footnote[$Delta = sqrt((L_x - L_y)^2 + (A_x - A_y)^2 + (B_x - B_y)^2)$] is a metric that compute euclidean distance between two points in color space.
  If we look at the result @fig-color_difference obtained, we can see that it is similar than the pixel-wise difference @fig-rgb_hist explained in @pixel-wise.
  However, this metrics is more focus on how human perceive colors and can give us a better understanding of what's happen at color level.
  But in our case, the difference is too small to have some good results.

So in metric point of view, human can't see when a message is hidden in an image just by observing the image.

=== Pixel-wise difference <pixel-wise>

If we look at the pixel-wise difference#report-footnote[$"pixel-wise" = | I_1 - I_2 |$] between the images in @fig-rgb_hist and @fig-gray_hist, we can easily see that the variation of the image with secret is only a very small noise.
But without the original image, it is not possible to make the pixel-wise comparison of the two images.
That's why human can't detect the presence of hidden message in an image without the help of some tools (unless the message is badly integrated to the image).

=== Histograms

However, if we take a look at the histograms of both RGB and grayscale image on @fig-rgb_hist and @fig-gray_hist, in both case the histogram of the image with secret hidden contains some small variations or oscillations that don't appear on histogram of non-modified image.
In this manner, it's possible to detect that something has been added to the image thanks to the histogram oscillations.

However, if we look at the histogram of green channel in @fig-full_hist, nothing appears on the histogram.
It is because the base image has a huge size compared to the hidden image ($6885 times 4534 "pixels vs" 1920 times 1080 "pixels"$)
So nothing is detected on histogram because modifications are too small compared to the amount of data.

So we can easily see that the histograms allow to discover that there is some hidden message in the image.
However, if nothing is detected, it doesn't mean that there is no hidden message.
That's why other methods must be applied.

=== Robustness

==== RGB image <robustness_rgb>

As shown in @fig-robust_rgb, the message is lost when the image is cropped, compressed or noised.
It's totally normal in both case:
- In case of cropped image, there is another length of the image used.
  So in function that get message, index will be chosen from a smaller list of index.
  The synchronization is therefore lost for generating the right sequence of index, as explained in @impl.
  So the message obtained is some random message that doesn't matter with the expected message.
- In case of compressed image, as we have a RGB image, the JPEG compression will first convert image in YCbCr space domain.
  Then, color channels Cb and Cr are decreased 2 times.
  Due to this, all small variations introduced by the encoded message don't survive to this operation, resulting in a random message.
- In case of noised image, as the message is encoded into small variations of the image, adding small variations like a Gaussian noise destroy totally the message because the small variations of the message will be erased by the added small variations.
  However if we add some noise in only some part of the image, the message should be partially recovered because all small variations introduced by the message will not be fully lost.

==== Grayscale image

As shown in @fig-robust_gray, the message is lost when the image is cropped or noised for the same reasons as those explained in @robustness_rgb.
However, the message is not lost when the image is compressed.
This is due to the JPEG compression that don't change the color space of a grayscale image, but simply transform image in Discrete Cosine Transform domain to keep only low frequencies and erase high frequencies of the image since human vision is less sensible to high frequencies than to low frequencies.
As the message introduced is essentially high frequencies (small variations = high frequencies), it means that if the compression remove high frequencies, the message could be lost.
That's why to not loose the entire message, a very high quality of compression must be applied.
For instance, with a quality of 95, the message is almost entirely erased, but with a quality of 98, it's possible to see a very noisy binary image.
In this way, certain small variations generated by the secret message are lost during the compression process if the quality of the compression is not very very high.
But not all, that's why the message can be partially recovered, depending on the compressive strength applied.
In our case, as shown on @fig-robust_gray, the message is almost entirely recovered thanks to a high compression quality (compression quality of 100).

So the steganography is very sensitive to image modifications because the hidden message is encoded in small variations of the image, which are very sensitive to changes.

#pagebreak()

= Conclusion

The steganography on images is a good way to secretly pass on informations.
However, encoded messages are very sensitive to modifications of the image, like cropping, noise or compression.

The small oscillations on the histogram of the image can reveal that image perhaps contains some secret message.
However, in case of big difference between size of image and size of message, theses oscillations can be totally hidden due to the large amount of data.

This is why we may wonder whether there are other ways to detect hidden messages and how effective these methods are.
