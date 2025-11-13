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

= Methodology

First of all, what is steganography and what are its advantages and disadvantages compared to cryptography?

#definition()["Steganography is the art of hiding information in ways that prevent the detection of hidden messages".@steg]<def>

== Steganography vs. Cryptography

Unlike the steganography, the cryptography is the art of securing a communication in the presence of hostile behavior. #report-footnote(link("https://en.wikipedia.org/wiki/Cryptography#cite_note-2")[Wikipedia])
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

= Implementation

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

#pagebreak()

= Results

== Bit-plane image

#figure(
  caption: "Bit-plane decomposition of an image",
  image("img/bit_plane.png", width: 125%),
)

== Binary image hidden in RGB image

#figure(
  grid(
    columns: 2,
    grid.cell(image("img/steg_img.png", fit: "cover", width: 120%)),
    grid.cell(image("img/msg.png", fit: "cover", width: 120%)),
  ),
  caption: [Binary image hidden],
)

#figure(image("img/hist.png"), caption: [Histogram of B channel])

#figure(
  caption: "Output of the code",
  [```text
  -------------------------------------------------------------
  Image comparison between original image and image with secret
  -------------------------------------------------------------
  ------------------------ CHANNEL R --------------------------
  -------------------------------------------------------------
  MSE: 0.0
  PSNR: 100
  SSIM: 1.0
  -------------------------------------------------------------
  ------------------------ CHANNEL G --------------------------
  -------------------------------------------------------------
  MSE: 0.0
  PSNR: 100
  SSIM: 1.0
  -------------------------------------------------------------
  ------------------------ CHANNEL B --------------------------
  -------------------------------------------------------------
  MSE: 0.124509
  PSNR: 57.178796157890275
  SSIM: 0.9986712006770483
  -------------------------------------------------------------
  ```],
)

#pagebreak()

== Complete grayscale image hidden in RGB image

The method implemented consist to hide multiple bit-plane

#figure(
  grid(
    columns: 2,
    grid.cell(image("img/full_img_msg.png", width: 120%)), grid.cell(image("img/full_msg.png", width: 120%)),
  ),
  caption: [Grayscale image hidden],
)

#figure(
  grid(
    columns: 2,
    grid.cell(image("img/full_hist_R.png")), grid.cell(image("img/full_pixel_wise_R.png", width: 119%)),
    grid.cell(image("img/full_hist_G.png")), grid.cell(image("img/full_pixel_wise_G.png", width: 119%)),
  ),
  caption: [Binary image hidden],
)

#figure(
  caption: "Output of the code",
  [```text
  -------------------------------------------------------------
  Image comparison between original image and image with secret
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
  PSNR: 100
  SSIM: 1.0
  -------------------------------------------------------------
  ```],
)

== Robustness tests

=== RGB image

#figure(
  grid(
    columns: 2,
    grid.cell(image("img/msg.png")), grid.cell(image("img/robustness_rgb_compress.png")),
    grid.cell(image("img/robustness_rgb_noise.png")), grid.cell(image("img/robustness_rgb_crop.png")),
  ),
  caption: [Robustness tests on RGB image],
)

=== Grayscale image

#figure(
  grid(
    columns: 2,
    grid.cell(image("img/msg.png", width: 120%)), grid.cell(image("img/robustness_gray_compress.png", width: 120%)),
    grid.cell(image("img/robustness_gray_noise.png", width: 120%)),
    grid.cell(image("img/robustness_gray_crop.png", width: 120%)),
  ),
  caption: [Robustness tests on grayscale image],
)

= Conclusion

Conclude your report.
// Bibliography and Appendix will be added automatically if enabled
