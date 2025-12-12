= Lecture 4

== Traces of image editing: histogram equalization

- Histogram equalization effectively increases the dynamic range of an image’s pixel values by subjecting them to a mapping such that the distribution of output pixel values is approximately uniform
- In order to identify it, we calculate the “uniformity” of the histogram
- For histogram equalized saturated images, the location of the impulsive component is often shifted

histogram cdf ???
Histogram equalization is characterised by a linear cdf cumulative density  function.

== Tampering detection

image manipulation (tampering): it is the application of image editing techniques to images in order to create an illusion or deception after the original photographing took place

- 5 cathegories of techniques

=== Tampering detection: pixel-based and format-based techniques

==== Pixel-based

- Pixels are the building blocks of images
- Image manipulation disrupts statistical properties of the pixels
- Directly or indirectly analyze shows that pixel-level correlations arise in case of specific form of tampering
- Cloning: cloned regions can be of any shape and location
- Resampling: introduces specific periodic correlations between neighboring pixels
- Splicing: disrupts higher-order Fourier Statistics.
- Statistical: images contain specific statistical properties

- image manipulation disrupts statistical properties of the pixels
- Histogram not very informative
- look at neighborhood of pixels !!
- If some modification is applied, statistics are corrupted (local statistics can become more smooth, etc...)
- If something is exactly equal to another thing in the image, it's an information that image has been modified because 2 photos of same object will not have same properties...

==== Format based techniques

- lossy compression introduces artifacts
- rely on image compression specificities to detect forgery
- JPEG is the most common format

===== Ex

- double JPEG compression
- JPEG blocking artifacts (due to grid of added image not aligned on grid of background image)
- JPEG Ghost detection: based on analyses of double JPEG compression artifacts detects lower quality image patches spliced into higher quality images
(if JPEG compression quality of a part of the image is not the same that in another part of the image, a part of the image is modified)

=== Tampering detection: camera-based, physics-based and geometry-based techniques

==== Camera-based techniques (examples)

