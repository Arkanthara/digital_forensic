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

=== Convolutional Texture Gradient Filter (CTGF) descriptor
- Calculates neighboring textures in specific areas (intervals) of gradient
- Describes the printer signature as a histogram of such textures
- Textures on almost flat areas (with an interval of small gradient values) are intentionally generated by printers firmware

- Step 1: Negative
  - The image pixels s in the scanned image S are inverted to pixels n given the following formula:
                                            $n = 255 – s$
  - Pixel values close to zero will mean white pixels and 255 are for black pixels.
  - This is made for convenience in the algorithm operations and yields a negative image N
- Step 2: Crop borders (in border, there are some artifacts on bad light or something else...)
  - Used to eliminate scanning noise at the image borders, generated by external light, folding
  - The negative image N is cropped, eliminating 6% of pixels in each border
  - New matrix: R
- Step 3.1: Convolution with ones 
  - Textures with $n times n$ neighbor pixels contained in $R$ are then represented by their sum
  - The convolution of $R$ with an $n times n$ matrix of ones results in the matrix of textures sums $C$
  - The pixel value in the center is replaced by the sum of multiplications between each neighbor in an $n times n$ window and corresponding values in $n times n$ kernel
- Step 3.2: Gradient (R) 
  - In parallel with the previous step, a gradient between a pixel and its $n^2 -1$ neighbors is calculated
  - Final gradient matrix is built as follows 
    if pixel is in the borders
    otherwise
- Step 4: Gradient filter 
  - Calculated textures in C are filtered according to an optimal interval of gradients found experimentally
  - Two parameters glow and ghigh define the range of gradient values that are valuable for printer signature
  - The final matrix T is the matrix C without values from out-of-gradient-range.
- Step 5: Histogram construction
  - Histogram is an approximate representation of the distribution of numerical data.
  - As matrix C sums up all neighboring values in an n x n area, the values from the histogram start at 0 and go until $255 times n^2$. Then, vector H with $255 times n^2$ dimensions is generated
- Step 6: Min-Max normalization
  - Final feature vector V is generated by applying a Min-Max normalization on H, scaling the components to the interval [0:1]

==== Dimensionality reduction 
- 3x3 CTGF filter can generate 255 x 32 = 2295 feature vectors for ML classifiers (curse of dimensionality).
- Some of these components are also not useful for classification
- Useless of features is evaluating in training set with following their elimination in both training and testing sets
- All features of the training dataset are stacked in a matrix F
- For each component calculation of the range of values is performed
- Then, calculation of the mean of all ranges from all components follows
- Vector KeepVector is generated by eliminating components that are smaller than the mean range

Extract features on the edges because here, there is some differences between printers !!!
Some of printer signatures are very different from other printer signatures...
However some of printer signatures are very similar, but with small variations that allows to make source attribution

==== Deep Learning for Laser printer source attribution
- Letters A end E are extracted, described by an ensemble of CNNs, the characterizations are fused, and the source of a given document is the majority voting of individual SVM classifications
- Each individual member of the ensemble works on different inputs (raw image, median residual and average residual)
- Such networks act as feature extractors (their penultimate layer outputs are fused), and their feature vectors are input to SVM classifiers
- Proposed is very shallow CNN on 28x28 inputs.

Deep learining: not too many classes (example: 100 producers with 10 models = 1000 classes maximum...)not limited by memory, not limited by office hours
However, sometimes interpretation of results is hard and we must properly prepare data before passing it to network
And networks need some data to train.... (There are more and more fake data generated on the web...)
Best solution is a good combination of human and AI.

We are interesting only in transition... We don't care about the shape because then we use histograms and histograms are shape independent !

We use median-residual and average residual images to train / perform analysis on our CNN...
We make a combination from this to have good classification...

==== Approaches for Printed pictures source detection
- Laser Printer attribution by Lee and Choi:
  - printed documents are scanned and converted to CMY color space (CMYK with black because we print a lot of black: it's less costly !)
  - noise of CMY image is isolated by subtracting the original image CMY and CMY filtered by the Wiener filter.
  - GLCM features are calculated from these residual noises and then fed to a machine learning classifier

Features from GLCMs: (To complete)

==== Approaches for Printed pictures source detection
- Laser Printer attribution by Lee and Choi:
  - based on statistics of Discrete Wavelet Transform from color bands (allows more accuracy when using filters because its directional filters...)
  - total of 39 statistical features are extracted from the HH (image is splitted into Low Low / Low High / High Low and High High...) Discrete Wavelet Transform subband and also in the image converted into the CMYK domain.
  - machine learning multi-class classifier can then pinpoint an unknown source if that source is in the training dataset (closed-set problem)

The use of CMYK colorspace is good because document is printed in CMYK....
However, we like also working in RGB because going from RGB to CMYK introduces some approximations...

In HH, we can see a lot of differences between printed image from multiple printers...

Features: (To complete !)

- Laser Printer attribution by Tsai:
  - also Based on statistics of Discrete Wavelet Transform from color bands
  - extraction a total of 45 features from three 2D DWT sub-bands (HH, HL, LH) (they add some components, but they neglect CMYK color space !)
  - performance is compared with four different feature selection algorithms

Note: working with HH etc... is cool, but there is too many data, so it is reduced to some features...

If we have not very good results (like for instance 88%), we increase accuracy of the method by using different methods...

== Conclusion

- Printer attribution is a hot research field in digital forensics
  - Criminal investigations
  - Documents Authentication/anti-counterfeiting
- How to deal with new coming devices and technologies?
- How to deal with adversarial attacks? (reproduce fingerprint of specific printer...)
- How to deal with the open set scenarios? (how can we apply old algorithm on new producers ?)

So we must provide flexibility to deal with different cases....

We must also known how to deal with 3D printing

With small modifications, people can make move the classification to absolute other class... (Ex: stop panel with some things added can be classified as limit to 45 km/h...)

Note: if document is printed in 600DPI, we need to scan it to higher quality, like 2x600 = 1200DPI to not missing something...
Note: we can introduce some textures/properties from a printer when printing with another printer...
