= Biometric forensics

== Attacks on biometric systems

- Direct attacks (spoofing or presentation attacks – PAs) are performed at the sensor level: the sensor is fooled but not replaced or tampered.
- Indirect attacks are performed inside the system by:
  - bypassing the feature extractor or the comparator (3, 5)
  - manipulating the biometric references in the biometric reference database (6)
  - exploiting possible weak points in communication channels (2, 4, 7, 8)

== Presentation attack defense methods

- software-based: biometric data from the sensor is analyzed to discriminate original/alive vs attacked sample (e.g., motion, texture)
- hardware-based: an additional sensor is used and its data analyzed to discriminate original/alive vs attacked sample (e.g., temperature, pulse)
- challenge-response: the user interacts with the system (e.g., prompted text in face/speaker recognition)

With only optical band:
- optical flows: gradient of changes in one picture (only local characteristics !)...
- texture analysis: global + local analysis -> classifier...

Multi-spectral face presentation attack defense
- color
- depth (protect again photos)
- infrared (protect again masks ?)
- thermal

Biometric are very unique and irreplacable => prefer password instead !!!