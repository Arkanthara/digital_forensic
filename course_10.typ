= Modern Steganography
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







