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

== H.264

The H.264 codec, also known as MPEG-4 AVC (Advanced Video Coding) or MPEG-4 Part 10, was developed in 2003.
It undergoes numerous transformations and is still undergoing improvements today
#report-footnote(link("https://en.wikipedia.org/wiki/Advanced_Video_Coding")[Wikipedia]).

=== Base principles

The process of video compression is based on redundancies, both statistical and human, especially on temporal redundancies.
Indeed the human visual system needs only around 25 frames per second to see a fluid video.
On top of that, each frame doesn't differ much from the other neighbor frames in a video.
This permits for instance to store only the change and not the entire frame, allowing to reduce amount of data used.

=== Compression

The video compression follow the structure bellow, as described in the diagram @basis.

#figure(caption: "Video compression and decompression structure", [
  ```pintora
  componentDiagram
  @param layoutDirection TB

  () "Raw video" as a0
  () "Compressed video" as a6
  component "Encoding" {
    [Block partitioning] as a1
    [Prediction] as a2
    [Transform] as a3
    [Quantize] as a4
    [Encode] as a5

    a0 --> a1
    a1 --> a2
    a2 --> a3
    a3 --> a4
    a4 --> a5
    a5 --> a6
  }

  component "Decoding" {
    [Block partitioning] as b1
    [Prediction] as b2
    [Transform] as b3
    [Quantize] as b4
    [Decode] as b5

    a6 --> b5
    b5 --> b4
    b4 --> b3
    b3 --> b2
    b2 --> b1
    b1 --> a0
  }
  ```
]) <basis>


#pagebreak()

= Implementation <impl>

#pagebreak()

= Results

#pagebreak()

= Discussion

#pagebreak()

= Conclusion