- Chromatic aberations: variations in chromatic aberration patterns across an image may be used as evidence of image tampering.
- Sensor noise: distortions of sensor noise pattern (example: PRNU)
- Color filter arrays
  - color calculation from neighbor pixels introduces recognizable correlation patterns between pixels in an image
  - different cameras may have different patterns (Bayer/Diagonal Bayer/Stripes/etc...)
  - different cameras interpolate using different, often, proprietary, filters (theses methods are repeated many times, so we can see when something is wrong.... In general, peoples make some assumption: if they use this, we will obtain this result etc... And in general, it's enough)

==== Physics-based techniques

- 2D lighting: considers only the two-dimensional (2-D) surface normals at the occluding object boundary
- 3D lighting: uses the model of the human eye to determine the required 3D surface normals
- Light environment: uses an approximation of a Lambertian surface, simplified further to consider only the occluding boundary of an object.

==== Geometric-based techniques

- principal point estimation: principal point is the projection of the camera center onto the image plane.
  When a person or object is translated in the image, the principal point is moved proportionally (perspective respected or not ???)
- metric measurements: tools from projective geometry that allow for the rectification of planar surfaces and, under certain conditions, the ability to make real-world measurements from a planar surface.

== Conclusion

Is this image modified or not ???

= Lecture 5: Digital Forensics of Printed Document

== Printed documents forensics: general principles

In nowadays digital society printed documents are still widely used (payment/advertisement/tracking and tracing, ...)

Why ? Some documents can contain important informations.
We want to be sure this documents are officials (QR code authenticity, stickers on products, counterfeiting, etc...)
Stafless stores: sure that what we bought is what we want to bought...

=== Negative effects

- same printing technologies are also publicly available and relatively cheap
- not only legal documents are producing:
  - fake currency
    - can destroy economy of a land... Sometimes, fake is better made than original
  - packages for fake products (very sensitive for medicaments !!!)
    - fake products packaging
  - fake ID documents with biometric adversarial attacks
    - print spoof attack is the simplest form of folding biometric authentication systems
    ex: face printing to unlock facial recognition
    - photo/video/mask attacks

=== Protection on couterfeiting

- compagnies focused on anti-counterfeiting solutions

== Device attribution: basic concepts

A set of computer vision techniques applied in a digital version of a document, aimed at pointing out which device is its source

- devices attribution can be done searching two kinds of artifacts (or signatures\fingerprint)
  - extrinsic (watermarking): inserted by the device in the document
  - intrinsic (blind): given by the analysis of the resulting document
- device attribution involves answering two questions:
  - which device brand and model produced a given document?
  - which specific device produced a given document ?

=== Steps

- understand how the device work
- find unique behavior of the device in the document.
  Common fingerprints of any kind of device:
  - texture of printing patterns
  - noise
  - distortions
  - other imperfections such as dust, scratches, etc... (create unique fingerprint !!!)
- describe these behaviors for device attribution.
  They are commonly yielded by devices manufacturing process or after use for a long time.

=== Principe of scanner operation

Scanner vs camera: quality of scan is better than photos from camera !!

- mirror reflects light that from the paper in the glass, illuminated by a lamp.
- a set of lens focuses the reflected light from the mirror into a sensor (CCD)
- data in the sensor is digitized via an analog-digital converter (ADC)

=== Principe of laser printing

drum is charged... lazer discharge drum where we want to print something.
Then toner put particles in this place, go on paper, deposit particles on paper.
Finally, fuzer fix particles in document thanks to compression and high temperature.

- data is written by a laser beam, which discharges certain places in a drum where ink must be put
- positively charged ink is then stick in the discharged places of the drum
- data with ink is spread on the paper by the fuser

Scanner vs camera: higher resolution !

=== Artifacts of laser printing

Human eyes interpolate small details
So laser make small points close to each other to see global color

- Laser printers have electric-mechanical parts that behave differently
- Differences can be seen on the halftones of printed material

- Banding: textural pattern composed of horizontal, low frequency, and periodic dark lines caused by the laser printer components variation, vibrations, and speed regulation that are perpendicular to direction in which the paper moves through the printer.
- Jitter: horizontal artifacts, but with a different frequency range and duration, caused by oscillatory disturbances of the printer’s drum and the developer roller.
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

== Approaches for text printed source detection (passive source attribution)

=== Printed text fingerprints

The following areas of a document can be used for analysis in laser printer attribution:
- Characters $->$ applied on text
- Segmented areas (frames) $->$ applied on text and images
- Whole document $->$ applied on text and images

==== Why passive approach ?

- Modification not change results (like inserting bad printer identification)
- Time constraint... Can work even if document was printed a long time ago and identification system has changed...

==== Laser Printer attribution by Ali et al. :

- applied in letters of text (letter I) (it's the simplest letter !!!)
- projection (pixel values) are used as fingerprints
- as the extracted letters cannot be of the same font and size, and to avoid the curse of dimensionality in machine learning, the images are pre-processed by Principal Component
- machine learning classifier (Gaussian mixture model (GMM)) is used to recognize these texture patterns for each printer

Not very accurate result when taking printer from same generation (for instance LJ1000 and LJ1200 !)

*Problem: Letter "I" don't appear a lot of times in a document !*

== GLCM approach for Laser printer attribution (Mikkilineni et al.)

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

==== Laser Printer attribution by Ferreira et al. :

- letters “e” are also analyzed
- proposed the multiscale and multidirectional texture analysis inside printed material
  - improvement of Mikkilineni et al. approach
  - 1 ad-hoc descriptor
  - fusion of both
- analysis that works on images, texts or on both (Must be the same image printed in multiple printers !)
- it can be applied in the whole document, letters or regions of interest (frames).
- reasoning behind the approach: there are multi-scale and multi-directional printing patterns inside printed material (areas with a specific gradient)

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

== Convolutional Texture Gradient Filter (CTGF) descriptor

- Calculates neighboring textures in specific areas (intervals) of gradient
- Describes the printer signature as a histogram of such textures
- Textures on almost flat areas (with an interval of small gradient values) are intentionally generated by printers firmware

=== Steps

- Step 1: Negative
  - The image pixels s in the scanned image S are inverted to pixels n given the following formula: $n = 255 – s$
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
  - In parallel with the previous step, a gradient between a pixel and its $n^2 -1$ neighbors is calculated: $d_(x, y) = |x - y|$
  - Final gradient matrix is built as follows
  $
    G(i, j) = cases(0 "if pixel is in the borders", max_(i - 1 <= p <= i + 1 \ j - 1 <= q <= j + 1)(d_(R_(i, j), R_(p, q))) "otherwise")
  $
- Step 4: Gradient filter
  - Calculated textures in $C$ are filtered according to an optimal interval of gradients found experimentally
  - Two parameters $g_("low")$ and $g_("high")$ define the range of gradient values that are valuable for printer signature
  - The final matrix T is the matrix C without values from out-of-gradient-range.
- Step 5: Histogram construction
  - Histogram is an approximate representation of the distribution of numerical data.
  - As matrix C sums up all neighboring values in an $n times n$ area, the values from the histogram start at 0 and go until $255 times n^2$. Then, vector H with $255 times n^2$ dimensions is generated
- Step 6: Min-Max normalization
  - Final feature vector V is generated by applying a Min-Max normalization on H, scaling the components to the interval [0:1]

=== Dimensionality reduction

- 3x3 CTGF filter can generate $255 times 3^2 = 2295$ feature vectors for ML classifiers (curse of dimensionality).
- Some of these components are also not useful for classification
- Useless of features is evaluating in training set with following their elimination in both training and testing sets
- All features of the training dataset are stacked in a matrix F
- For each component calculation of the range of values is performed
- Then, calculation of the mean of all ranges from all components follows
- Vector KeepVector is generated by eliminating components that are smaller than the mean range

Extract features on the edges because here, there is some differences between printers !!!
Some of printer signatures are very different from other printer signatures...
However some of printer signatures are very similar, but with small variations that allows to make source attribution

== Deep Learning for Laser printer source attribution

- Letters A end E are extracted, described by an ensemble of CNNs, the characterizations are fused, and the source of a given document is the majority voting of individual SVM classifications
- Each individual member of the ensemble works on different inputs (raw image, median residual and average residual)
- Such networks act as feature extractors (their penultimate layer outputs are fused), and their feature vectors are input to SVM classifiers
- Proposed is very shallow CNN on 28x28 inputs.

Deep learining: not too many classes (example: 100 producers with 10 models = 1000 classes maximum...) not limited by memory, not limited by office hours

However, sometimes interpretation of results is hard and we must properly prepare data before passing it to network
And networks need some data to train.... (There are more and more fake data generated on the web...)
Best solution is a good combination of human and AI.

We are interesting only in transition... We don't care about the shape because then we use histograms and histograms are shape independent !

We use median-residual and average residual images to train / perform analysis on our CNN...
We make a combination from this to have good classification...

== Approaches for Printed pictures source detection

=== Laser Printer attribution by Lee and Choi:

- printed documents are scanned and converted to CMY color space (CMYK with black because we print a lot of black: it's less costly !)
- noise of CMY image is isolated by subtracting the original image CMY and CMY filtered by the Wiener filter.
- GLCM features are calculated from these residual noises and then fed to a machine learning classifier

Features from GLCMs:
- homogeneity
- contrast
- energy
- correlation
- covariance

=== Laser Printer attribution by Lee and Choi:

- based on statistics of Discrete Wavelet Transform from color bands (allows more accuracy when using filters because its directional filters...)
- total of 39 statistical features are extracted from the HH (image is splitted into Low Low / Low High / High Low and High High...) Discrete Wavelet Transform subband and also in the image converted into the CMYK domain.
- machine learning multi-class classifier can then pinpoint an unknown source if that source is in the training dataset (closed-set problem)

The use of CMYK colorspace is good because document is printed in CMYK....
However, we like also working in RGB because going from RGB to CMYK introduces some approximations...

In HH, we can see a lot of differences between printed image from multiple printers...

Features:
- sdv
- skewness
- kurtosis
- covariance
- correlation

=== Laser Printer attribution by Tsai:

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

= Lecture 6: Deep learning methods in digital forensics

=== Introduction

==== When problem happen

In the end of the 90’s, the diffusion of easy-to-use image editing tools raised increasing alarm about the credibility of digital images and the possible use of manipulated images for malevolent purposes

- Use of digital images in a court of law
- Gossip / defamation
- Bias the political debate

First technical solutions were appeared in the early 2000’s proposed by researchers working in steganalysis

==== AI media revolution

An ubiquitous presence

- Image taken by cell-phone are “doctored” at the origin
- All cell phones have AI-based apps to retouch/manipulate images easily and in a credible way
- AI image editing tools are freely available online
- All photo editors are equipped with AI tools easier and easier to use
- Video enacting or puppeteering will soon be available on any video conferencing systems
- Companies are already working on a video version of DALL-E

Does conventional MMF (Multi-Media Forensic) still make sense?
- The amount of possible modifications, their extent and the progress of image editing AI clearly outgun the capabilities of MMF research
- MMF forensics IN THE WILD is more difficult than ever
- Understanding that an image has been “manipulated” by an AI tool may (no longer) be a meaningful info

== DNN watermarking

=== Shift of paradigm

==== Old idea

Why don't we embed an invisible watermark in all AI images so to ease

- Origin verification
- Trace manipulation history
- Detection of abuses

Unfeasible solution: how can we enforce the watermarking of all images generated or edited by means of AI?

==== New idea

Rather than engaging a hopeless race of arms with generative AI companies, team up with them to ease the ethical use of digital images and identify abuses

Watermark AI generative models so that all the images they produce contain a watermark

Possibly feasible: only a handful of companies are capable to train from scratch a new AI generative model

=== DNN watermarking in nutshell

DNN watermarking has been proposed as a way to protect the IPR of DNN models

It indissolubly embeds within a DNN model a piece of information to be used later for a given purpose
The watermark should resist moderate to strong model modifications, like pruning, compression, fine tuning and even transfer learning

DNN watermarking = function watermarking

Digital communication problem (multi-bit watermarking)

Watermarking:

- White-box
- black-box
- Box-free... Joint DNN and media watermarking

==== Kill two birds with one bullet

Box-free watermarking can be used to detect and trace synthetic contents to the model which generated them

==== Challenges

- Development of a brand new theory of function watermarking
- Model-level robustness
- Image-level robustness
- Security model
  - Embedded information
  - Who does what?
  - Keyword management
- Security against intentional attacks

== GAN watermarking: early and new solutions

=== Image processing

Watermark is quite resistant

=== Model pruning

We can cut up to 1/4 of the network, watermark is preserved

=== Model quantization

Precision in model coefficients... Watermark preserved until precision of 3 number after ,.

=== Fine tuning

...

=== Super resolution

Create super resolution with watermark

== Supervised watermarking

graph here

== Retraining free fingerprinting

For some applications it may be useful to embed different watermarks in different version of the same DNN model

With most methods this requires a heavy retraining

=== Solution

Introduce a personalized layer in the generator whose parameters are responsible for watermark embedding

The parameters are generated (feedforward) by a separate parameter-
generation (ParamGen) network for each different watermark

ParamGen network derives the parameters resulting in the embedding of the desired watermark without retraining

Introduce some small modifications in watermark to have unique watermark for each user...

Normalization step: mean = 0 and std = 1...

To create a model with a given watermark it is only necessary to run the ParamGen networks and generate the weights of the personalized normalization layer

=== Sense of achievable results

- Boundary Equilibrium GAN (BEGAN)
- Spectral Normalization GAN (SNGAN)
- Progressive Growing GAN (PGGAN)
- Face generation, trained on CelebA dataset
- Penultimate layer for PN
- ParamGen networks: fully connected, ReLu, 128 wm bits

The $L_("const")$ is crucial to enforce a uniform behavior of models watermarked with different bits

Some results...

=== Conclusion

Limits of classical Multimedia forensics in the AI era

- Still valid in specific, narrow, scenarios
- Difficult (impossible) to cope with in a wide settings
  - Disinformation campaigns

DNN-based active fingerprinting may provide a solution

- Challenges to be solved (robustness and security)
- No general solution, but can be a valid complement to passive MMF

= Lecture 7: Modern Steganography

== Methods of information hiding

In computer science, information hiding is the principle of segregation of the design decisions in a computer program that are most likely to change, thus protecting other parts of the program from extensive modification if the design decision is changed

== Steganography: hidden communication
Steganography is the art/science of communicating hiding the existence of the communication

In contrast to cryptography, where the enemy is allowed to intercept and modify messages without being able to violate the security ensured by a cryptosystem, the goal of steganography is to hide messages inside other harmless messages in a way that does not allow the enemy to even detect the presence of the embedded secret message

== Cryptography
Cryptography is the study of secure communications techniques that allow only the sender and intended recipient of a message to view its contents.

The term is derived from the Greek word kryptos, which means hidden.
It is closely associated to encryption, which is the act of scrambling ordinary text into what is known as ciphertext and then back again upon arrival

== Steganography
- Greek Words : STEGANOS – “Covered” GRAPHIE – “Writing”
- Steganography is the art and science of writing hidden messages in such a way that no one apart from the intended recipient knows of the existence of the message.
- This can be achieve by concealing the existence of information within seemingly harmless carriers or cover
- Carrier: text, image, video, audio, etc.

The primary goal of steganography is to hide a message inside another message in a way that avoids drawing suspicion to the transmission of the hidden message. If suspicion is raised, then the goal is defeated.

== Historical notes
- Steganography is as old as the humans
- Ancient Chinese
- Herodotus:
  - Tatooing the head of a shaved slave
  - Writing on wood tablets then covered by wax
- Boccaccio: Amorosa visione (acrostic)
- Music-stego
- Invisible ink
- Modern publishing

=== Ancient Chinese
- Wax  balls:  the  messages  were  written  on  silk  and  encased  in  balls  of  wax.

  The wax ball could then be hidden in the messenger

- Paper masks: The sender and the receiver shared copies of a paper mask with
  a number of holes cut at random locations

=== Herodotus
- Shaved slaves: messages were written over slaves heads
- Wax tablet: method was to engrave a message  in a block of wood, then cover it with wax, so it  looked like a blank wax tablet.
  When they wanted to retrieve
the message, they would simply melt off the wax

=== Acrostic

- Take initial letters:  mfbuyiwubfstidttmnttgilaumwuniptcosnatpttafsotncaiaswttitintplpftbtxlfan
htitqompca
- Filter with p = 3.141592653689793...-> buubdlupnpsspx
- Take the previous letter in the alphabet: ATTACK TOMORROW

=== Music-stego

=== Invisible inks
- Lemon, urine: after burned released carbon shows up
- Refined with chemistry: salt ammoniac dissolved in water
- Refined with biology: some  natural unique responses

=== Modern publishing
- Intended gaps: False  intended data
- Microdots: imperceptible dots
- Line spacing: modern  publishing

== Steganography in the digital age
- Renewed interest starting from nineties
- Enabling technologies:
  - Wide band communication channels
  - Diffusion of multimedia contents
  - Possibility of using automated steganographic  techniques with high payloads
- Motivations
  - Espionage, terrorism
  - Dissidents, freedom of expressing own opinions against censorship
  - Privacy protection - avoid big-brother scenarios

== Steganalysis
- Complementary motivations pushed researchers to study steganalysis
  - Techniques to reveal the presence of hidden messages(possibly without decyphering them)
- Motivations
  - Intelligence, police
  - Control of public opinion
- Regardless of motivations, the study of steganalysis is necessary to determine the security of steganographic techniques

=== Opposite requirements
In steganography designers must face with 2 opposite requirements:
- Invisibility (statistical) This invisibility must be statistical...
- Capacity (payload) This is the amount of data that we want to communicate...

=== Perceptual invisibility
The hidden message must remain invisible even after the applications of signal processing techniques

=== The invisibility requirement
- Together with perceptual invisibility we require
  - statistical invisibility
- Assumptions on warden behavior
  - Active, passive
  - Kerckhoff’s principle:
    - The warden knows the steganographic algorithm
    - The warden knows the statistics of the image source used by Alice
- Invisibility alone is not sufficient
  - Real life is always more complex than mathematical models (as cryptographers learnt quite soon)
  Example to avoid some steganography transmission in images: compress image 2-3% and there is no more steganography.

=== A first choice: hiding domain
- Spatial/pixel domain steganography
  - Easy to use
  - High capacity (guarantee perfect extraction of the message of receiver side...)
  - Simple analysis of perceptual visibility
- Transform/compressed domain steganography (JPEG)
  - The message is conveyed by (block) DCT coefficients
  - Wide diffusion of JPEG images
  - Lower security (due to the availability of good statistical models
to describe DCT coefficients)
- Example: F5, OutGuess, Jsteg (most of them are available on the internet)

==== Spatial/pixel domain
The stego-message is hidden in the array of integer numbers a digital image consists of

==== Transform/frequency domain
In some cases, for instance with JPEG images, the stego message is hidden into the (block) DCT coefficents of the images

=== Three classes of steganographic algorithms
- Steganography by cover selection
- Steganography by cover synthesis
- Steganography by cover modification

==== Steganography by cover selection
- Alice has a database of images, wherein she chooses the image corresponding to the correct message. The message can be linked to
  - Semantic image content
  - Value of a selected subset of LSB’s
  - Image (or subimage) hash
- Pros
  - Almost perfect security
- Cons
  - Very low payload
  - Example: an 8 character message (64 bit) requires a database with at least  264 (1019) images

==== Steganography by cover synthesis
- Alice creates an image on-the-fly conveying the to-be-transmitted message
- Creating a realistic image is not easy. Alice could proceed as follows
  - Alice gathers several shots of the same scene
  - Alice divides the images into blocks. Each block is associated to some message bits (e.g. through a subset of LSB’s)
  - Alice builds the final image by properly assembling the blocks from various images
- Pros: good security (problems at block borders)
- Cons: still low payload (too many images needed)

==== Cover synthesis by AI
- GANs and other generative models proved to be able to generate visually plausible fakes
- Two CNNs struggling following a Game-theoretic formulation

==== Steganography by cover modification
- By far the most common approach
- It allows large payloads, but security must be studied carefully

==== A detailed example: LSB embedding

The least sensitive bits (LSB’s) of the pixels of an image (or the DCT coefficients) are replaced with the stego-message  (payload = 1bpp)

==== Visual imperceptibility

LSB replacement looks perfect (but is not): the LSB plane of an image is very similar to noise

==== Attacking LSB replacement
As a matter of fact, steganalysis of LSB replacement steganography is quite easy (at least for high payload)

- If x(i) is even we have 01100000 which remains as is or is increased by 1 -> 01100001
- If x(i) is odd we have 01100001 which remains as is or is decreased by 1 -> 01100000
- Consider the pair (0,1): (00000000, 00000001)
- Half of the pixels equal to 0 pass to 1 and half of the pixels equal to 1 pass to 0
- At the end we have about the same number of pixels = 0 and pixels = 1, that is hstego(0) = hstego(1)

==== Countermeasures
- Perfect steganography requires that all image statistics are preserved, however
  - It is impossible to derive adequate statistical models of images (slightly better in the DCT domain)
  - It would be too complicated
- Four empirical approaches are used in practice
  - Model-preserving staganography
  - Stochastic modulation
  - Steganalysis-aware steganography
  - Distortion minimization

==== Model-based steganography
- A model is identified to describe the image source
- Steganography acts in such a way not to modify the model
- Example: statistic restoration (We modify for instance the LSB to have same statistics characteristics... And we know exactly which bit pick up...)
  - The message is inserted in a subset of pixels (or coefficients)
  - Other pixels are modified so to restore the statistical model, e.g. the histogram
  - OutGuess -> works in this way in the DCT domain
- Nearly perfect security as long as the steganalysis relies only on the adopted statistical model (in practice this is never the case)

==== Stochastic modulation
- It simulates the noise added to the image during the acquisition
phase
- Steganography works by adding a noise that resembles acquisition noise
  - Thermal noise
  - Quantization noise
  - PRNU
- It allows rather high payloads (0.8 bpp bit per pixel)

==== Steganalysis-aware steganography
Extension of stochastic modulation... Make convolution of message and cover image... It's one of the hardest to detect method...
- The steganographer acts in such a way to eliminate (reduce) the artefacts exploited by the steganalyzer
- Example: ±1-steg
  - If the LSB is the correct one doesn’t do anything
  - If the LSB is wrong, add or subtract 1 randomly
  - Observation: ±1steg does not modify only the LSB 01111111+1=10000000 (conditional summation allowing to extract the message...)
- Security increases dramatically since the histogram does not change significantly (convolution)
- F5 uses ±1-steg in the frequency domain

==== Distortion (impact) minimization
- Most modern approach
- Define a cost function
  - How much does it cost to modify a certain pixel? Say ρ(i)n
  - Overall cost  = $sum_(i = 1)^n rho(i)[x(i) − y(i)]^2$
- Identify an embedding rule which minimizes the embedding cost
  - F5 is optimum from this point of view (DCT domain)

==== Typical payloads
- Payload
  - from 0.1 to 0.5 bpp in the pixel domain: 1000x1000 image => ~ 40Kbyte
  - up to 0.8 bpnzc in the DCT domain: The actual payload depends on the image content. A realistic value is around 20Kbyte for a 1000x1000 image

=== Steganalysis
The application scenario is of the outmost importance together with the information available to the warden
- Blind vs targeted steganalysis
- Knowledge of cover image statistics
- Knowledge of payload

==== hypothesis test
- Rigorous formulation
- Observables: y = {y1, y2 ... yN}
  - Image pixels, audio signal samples, etc.
  - Often to simplify the  problem the analysis relies on some functions of y (features)
- Two alternative hypothesis
  - H0 : y does not contain a hidden message
  - H1 : y contains a hidden message
- Optimum decision with respect to a certain criterion
- Bayes criterion
  - Minimization of overall error probability
  - Difficult to apply since a prior probabilities are not known
- Neyman-Pearson criterion
  - False alarm probability
    - Decide in favour of H1 when H0 holds
  - Missed detection probability
    - Decide in favour of H0 when H1 holds
  - N-P: minimize Pm for a given (maximum) Pf
- In steganalysis we must first fix Pf and then decide how to use the result of the test

Example: Let us assume that the test relies on a single statistics with known pmf
(Gaussian) under both H0 and H1.

For any value of Pf (threshold) we find a Pm.
The plot showing Pd = 1- Pm as a function of Pf is called ROC curve

The goodness of a steganalyzer is evaluated by means of the ROC curve or its AUC (areas under curve the big is the area, the more accurate the system is for steganalysis... For steganography, we expect something linear...).
Perfect security requires that performance are equal obtained by means of a random guess (diagonal ROC, AUC = ½).

Example:
- Let us assume that the pdf of the image source is known. In this case the steganalyzer can use a Chi Suare test
- Divide the pdf in several intervals (bins)
- Compute how many times the observed samples fall in the bins: let us indicate this value as ni
- Given the pdf let indicate with pi the probability that a sample falls into the i-th bin
in − npi( )2
npi
n
 2 = i=1
- High values are taken as an evidence in favour of H1

=== Choice of statistics (feature)
- In targeted seteganalysis we use few ad-hoc statistics
- Example: LSB replacement steganalysis
  Given an image and its histogram, we can use a Chi-square test in which the assumed pmf is
  $h_(H_(p 1)) (2k) = h_(H_(p 1)) (2k +1) = (h(2k) + h(2k +1)) / 2$ with $h$ value of a bin inside histogram... So we compare consecutive bins of histogram !!
  Such a test reveals the presence of LSB steganography (at 1 bpp)with great accuracy. Steganalysis is obviously more difficult at low payloads

- With blind steganalysis everything is more difficult
- If source statistics are known we can still use targeted features
- Otherwise
  - Compute many features (> 100) that do not depend on image content
  - Train a classifier with properly chosen examples
    - Neural networks, Support Vector Machines (SVM)
- ROC curves are evaluated empirically on a test set
- CNN applied directly in the pixel domain are rapidly replacing SVMs (obtain benefits in computationnal power, but lost accuracy by no pre-processing of images to have better results of analysis...)

== Summary
- Several steganographic techniques exist with a large number of available software packages
  - Security looks trivial but is not
  - Need to know at least basic principles
  - Take care of system attacks
- Steganalysis
- Reliable in some selected cases, but difficult in general
- Strongly dependent on application scenario
- Work in progress

