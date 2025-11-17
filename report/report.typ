// Main report file
#import "template.typ": make-report, report-footnote
#import "metadata.typ": my-report
#import "@preview/theofig:0.1.0": definition

// Main content
#show: make-report.with(my-report)

= Introduction

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
