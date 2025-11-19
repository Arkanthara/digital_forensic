// Main report file
#import "template.typ": make-report, report-footnote
#import "metadata.typ": my-report
#import "@preview/theofig:0.1.0": definition
#import "@preview/pintorita:0.1.4"
#show raw.where(lang: "pintora"): it => pintorita.render(it.text, style: " larkLigh")

// Main content
#show: make-report.with(my-report)

= Introduction

Nowadays, a large number of videos circulate on the internet.
Given that each video is composed of around twenty images per second, storing and transmitting videos requires a large amount of data.
This is why methods have been implemented to reduce the amount of data used by a video while preserving its visual quality.
However, some videos circulating on the internet convey a distorted image of reality through clever modifications to the original content, which can even lead to people being exonerated in court.
This is why it is important to know the history of a video, which can be achieved through digital forensics.
Since video compression leaves traces, these can be analyzed to reveal any modifications to the video.
The objective of this work will therefore be to understand how video compression works and to see how the traces left by compression can be used to detect modifications to the video.

#pagebreak()

= Methodology <methodology>

In general, video are sequence of images called frames.
Based on this kind of video, we will start by studying how video compression works.
To do this, we will use the h264 codec, as it is the most widely used codec on the web.

== Redundancies

=== Psychovisual redundancies

The imperfections of the human visual system can be exploited to reduce the amount of data used by a video without a loss of visual quality.

==== Spatial irrelevance

The human visual system has some difficulties to perceive small details due to its limitations.
The optics of the eyes and the neural processing tend to smooth out fine patterns.
For example: a document printed by a laser printer is composed of small dots that are very close together.
However, we cannot see the individual dots at a normal distance: we only perceive a uniform surface.

This is why this feature can be used to remove small details that are invisible or barely visible for human visual system.

==== Spectral irrelevance

The human visual system consists of approximately 100 million rods responsible for perceiving brightness and approximately 6.5 million cones responsible for perceiving colors.
Due to the high amount of rods, the human visual system is more sensitive to brightness compared to color.

There are 3 types of cones:
- L-cones ($approx 65%$), sensitive to long wavelengths (such as the red color).
- M-cones ($approx 33%$), sensitive to medium wavelengths (such as the green color).
- S-cones ($approx 2%$), sensitive to short wavelengths (such as blue color).
In this way, human visual system is less sensitive to blue color than to other colors due to its amount of S-cones.

Therefore, retaining all the spectral details of the video may prove unnecessary for good quality reproduction of the video.

==== Temporal irrelevance

The human visual system is not sensitive to rapid changes.
Thus, in the case of a video, only about 30 frames per second are necessary for humans to perceive smooth motion.
Since human visual system is unable to detect rapid changes between successive frames, this can be exploited to reduce the amount of data used by a video without loss of visual quality.

=== Statistical redundancies

The statistical redundancies of each frame of a video can be used to optimize the amount of data used.
Among these redundancies, we have spatial, spectral, and temporal redundancies, as in the human visual system.

==== Spatial irrelevance

These redundancies are introduced by a strong correlation between neighboring pixels.
By the way, in an image, each pixel is correlated with its neighbors in such a way that the final result is something visible and understandable to humans.
An image created with no correlation between pixels is something like a noisy image because each pixel is independent from the others.
So the spatial redundancies can be exploited to predict for instance values of pixels according to neighboring pixels.
In this manner, some data can be deleted, which reduces amount of data used.

==== Spectral irrelevance

These redundancies are created by strong correlation between neighboring pixels in color domain.
This is because color changes are often gradual, and colored regions regularly extend beyond a single pixel.
Thus, a pixel is strongly correlated with its neighbors in the color domain, which can be exploited to reduce amount of data used.

==== Temporal irrelevance

These redundancies are the most important for video compression.
In fact, changes to the elements present in the video occur gradually, especially in consecutive frames.
Thus, between two consecutive frames, there will not be many changes, as shown by @diff_frame.
Indeed, the amount of change created by this moving car is very small.

#figure(
  caption: "Difference between 2 consecutive frames for a 30 fps video",
  grid(
    columns: 2,
    gutter: 0.5cm,
    image("./img/frame.jpg"),
    image("./img/diff_frame.jpg")
  )
)<diff_frame>

