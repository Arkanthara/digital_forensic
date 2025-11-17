// Main report file
#import "template.typ": make-report, report-footnote
#import "metadata.typ": my-report
#import "@preview/theofig:0.1.0": definition

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

#pagebreak()

= Implementation <impl>

#pagebreak()

= Results

#pagebreak()

= Discussion

#pagebreak()

= Conclusion
