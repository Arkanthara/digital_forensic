== Histogram equalization

- increases dynamic range of an image's pixel values by subjectiong them to a mapping such that the distribution of output pixel values is approximately uniform.
- in order to identify it, we compute normal of histogram.

histogram cdf ???
Histogram equalization is characterised by a linear cdf.

== Tampering detection

image manipulation (tampering): it is the application of image editing techniques to images in order to create an illusion or deception after the original photographing took place

=== 5 cathegories of techniques

==== pixel-based

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

==== Camera-based techniques (examples)

- Chromatic aberations: variations in chromatic aberration patterns across an image may be used as evidence of image tampering.
- Sensor noise: distortions of sensor noise pattern (example: PRNU)
- Color filter arrays
  - color calculation from neighbor pixels introduces recognizable correlation patterns between pixels in an image
  - different cameras may have different patterns (Bayer/Diagonal Bayer/Stripes/etc...)
  - different cameras interpolate using different, often, proprietary, filters (theses methods are repeated many times, so we can see when something is wrong.... In general, peoples make some assumption: if they use this, we will obtain this result etc... And in general, it's enough)

===== Physics-based techniques

- 2D lighting: considers only the two-dimensional (2-D) surface normals at the occluding object boundary
- 3D lighting: uses the model of the human eye to determine the required 3D surface normals
- Light environment: uses an approximation of a Lambertian surface, simplified further to consider only the occluding boundary of an object.

===== Geometric-based techniques

- principal point estimation: principal point is the projection of teh camera center onto the image plane.
when a person or object is translated in the image, the principal point is moved proportionally (perspective respected or not ???)
- metric measurements: tools from projective geometry that allow for the rectification of planar surfaces and, under certain conditions, the ability to make real-world measurements from a planar surface.

==== Conclusion

Is this image modified or not ???

= Digital Forensics of Printed Document

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

=== Device attribution

A set of computer vision techniques applied in a digital version of a document, aimed at pointing out which device is its source

- devices attribution can be done searching two kinds of artifacts (or signatures\fingerprint)
  - extrinsic (watermarking): inserted bz the device in the document
  - intrinsic (blind): given by the analysis of the resulting document
- device attribution involves answering two questions:
  - which device brand and model produced a given document?
  - which specific device produced a given document ?

==== Steps

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

drum is charged... lazer discharge drum where we want to print something. Then toner put particles in this place, go on paper, deposit particles on paper.
Finally, fuzer fix particles in document thanks to compression and high temperature.

- data is written by a laser beam, which discharges certain places in a drum where ink must be put
- positively charged ink is then stick in the discharged places of the drum
- data with ink is spread on the paper by the fuser

