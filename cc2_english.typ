#import "@preview/tablem:0.3.0": tablem
// Main report file
#import "template.typ": make-report, report-footnote
#import "metadata.typ": my-report

#show: make-report.with(my-report)


= Image Editing

== Image Retouching Traces: Histogram Equalization

Histogram equalization is an image processing technique aimed at *increasing the contrast* of an image.
It achieves this by reassigning pixel values (their luminance or color) so that the distribution of new values is approximately *uniform*.
This has the effect of spreading out the dynamic range of pixels, making details more visible, especially in dark or very bright areas.
- *Identification:* To detect if this technique has been applied, one analyzes the image's *histogram*.
One seeks to calculate its "uniformity".
- *Key Feature (CDF):* An image that has undergone histogram equalization is characterized by a *Cumulative Distribution Function (CDF)* of its pixel values that is *linear* in shape.
It is this linearity of the CDF that guarantees the uniform distribution of output pixels.
- *Case of Saturated Images:* Applying equalization to images with zones of *saturation* (maximum or minimum pixel values reached) often leads to a *displacement* of the histogram's *impulsive peaks*, which can *complicate the detection* of the manipulation.
- *Detection Complicated by Saturation:* Detection of equalization often relies on observing the *alignment of steps* or the *linearity* of the CDF.
In images with saturation zones (pixels at 0 or 255), equalization forces these large masses of pixels to *spread out* over the new dynamic range.
This results in *shifting* the *impulsive peaks* (the steep steps) of the histogram to unexpected positions.
This displacement *disrupts the statistical models* used to judge the "cleanliness" of the pixel distribution, making it harder to confirm or deny the presence of equalization.

#pagebreak()

== Tampering Detection

Image alteration or *forgery* (_tampering_) is the application of editing and retouching techniques after the original capture, with the aim of creating an _illusion_ or a *deception*.
- It typically groups *five categories* of main techniques.

=== Tampering Detection: Pixel-based and Format-based Techniques

==== Pixel-based Techniques

Since pixels are the fundamental units of an image, any manipulation disrupts their intrinsic *statistical properties*.
Direct or indirect analysis of these properties reveals specific *correlations* introduced by retouching.
- *Image manipulation* corrupts the statistical properties of pixels, notably *local* statistics which may become artificially smoothed.
- *Cloning:* Consists of copying/pasting a region (of any shape and location) within the same image.
- *Resampling:* Introduces specific *periodic correlations* between neighboring pixels, often detectable by frequency analysis.
- *Splicing:* Technique of pasting a part of an image from another source, which disturbs *higher-order Fourier statistics*.
*Identification by pixels:*
- The histogram alone is not very informative. One must analyze the *immediate neighborhood* of the pixels.
- A strong indication of modification is the *presence of two exactly equal regions* in an image, because two photos of the same object, even taken under identical conditions, would never have the same noise and sensor statistical properties.
==== Format-based Techniques

These techniques rely on analyzing the specificities and *artifacts* introduced by *lossy compression*, with JPEG format being the most common.
- Lossy compression (like JPEG) introduces specific *artifacts* into the image.
- These methods exploit the particularities of compression schemes to detect forgery.
===== Examples

- *Double JPEG Compression:* When an image already compressed in JPEG is edited and then *recompressed* in JPEG, the second compression leaves very recognizable artifact patterns.
- *JPEG Blocking Artifacts:* If a zone is spliced, it is likely that the JPEG compression grid of the inserted fragment is *not aligned* with that of the background image, creating artifact boundaries.
- *JPEG Ghost Detection:* Based on the analysis of double compression artifacts.
It allows detecting the insertion of *low-quality* image patches into a *higher-quality* image, signaling that different parts of the image have undergone different levels of compression.

#pagebreak()

== Tampering Detection: Camera-based, Physics-based, and Geometry-based Techniques

These techniques focus on analyzing intrinsic properties related to the *capture process* or the *spatial consistency* of the image.
==== Camera-based Techniques

They exploit specific characteristics left by the sensor and the internal processing of the camera.
- *Chromatic Aberrations:* Variations in chromatic aberration patterns (color fringes at contrasts) within an image can signal an *inserted* or *altered zone*, as they should be uniform.
- *Sensor Noise:* Any alteration _distorts_ the unique sensor noise pattern (the *PRNU* - _Photo-Response Non-Uniformity_), which is like the sensor's fingerprint.
- *Color Filter Arrays (CFA):*
  - Calculating colors (_demosaicing_) from neighboring pixels introduces *recognizable correlations* between pixels of an image.
- Different cameras use different filter patterns (Bayer, Diagonal Bayer, Stripes, etc.) and _proprietary_ interpolation algorithms.
- These methods, applied repeatedly and according to well-known assumptions, allow for *detecting an inconsistency* when a part of the image has been processed by a different filter.
==== Physics-based Techniques

These methods verify if *light and shadows* in the image are *consistent* with the geometry of objects, signaling if an object has been inserted or if light sources are impossible.
- *Surface Normal Verification (2D vs 3D):*
  - *Surface normals* represent the *orientation* of an object's surface relative to the light source (they are essential for determining shadow/light intensity).
- *2D Lighting:* This simplified approach analyzes surface normals by considering only the *contour* of an object (its _occlusion boundary_) in the two-dimensional plane of the image.
- *3D Lighting:* Uses more complex scene models (sometimes inspired by human perception) to determine *3D surface normals*, allowing for much more precise verification of *spatial consistency* between the light source, objects, and shadows.
===== Clarification: 2D Lighting Analysis

The 2D Lighting approach is a *simplified* technique aimed at determining the direction of the light source and the consistency of cast shadows, without needing to reconstruct the full 3D space of the scene.
- *Principle of Surface Normals:* The amount of light (brightness) reflected by a point on an object's surface depends on the *angle* between the *surface normal* (the line perpendicular to the surface at that point) and the *direction of the light source*.
- *Simplified 2D Analysis:* To simplify the calculation, the 2D approach focuses only on the *occlusion boundary* (the *contour* of the object) in the image.
- The analysis assumes that the *change in light intensity* along this contour is directly related to the direction of the light.
- For example, the side of an object directly facing the light should be brighter, while the opposite side (the shadow edge) should darken quickly.
- *Forgery Detection:* The goal is to ensure that the light intensity at the edges of the inserted object (_spliced fragment_) is *compatible* with the light intensity of the edges of the background image objects.
If an inserted object was not lit by the same light as the background, the pixel intensity along its contour will betray the inconsistency.
- *Limitation:* This method ignores the internal *curvature* and *3D details* of the object's surface, as it only looks at its 2D projection (the contour).
It is therefore *less robust* than 3D analysis, but much faster to compute.
- *Light Environment Analysis:*
  - This technique determines the *direction* and *nature* of the light source.
- It often simplifies analysis by approximating a *Lambertian* surface (an ideal surface that reflects light *perfectly diffusely* in all directions).
- The analysis then focuses on the *occlusal boundary* (the contour) of an object to verify if the lighting on that object is *compatible* with the lighting of the rest of the scene.
An inconsistency signals that an object was inserted afterwards.
==== Geometric-based Techniques

They use principles of perspective to verify if the scene and inserted objects respect the laws of projection geometry.
- *Principal Point Estimation:* The principal point is the projection of the camera's *optical center* onto the image plane.
- When an object is *moved* (_translated_) in the image, the principal point associated with that object must move *proportionally* if perspective is respected.
Detection verifies this proportionality.
- *Metric Measurements:* Employs *projective geometry* tools to:
  - *Rectify* planar surfaces (walls, floors).
- Allow, under certain conditions (if reference elements are known), taking *real measurements* from the planar surface of the image, thus revealing scale inconsistencies.


#pagebreak()

= Digital Forensics of Printed Document

== General Principles of Printed Document Forensics

Despite the digitalization of society, printed documents (payments, advertising, traceability, etc.) remain *widely used* and *essential*, as some contain *vital* information.
- *Objective:* The goal is to guarantee the _authenticity_ of these documents (verification of QR codes, labels, anti-counterfeiting, etc.).
- *Example:* In _staffless stores_, forensic analysis can help ensure that the purchased item corresponds to the registered item.
=== Negative Effects and Challenges

