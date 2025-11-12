Scanner vs camera: higher resolution !

=== Artifacts of laser printing

Human eyes interpolate small details
So laser make small points near to see global color

- Laser printers have electric-mechanical parts that behave differently
- Differences can be seen on the halftones of printed material

- Banding: textural pattern composed of horizontal, low frequency, and periodic dark lines
caused by the laser printer components variation, vibrations, and speed regulation that are perpendicular to direction in which the paper moves through the printer.
- Jitter: horizontal artifacts, but with a different frequency range and 
duration, caused by oscillatory disturbances of the printer’s drum and 
the developer roller.
- Skewed jitter: a periodic artifact like the others, but it differs from the 
previous ones as it is formed by vertical lines.

=== Laser printer attribution

Depending on the type of document of interest, laser printer attribution can be split into three branches: 
- text 
- images/colored documents
- both text and images/colored document

We use different scanner and techniques to increase accuracy of the method...
In fact, using different kind of scanners will reveal some artifacts that another scanner don't reveal because its grid is not aligned to capture this artifact...
Sometimes, scanner can be optical + post-processing
Then, we can compute fingerprint of the document

== Printed document authentication: active approach
=== Active forensics on printed documents

- Insert information in the printed material or in the printed process that help the user to identify the printing authenticity
- They leave extrinsic signatures that can be detected visually, with help of software or even with physical and chemical procedures
- Some examples of such authentication techniques include: 
  - printer steganography 
  - 2D barcodes
- Xerox pioneered in the mid 80’s an encoding mechanism represented by tiny dots spread over an entire print area.
  This authentication method was unknown to the general public until 2004
- Consists of a dot-matrix of yellow dots: 
  - encodes the serial number of the device, date and time of the printing, and is repeated several times across the printing area
- Scientists at the TU Dresden found four different encoding schemes after analyzing several documents

==== Disadvantages of Machine identification codes

- Mostly used in printers sold in the USA (FBI requirement)
- Machine identification codes can be anonymized/removed (adding some yellow dots, ...)

== Printed text: passive source attribution
=== Printed text fingerprints

The following areas of a document can be used for analysis in laser printer attribution:
- Characters $->$ applied on text
- Segmented areas (frames) $->$ applied on text and images
- Whole document $->$ applied on text and images

==== Why passive approach ?
- Modification not change results (like inserting bad printer identification)
- Time constraint... Can work even if document was printed a long time ago and identification system has change...

=== Approaches for text printed source detection

Laser Printer attribution by Ali et al. :
- applied in letters of text (letter I) (it's the simplest letter !!!)
- projection (pixel values) are used as fingerprints
- as the extracted letters cannot be of the same font and size, and to avoid the curse of dimensionality in machine learning, the images are pre-processed by Principal Component 
- machine learning classifier (Gaussian mixture model (GMM)) is used to recognize these texture patterns for each printer

Not very accurate result when taking printer from same generation (for instance LJ1000 and LJ1200 !)

===== Problem: Letter "I" don't appear a lot of times in a document !

Laser Printer attribution by Mikkilineni et al.:
- letters E are also analyzed
- letters are described by statistics of Gray-Level co-occurrence matrices (GLCM) considering some neighborhood directions
- these vectors are then input to any machine learning multi-class classifiers

Compute co-occurrence matrix on both directions. The co-occurrence matrix give an overview of color changes in the matrix...
Then we can extract:
- contrast: measure of intensity contrast between pixel and its neighborhood
- correlation: how correlated is a pixel to other
- energy: 
- homogeneity: closeness of distribution of elements in GLCM

All coefficients are normalized to be independent of the size !

Laser Printer attribution by Ferreira et al. :
- letters “e” are also analyzed
- proposed the multiscale and multidirectional texture analysis inside printed material
  - improvement of Mikkilineni et al. approach
  - 1 ad-hoc descriptor
  - fusion of both
- analysis that works on images, texts or on both (Must be the same image printed in multiple printers !)
- it can be applied in the whole document, letters or regions of interest (frames).
- reasoning behind the approach: there are multi-scale and multi-directional printing patterns inside printed material (areas with a specific gradient)

=====

We make the same than PRNU on printers: we took multiple letters and then obtain mean letter...

Warning: changing toner or something of this kind can erase some local properties !!!

Novelties of the proposed method:
- multidirectional GLCM approach
- multidirectional and multiscale GLCM approach
- Convolutional Gradient Texture Filter (CGTF) approach
- investigation on chunks of documents (frames)
- dimensionality reduction approach

=== Multidirectional GLCM approach for Laser printer attribution
GLCM GLCM-MD
- GLCMs: 2d histograms aimed at describing the neighborhood of pixels of a given image in a given direction and offset.
- More directions (eight) are used in the GLCM approach, yielding more matrices.
- At each neighborhood direction, 22 statistics are calculated, resulting with 22 x 8=176 dimensional feature vector used to identify the texture of a given printer

(Note: consider feature matrix as a vector to make some reduction)
take document - extract letters - get different scale - create GLCM feature vector - convert to line feature vector - reduce dimensionality - classify

- Adding to the last approach the Gaussian pyramidal image decomposition
- Four scales are considered: the original, two downscales and one up-scale
- At each scale, 176 statistical features are extracted as in the previous approach

=== Investigation of document frames 

Analyse on block images of the document (compared on text letter of the document)
Method used if the document is considered as an image...

- Laser printer signatures are investigated in the segmented areas of the document
- Frames are rectangular areas of the image with sufficient printed material
  - The document is divided in a matrix of frames with five columns by six rows of about 900 by 980 pixels
  - To be a valid frame, it must contain a minimum accepted ratio between dark pixels (black and dark grey) and blank ones (blank and light gray) as 0.02.
  In general, they work with middle range intensity blocks...
- Description and classification are performed on these areas

