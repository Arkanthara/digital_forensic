= Deep learning methods in digital forensics

== Introduction

=== When problem happen

In the end of the 90’s, the diffusion of easy-to-use image editing tools raised increasing alarm about the credibility of digital images and the possible use of manipulated images for malevolent purposes
 
- Use of digital images in a court of law
- Gossip / defamation
- Bias the political debate

First technical solutions were appeared in the early 2000’s proposed by researchers working in steganalysis

=== AI media revolution

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

=== DNN watermarking

==== Shift of paradigm

===== Old idea

Why don’t we embed an invisible watermark in all AI images so to ease

- Origin verification
- Trace manipulation history
- Detection of abuses

Unfeasible solution: how can we enforce the watermarking of all images generated or edited by means of AI?

====== New idea

Rather than engaging a hopeless race of arms with generative AI companies, team up with them to ease the ethical use of digital images and identify abuses

Watermark AI generative models so that all the images they produce contain a watermark

Possibly feasible: only a handful of companies are capable to train from scratch a new AI generative model

==== DNN watermarking in nutshell

DNN watermarking has been proposed as a way to protect the IPR of DNN models

Y. Uchida, Y. Nagai, S. Sakazawa, and S. Satoh, “Embedding watermarks into deep neural networks,” in Proc. ICMR’17, 2017
Li, Y., Wang, H., & Barni, M. (2021). A survey of deep neural network watermarking techniques. Neurocomputing, 461, 171-193.

It indissolubly embeds within a DNN model a piece of information to be used later for a given purpose
The watermark should resist moderate to strong model modifications, like pruning, compression, fine tuning and even transfer learning

(Here a graph)

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

===== Image processing

Watermark is quite resistant

===== Model pruning

We can cut up to 1/4 of the network, watermark is preserved

===== Model quantization

Precision in model coefficients... Watermark preserved until precision of 3 number after ,.

===== Fine tuning

Blabla

===== Super resolution

Create super resolution with watermark

=== GAN watermarking: early and new solutions

==== Retraining free fingerprinting

For some applications it may be useful to embed different watermarks in different version of the same DNN model

With most methods this requires a heavy retraining

==== Solution

Introduce a personalized layer in the generator whose parameters are responsible for watermark embedding

The parameters are generated (feedforward) by a separate parameter-
generation (ParamGen) network for each different watermark

J. Zhang, D. Chen, J. Liao, W. Zhang, G. Hua, and N. Yu, “Passport-aware normalization for deep model protection,” Advances in Neural Information Processing Systems, vol. 33, pp. 22 619–22 628, 2020.
J. Fei, Z. Xia, B. Tondi, M. Barni, Robust retraining-free GAN fingerprinting via Personalized Normalization, IEEE WIFS 2023

ParamGen network derives the parameters resulting in the embedding of the desired watermark without retraining

Introduce some small modifications in watermark to have unique watermark for each user...

Normalization step: mean = 0 and std = 1...

To create a model with a given watermark it is only necessary to run the ParamGen networks and generate the weights of the personalized normalization layer

==== Sense of achievable results

- Boundary Equilibrium GAN (BEGAN)
- Spectral Normalization GAN (SNGAN)
- Progressive Growing GAN (PGGAN)
- Face generation, trained on CelebA dataset
- Penultimate layer for PN
- ParamGen networks: fully connected, ReLu, 128 wm bits Sense of achievable results

=== Conclusion

Limits of classical Multimedia forensics in the AI era

- Still valid in specific, narrow, scenarios
- Difficult (impossible) to cope with in a wide settings
  - Disinformation campaigns

DNN-based active fingerprinting may provide a solution
- Challenges to be solved (robustness and security)
- No general solution, but can be a valid complement to passive MMF