One of the major challenges is that the *same professional printing technologies* are now *accessible* and relatively *cheap* for the general public and counterfeiters.
- *Counterfeit Currency:* The production of fake money can *destroy the economy* of a country.
Sometimes the counterfeit is technically *better realized* than the original currency.
- *Fake Product Packaging:* Creation of packaging for counterfeit products, which is *extremely critical* in the field of *medicine* where it endangers public health.
- *Fake Identity Documents:* Creation of fake ID documents integrating *biometric adversarial attacks*.
- *Print Spoof Attack:* This is the simplest form of attack against biometric authentication systems (examples: printing a person's face to unlock facial recognition, or using photos, videos, or masks).
=== Protection against Counterfeiting

- To counter these threats, many *companies specialize* in developing *anti-counterfeiting* solutions (special inks, security patterns, etc.).

#pagebreak()

== Device Attribution: Basic Concepts

Device Attribution is a set of computer vision techniques applied to a digital version of a document, aiming to identify its *source of origin* (the machine that produced it).
- Attribution is done by looking for two types of *signatures* or *fingerprints*:
  - *Intrinsic* (_Intrinsic / Blind_): Artifacts naturally present in the document, resulting from the capture or printing process.
- *Extrinsic* (_Extrinsic / Watermarking_): Information inserted _intentionally_ by the device (e.g., traceability micro-dots).
- Attribution aims to answer two questions:
  - Which *brand* and which *model* of device produced this document?
- Which *specific device* (serial number, unit) produced this document?
=== Steps of Attribution

- *Understanding the Operation:* First, one must know how the device works (scanner, laser printer, etc.).
- *Search for Uniqueness:* One looks for a *unique behavior* left by the device in the document.
- *Common Fingerprints:* The *texture* of printing patterns, *noise*, *distortions*, and other imperfections like *dust* or *scratches* (which create a unique fingerprint).
- These behaviors are generally the result of the *manufacturing process* or the *wear and tear* of the device over time.
- *Description:* One models and describes these unique behaviors to use them in attribution.
=== Scanner Operating Principle

- Scans have *better quality* than photographs taken with a camera.
- A *lamp* illuminates the document through a glass pane. Light is reflected by the paper.
- A system of *mirrors* and *lenses* focuses the reflected light onto a *sensor* (_CCD_ or _CMOS_).
- The analog data from the sensor is digitized by an *Analog-to-Digital Converter* (_ADC_).
=== Laser Printing Principle

The process involves the use of electrostatic charge, toner, and heat to fix the ink.
- The *drum* is first positively charged.
- A *laser beam* discharges the areas of the drum where ink needs to be deposited.
- The *toner* (positively charged ink powder) adheres to the discharged areas of the drum (according to the image to be printed).
- The toner is then transferred onto the paper.
- The *fuser* permanently fixes the ink particles onto the document thanks to *compression* and *high temperature*.
- *Advantage:* Laser printing offers *higher resolution* than many other methods.
=== Laser Printing Artifacts

Since the human eye tends to interpolate small details, laser printers use *small, closely spaced dots* (_halftones_) to simulate global color.
Subtle differences between machines are often visible in these *halftones*.
- The *electro-mechanical* components of laser printers behave differently from one machine to another.
- *Banding:* Textured pattern composed of *dark, horizontal, periodic, and low-frequency lines*.
It is caused by variations in laser components, *vibrations*, or poor regulation of paper movement speed (perpendicular to the motion).
- *Jitter:* *Horizontal* artifacts but with a different frequency range and duration.
They are caused by *oscillatory* perturbations of the printer drum and the *developer roller*.
- *Skewed Jitter:* Similar *periodic* artifact, but manifests as *vertical lines*.
==== Clarification: Causes of Laser Printing Artifacts

Laser printers are high-precision machines relying on *perfect* alignment and speed of rotation and translation.
Artifacts (Banding, Jitter) result from inherent *imperfections* in electro-mechanical components and their wear.
- *General Causes:*
  - Mass production means components (drum, rollers, motors) have slight *manufacturing tolerances* that differ from one machine to another.
- These differences lead to minimal but regular *speed variations* and *oscillations*.

- *1.
  Banding:*
  - *Cause:* *Banding* (_dark horizontal lines_) is mainly due to inconsistencies in *paper movement* and the *charging process*.
- *Mechanism:*
  - *Speed Regulation:* The motor pulling the paper does not have a perfectly constant speed.
If the paper slows down or speeds up slightly while printing a line, this creates a variation in ink density (a darker or lighter band).
- *Vibrations:* Vibrations of rollers or other components, perpendicular to the printing direction, affect line quality over large areas, creating a *low-frequency* pattern.
- *2. Jitter:*
  - *Cause:* *Jitter* (_horizontal fluttering_) is directly linked to the *rotation* of two critical components: the *drum* and the *developer roller*.
- *Mechanism:*
  - These rollers are never perfectly cylindrical nor perfectly stable.
They exhibit slight *oscillations* or *eccentricities* during rotation.
- These micro-oscillations cause the toner application on the drum (and thus on the paper) to be *shifted horizontally* from one line to another.
This shift creates irregular edges and *high-frequency* artifacts (as they are linked to rapid rotation).
- *3. Skewed Jitter:*
  - *Cause:* Although similar to Jitter, *Skewed Jitter* manifests as *vertical* or oblique lines.
- *Mechanism:* It is often caused by a *misalignment* or a problem in the *laser beam* optics itself, rather than the rollers.
The laser line writing on the drum may not be perfectly perpendicular or follow a constant alignment across the width of the drum, resulting in periodic vertical distortion.
These three artifacts constitute a *physical signature* of the device, usable for attribution.

#pagebreak()

== Authentication of Printed Documents: Active Approach

=== Active Forensic Analysis on Printed Documents

The *active* approach consists of *intentionally inserting* information (_extrinsic signatures_) into the document or during the printing process, aiming to facilitate the *identification of its authenticity*.
- These extrinsic signatures can be detected: *visually*, using *software*, or via *physico-chemical procedures*.
- *Examples of Active Techniques:*
  - Printer Steganography.
  - 2D Barcodes.
- *Machine Identification Code:*
  - Xerox pioneered this mechanism as early as the mid-80s (method not public until 2004).
- It consists of a *matrix of tiny yellow dots* dispersed over the entire printing area.
- This code encodes the device's *serial number*, the *date*, and the *time* of printing, and is repeated multiple times.
- Scientists (notably at the University of Dresden) discovered at least four different encoding schemes after analysis.
==== Disadvantages of Machine Identification Codes

- They are mainly used in printers sold in the *United States* (FBI requirement).
- They can be *anonymized* or *removed* (for example, by adding other yellow dots to disrupt the code).


#pagebreak()

== Approaches for Printed Text Source Detection (Passive Attribution)

Passive attribution (_Passive Source Attribution_) aims to identify the source of a printed document by analyzing *intrinsic fingerprints* left by the printing device (generally laser or inkjet).
=== Printed Text Fingerprints

Physical imperfections of the laser printing process create *micro-patterns* that are unique to each machine.
- Areas of a document that can be used for attribution analysis are:
  - *Characters:* Analysis focuses on *irregularities* of contours and letter filling (_applied to text_).
- *Segmented Zones:* Frames or blocks of text/image are isolated to analyze local artifact patterns (like *Jitter* or *Banding*) (_applied to text and images_).
- *Entire Document:* A global analysis to extract the average noise pattern of the document (_applied to text and images_).
=== Advantages of the Passive Approach

The passive approach is preferred for its robustness and longevity compared to the active approach (which uses inserted identification codes).
- *Resistance to Modifications:* Modifying the document (for example, by inserting a fake printer ID code) does *not corrupt* the results of passive analysis, because it relies on *physical imperfections* and not encoded data.
- *Temporal Independence:* It works even if the document was printed a *long time ago* and active identification systems (_Machine Identification Codes_) have evolved or are no longer supported.
The device's *mechanical signatures* remain relevant.


#pagebreak()

== Laser Printer Attribution

Laser printer attribution is the search for the machine's signature in the printed document.
Depending on the nature of the analyzed document, it can be divided into three categories:

- *Text* (only).
- *Images / Color Documents*.
- *Text and Images / Color Documents* (combined).
=== Improving Precision via Imaging and Post-processing

To increase the *accuracy* of attribution methods, forensic experts often use *different types of scanners* and post-processing techniques.
- Using *different scanners* (or scanners with different settings) is crucial because the *sensor grid* of each scanner interacts differently with artifact patterns (Jitter, Banding).
- If the scanner grid is *aligned* with a printing artifact, it may *not reveal* it clearly.
By using a scanner whose grid is *misaligned*, fine and periodic printer patterns become more visible.
- Scanning is sometimes followed by *post-processing* (filtering, enhancement) to isolate and accentuate artifacts.
- It is by combining information revealed by these different scans that the complete *fingerprint* of the document can be calculated.
=== Laser Printer Attribution by Ali et al.

This method is an example of a passive approach for laser printer source detection:

- *Target:* It is applied specifically on text *characters* (the letter _I_ is often chosen for its structural *simplicity*).
- *Fingerprint:* *Projections* (pixel values) of the character are used as fingerprints.
- *Pre-processing:* Since extracted characters may have different sizes and fonts, and to avoid the *curse of dimensionality* problem in machine learning, images are pre-processed by *Principal Component Analysis* (PCA).
- *Classification:* A *machine learning* classifier (often a Gaussian Mixture Model - GMM) is trained to *recognize* these unique texture patterns for each printer.
- *Method Limitation:*
  - Precision is *low* when the tested printers come from the *same generation* (e.g., LJ1000 and LJ1200 models of the same brand).
- A *practical problem* is that the letter "I" does not appear frequently enough in all documents to ensure the extraction of a sufficient number of samples.


#pagebreak()

== Laser Printer Attribution: GLCM Approach (Mikkilineni et al.)

This method uses statistical texture analysis to characterize the footprint of a laser printer.
- *Target:* Text *characters* (often the letter "E") are analyzed.
- *Description:* Letters are described by the *statistics* of the *Gray-Level Co-occurrence Matrix* (GLCM), considering several neighborhood directions.
- *Classification:* Feature vectors extracted from the GLCM are then used as input to a multi-class *machine learning* classifier.
- *GLCM Matrix:* The co-occurrence matrix is a *2D histogram* that gives an overview of the *frequency* with which a pixel value appears next to another pixel value in a given direction and at a given distance.
- *Extracted Statistics (Normalized):*
  - *Contrast:* Measure of intensity difference between a pixel and its neighbors (rough vs. smooth texture).
- *Correlation:* Degree of linear relationship of a pixel with its neighbors (homogeneity).
- *Energy:* Measure of regularity or repetition of pixel pairs (uniform texture).
- *Homogeneity:* Measure of the closeness of the distribution of GLCM elements to its diagonal (homogeneous texture).
- *Warning:* *Changing toner* or other consumables can *erase* or *modify* certain local printing properties, disrupting the fingerprint.
===== Detail of the Gray-Level Co-occurrence Matrix (_GLCM_)

The *Gray-Level Co-occurrence Matrix* (GLCM) is a statistical tool widely used to *analyze image texture*.
It quantifies the frequency with which different pairs of pixel values (gray levels) occur at a specified *distance* and in a specified *direction*.
- *Basic Principle:* The GLCM is a *2D histogram* that captures *spatial relationships* between neighboring pixels.
- If the image has $N$ gray levels (e.g., 256), the GLCM is a matrix of size $N times N$.
- Each entry $(i, j)$ of the matrix stores the *number of times* a pixel with intensity value $i$ appears immediately adjacent (according to a given angle and distance) to a pixel with intensity value $j$.
- *Key Parameters:* The GLCM must be calculated based on two fundamental parameters:
  - *Distance ($delta$):* This is the spatial gap between the two analyzed pixels (usually $delta=1$ pixel for printer attribution).
- *Angle ($theta$):* This is the direction of the neighborhood (often 0°, 45°, 90°, 135°, etc.).
The *Multi-directional GLCM* uses several of these angles to obtain a complete characterization.
- *Application to Laser Printer:*
  - A printer's *signature* (its mechanical defects) manifests as *dot patterns* and *irregularities* that change how light and dark pixels neighbor each other.
- By calculating the GLCM, one captures the *micro-textural* aspect of these imperfections.
For example, a printer with a lot of *Jitter* will have a different GLCM than a printer with a pronounced *Banding* pattern.
- *Feature Extraction (Statistics):*
  - The matrix itself is too large to be used directly.
Therefore, *statistics* called *Haralick features* (like Contrast, Homogeneity, Correlation, Energy) are extracted from it; these are synthetic numbers describing the texture.
- *Example - Contrast:* Printers having very irregular character edges (a "rough" texture) will have high contrast values (intensity difference) between neighboring pixels.
- *Normalization:* These coefficients are *normalized* to ensure they are independent of the size of the analyzed block (letter or frame).
==== Laser Printer Attribution by Ferreira et al.

This approach is an *improvement* of the method by Mikkilineni et al.
- *Principles:* It proposes a *multi-scale and multi-directional texture analysis* in the printed material.
- The approach relies on the fact that there are *multi-scale* and *multi-directional* printing patterns (zones with a specific gradient) in the document.
- It can be applied to the *entire document*, *letters*, or *regions of interest* (_frames_).
- *Improvement:* It uses an *ad-hoc descriptor* as well as a *fusion of results* from the Mikkilineni method and this new descriptor.
- *PRNU Analogy:* Similar to *PRNU* extraction for cameras, *multiple samples* (several letters or regions) are taken to obtain an *average letter* or *average fingerprint* that is more stable for the printer.
- *Novelties of this method:*
  - *Multi-directional GLCM* approach.
  - *Multi-directional and multi-scale GLCM* approach.
- *Convolutional Gradient Texture Filter* (CGTF) approach.
- Study on document *chunks* (_frames_).
  - Use of *dimensionality reduction*.
=== Multi-directional GLCM Approach (GLCM-MD)

- *Principle:* The GLCM is used as a *2D histogram* to describe pixel neighborhood in a given direction and offset.
- *Feature Vector:* *Eight neighborhood directions* are used, generating eight matrices.
- For each neighborhood direction, *22 statistics* are calculated.
- This results in a feature vector of $22 times 8 = 176$ dimensions used to identify the printer texture.
- *Process:* Document -> Letter Extraction -> Different Scales -> GLCM Feature Vector Calculation -> Dimensionality Reduction -> Classification.
=== Multi-directional and Multi-scale GLCM Approach

- This approach adds *Gaussian Pyramidal Image Decomposition* to the previous one.
- *Scales:* *Four scales* are considered: the original, two size reductions (_downscales_), and one size increase (_up-scale_).
- *Feature Vector:* At each scale, *176 statistical features* are extracted, which considerably increases the number of descriptors.
=== Study on Document Blocks (_Frames_)

This analysis is performed on image *blocks* of the document, often used when the document is considered as a *complete image*, as opposed to single-letter analysis.
- *Objective:* Study laser printer signatures in *segmented zones* of the document.
- *Block Definition:* Blocks are *rectangular* areas of the image containing *enough printed material*.
- *Example:* The document is divided into a matrix of blocks (e.g., five columns by six rows).
- *Block Validation:* For a block to be considered *valid*, it must contain a *minimal acceptable ratio* between dark pixels (black/dark gray) and light pixels (white/light gray), for example a minimum ratio of 0.02.
- Analysis generally focuses on blocks of *medium intensity*.
- *Result:* Description and classification of fingerprints are performed on these zones.
=== Multi-directional GLCM vs Simple GLCM

The fundamental difference lies in the *granularity of spatial analysis*.
Where the simple approach tends to "smooth" information, the multi-directional approach (_GLCM-MD_) retains specificities of each angle to create a much richer signature.
=== Simple GLCM (Standard Approach)

- *Method:* It generally calculates the co-occurrence matrix on *a single direction* (often horizontal at $0^degree$) or performs the *average* of statistics obtained on four main directions ($0^degree, 45^degree, 90^degree, 135^degree$).
- *Limitation:* By looking at only one direction or averaging, this method *flattens* directional details.
It implicitly assumes texture is similar in all directions.
- *Risk:* It may miss specific artifacts that only appear at a precise angle (e.g., an oblique mechanical defect).
=== Multi-directional GLCM (_GLCM-MD_)

- *Method:* It performs *no averaging*.
It calculates matrices and statistics *separately* for an expanded set of directions (typically *eight distinct directions*).
- *Exploitation of Anisotropy:* It assumes that printer defects (Banding, Jitter) are *oriented*:
  - *Banding* creates strong horizontal patterns (detected by the $0^degree$ direction).
- *Jitter* or scratches create vertical or diagonal patterns (detected by $90^degree$ or oblique directions).
- *Enriched Signature:* Instead of obtaining a global contrast value for the image, one obtains a *contrast profile* according to orientation.
- The classifier can thus learn: "This printer has strong contrast at $90^degree$ but weak contrast at $0^degree$".
- *Feature Explosion:* This explains the size of the vector.
  - *Simple GLCM:* 22 statistics (averaged).
- *GLCM-MD:* 22 statistics $times$ 8 directions = *176 distinct features*.

#pagebreak()

== Convolutional Texture Gradient Filter (CTGF) Descriptor

This method calculates neighboring textures in specific gradient zones (intervals) to create a printer signature in the form of an histogram.
- It relies on the idea that *textures in almost flat zones* (low gradient) are generated *intentionally* by the printer *firmware* (_dithering_ or halftoning techniques) and contain a very discriminative signature.
=== Algorithm Steps

- *Step 1: Negative*
  - Pixels $s$ of the scanned image $S$ are inverted according to the formula $n = 255 - s$.
- Values close to 0 become white, and 255 become black.
This produces the negative image $N$, which simplifies subsequent calculations.
- *Step 2: Border Cropping*
  - *6% of pixels* are eliminated on each edge of the negative image $N$ (producing matrix $R$).
- *Goal:* Remove *scanning noise* often present at edges (external light, paper fold, scanner mechanical artifacts).
- *Step 3.1: Convolution (Sum)*
  - The *sum* of neighbors in an $n times n$ window is calculated for each pixel of $R$.
- This corresponds to a *convolution* of $R$ with an $n times n$ matrix filled with 1s. The result is the texture sum matrix $C$.
- *Step 3.2: Gradient Calculation (R)*
  - In parallel, the gradient (absolute maximum difference) between a central pixel and its neighbors ($n^2 - 1$) is calculated.
- The final gradient matrix $G$ is constructed as follows:
  $
    G(i, j) = cases(0 "if the pixel is at the edge", max_(i - 1 <= p <= i + 1 \ j - 1 <= q <= j + 1)(d_(R_(i, j), R_(p, q))) "otherwise")
  $
  where $d_(x, y) = |x - y|$.
- *Step 4: Gradient Filter*
  - Only texture values from matrix $C$ whose corresponding gradient in $G$ falls within an *optimal interval* $[g_("low"), g_("high")]$ (found experimentally) are kept.
- The final matrix $T$ is therefore $C$ purged of values outside the relevant gradient range.
- *Step 5: Histogram Construction*
  - An histogram of the distribution of values in $T$ is constructed.
- The scale of values ranges from 0 to $255 times n^2$. Vector $H$ thus has this dimension.
- *Step 6: Min-Max Normalization*
  - The final vector $V$ is normalized to bring its components into the interval $[0, 1]$.
=== Dimensionality Reduction

A $3 times 3$ CTGF filter generates a vector of 2295 dimensions, leading to the *curse of dimensionality* for classifiers.
- *Problem:* Some components do not vary enough to be useful for classification.
- *Solution:*
  - All features of the training set are stacked into a matrix $F$.
- The *range* of values for each component (Max - Min) is calculated.
- The *average* of all these ranges is calculated.
  - *KeepVector:* Components whose range is *lower than the average* are eliminated.
- *Note:* Extraction focuses on *edges* (or specific gradient zones) because that is where subtle variations reside that allow distinguishing printers, even those with very similar signatures.
=== In-depth Explanation of CTGF

The *CTGF* (_Convolutional Texture Gradient Filter_) is an advanced method for extracting a laser printer's *fingerprint* from a scanned document.
==== What is it for?

The goal is to capture the *printing micro-pattern* (how ink is deposited) without being disturbed by text content (letter shapes).
- Laser printers cannot print real "gray".
To simulate gray, they place black dots more or less spaced apart. This is *halftoning*.
- Each printer brand and model uses a different halftoning algorithm and mechanics.
- CTGF serves to *isolate* and *quantify* this specific halftoning pattern, which is invisible to the naked eye but unique to the printer.
==== Why these calculation steps?

Each step of the algorithm has a precise physical reason to "clean" the signal and keep only the printer's signature:

- *1.
  The Negative:*
  - This is a mathematical convenience. By inverting the image, ink (black) becomes high values (white) and paper (white) becomes 0. This makes sums and "ink quantity" calculations more intuitive.
- *2. Border Cropping:*
  - Scan edges are often "dirty" (shadows, light distortion, paper edges).
These artifacts come from the *scanner*, not the printer. They are removed so as not to skew the analysis.

- *3.
  Convolution (Sum on $n times n$ neighborhood):*
  - *The Goal:* Instead of looking at an isolated pixel (which is either black or white), one looks at *ink density* in a small area (the neighborhood).
- This transforms a binary dot grid into a local "texture" or gray level value.
This is what reveals the halftoning pattern.

- *4.
  Gradient and Filter (The Crucial Step):*
  - *Why?* We don't want to analyze the *entire* document.
- Totally white areas (empty paper) have no ink, so no signature.
- Sharp edges of letters (pure black text) have too strong a contrast that masks micro-details.
- *The Filter:* The gradient (intensity change) is calculated.
Only pixels with an *average* gradient (neither flat nor abrupt edge) are kept.
- It is in these smooth transition zones (blurred edges or grayish areas) that the printer's *firmware* leaves its most visible signature (the artificial dot pattern).
- *5. The Histogram:*
  - Once these "pure" texture values are isolated, the image (too heavy) is not kept.
We simply count *how many times* each texture type appears.
- This distribution (the histogram) becomes the unique signature: "This printer produces a lot of Type A textures and few Type B".
=== Importance of the Texture Histogram (CTGF)

Knowing that a printer produces *a lot* of Texture A and *little* of Texture B is the *key to device attribution*.
This distribution is the unique *statistical profile* replacing the image.
==== The Unique Signature of a Printer

- *Texture A and Texture B:* In the context of CTGF, *Texture A* could represent, for example, a neighborhood sum indicating a pattern of four tight dots.
*Texture B* could be a pattern of two loose dots.
- *Physical Reason:* The frequency (distribution) of these patterns is not random.
It is determined by:
- *The Firmware:* The halftoning algorithm integrated by the manufacturer into the printer software (*firmware*) will decide *exactly* how gray areas will be converted into dots.
This choice is unique to the brand/model.
- *Mechanics:* Micro-defects of the device (slight variations in laser speed, drum, or motor) will *distort* the ideal distribution.
A printer slightly defective on its horizontal axis might favor Texture A over Texture B.

==== Why the Histogram is the Signature

- *Quantification:* The histogram is the simplest and most *efficient* way to quantify this signature.
It contains only numbers (frequency counts) and not millions of pixels.
- *Characteristic Distribution:* Two printers of the same model, but used differently (wear, dust, environment), will have *distributions* (_histograms_) *very close* but *never identical*.
Printer \#1's histogram might show a peak at 500 (Texture A) and Printer \#2 a peak at 510. This *micro-variation* allows distinction.
- *Machine Learning Analysis:*
  - The Machine Learning classifier (the final step) doesn't need to know *what* Texture A and Texture B are.
  - It simply learns that the *frequency vector* (the histogram) $["Frequency_A", "Frequency_B", "Frequency_C", ...]$ corresponds to Printer X, while vector $["Frequency'_A", "Frequency'_B", "Frequency'_C", ...]$ corresponds to Printer Y.
  - The *difference in distribution* (the peak being at 500 instead of 510) becomes the *discriminating criterion* for attribution.
- *Conclusion:* The texture histogram is thus a *numerical representation* of the fingerprint left by the printer's *firmware* and *mechanics*.

#pagebreak()

== Deep Learning for Laser Printer Source Attribution

Using Deep Learning (DL) is a *passive* approach aimed at automating the extraction of fine signatures from a laser printer.
- *Method:* Characters (often letters "_A_" and "_E_" for their frequency) are extracted and then characterized by an *ensemble* of Convolutional Neural Networks (CNN).
- Characterizations (extracted features) are *fused*.
  - Final classification is obtained by a *majority vote* of individual SVM (_Support Vector Machine_) classifiers.
- *Ensemble Network:* Each member of the CNN ensemble works on *different inputs* of the character image:
  - The raw image.
- The *median residual*.
  - The *average residual*.
- *Role of CNN:* The networks act as *feature extractors*.
Their outputs from the penultimate layer are fused, and these *feature vectors* are then sent to SVM classifiers.
- *Architecture:* The proposed approach generally uses a *very shallow CNN* optimized for inputs of $28 times 28$ pixels.
=== Advantages and Challenges of Deep Learning (DL)

- *Advantages:* DL allows handling a *large number of classes* (e.g., 100 producers with 10 models = 1000 classes maximum).
It is *not limited by memory* or office hours (once trained).
- *Challenges:*
  - *Interpreting results* can be difficult.
  - *Data preparation* must be very rigorous.
- These networks require a *large amount of data* for training.
=== Residual Images (Noise Images)

- *Residuals:* Median and average *residual images* are used for analysis because they *isolate the printer's signature* (noise and defects).
- *Focus on Transition:* Analysis focuses solely on the *transition zone* (character contour) because histograms are then used, and these are *shape independent*.
What matters is the *texture pattern* in this zone, not the letter shape itself.
- *Optimal Solution:* The best forensic solution is often a *combination* of human interpretation capabilities and artificial intelligence performance for feature extraction.
=== Role of SVM and Combination with CNNs

The described approach uses Convolutional Neural Networks (_CNN_) for one task (extraction) and Support Vector Machines (_SVM_) for another (classification).
==== Why use SVM instead of CNN alone?
Using an SVM after feature extraction by CNN presents several strategic advantages, particularly in *forensic analysis* where datasets (printed documents for each printer) are often limited:

- *1.
  CNN as Feature Extractor:*
  - The CNN is *excellent* for automatically learning relevant *visual features* (texture patterns, noise) left by the printer (similar to GLCM, but much more sophisticated).
- After learning, the output of the CNN's penultimate layer (the *feature vector*) is used, which is a *dense representation* of the printer's signature.
- *2. Efficiency and Robustness of SVM:*
  - SVMs are particularly *effective* for classification when the *number of samples* per class is *low* (which is often the case for specific machine forensic attribution).
- An SVM is intrinsically designed to find the *best decision boundary* (the *hyperplane*) that maximizes the margin between classes.
It is very robust against the *high dimensionality* of feature vectors provided by the CNN.
- *Risk with end-to-end CNN:* Using CNN for extraction *and* classification might require much more training data to reach satisfactory generalization, and it would risk *overfitting* on small datasets.
- *3. Feature Fusion:*
  - In this approach, features coming from *multiple networks* (trained on raw image, median residuals, etc.) are *fused*.
An SVM is very suitable for classifying these *fused high-dimensional feature vectors*.
==== What is a Support Vector Machine (SVM)?
A *Support Vector Machine* (SVM) is a very popular and robust classification algorithm in *supervised learning*.
- *Principle:* The goal of SVM is to find a *hyperplane* in a multidimensional space that separates data classes as clearly as possible.
- *Hyperplane and Margin:*
  - The *hyperplane* is the decision boundary.
- The SVM chooses the hyperplane that has the *widest margin* (largest distance) between the boundary and the closest data points of each class.
- *Support Vectors:* The data points closest to the hyperplane are called *support vectors*.
These are the critical points that determine the position and orientation of the hyperplane.
- *Feature Space:* To separate classes non-linearly (when the boundary is not a simple straight line), the SVM uses *kernel functions* to project data into a *higher-dimensional space* where linear separation becomes possible.

#pagebreak()

== Printed Image Source Attribution: Approaches and Objectives

The *main objective* of source attribution for printed images is to *isolate and quantify* the *microscopic defects* introduced by the *mechanics* and *printing algorithms* (_firmware_) of a specific machine.
These defects, which are the printer's *fingerprint*, often manifest in printing *noise* and *texture*.
=== 1. Residual Noise Attribution (Lee and Choi - GLCM)

This approach seeks to reveal the printer's footprint by focusing on *ink deposition irregularities*.
- *Color Space:* Documents are converted to *CMY* (Cyan, Magenta, Yellow), or *CMYK* (with Black, used massively because *cheaper*), as this is the physical color space in which ink is deposited.
- *Residual Noise Isolation:*
  - Residual noise is isolated by subtracting the original image from its *filtered* version (usually by *Wiener filter*).
- *Objective:* The Wiener filter removes random noise while preserving main visual content (the signal).
What remains after subtraction is the *printing signature* (micro-halftoning patterns and artifacts).
- *Feature Extraction (GLCM):* *Texture statistics* (_GLCM_) are calculated from this residual noise.
- *Homogeneity:* Measures texture regularity. A high value indicates very uniform ink deposition.
- *Contrast:* Measures ink density deviation (between light and dark micro-dots). Reveals deposition "roughness".
- *Energy:* Measures regularity and pattern repetition.
- *Correlation and Covariance:* Quantify linear dependence between neighboring pixels. Reveal spatial organization of defects.
- *Classification:* These statistical descriptors are transmitted to a machine learning classifier for identification.
=== 2. Wavelet Transform Attribution (Lee and Choi - DWT)

This method uses frequency analysis, which is more sensitive to *periodic structures* like *Banding* or *Jitter*.
- *Method:* Based on *Discrete Wavelet Transform* (DWT).
- *DWT Advantage:* DWT uses *directional* filters to decompose the image.
This makes it more *precise* than GLCM for capturing oriented artifacts (horizontal, vertical, diagonal) left by printer mechanics.
- *HH Sub-band:* DWT divides the image into four sub-bands (LL, LH, HL, *HH*).
- The *HH* sub-band (_High High_) represents *high-frequency information* (fine details and textures) in both directions (horizontal and vertical, thus diagonal).
Printer *artifacts* are highly concentrated in this sub-band.
- *Extraction:* *39 statistical features* are extracted from the HH sub-band.
- *Standard Deviation (SDV):* Measures value dispersion, indicating the *amount* of noise/texture.
- *Skewness and Kurtosis:* Describe the *shape* of the noise distribution.
Are very discriminative for non-Gaussian noise patterns.
- *Correlation and Covariance:* Measure spatial relationship of high-frequency noise.
- *Problem:* Attribution is a *closed-set problem*.
The classifier can only identify the printer if it was included in the training dataset.
=== 3. DWT Attribution (Tsai)

Tsai's approach is a DWT analysis variant exploring a wider feature space.
- *Extraction:* It also uses DWT but extracts *45 features* from *three* sub-bands (HH, HL, LH).
- *Trade-off:* By using three sub-bands, it captures more directional information, but the author chooses to neglect the *CMYK* color space, preferring to work with less transformed raw data (RGB).
- *Optimization:* To counter the large amount of DWT data, it relies on *feature selection algorithms* to retain only the most relevant descriptors and optimize performance.
=== General Remarks and Conclusion

- *Scan Resolution:* To avoid missing sub-pixel artifacts, it is often necessary to scan at a *higher resolution* (e.g., 1200 DPI) than the printing one (e.g., 600 DPI).
- *Improving Precision:* If precision is insufficient (e.g., 88%), one must *combine* methods, *enrich* features, or *refine* classifiers.
- *Future Challenges:*
  - Forensics must adapt to *new technologies* (3D printing, new inks).
- Algorithm *flexibility* is essential to handle *open-set scenarios* (new unknown printers).
- The growing threat of *adversarial attacks* (where a counterfeiter attempts to intentionally reproduce or erase a printer's footprint) requires developing *robust* methods.

#pagebreak()

= Deep learning methods in digital forensics

== Deep Neural Network Watermarking (DNN Watermarking)

DNN watermarking is a recent approach proposed to *protect Intellectual Property Rights* (IPR) of deep learning models and, above all, to *authenticate* and *trace* media content generated by AI (_synthetic content_).
=== Shift of Paradigm

Historically, the problem of image authenticity arose in the late 90s, with the spread of easy-to-use editing tools.
The first solutions (_Multi-Media Forensics_ - MMF) emerged in the early 2000s. The advent of generative AI necessitated a change in approach:

- *Old Idea (Unfeasible):* Embed an invisible watermark in *all* images generated or edited by AI to verify origin, trace history, and detect abuse.
- *Problem:* Impossible to *enforce* this marking on *all* software and *all* images generated worldwide.
- *New Idea (More Feasible):* Work *with* generative AI companies to *watermark the models* themselves.
- *Principle:* Watermark the DNN model so that *all* images it produces contain the embedded signature.
- *Justification:* Only a *handful* of companies are capable of training these generative models from scratch, making application more manageable.
=== DNN Watermarking in Brief

*DNN watermarking* is a form of *function watermarking* that *inseparably* embeds information into the DNN model.
- *Objective:* Allow *detecting* and *tracing* synthetic content back to the model that generated it.
It's the "Kill two birds with one bullet" approach.
- *Robustness:* The watermark must withstand common model modifications, including:
  - *Pruning*.
- *Compression*.
  - *Fine-tuning*.
  - *Transfer learning*.
- *Types of Watermarking:*
  - *White-box:* The attacker/verifier has access to model weights and architecture.
- *Black-box:* The attacker/verifier only has access to model inputs and outputs (the model is a black box).
- *Box-free:* *Joint watermarking* of DNN and media.
This is the preferred type for traceability of generated images.
- *Nature of the Problem:* It is considered a *digital communication problem* (multi-bit watermarking).
=== Detail: Box-free Watermarking

Box-free watermarking is the most promising method for forensics of AI-generated content, as it solves the problem of *dissociation* between the model (the fingerprint source) and final content (the image).
- *Fundamental Principle:* It is a *Joint DNN and Media Watermarking*.
The watermark is designed to be both *embedded* in the *DNN Model* weights and *injected* into the *Output Media* (the generated image) by the generation process itself.
=== Why "Box-free"?

Unlike *White-box* methods (requiring access to internal model weights) and *Black-box* methods (looking only at model behavior), box-free watermarking focuses on *proof of origin* contained in the output file, even if strongly altered:

- *Traceability:* When a user receives the generated image, watermark information is *directly readable* in the image (the media), without needing to query the DNN model online.
- *Robustness:* The watermark is encoded to be *statistically* or *visually* present in the image, linking it to the creator model.
It is designed to withstand common alterations (JPEG compression, resizing, cropping, noise).
- *Ideal Solution for Generation:* In the case of generative AI (like DALL-E or Midjourney), this method allows to:
  1. *Sign the model* during its training.
2. Ensure *signature is transferred* into every produced image.
3. Verify the *image signature* to confirm which specific model generated it.

=== How is it done?
Although exact theory is under development, implementation often relies on:

1. *Loss Function Modification:* During DNN model training, the *loss function* is modified to not only optimize generated image quality but also ensure the produced image carries a specific *invisible pattern or statistic* (the watermark).
2. *Subtle Injection:* The watermark is generally injected into *high-frequency textures* of the image (noise), making it almost undetectable to the human eye, but easy to read by forensic verification algorithms.
Box-free watermarking is thus key to *identifying abuse* and ensuring *ethical use* of AI-generated media.
=== The Context: The AI Media Revolution

The ubiquity of AI makes conventional Multimedia Forensics (_MMF_) increasingly difficult:

- Mobile phone images are already *modified* at source (by *firmware*).
- AI editing tools are *easily accessible* and produce *credible* modifications.
- The volume of modifications and AI progress *exceed* traditional MMF capabilities.
- In the future, even the fact that an image was "manipulated" by an AI tool might *no longer* be significant information, hence the need to know the exact *source*.
=== Challenges of DNN Watermarking

Several major challenges must be met for DNN watermarking to be effective:

- *Theory:* Development of a *whole new theory* of function watermarking.
- *Model-level Robustness:* Ensure watermark withstands structural modifications (pruning, compression).
- *Image-level Robustness:* Ensure watermark on generated images withstands image alterations (JPEG compression, noise, cropping).
- *Security Model:* Precisely define:
  - Embedded information.
- Role of each actor (_Who does what_).
  - *Key management*.
- *Security against Intentional Attacks:* Protect watermark against active attempts at removal or falsification.

#pagebreak()

== GAN Watermarking: Early and New Solutions

GAN Watermarking (_Generative Adversarial Networks_) is a specific case of DNN watermarking.
It aims to insert a signature into the generator model, making every image it produces traceable.
The major difficulty is watermark *robustness* against common attacks aimed at removing it.
=== Robustness against Post-processing and Model Attacks

#tablem[
  | Attack | Description and Objective |
  Watermark Robustness |
  | :--- | :--- | :--- |
  | *Image Processing* |
  Application of common operations on generated image: JPEG compression, noise addition, filtering, cropping. |
  The watermark is generally *quite resistant* to these operations, as it is often encoded in frequencies where compression is least aggressive (mid-frequencies).
  |
  | *Model Pruning* | Intentional removal of a fraction of model weights (neurons and connections) (to reduce size or attempt signature removal).
  | The watermark is very *well preserved*. It is possible to *cut up to $1/4$* (25%) of the network without destroying the watermark.
  This suggests information is *distributed* redundantly across the network. |
  |
  *Model Quantization* | Reduction of model coefficient (weight) precision (e.g., going from 32-bit float to 16-bit) to accelerate inference.
  | The watermark is *preserved* even with aggressive quantization (e.g., down to a precision of *3 decimal places*).
  If precision is reduced beyond this threshold, model performance itself degrades heavily, making the attack non-viable.
  |
  | *Fine Tuning* | Retraining the model on a new dataset.
  This is one of the most powerful attacks. | The goal is to ensure that watermark embedding (via a custom loss function) *weighs* enough in training so that moderate fine-tuning cannot "crush" it.
  The watermark is designed to be an *intrinsic* feature of the model, difficult to relearn without degrading generator quality.
  |
  | *Super Resolution* | Application of another AI model to improve image resolution. |
  The watermark must be designed to *withstand upscaling* or to be *reproduced* by the super-resolution process.
  Ideally, the signature (noise pattern) is so well encoded that it is *amplified* (or at least preserved) when image resolution is increased.
  |
]

=== Supervised Watermarking

Supervised watermarking is a deep learning approach to make the watermark inseparable from generated content.
- *Principle:* It involves training the DNN model to fulfill *two objectives simultaneously*:
  1. Generate a *high-quality* image (primary objective).
2. *Embed the watermark* (secondary objective, controlled by a specific loss function).
- *Operation:* The process is often visualized as follows:
  - An *Encoder* takes image content and desired watermark.
- The *Generator network* learns to create the image with embedded watermark.
- A *Discriminator network* attempts to distinguish watermarked image from normal image, forcing the generator to make the watermark *invisible*.
- A *Verifier network* is trained to *extract* the watermark from the image, ensuring it is *readable* at the end of the chain.

#pagebreak()

== Retraining-free Fingerprinting

Deep Neural Network (DNN) watermarking is often resource-expensive, as embedding a new watermark generally requires a complete and heavy *retraining* of the model.
For some applications (e.g., identifying specific version of an AI model distributed to different users), it is necessary to embed *different watermarks* for different versions.
=== The Solution: ParamGen Network

To bypass retraining costs, the proposed solution consists of making watermark embedding *parameterizable*:

- *Personalized Layer:* A *custom normalization layer* is introduced into the generator network (the GAN).
Parameters of this layer are solely responsible for watermark embedding.
- *ParamGen Network:* Parameters of this custom layer are not learned by retraining the generator, but are *generated* (_feedforward_) by a distinct network called *ParamGen Network*.
- *Operation:* To obtain a model with a given watermark, one simply runs the *ParamGen* network which, based on the desired watermark (bits to encode), generates *specific weights* for the custom normalization layer.
- *User Modification:* Small modifications are made to the base watermark to create a *unique watermark for each user* (or each version).
- *Normalization Step:* The custom layer is often a Normalization Layer aiming to standardize activations (e.g., *mean = 0* and *standard deviation = 1*), which is an ideal injection point for a subtle watermark.
- *Advantage:* The model is watermarked with a new watermark *without requiring retraining* of the main generator.
=== Result Validation

This approach has been successfully tested on various state-of-the-art GAN models, demonstrating its versatility:

- *Tested Models:* Boundary Equilibrium GAN (_BEGAN_), Spectral Normalization GAN (_SNGAN_), and Progressive Growing GAN (_PGGAN_).
- *Application:* Face generation (trained on _CelebA_ dataset).
- *Implementation:* The *ParamGen* network is typically a fully connected network with ReLU layers, trained to generate parameters from a *128-bit* watermark.
- *Importance of $L_("const")$:* A *constancy* loss function ($L_("const")$) is crucial to ensure watermarked models with different watermark bits maintain *uniform behavior* (i.e., generated image quality does not change based on watermark).
=== Conclusion on Forensics in the AI Era

- *Limits of Classic MMF:* Traditional Multimedia Forensics (_MMF_) remains *valid in specific and narrow scenarios*.
However, it is *difficult (if not impossible)* to apply at large scale against *disinformation campaigns* and massive amounts of synthetic content.
- *DNN-based Active Solution:* DNN-based active fingerprinting offers an indispensable complementary solution.
- *Challenges:* Major challenges (robustness to attacks, security) still need to be solved.
- *Complementarity:* DNN watermarking is not a universal solution, but a *valid and necessary complement* to traditional passive MMF methods.
- *Need for Flexibility:* The ability to generate different watermarks without retraining is essential to provide the *flexibility* and *traceability* required by future security and authentication applications.

#pagebreak()

= Modern Steganography

== Information Hiding Methods

The principle of *information hiding* is a fundamental concept in computing and digital security.
It consists of *masking* the presence of a message or data in a medium not intended to contain them.
- *General Definition (Computing):* In software engineering, the idea is to separate design decisions of a program likely to change.
This protects other parts of the program against extensive modifications if the initial decision is altered.
- *Definition (Security and Multimedia):* In the context of forensics and security, information hiding groups techniques aiming to insert a secret message (_payload_) into a _cover media_ in a *stealthy* or *invisible* manner.
=== Hiding Techniques

There are two main hiding techniques, whose objectives and robustness properties are different:

- *1.
  Steganography:*
  - *Objective:* Hide the very *existence* of the secret message.
The modified media (_stego-media_) must be visually and statistically *indistinguishable* from original media.
- *Stakes:* The attacker (steganalyst) attempts to prove a message exists. Steganography is a *war of detection*.
- *Categories:*
  - *Linguistic:* Hiding in text (e.g., acrostics, specific word choices).
- *Technical/Digital:* Hiding in digital data (images, audio, video).
The most common method is alteration of the *Least Significant Bit* (LSB) of image pixels.
- *Robustness:* The message is often *fragile* and easily destroyed by standard compression or filtering.

- *2.
  Watermarking:*
  - *Objective:* Embed a message (the watermark) in the media in a *robust* (difficult to remove) but *invisible* (non-intrusive) way.
The watermark often serves to prove *ownership*, *authenticity*, or *traceability*.
- *Stakes:* The attacker attempts to *remove* the watermark. Watermarking is a *war of removal*.
- *Types of watermarks:*
  - *Fragile:* The watermark is altered by the slightest modification (used to prove *authenticity*).
- *Robust:* The watermark withstands common alterations (compression, noise, editing) (used to prove *ownership*).
- *Applications:* *DNN Watermarking* methods we studied are an advanced application of this technique for AI model traceability.
=== Application Domain

These techniques are essential for *multimedia forensics*, as they fuel defense and attack mechanisms:

- *Source Attribution (Forensics):* Forensic analysis seeks to *detect* steganography (_steganalysis_) or to *verify* absence/presence of a watermark (_watermark detection_).
- *Defense against Counterfeiting:* Robust watermarks are used to mark valuable documents or copyrighted images.

#pagebreak()

== Basics of Cryptography

Cryptography is the *science of secure communication*.
Its main objective is to guarantee that only the sender and intended recipient of a message can *view* and *understand* its content.
- *Etymology:* The term is derived from Greek word *kryptos* ($kappa rho upsilon pi tau o sigma.alt$), meaning *hidden* or *secret*.
=== Cryptography and Encryption

Cryptography is closely associated with the concept of *encryption*, but these terms are not strictly synonymous:

- *Encryption:* It is the *act* of transforming ordinary readable text (called *plaintext*) into a scrambled and incomprehensible message (called *ciphertext* or *cryptogram*).
- *Decryption:* It is the reverse operation, allowing reconversion of *ciphertext* into *plaintext* upon arrival.
=== Fundamental Objectives of Cryptography

Modern cryptography goes well beyond simple information hiding (confidentiality).
It rests on four essential pillars to guarantee communication security:

- *1.
  Confidentiality:*
  - *Definition:* Ensure message content can only be read by authorized parties.
- *Mechanism:* *Encryption* is the main technique to achieve this objective.

- *2.
  Integrity:*
  - *Definition:* Guarantee message has not been *modified* or *altered* during transmission, whether intentionally or accidentally.
- *Mechanism:* Use of *Hashing Functions* and *Message Authentication Codes* (MAC).
- *3. Authenticity / Authentication:*
  - *Definition:* Verify *identity* of message sender and/or source validity.
- *Mechanism:* Use of *Digital Signatures* and *certificates*.

- *4.
  Non-Repudiation:*
  - *Definition:* Prevent message sender (or recipient) from *denying* later having sent (or received) this message.
- *Mechanism:* Also relies on *digital signature*, creating irrefutable proof.
=== Relation with other Domains

Cryptography is a vast domain overlapping several disciplines:

- *Cryptology:* Generic term encompassing cryptography (algorithm design) and *cryptanalysis* (study of methods to break or attack these algorithms).
- *Steganography:* Although steganography hides the *existence* of the message, while cryptography hides the *content*, both are often used together (encrypting a message before hiding it steganographically).
== Basics of Steganography

*Steganography* is the *art* and *science* of *hiding the very existence* of a communication or message.
- *Etymology:* The term is derived from Greek words:
  - *STEGANOS* ($sigma tau epsilon gamma alpha nu o sigma.alt$): Means "_Covered_" or "_Hidden_".
- *GRAPHY* ($gamma rho alpha phi iota alpha$): Means "_Writing_".
=== Main Objective

- *Contrast with Cryptography:* In cryptography, the enemy is allowed to intercept and modify messages, but cannot violate security (*content is hidden*).
In steganography, the objective is to *hide the message in other harmless messages* so the enemy *cannot even detect its presence*.
- *Goal:* Hide the message so transmission arouses *no suspicion*.
If the secret message's presence is detected, steganography's goal has failed.
- *Mechanism:* This is achieved by concealing secret information (_secret message_) in a medium appearing mundane and harmless (*harmless carrier / cover*).
- *Carrier Medium:* The medium can be *text*, *image*, *video*, *audio*, etc.

=== Historical Notes

Steganography is a practice as old as humanity, used for secret communication throughout ages:

- *Herodotus (Ancient Greece):*
  - *Shaved Slaves:* Messages were tattooed on a slave's shaved head.
Once hair grew back, the message was hidden until the slave was shaved again.
- *Wax Tablets:* A message was carved on a wooden tablet, then covered with wax.
The tablet looked like a blank wax tablet. Wax had to be melted to retrieve the message.
- *Ancient Chinese:*
  - *Wax Balls:* Messages written on silk were enclosed in wax balls, which could be easily hidden on the messenger.
- *Paper Masks:* Sender and receiver shared masks with randomly cut holes.
The message was readable only through mask holes placed over text.
- *Medieval and Modern Techniques:*
  - *Acrostics:* Secret messages formed by *initials* of words, lines, or stanzas (e.g., *L'Amorosa Visione* by Boccaccio).
*Example:* Cryptographic analysis can reveal a message from a series of filtered letters.
- *Invisible Inks:* Natural substances (lemon juice, urine) turning black after heating, revealing message.
Chemical (ammonia salts) or biological techniques were also used.
- *Modern Publishing:* Use of imperceptible *micro-dots*, intentional *line spacing*, or intentional *gaps* and errors to encode information.
=== Steganography in the Digital Era

The field saw renewed interest starting in the 1990s:

- *Key Technologies:*
  - *Broadband Communication Channels:* Allow masking *large amounts* of data (payload) in large files (images, videos).
- *Multimedia Content Distribution:* Images and videos are so common that sending a steganographed file is not suspicious.
- *Automated Techniques:* Allow achieving *high payloads* without degrading medium quality.
- *Motivations:*
  - *Espionage and Terrorism:* Exchanging secret information without being detected.
- *Dissidents:* Bypassing *censorship* and protecting *freedom of speech* in restrictive regimes.
- *Privacy Protection:* Avoiding mass surveillance (_big-brother scenarios_).
=== Steganalysis

*Steganalysis* is the complementary field of study to steganography.
It is the art and science of *detecting* presence of secret messages hidden in a carrier medium, even if these messages cannot be decrypted or read.
- *Objective:* Reveal presence of hidden messages (potentially without decrypting them).
- *Motivation:*
  - *Intelligence and Police:* Used by intelligence agencies and law enforcement to detect illicit or terrorist communications.
- *Public Opinion Control:* Can be employed to monitor unauthorized message distribution (in censorship contexts, for example).
- *Fundamental Interest:* Regardless of motivations (security or ethical), studying steganalysis is *necessary* to *determine security* of steganographic techniques.
- *Principle:* If a steganography technique withstands best steganalysis tools, then it is considered *secure* and *undetectable*.
Steganalysis thus fuels design of more robust steganographic methods.

#pagebreak()

== Requirements of Modern Steganography

Designing an effective steganographic method is a balancing act between two *opposing* requirements: concealment (invisibility) and amount of hidden data (capacity).
- *1. Invisibility (Statistical)*
- *2. Capacity (Payload)*

=== 1. The Invisibility Criterion

Invisibility is the strictest requirement.
It must be considered from two angles:

- *Perceptual Invisibility:*
  - Hidden message must be *indistinguishable* by human eye.
Original image (_cover image_) and modified image (_stego-image_) must look identical.
- This requirement must be maintained *even after* applying common *signal processing* techniques (slight compression, cropping, etc.).
- *Statistical Invisibility:*
  - The most difficult criterion to satisfy.
*Statistics* of modified image must not differ significantly from those of original image.
- *Consequence:* The steganalyst (the "warden") must not be able to detect message presence via statistical analysis (histograms, moments, etc.) or machine learning.
- *Practical Example:* Simple JPEG compression of 2-3% can destroy or reveal certain steganographic messages if not designed to withstand this statistical alteration.
- *Kerckhoff's Assumptions:* Designing a good steganographic algorithm (just like in cryptography) must respect *Kerckhoff's Principle*: the system must remain secure *even if the enemy knows the algorithm* used and *knows statistics of Alice's source image*.
- *Limitation:* Invisibility alone is not enough, as reality and steganalyst attack models are often more complex than initial mathematical models.
=== 2. The Capacity Criterion (Payload)

- *Definition:* This is the *amount of data* (_payload_) one wishes to communicate secretly.
- *Trade-off:* Higher capacity requires more modification of carrier medium.
More modification leads to greater statistical alterations, compromising invisibility.
=== Choice of Hiding Domain

Choice of domain where message is hidden has major impact on capacity and security:

- *Spatial/Pixel Domain:*
  - *Method:* Message is hidden by directly modifying pixel values (e.g., modifying Least Significant Bit - LSB).
- *Advantages:* *Easy to use*, *high capacity* (receiver can guarantee perfect message extraction).
Simple to evaluate for perceptual invisibility.
- *Disadvantages:* *Low robustness* to compression or noise.
Statistical detection relatively easy.

- *Transform/Compressed Domain:*
  - *Method:* Message is encoded by modifying *DCT coefficients* (_Discrete Cosine Transform_) (used in JPEG compression).
- *Advantages:* *Better resistance* to compression (since modifications are done directly in compressed format).
Benefits from *wide distribution* of JPEG images.
- *Disadvantages:* *Lower capacity* and *inferior security* (due to existence of good statistical models describing DCT coefficients).
- *Algorithm Examples:* *F5*, *OutGuess*, *Jsteg*.

#pagebreak()

== Steganography in Spatial Domain

Steganography in the spatial domain is the most direct and intuitive hiding method.
It consists of *directly modifying pixel values* of the carrier image (_cover image_) to encode secret message.
- *Principle:* Secret information is inserted into *Least Significant Bits* (LSB) of pixels.
These bits contribute least to visual perception of pixel, ensuring perceptual invisibility.
=== The Least Significant Bit (LSB) Method

LSB technique is most common in spatial domain:

- *Operation:*
  - A pixel is generally represented by 8 bits (value 0 to 255).
LSB is the bit having least influence on final pixel value.
- The algorithm *replaces* one or more LSBs of carrier pixel with one or more bits of secret message.
- *Example (on 1 LSB):*
  - Original pixel value: $1011010cal(1)$ (181 in decimal).
- If secret bit to hide is $cal(0)$, new pixel becomes: $1011010cal(0)$ (180 in decimal).
- Value difference is only 1 (or $-1$ if going from $cal(0)$ to $cal(1)$).
This variation is *undetectable* by human eye.
- *Consequence:* To hide a secret bit, algorithm modifies pixel value by at most $plus.minus 1$.
- *Capacity:* Capacity is very high, as up to 3 LSBs per color channel (Red, Green, Blue) in a pixel can be used, allowing hiding large amount of data.
=== Advantages

1. *Ease of Use:* Implementation is simple and fast.
2. *High Capacity:* Allows hiding largest possible *payload*, as insertion is done on almost all pixels.
Receiver is thus assured of *perfect extraction* of message.
3. *Perceptual Invisibility:* LSB modification is generally sufficient to ensure modified image (_stego-image_) is visually identical to original image.
=== Disadvantages and Vulnerability

1. *Low Robustness:* LSB watermark is *very fragile* and easily destroyed.
Slightest image manipulation (JPEG compression, noise addition, resizing) will affect LSBs randomly, making message unrecoverable.
2. *Easy Statistical Detection:* Steganalysis is relatively simple in this domain.
Modifying many LSBs *alters statistical distribution* of colors in image.
- *Example:* LSB insertion tends to make LSBs more random.
*Histograms* of modified image often show anomalies or unnatural statistical patterns that steganalysis algorithms can easily detect.
In conclusion, spatial domain steganography is ideal for *high capacity* and *simplicity*, but its *low security* limits it to contexts where image undergoes *no alteration* or compression after insertion.

#pagebreak()

== Transform Domain Steganography

Transform domain steganography is a more sophisticated approach than spatial domain, preferred for its *better robustness* against common image operations, particularly JPEG compression.
- *Principle:* Secret message is hidden not in direct pixel values, but in *coefficients* obtained after mathematical transformation applied to image (like DCT or DWT).
=== The Case of JPEG Compression and DCT

In JPEG images, information hiding is done at level of *Discrete Cosine Transform* (DCT) coefficients.
- *JPEG Process:* JPEG compression starts by dividing image into $8 times 8$ pixel blocks, then applies DCT to each block.
DCT converts spatial information into frequency information (coefficients).
- *DCT Coefficients:*
  - Coefficient $(0, 0)$ is *low frequency* coefficient (DC component) representing average block color.
- Other coefficients represent *high frequencies* (details and rapid color changes).
- *Hiding Method:*
  - Message is encoded by subtly modifying *mid-frequency* and *high-frequency AC coefficients*.
- *DC* coefficients (very sensitive) and very *high frequency* coefficients (often zeroed during quantization and compression) are generally avoided.
=== Advantages

1. *Better Robustness:* Since modifications are done directly in frequency domain and encoded in coefficients *least affected* by quantization (information loss step of JPEG compression), message withstands recompression or slight alteration better.
2. *Wide Distribution:* JPEG images are most widespread image format, offering very common and unsuspicious *carrier medium*.
=== Disadvantages and Challenges

1. *Lower Capacity:* To ensure invisibility, only certain coefficients can be modified, reducing amount of data (_payload_) hideable compared to spatial domain.
2. *Inferior Security (Steganalysis):* Statistical detection can paradoxically be *easier*.
- Statistical models describing DCT coefficient distribution are well known (e.g., Laplace distribution).
- Steganography algorithms (even sophisticated ones like *F5* or *OutGuess*) struggle to preserve *perfectly* natural statistical distribution of coefficients, making anomalies detectable.
=== Notable Algorithms

Many famous algorithms work in this domain:

- *Jsteg:* One of first DCT-based algorithms.
- *OutGuess:* A method attempting to *correct* statistical distribution after message insertion to counter steganalysis.
- *F5:* Advanced algorithm using *matrix encoding technique* to minimize number of DCT coefficient modifications, thus increasing security.

#pagebreak()

== Steganography by Cover Selection

Steganography by Cover Selection reverses traditional hiding process.
Instead of modifying existing medium to hide message, Alice *chooses* an already existing medium in a database corresponding to message she wants to send.
- *Principle:* Alice and Bob share very large *database* of images (or any other media).
Alice sends *no* modified data; she sends only *index* or *image itself* (unmodified) associated with secret message.
=== How is message encoded?

Secret message can be linked to specific image in database according to various predefined criteria:

1. *Semantic Content of Image:* Message can be linked to subject or theme of image.
(Example: sending cat image to mean "OK", and dog image to mean "Cancel").
2. *Value of LSB Subset:* Image is chosen because a *subset* of its least significant bits (LSB) corresponds *already* to message bits.
3. *Image Hash (or sub-image):* Secret message can be result of image (or part of it) hashing.
Alice looks for image whose hash corresponds to message.

=== Advantages

- *Almost Perfect Security (Invisibility):*
  - This is main advantage.
Transmitted image *is not modified*. It is perfectly *authentic* and *statistically pure*.
- *Steganalysis* algorithms are totally *ineffective*, as they cannot detect alteration.
Steganalysis can only hope to detect image was "chosen", which is extremely difficult without shared database.
=== Disadvantages

- *Extremely Low Capacity (Payload):* This is major limitation of this method.
- Message length is directly limited by *database size* ($cal(D)$).
- If secret message has 8 characters (64 bits), this means there must be at least $2^64$ different images in database ($approx 10^19$ images) to guarantee image exists for every possible message.
- *Gigantic Database:* Having such a vast database is impractical for common use, even with current storage resources.
=== Conclusion

This method is a theoretical demonstration of inverse relationship between capacity and security: by obtaining almost perfect security, one sacrifices almost all useful capacity.
It is mainly used in scenarios where payload is very limited (a few bits) or in lab experiments.
== Steganography by Cover Synthesis

Steganography by cover synthesis is an *active* technique where sender (Alice) *generates from scratch* (_on-the-fly_) the carrier medium (_cover image_) specifically to encode secret message.
Goal is to ensure image carries message *from its creation*, thus guaranteeing maximal statistical security.
=== Principle 1: Synthesis by Block Assembly (Traditional Method)

This method is historically used to bypass difficulty of creating realistic images artificially:

- *Source Materials:* Alice must possess set of *several shots* of *same scene* (or very similar scenes) so pieces fit together.
- *Encoding Process:*
  - Image is divided into small *blocks* or tiles.
- Secret message is encoded by block *selection*: Alice chooses, for each position in final image, block from source images whose *local properties* (e.g., LSB subset) correspond to message bits at that point.
- Final image is constructed by *assembling* chosen blocks.

- *Key Advantage:* *Good statistical security*.
Since each block is piece of *real image*, local statistics are less likely to be detected by steganalyst than in artificial LSB modification case.
- *Limits:*
  - *Low Payload:* Requires huge amount of source blocks to encode average size message, making approach impractical.
- *Border Defects:* Main weak point lies in *junctions* between blocks.
Even if scene is same, lighting or noise differences can create visible lines (_block borders_) steganalyst can exploit.
=== Principle 2: AI Cover Synthesis

Use of Generative Artificial Intelligence has transformed this approach, solving realism and edge problems.
- *Generative Models:* *GANs* (_Generative Adversarial Networks_) and diffusion models generate visually indistinguishable fakes from real (_visually plausible fakes_).
- *Game Theory Formulation:* This method relies on *adversarial formulation* inspired by *Game Theory*:
  - *Generator (Alice):* This is a CNN trained not only to create high quality image (realistic), but also to *inject secret message* in most undetectable way possible.
- *Steganalyst (The Warden):* This is another CNN trained to *detect* if message is present or not in image.
- *Struggle:* Both networks train simultaneously, Steganalyst success forcing Generator to hide message more subtly, and vice-versa.
- *Result:* Generator learns to hide information in *textures* or *noise frequencies* of output image, where human eye and even traditional analysis tools struggle to find it.
Message is embedded in image *from first generation pass*.
This approach is most promising for modern steganography, allowing *high security* by guaranteeing statistical properties of synthesized carrier are almost ideal.

#pagebreak()

== Steganography by Cover Modification

Steganography by cover modification is, *by far, the most common approach* and traditional way to hide information.
It consists of inserting secret message by *slightly altering* existing media (text, image, audio, video).
=== General Principle

- *Mechanism:* Sender (Alice) takes existing media (carrier) and modifies it in *subtle* or *statistically insignificant* way to insert secret message (_payload_).
- *Perceptual Invisibility:* Modification is designed to be undetectable by human eye or ear.
- *Application Domains:* This method is employed in all domains we previously studied:
  - *Spatial domain:* Direct modification of Least Significant Bits (LSB) of pixels.
- *Transform domain:* Modification of DCT or DWT coefficients.
=== Main Advantages

- *Large Payloads:* This is main advantage.
Since one can generally modify many elements of carrier (e.g., each pixel of image), it is possible to encode *large amount* of secret data.
Capacity is directly linked to carrier size.
- *Simplicity:* In domains like LSB, implementation is extremely simple.
=== The Challenge of Statistical Security

Although this method allows high payloads, *security must be studied carefully*.
This is heart of *steganalysis*:

- *Statistical Alteration:* Inserting message, even by modifying only LSB, introduces *irregularity* in natural statistical distribution of carrier.
- *Vulnerability to Steganalysis:* Steganalysts use sophisticated models (based on machine learning or higher-order statistics) to detect these statistical alterations.
- *Trade-off:* To increase security (reduce detectability), modern methods (like *WOW* or *HUGO*) have become very complex, selecting insertion points *adaptively* to minimize impact on statistics.
This often reduces effective payload compared to theoretical potential, but considerably improves security.
=== Categories of Modification Methods

Carrier modification divides into two categories depending on how insertion points are chosen:

- *Random/Sequential Methods:* Bits are inserted simply (e.g., sequentially in image scan order or pseudo-randomly).
These methods are largely outdated and easily detectable.
- *Adaptive Steganography Methods:* Algorithm analyzes local content of carrier and inserts message only in *complex texture zones* or *high noise*.
These zones are naturally more random, allowing easier masking of statistical alteration introduced by message.
== LSB Steganography

*Least Significant Bit* (LSB) steganography is most elementary hiding technique.
It operates by direct *replacement* of least significant bits of carrier with secret message bits.
- *Mechanism:* *Least significant bits* of image pixels (or, in compressed domain variants, DCT coefficients) are replaced by encrypted message.
- *Capacity:* Replacing one LSB per pixel allows payload of *1 bit per pixel* (_1bpp_), offering very high encoding capacity.
=== Visual Imperceptibility

- *Principle:* LSB replacement achieves almost perfect *visual imperceptibility*.
LSB alteration modifies pixel value by at most $\pm 1$ (if pixel is encoded on 8 bits).
- *LSB Property:* LSB bit plane of natural image (unmodified) is already very close to *white noise*.
Inserting encrypted message (which is itself very close to random noise) in this plane entails *no perceptible alteration* by human eye.
=== Attacking LSB Replacement

Steganalysis demonstrates that LSB replacement is statistically *easy to detect*, especially for high payload, as it modifies natural relationship between pairs of pixel values.
- *Parity Alteration:*
  - If pixel value $x(i)$ is *even* (e.g.: $01100000$), inserting $1$ (secret bit) makes it *odd* ($01100001$).
Inserting $0$ leaves it *even*.
- If $x(i)$ is *odd* (e.g.: $01100001$), inserting $0$ makes it *even* ($01100000$).
Inserting $1$ leaves it *odd*.
- *Consequence on Distribution:* Inserting random message (where $0$s and $1$s are equiprobable) *forces equalization* of frequencies of adjacent even and odd values.
- *Example:* Considering value pair $(0, 1)$:
  - About *half* of pixels with value $0$ (even) become $1$ (odd) to encode a $1$.
- About *half* of pixels with value $1$ (odd) become $0$ (even) to encode a $0$.
- *Result:* After insertion (hstego), frequency of pixels with value $k$ becomes very close to frequency of pixels with value $k+1$, canceling slight natural asymmetry present in unmodified images.
Detectors (like RS analysis or histogram shift) can exploit this *statistical anomaly*.
=== Countermeasures

*Perfect* steganography would require preserving *all* image statistics, but this is impractical (impossible to perfectly model images, excessive complexity).
Four empirical approaches are used in practice to improve statistical security:

- *1.
  Model-preserving steganography:* Seeks to correct alterations after insertion to maintain certain low-level statistics (e.g., histogram moments) known to be exploited by steganalysts.
- *2. Stochastic modulation:* Uses controlled noise insertion or adapts method to make process more random, masking alteration introduced by message.
- *3. Steganalysis-aware steganography:* Uses results of steganalytic classifier to dynamically determine where to insert message, choosing locations minimizing detection risk.
- *4. Distortion minimization:* Most effective approach (e.g., *HUGO*, *WOW*).
It chooses *adaptively* insertion points causing *smallest possible modification* to image statistics, focusing on complex texture zones.
=== Exploiting LSB Statistical Anomaly

Main anomaly created by LSB insertion is that natural statistical relationship between consecutive pixel values is *regularized* or *equalized* artificially.
Steganalysts exploit this phenomenon by measuring *modification of value pairs* or *spatial correlation* of pixels.
==== Principle of Statistical Alteration (Recap)

In unmodified natural image, histogram presents certain irregularity and *slight asymmetry* between adjacent value pairs $(k, k+1)$.
Random LSB message insertion (for high payload) forces about half of pixels with value $k$ to become $k+1$, and half of pixels with value $k+1$ to become $k$.
- *Consequence:* Frequency of values $k$ and $k+1$ tends to balance ($"hstego"(k) approx "hstego"(k+1)$), which is *artificial sign* of modification.
==== Methods Exploiting Anomaly

Two large families of steganalytic techniques exploit this forced regularization:

===== 1. Pair-of-Values Analysis

These methods observe frequencies of specific value pairs (often lower-order pairs):

- *Histogram Shift Analysis:*
  - This technique focuses on observing histograms.
If LSB insertion is used, frequency of values $k$ and $k+1$ in modified image deviates from expected frequencies for natural image.
- For 1 bpp payload, alteration is maximal and steganalyst can quantify deviation between observed distribution and theoretical distribution of natural image to deduce *probability* message is hidden.
===== 2. RS Analysis

RS analysis is classic and most powerful method to detect LSB insertion.
It exploits *spatial relationship* between pixels:

- *Principle:* It measures *ease* with which pixel groups are modified or preserved under simple transformation (usually parity modification).
- *Regular (R) and Singular (S) Groups:*
  - Image is divided into small pixel groups (e.g., $2 times 2$).
- A *discrimination function* is applied on these groups.
- Analysis counts number of groups becoming *more regular* (groups $R$) or *more singular* (groups $S$) after *permutation operation* (parity shift, for example).
- *Exploitation:*
  - Random LSB insertion *increases* number of groups behaving like regular groups ($R$) and *decreases* number of singular groups ($S$) when applying permutation operation on LSB plane.
- If image is not steganographed, curves $R$ and $S$ behave in certain way.
If it is, they *cross* at characteristic point.
- Steganalyst can *quantify* curve separation to *estimate size* (payload) of hidden message.
=== Conclusion

Statistical anomaly created by pixel value regularization (equalization of $"hstego"(k)$ and $"hstego"(k+1)$) provides *quantitative signature* of modification.
Steganalysis techniques use signature to prove message existence, thus realizing opposite goal of steganography.

#pagebreak()

== Empirical Approaches to Steganography: Improving Security

Modern empirical approaches aim to overcome statistical weaknesses of simple steganography (like LSB replacement) by making modifications *less detectable* by steganalysis tools.
=== Model-based Steganography

- *Principle:* A *statistical model* is identified to describe source image.
Steganography acts to insert message *without modifying parameters of this model*.
- *Statistical Restoration:* Message is inserted in subset of pixels or coefficients.
Other pixels are then *modified* to restore statistical model (e.g., histogram).
- *Example:* *OutGuess* algorithm uses this principle in DCT domain to realign statistics after insertion.
- *Security:* Security is almost perfect *as long as* steganalysis relies *solely* on adopted statistical model.
In practice, this is never case, as steganalysts use higher-order models.
=== Stochastic Modulation

- *Principle:* This technique *simulates noise* naturally added to image during acquisition phase.
Steganography works by adding noise resembling acquisition noise.
- *Simulated Noise Types:*
  - Thermal noise.
  - Quantization noise.
- PRNU noise (_Photo-Response Non-Uniformity_).
- *Payload:* Allows relatively *high* payloads (up to $0.8$ _bpp_).
=== Steganalysis-aware Steganography

- *Principle:* Extension of stochastic modulation.
Steganographer actively works to *eliminate or reduce* known artifacts exploited by steganalyst (often by *convolution* of message and source image).
This is one of *most difficult methods to detect*.
- *Example:* *$plus.minus 1$-steg*:
  - If LSB is incorrect, algorithm *adds or subtracts 1* *randomly* (conditional), instead of simply flipping LSB.
- *Observation:* This doesn't modify only LSB (e.g., $01111111 + 1 = 10000000$), which is *conditional summation* allowing message extraction.
- *Impact:* Security increases *drastically* because histogram does not change significantly.
*F5* algorithm uses $plus.minus 1$-steg in frequency domain.

=== Distortion Minimization

- *Principle:* Most *modern* approach.
It defines *cost function* quantifying statistical "damage" caused by pixel modification.
- *Cost:* Cost function $ρ(i)$ measures cost of modifying given pixel.
- *Global Cost:* Total cost is given by formula: $sum_(i=1)^n ρ(i)[x(i) - y(i)]^2$.
- *Insertion Rule:* Algorithm seeks insertion rule *minimizing this global cost*.
- *Example:* *F5* is considered optimum from this point of view in DCT domain.
=== Typical Payloads

- *Pixel Domain:* From $0.1$ to $0.5$ _bpp_.
For $1000 times 1000$ image, represents about $40 "KB"$ hidden data.
- *DCT Domain:* Up to $0.8$ _bpnzc_ (_bit per non-zero coefficient_). Real payload depends on content.
Realistic value is about $20 "KB"$ for $1000 times 1000$ image.
=== Steganalysis

Steganalysis is study of methods to detect hidden messages.
Success depends heavily on *application scenario* and information available to Warden.
- *Scenarios:*
  - *Blind Steganalysis:* Algorithm used is unknown.
- *Targeted Steganalysis:* Algorithm is known (Kerckhoff's principle).
- *Warden's Knowledge:* Depends on knowledge of source image statistics and payload.
=== Hypothesis Test Formulation

Steganalysis is formulated as *rigorous hypothesis test*:

- *Hypotheses:*
  - $H_0$: Observation $y$ *does not contain* hidden message.
- $H_1$: Observation $y$ *contains* hidden message.
- *Decision Criteria:*
  - *Neyman-Pearson Criterion (N-P):* Used for steganalysis.
Vises to *minimize non-detection probability* ($P_m$) for fixed *false alarm probability* ($P_f$).
=== ROC Curve and Performance Metric

- *ROC Curve (_Receiver Operating Characteristic_):* Plots correct detection rate ($P_d = 1 - P_m$) versus false alarm rate ($P_f$).
- *AUC (_Area Under Curve_):* Area under ROC curve evaluates steganalyst goodness.
More precise system has *large AUC* (close to 1).
- *Perfect Security:* Performance equivalent to random guess, ROC curve is on diagonal ($text(A U C) = 0.5$).
=== Chi-Square Test

- *Principle:* Used if source image distribution (_pdf_ - _probability density function_) is known.
- *Statistic:* $χ^2$ statistic is calculated by: $χ^2 = sum_(i=1)^n (n_i - n p_i)^2 / (n p_i)$.
- *Decision:* *High values* of $χ^2$ statistic are taken as evidence for $H_1$ (message presence).
=== Feature Selection

- *Targeted Steganalysis:* Uses few *ad-hoc* statistics.
- *LSB Example:* $χ^2$ test uses *probability mass function* (_pmf_) under $H_1$ where consecutive histogram bins are equalized: $h_(H_1)(2k) = h_(H_1)(2k + 1) = (h(2k) + h(2k + 1)) / 2$.
- *Blind Steganalysis:* Requires machine learning based approaches:
  - Calculate *over 100 features* independent of image content.
- Train *classifier* (_SVM_) with appropriate examples.
- *CNNs* applied directly in pixel domain are replacing SVMs, although they may sacrifice precision without pre-processing.
=== Summary

- *Steganography:* Many techniques exist, but security is not trivial.
Knowledge of principles is essential to avoid simple attacks.
- *Steganalysis:* It is *reliable* in selected cases (targeted steganalysis, high payload), but *difficult* in general case (blind steganalysis).
- *Active Domain:* These domains remain subjects of intense research (_work in progress_).

#pagebreak()

= Biometric forensics

== Biometric Criminalistics: Classification of Attacks on Biometric Systems

Biometric systems, although designed for security, present several vulnerability points exploitable by attackers.
These attacks are generally classified into two main categories, depending on injection point of forged signal into system architecture.
=== 1. Direct Attacks

Direct attacks, also called *presentation attacks* (PAs) or *spoofing*, are simplest and most common.
They occur at *sensor* level:

- *Location:* Point 1 (User Interface / Sensor).
- *Principle:* Attacker attempts to deceive sensor by presenting *counterfeit* of legitimate biometric characteristic (imitation of biometric sample) without modifying or manipulating sensor itself.
- *Examples:*
  - Using *fake finger* made of gelatin or silicone on fingerprint scanner.
- Using *photograph* or *video* to deceive facial recognition system.
- Using *audio recording* to bypass voice recognition system.
- *Countermeasure:* *Presentation Attack Detection* (PAD) or *liveness detection* is main defense against this attack type.
=== 2. Indirect Attacks

Indirect attacks are more sophisticated.
They are conducted *inside biometric system* targeting processing modules or communication channels:

- *Location:* Points 2 to 8 in internal system architecture.
- *Principle:* Attacker needs no physical sample. Manipulates digital data and internal processes.
=== Specific Vulnerabilities in Indirect Attacks

Indirect attacks target several critical system modules:

- *Communication Channels (Points 2, 4, 7, 8):*
  - Attacker can *intercept* and *manipulate* biometric data (raw sample, features, matching score) as they transit between modules.
- Can for example inject *valid feature set* inside channel (Point 2) before feature extractor.
- *Feature Extraction Module (Point 3):*
  - Attacker *bypasses* extraction module and injects *synthetic biometric features* (or stolen ones) directly into comparator.
- *Comparison Module (Point 5):*
  - Attacker manipulates *comparator* to generate high matching score, granting access.
- *Reference Database (Point 6):*
  - Critical target.
Attacker can *manipulate* or *replace* stored *biometric references* (templates).
- Common technique is *template planting*: attacker inserts own valid template for legitimate user, giving permanent access.
=== Importance of Cryptography

Indirect attacks underscore importance of *cryptography* and *anti-tamper mechanisms* to protect stored data (Point 6) and communication channels (Points 2, 4, 7, 8).
Biometric criminalistics focuses on analyzing these flaws to strengthen global security.

#pagebreak()

== Biometric forensics: classification: Attacks on biometric systems (course version)

- Direct attacks (spoofing or presentation attacks - PAs) are performed at the sensor level: the sensor is fooled but not replaced or tampered.
- Indirect attacks are performed inside the system by:
  - bypassing the feature extractor or the comparator (3, 5)
  - manipulating the biometric references in the biometric reference database (6)
  - exploiting possible weak points in communication channels (2, 4, 7, 8)


#pagebreak()

== Presentation Attacks

Presentation attacks (PA), often called *spoofing*, are *direct* attacks conducted at biometric sensor level.
They consist of presenting artifact or imitation to capture interface with aim of impersonating legitimate user.
- *Principle:* Attacker presents physical or digital counterfeit of biometric characteristic (face, fingerprint, voice, etc.) to sensor.
- *Vulnerability:* These attacks exploit fact that most sensors do not verify *vitality* or *alive* character (_liveness_) of presented sample.
=== Examples of Presentation Attacks by Biometric Model

- *Facial Recognition (FaceID):*
  - *Photos:* Use of high-resolution *photographs* (on paper or screen) to deceive basic systems.
- *Silicone Masks:* Use of realistic *silicone masks* or 3D prosthetics to simulate victim's face.
- *2D Deepfake:* *Realistic* facial images are generated using *Generative Adversarial Networks* (GAN) to be displayed on screen in front of camera.
- *Fingerprint:* Fingerprint spoofing is often achieved using *fake fingers* or *gummy fingers*.
- *With Cooperation (or victim access):* Materials like *gelatin* or *wood glue* are used to create mold (or positive print) of legitimate finger.
- *Without Cooperation:* *Latent fingerprint* (left on surface) is *lifted* and transferred to medium (like *PCB*) to serve as mold for creating fake finger.
- *Iris Recognition:*
  - *Iris Spoofing:* Use of iris images printed on *high quality paper* using inkjet printer or displayed on contact lenses.
- *Finger-vein:*
  - *Vein Spoofing:* Sophisticated counterfeit targeting internal vein pattern recognition systems.
- *Voice Recognition:*
  - *Voice Attack:* *Playback of a voice recording*, use of computer-generated *synthesised speech*, or *converted voice* to deceive microphone.
=== Defense against PAs

Main defense against these attacks is *Presentation Attack Detection* (PAD), using techniques to verify *vitality* or physical properties (heat, motion, reflectivity) of presented sample.
== Presentation Attack Defense Methods

Defense against Presentation Attacks (PAs) is essential to guarantee integrity of biometric systems.
These methods, collectively called *Presentation Attack Detection* (PAD) or *liveness detection*, are classified according to analysis nature.
=== Classification of Defense Methods

- *Software-based:*
  - System analyzes raw or transformed *biometric data* coming from existing single sensor.
- Analysis focuses on characteristics distinguishing original/live sample from counterfeit/attacked sample (examples: analysis of *texture*, *movement*, *eye blinking*).
- *Advantage:* Generally cheaper to implement, as it requires no new hardware.
- *Hardware-based:*
  - One or more *additional sensors* are used.
- Data from these sensors are analyzed to confirm source *vitality*.
- *Examples:* Measuring skin *temperature*, detecting *pulse* (blood flow), analyzing *conductivity* or *electrical properties*.
- *Challenge-Response:*
  - User must interact with system in *unpredictable* manner to prove liveness.
- *Examples:* Asking user to repeat *random text* (for voice recognition) or perform *specific movement sequence* (for facial recognition).
=== Single Optical Band Defense

When system uses only single optical sensor (visible band), detection relies on advanced image analyses:

- *Optical Flows:*
  - Analysis of *gradient of changes* between consecutive images.
- Used to verify if movement is *natural* (3D) or if it is simple 2D movement of photo or screen.
- *Limit:* These features are often *local* and less effective against sophisticated masks.
- *Texture Analysis:*
  - Uses descriptors (like LBP, SIFT) to analyze *surface structure* of presented sample.
- Allows detecting texture differences between human skin and counterfeit materials (paper, silicone, gelatin).
- Combines *global* and *local* features to feed a *classifier*.
=== Multi-spectral Face Presentation Attack Defense

Use of multiple sensors or multispectral cameras considerably improves robustness:

- *Depth:* Systems measuring depth (3D or structured cameras) protect effectively *against photos* and 2D images (lacking depth).
- *Infrared (IR):* IR sensors can be used to analyze *skin reflection*, subsurface vein pattern, or detect *masks* (which may block or reflect IR wavelengths differently).
- *Thermal:* Thermal sensors measure *body heat*.
Photo or mask does not emit thermal profile consistent with living being.
- *Color:* Spectral color analysis to detect color anomalies of counterfeit materials.
=== Importance of Biometric Reversibility

- *Conclusion:* Biometric data are by nature *very unique* and *irreplacable*.
If fingerprint or iris template is compromised, impossible to revoke and choose new one (unlike password).
- *Consequence:* For scenarios where security is critical, preferable to prioritize *very robust* biometric defense mechanisms or use them in *combination* with other factors (like a *password*) to guarantee revocability in case of compromise.


#pagebreak()

== Presentation Attack Defense Methods

Presentation Attack Detection (PAD) methods aim to verify sample *liveness* to counter *spoofing* at sensor level.
=== Classification of Defense Methods

- *Software-based:*
  - Analyzes sensor *biometric data* to detect signs of counterfeit (examples: analysis of *texture*, *movement* or *blinking*).
- *Advantage:* Low implementation cost.

- *Hardware-based:*
  - Uses *additional sensors* to measure non-imitable physical properties.
- *Examples:* Measuring skin *temperature*, detecting *pulse* or analyzing *conductivity*.
- *Challenge-Response:*
  - User must interact in *unpredictable* manner (examples: repeat *random text*, perform *specific movement*).
=== Specific Techniques

- *Single Optical Band:*
  - *Optical Flows:* Analysis of *gradient of changes* between images to distinguish 2D movements (photo/screen) from 3D movements (live).
- *Texture Analysis:* Uses descriptors to distinguish human skin texture from that of counterfeit materials (silicone, paper).
- *Multi-spectral (Advanced Defense):*
  - *Depth:* Protects *against photos* and 2D images.
- *Infrared (IR):* Analyzes *skin reflection* or vein patterns, effective *against masks*.
- *Thermal:* Measures *body heat* (thermal profile).
=== Note on Biometric Security

- *Irreplaceability:* Biometric data are *unique and irreplaceable*.
If a template is compromised, it cannot be revoked like a password.
- *Recommendation:* Crucial to use *very robust PAD* mechanisms or combine biometrics with other factors (like password) in high security scenarios.