So if only the changes are recorded, most of the frame can be compressed.

== H.264

The H.264 codec, also known as MPEG-4 AVC (Advanced Video Coding) or MPEG-4 Part 10, was developed in 2003.
It undergoes numerous transformations and is still undergoing improvements today
#report-footnote(link("https://en.wikipedia.org/wiki/Advanced_Video_Coding")[Wikipedia]).

=== Compression

// #figure(caption: "Video compression and decompression structure", [
//   ```pintora
//   componentDiagram
//   @param layoutDirection TB
//
//   () "Raw video" as a0
//   () "Compressed video" as a6
//   component "Encoding" {
//     [Block partitioning] as a1
//     [Prediction] as a2
//     [Transform] as a3
//     [Quantize] as a4
//     [Encode] as a5
//
//     a0 --> a1
//     a1 --> a2
//     a2 --> a3
//     a3 --> a4
//     a4 --> a5
//     a5 --> a6
//   }
//
//   component "Decoding" {
//     [Block partitioning] as b1
//     [Prediction] as b2
//     [Transform] as b3
//     [Quantize] as b4
//     [Decode] as b5
//
//     a6 --> b5
//     b5 --> b4
//     b4 --> b3
//     b3 --> b2
//     b2 --> b1
//     b1 --> a0
//   }
//   ```
// ]) <basis>

Video compression follows steps similar to those used in image compression, which consist of data transformation, quantization for lossy compression, and data encoding for efficient storage on disk.
However, some additional steps are provided to exploit temporal redundancies.

More concretely, we have the steps bellow.

==== Color Space Transform

The frame is first transformed from RGB color space to YCbCr color space.
Instead of representing the frame in RGB color space, the YCbCr color space is used to divide the frame into luminance (Y) and chrominance (both Cb and Cr).
#figure(
  caption: "Image decomposed in YCbCr color space",
  grid(
  columns: 3,
  gutter: 0.5cm,
  figure(caption: "Y channel", supplement: none, image("./img/y.jpg")),
  figure(caption: "Cb channel", supplement: none, image("./img/cb.jpg")),
  figure(caption: "Cr channel", supplement: none, image("./img/cr.jpg")),
)) <ycbcr>

The luminance looks after the luminosity, the brightness of the image whereas the chrominance looks after colors of the image, as shown on @ycbcr.

In this way, since the human visual system is less sensitive to color than to brightness, chrominance could be compressed more than luminance at a later stage.

==== Partitioning

Then, the frame is divided into macroblock generally of size $16 times 16$.
These macroblocks perfectly represent specific regions of the image and are very useful for working on small areas of the image.
This allows for easier detection of elements such as moving and not moving objects, more accurate motion prediction, and an efficient means of compressing data.
Indeed, some parts of the image may be flat while others may contain a large amount of detail.
In this way, some parts of the image can be compressed more than others.


- Partitioning into Macroblocks: the image is partitioned in Macroblocks, generally of size 16x16.
  Then, depending on precision of prediction step needed, each Macroblock can be decomposed to smaller block (typically of size 16x8, 8x8, 4x4)
- Prediction: this step is decomposed in 2 substeps:
  - Intra prediction: this step consists to predict value of a block according to neighboring blocks of the same frame.
  - Inter prediction: this step consists to predict value of a block according to previous and future frames.
    This is based on temporal redundancies.
    For instance, a video of a moving object will probably have only the object that moves without any changes in the background.
    In this way, only the changes can be stored, the rest staying the same.
    This is the greatest way for compression to reduce the amount of data.
- Transform. In this step, the prediction error coming from previous step is transformed by an integer transformation.
  This transformation is similar to Discrete Cosine Transform, but is faster and avoid floating point errors.
  In this way, prediction error is decomposed into low and high frequencies.
- Quantization: due to imperfections of human visual system that is less sensible to small details (high frequencies), only low frequencies can be kept to have a good reproduction of the video with a reduction of amount of data.
- Encode: All parameters are then stored into the disk in such a way the video can be reconstructed.


#pagebreak()

= Implementation <impl>

#pagebreak()

= Results

#pagebreak()

= Discussion

#pagebreak()

= Conclusion
