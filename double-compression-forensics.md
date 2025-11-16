# Double Compression Detection in Video Forensics: Comprehensive Document Repository

## Executive Summary

This document provides a comprehensive collection of resources for double compression detection in video forensics across multiple codecs: H.264, H.265, H.266, AV1, and MKV container format. The research spans from fundamental codec documentation to advanced forensic detection methodologies.

---

## Part 1: Double Compression Detection Research & Methods

### 1.1 Key Research Papers on Double Compression Detection

#### H.264 Double Compression Detection

**"A Contrario Detection of H.264 Video Double Compression"** (Li et al., ICIP 2023, Zenodo 2023)
- **Focus**: Novel method for identifying double compression in H.264 codec videos
- **Key Innovation**: Exploits the periodicity of frame residuals caused by fixed Group of Pictures (GOP) in initial compression
- **Framework**: Employs an "a contrario" framework to minimize and control false detections
- **Advantage**: No threshold tuning required, enabling automatic detection
- **Availability**: Open source code available at GitHub (li-yanhao/gop_detection)
- **Citation**: https://zenodo.org/records/8373063

**"Codec and GOP Identification in Double Compressed Videos"** (Bestagini et al., 2016)
- **Focus**: Method exploiting coding-based footprints to identify codec and GOP size in first compression step
- **Principle**: Uses compression idempotency - re-encoding with same codec and parameters produces similar sequences
- **Application**: Video forensics and quality assessment
- **Testing**: Validated on MPEG-2, MPEG-4, H.264/AVC, and DIRAC codecs
- **Proof of Concept**: Tested on YouTube-downloaded videos

**"Detection of Double-Compressed Videos Using Descriptors of Video Encoders"** (2022)
- **Focus**: Detection using encoder descriptors rather than video content analysis
- **Methodology**: Compares subset of encoding modes used by different hardware encoders
- **Coverage**: H.264 and HEVC encoders tested
- **Key Finding**: Identifies that hardware encoders use subset of available encoding modes as fingerprints
- **Source**: PMC NCBI (Published November 2022)

#### H.265/HEVC Double Compression Detection

**"Detection of Double Compression in HEVC Videos Containing B-Frames"** (Furushita et al., 2025)
- **Focus**: First dedicated study on detecting double compression in HEVC videos with B-frames
- **Methodology**: Bi-LSTM classifier analyzing frame-level encoding features
- **Features**: 28-dimensional feature vector including frame type, CU size, QP, prediction modes
- **Dataset**: 129 HEVC-encoded YUV videos from 43 original sequences
- **Accuracy**: 80.06% detection accuracy, outperforming existing baselines
- **Significance**: Addresses realistic double compression scenarios with B-frames
- **Source**: PMC NCBI, Citation Managers (Published June 2025)

**"Double HEVC Compression Detection with Different Bitrates Based on Co-occurrence Matrix of PU Types and DCT Coefficients"** (ITM Conferences)
- **Focus**: Detection method for different bitrates in HEVC
- **Features**: Co-occurrence matrices of PU (Prediction Unit) types and DCT coefficients
- **Approach**: Statistical analysis of quantization parameter effects

**"Double HEVC Compression Detection with the Same QPs Based on the PU Numbers"** (ITM Conferences)
- **Focus**: Specifically addresses detection when compression uses same quantization parameters
- **Method**: Analyzes number of 4×4 PU blocks in each I-frame
- **Application**: Challenging scenario in forensics

**"A Two-Stage Cascaded Detection Scheme for Double HEVC Compression Based on Temporal Inconsistency"** (Hindawi, 2021)
- **Focus**: Two-stage cascade detection addressing different recompression settings
- **Approach**: Temporal inconsistency analysis
- **Challenge**: Addressing diverse compression parameter combinations

**"Exposing Video Compression History by Detecting Transcoded HEVC Videos from AVC Coding"** (MDPI, 2019)
- **Focus**: Detection of transcoding from H.264 to H.265
- **Method**: Statistics of Prediction Units (PUs)
- **Application**: Compression history analysis

#### Double Compression Detection - General Methods

**"Digital Video Manipulation Detection Technique Based on Compression Algorithms"** (arXiv, 2024)
- **Focus**: Forensic technique analyzing H.264 compression algorithms
- **Features**: Macroblock information and motion vectors
- **Classifier**: Support Vector Machine (SVM)
- **Application**: Detecting manipulation traces

**"DHNet: Double MPEG-4 Compression Detection via Multiple DCT Histograms"** (Nam et al., IEEE MultiMedia, 2021)
- **Focus**: Neural network-based approach for MPEG-4 double compression detection
- **Features**: Multiple DCT histograms on multiresolution blocks
- **Auxiliary Information**: Quantization table vectors
- **Performance**: High accuracy for surveillance and shooting device videos
- **Citation**: arXiv:2107.08939

**"MPEG-2 Prediction Residue Analysis"** (Vázquez-Padín & Pérez-González, arXiv 2019)
- **Focus**: Semi-analytic model for MPEG-2 double compressed sequences
- **Theory**: Explains Variation of Prediction Footprint (VPF) behavior
- **Insight**: Reveals impact of quantizer deadzone width on detection methods

#### Variation of Prediction Footprint (VPF) - Key Method

**"Video Integrity Verification and GOP Size Estimation via Generalized Variation of Prediction Footprint"** (Vázquez-Padín et al., IEEE TIFS, 2019)
- **Focus**: Comprehensive investigation of VPF for double compression detection
- **Innovation**: Generalized VPF (G-VPF) extending to videos with B-frames
- **Features**: Motion vector analysis to enhance VPF acquisition
- **Capability**: Handles bidirectional frame compensation
- **Performance**: Outperforms state-of-the-art in detection and GOP estimation
- **GitHub**: IAPP-Group/GVPF available with MATLAB code

**"Prediction Residue Analysis in MPEG-2 Double Compressed Video Sequences"** (Vázquez-Padín & Pérez-González, EUSIPCO 2019)
- **Focus**: Theoretical characterization of prediction residue evolution
- **Analysis**: Impact of frame type (I vs P), compression strength, deadzone width
- **Method**: Autoregressive models for temporal dependencies

**"How To Check Video Integrity By Detecting Double Encoding With VPF Analysis"** (Forensic Focus)
- **Educational**: Comprehensive explanation of VPF methodology
- **Principle**: Detection of periodic peaks in Variation of Prediction Footprint signal
- **Application**: Reliable double encoding detection with periodicity analysis
- **Practical Implementation**: Step-by-step VPF analysis approach

### 1.2 Advanced and Specialized Topics

**"AIM 2024 Challenge on Compressed Video Quality Assessment: Methods and Results"** (arXiv, 2024)
- **Scope**: 459 videos with 14 codecs (AVC/H.264, HEVC/H.265, AV1, VVC/H.266)
- **Dataset**: Comprehensive collection with various compression artifacts
- **Application**: Quality assessment and artifact evaluation
- **Relevance**: Provides comparative analysis across multiple codecs

**"Forensic Recognition of Codec-Specific Image Compression Artefacts"** (ACM DL, 2023)
- **Scope**: 10 different lossy image compression formats including video-coding related (AVIF, HEIC, BPG, WEBP)
- **Method**: ResNet-18 fine-tuning with different file sizes
- **Accuracy**: Almost perfect for low quality, 85%+ for high quality
- **Insight**: Classification based purely on spatial compression artifacts

**"A Review on HEVC Video Forensic Investigation under Different Scenarios"** (MECS Press)
- **Comprehensive**: Summary of all existing methodologies for HEVC forgery detection
- **Categories**: Transcoding detection, fake bitrate detection, double compression detection
- **Methodology**: Classification of detection techniques

---

## Part 2: Codec Specifications & Architecture

### 2.1 H.264/AVC (Advanced Video Coding)

**Official Standards**
- **Standards**: ITU-T Recommendation H.264 (February 2016) | ISO/IEC 14496-10
- **Also Known**: MPEG-4 Part 10
- **Status**: Most widely used codec (79% of video industry developers as of Dec 2024)

**Technical Specifications**
- **Block-Based Compression**: Block-oriented, motion-compensated coding
- **Macroblock Size**: 16×16 pixels (largest partition)
- **Transform**: Integer DCT with 4×4 and 8×8 block sizes
- **Prediction**: Multi-picture inter-prediction with variable block sizes
- **Entropy Coding**: CAVLC (Context-Adaptive Variable Length Coding) and CABAC (Context-Adaptive Binary Arithmetic Coding)
- **Loop Filter**: Deblocking filter for artifact reduction
- **Features**: 
  - Reduced-complexity integer DCT
  - Variable block-size segmentation
  - Multi-picture inter-picture prediction
  - Robust fault tolerance
  - Excellent network adaptability
- **Applications**: Video conferencing, digital storage, broadcasting, RTP/IP streaming, multimedia telephony
- **Bitrate**: Achieves half the bitrate of MPEG-2, H.263, or MPEG-4 Part 2
- **Resolution**: Up to 8K UHD support
- **Forensic Significance**: 
  - Macroblock types and motion vectors are exploitable for manipulation detection
  - Encoding mode selection varies by hardware vendor
  - Prediction residue periodicity detectable in double compression
  - Quantization parameter (QP) effects on DCT coefficients

**Key Documents**
- ITU-T H.264.1 (Conformance Specification)
- RFC 7798 variants for transport

### 2.2 H.265/HEVC (High Efficiency Video Coding)

**Official Standards**
- **Standards**: ITU-T Recommendation H.265 (2013) | ISO/IEC 23008-2 (MPEG-H Part 2)
- **Developer**: Joint Collaborative Team on Video Coding (JCT-VC)
- **Status**: Widely deployed for broadcasting and streaming

**Technical Specifications**
- **Compression Efficiency**: 25-50% better than H.264 at same quality level
- **Block Structure**: Coding Tree Units (CTUs) replacing fixed macroblocks
  - CTU Sizes: 16×16, 32×32, or 64×64
  - Coding Units (CU) with quad-tree decomposition
  - Prediction Units (PU) for prediction mode selection
  - Transform Units (TU) with quad-tree structure
- **Transform Types**: Integer DCT and DST (Discrete Sine Transform)
- **Transform Sizes**: 4×4, 8×8, 16×16, 32×32 blocks
- **Prediction**: 
  - Enhanced intra-prediction (35 directional modes)
  - Improved motion compensation
  - Sample-adaptive offset (SAO) filtering
  - Advanced loop filtering
- **Frame Types**: I-frames, P-frames, B-frames with improved handling
- **Applications**: 4K/8K broadcasting, streaming, surveillance, mobile HD video
- **Resolution**: Up to 8K UHD (8192×4320)
- **Bitrate Reduction**: 40-50% vs H.264
- **Forensic Significance**:
  - PU size distribution affected by double compression
  - CU structure and quantization interactions
  - DCT coefficient histograms show double compression traces
  - B-frame analysis reveals recompression signatures
  - Encoding mode frequencies vary by encoder implementation

**Key Features for Forensics**
- Variable block sizes create unique patterns
- Quantization parameter effects on TU coefficients
- Motion vector field analysis for double compression detection

### 2.3 H.266/VVC (Versatile Video Coding)

**Official Standards**
- **Standards**: ITU-T H.266 | ISO/IEC 23090-3 | MPEG-I Part 3
- **Finalized**: July 6, 2020
- **Developer**: Joint Video Experts Team (JVET) with Fraunhofer HHI contributions
- **Status**: Latest generation standard for future applications

**Technical Specifications**
- **Compression Efficiency**: 30-50% bitrate reduction compared to HEVC
- **Encoding Complexity**: 10× higher than HEVC
- **Decoding Complexity**: ~1.5× higher than HEVC
- **Block Partitioning**: Multi-type tree (MTT) architecture
  - Binary tree (BT) and ternary tree (TT) decomposition
  - More flexible than HEVC quad-tree
  - Supports up to 128×128 pixel blocks down to 4×4
- **Color Support**: YCbCr 4:4:4, 4:2:2, 4:2:0
- **Bit Depth**: 8-bit to 16-bit per component
- **Transform Types**: Multiple transform selections (MTS)
- **Prediction Modes**: Enhanced intra and inter prediction
- **Resolution Support**: 4K to 16K resolution, 360° VR video
- **HDR Support**: BT.2100, 16+ stops HDR
- **Frame Rates**: Variable and fractional 0-120 Hz
- **Scalability**: Temporal and spatial scalability
- **Applications**: Future streaming, 8K broadcasting, videoconferencing, VR
- **Forensic Status**: Limited existing double compression detection research (emerging area)

**Key Tools Exploitable for Forensics**
- Multiple Transform Selection (MTS) modes
- Cross-component linear model (CCLM) for chrominance prediction
- Partition structure signatures from MTT architecture

**Implementation Status**
- Fraunhofer VVenC (encoder) and VVdeC (decoder) available
- Open source implementations through GPAC
- Real-time 8K60 streaming capable
- Adoption growing in broadcast (DVB integration announced Feb 2022)

### 2.4 AV1 (AOMedia Video 1)

**Official Standards**
- **Standard**: AOMedia Video 1 Codec Specification
- **Developer**: Alliance for Open Media (AOM)
- **Status**: Open, royalty-free codec
- **Design Focus**: Real-time applications and high resolutions

**Technical Specifications**
- **Compression Efficiency**: Up to 50% better than H.264, comparable to H.265
- **Block Partitioning**: Recursive superblock partitioning
  - Block sizes: 4×4 to 128×128 pixels
  - Flexible adaptive partitioning
- **Transform Types**: 16 separable 2D transform kernels
  - DCT, ADST (Asymmetric Discrete Sine Transform), fADST, IDTX
  - Up to 19 different scales (64×64 down to 4×4)
- **Internal Precision**: 10 or 12-bit processing (reduces rounding errors)
- **Profiles**: Main, High, Professional
- **Bit Depth**: 8-bit to 12-bit per sample
- **Color Gamuts**: ITU-R Recommendation BT.2020 support
- **Prediction Modes**: 
  - Advanced intra and inter prediction
  - Higher accuracy motion estimation
- **Filtering**:
  - Constrained Directional Enhancement Filter (CDEF)
  - Loop Restoration Filter
  - Deblocking with adaptive strengths
  - Film grain synthesis
- **Encoding Complexity**: 5-10× slower than VP9 (but improving with optimization)
- **Decoding Complexity**: Moderate, increasingly hardware-accelerated
- **Resolution Support**: 4K, 8K, UHD content
- **Applications**: Streaming (WebRTC), gaming, content delivery, future broadcasting
- **Hardware Acceleration**: Growing support in modern devices
- **Forensic Status**: Very limited existing research (emerging codec for forensics)

**Entropy Coding**
- Advanced arithmetic coding techniques
- Context modeling for improved compression
- Support for uncompressed bitstream elements

**Challenges for Forensics**
- Fewer existing forensic tools compared to H.264/H.265
- Complex prediction and transform mechanisms
- Limited reference implementations for forensic analysis
- Recent adoption means less real-world double-compressed AV1 content in forensic databases

### 2.5 MKV/Matroska Container Format

**Official Standard**
- **Full Name**: Matroska Multimedia Container
- **Standards**: Extensible Binary Meta Language (EBML) based open standard
- **Status**: Free, open-source project
- **Standards Body**: Matroska Project (https://matroska.org)

**File Extensions**
- `.mkv` - Video with audio and/or subtitles
- `.mk3d` - Stereoscopic 3D video
- `.mka` - Audio-only files
- `.mks` - Subtitles only

**Technical Specifications**

**Container Capabilities**
- Unlimited number of video tracks
- Unlimited number of audio tracks
- Multiple subtitle tracks
- Image tracks
- Chapter information
- Menus and attachments
- Metadata and tagging information
- Font files for subtitles
- Comprehensive header information

**Supported Video Codecs in MKV**
- **H.264/AVC**: Matroska ID `V_MPEG4/ISO/AVC`
- **H.265/HEVC**: Matroska ID `V_MPEGH/ISO/HEVC`
- **H.266/VVC**: Recently added support
- **AV1**: Matroska ID `V_AV1`
- **VP8**: Matroska ID `V_VP8`
- **VP9**: Matroska ID `V_VP9`
- **MPEG-2**: Matroska ID `V_MPEG2`
- **MPEG-1**: Matroska ID `V_MPEG1`
- **MPEG-4 Part 2**: Matroska ID `V_MPEG4/ISO/AP`
- **Motion JPEG**: Matroska ID `V_MJPEG`
- Additional codec support as needed

**Supported Audio Codecs**
- AAC, MP3, FLAC, Vorbis, AC-3, E-AC-3, DTS, TrueHD, and many others

**Structural Features**

**EBML Header Specifications**
- Document type: "Matroska"
- Maximum ID length: 4 octets
- Maximum size length: 1 to 8 octets
- Language codes: ISO 639-2 (3-letter) with optional country code
- Modern versions support BCP 47 language tags

**Metadata Support**
- Title, author, copyright information
- Creation date and software information
- Language specifications per track
- Track descriptions and names
- Chapter metadata
- Cue points for seeking

**Advantages for Forensics**
- Preservation of original codec data and bitstream integrity
- Metadata that may reveal processing history
- Support for preserving multiple versions/tracks
- Open standard allows complete forensic examination
- No codec re-encoding when used as container

**Forensic Considerations**
- Container itself doesn't alter codec compression
- Metadata can provide processing history clues
- Multiple tracks may indicate editing operations
- Chapter data and timestamps may reveal manipulations
- Tool-specific metadata patterns identifiable

**Implementation Status**
- Wide player support (VLC, MPC-HC, Kodi, etc.)
- FFmpeg full support
- Cross-platform compatibility
- Hardware support growing (Windows Media Foundation, etc.)

---

## Part 3: Comparison Matrix - Double Compression Detection Capability

| Codec | Detection Status | Primary Methods | Maturity Level | Key Challenges |
|-------|-----------------|-----------------|----------------|-----------------|
| **H.264** | Well-established | VPF, GOP analysis, DCT histograms, encoder descriptors | Mature | Aligned vs non-aligned GOP, same QP scenarios |
| **H.265/HEVC** | Well-established | PU statistics, DCT analysis, CU structures, B-frame analysis | Mature | B-frame complexity, varied encoding modes, same QP |
| **H.266/VVC** | Emerging | MTT structure analysis (theoretical) | Early research | Very limited literature, complex block partitioning |
| **AV1** | Minimal/Emerging | No dedicated methods published | Pre-research | Complex transforms, flexible partitioning, few forensic tools |
| **MKV Container** | Container-agnostic | Metadata analysis, encoder fingerprinting | Codec-dependent | Codec within container determines feasibility |

---

## Part 4: Technical Approaches to Double Compression Detection

### 4.1 Non-Machine Learning Approaches (As Per Your Focus)

#### 1. Variation of Prediction Footprint (VPF) Analysis
- **Principle**: Analyzes periodicity in macroblock type distribution
- **Mechanism**: Fixed GOP causes predictable patterns in prediction residuals
- **Detection**: Fourier analysis reveals periodic components from double compression
- **Advantage**: No threshold tuning, fully automatic
- **Applicability**: H.264, HEVC, MPEG-2
- **Limitation**: Requires different GOP sizes between compressions

#### 2. Encoding Mode Frequency Analysis
- **Principle**: Hardware encoders use subset of available encoding modes
- **Method**: Compares mode usage between test video and known encoder samples
- **Advantage**: Source encoder identification possible
- **Application**: Differentiates between original device encoding and re-encoding

#### 3. DCT Coefficient Histogram Analysis
- **Principle**: Quantization introduces statistical patterns in frequency domain
- **Method**: Analyzes distribution of quantized DCT coefficients
- **Markers**: Periodic patterns in coefficient distributions indicate double compression
- **Metrics**: Co-occurrence matrices of DCT values at specific frequencies

#### 4. Prediction Unit (PU) and Coding Unit (CU) Statistics
- **For HEVC**: Analyzes distribution of PU sizes and types
- **For HEVC**: CU depth patterns change with recompression
- **Markers**: Specific size distributions typical of recompressed content

#### 5. Motion Vector Field Analysis
- **Principle**: Motion prediction patterns change during recompression
- **Method**: Analyzes motion vector distribution and consistency
- **Application**: Particularly useful for low-motion and static-background videos

#### 6. Quantization Parameter (QP) Effects
- **Principle**: QP variation between compressions creates detectable artifacts
- **Method**: Analyzes how QP affects block statistics across frames
- **Limitation**: Challenging when both compressions use same QP

#### 7. Macroblock Type Distribution
- **Principle**: Distribution of I-MB, P-MB, S-MB types follows predictable patterns
- **Method**: Statistical analysis of macroblock classification sequences
- **Advantage**: Works without threshold tuning

---

## Part 5: Key Research Centers & Resources

### Universities and Research Institutions
- **Fraunhofer HHI (Germany)**: Leading VVC/H.266 and HEVC research
- **University of Vigo (Spain)**: VPF analysis pioneers (Vázquez-Padín, Pérez-González)
- **University of Firenze (Italy)**: HEVC forensics research (Piva, Fontani, Shullani group)
- **Université Côte d'Azur (France)**: H.264 a contrario detection (Li, Colom, Morel group)

### Open Source Tools and Code
- **gop_detection** (GitHub: li-yanhao): H.264 a contrario double compression detection
- **GVPF** (GitHub: IAPP-Group): Generalized VPF for video integrity verification
- **VVenC/VVdeC** (Fraunhofer HHI): VVC encoder/decoder implementations
- **FFmpeg**: Comprehensive multimedia framework supporting all codecs
- **GPAC**: VVC integration and multimedia processing

### Professional Tools Implementing Research
- **Amped Authenticate**: Implements VPF analysis for forensic video examination
- **Belkasoft eDiscovery**: Compression artifact analysis capabilities

---

## Part 6: Literature Review: Recent Trends (2024-2025)

### Emerging Areas
1. **B-frame Double Compression Detection**: First dedicated HEVC B-frame study (2025)
2. **H.266/VVC Forensics**: Beginning of research into newest standard
3. **AV1 Forensic Analysis**: Limited but growing research interest
4. **Multi-codec Analysis**: Comparative frameworks across standards
5. **Temporal Analysis Methods**: LSTM-based approaches gaining adoption

### Challenges Under Active Investigation
- Same quantization parameter (same QP) double compression detection
- Variable GOP size scenarios
- Different bitrate combinations
- Cross-codec detection (e.g., H.264 to H.265 transcoding)
- Real-world platform processing (social media, streaming services)

---

## Part 7: Recommended Research Path

### For Comprehensive Forensic Analysis:
1. **Start with H.264**: Most established literature, mature detection methods
   - Implement/study VPF analysis
   - Study GOP-based detection
   
2. **Progress to H.265/HEVC**: Widely deployed, good research availability
   - Study PU/CU statistics
   - Focus on B-frame handling
   - Study same-QP scenarios
   
3. **Investigate H.266/VVC**: Emerging standard
   - Limited existing work
   - Opportunity for novel contributions
   - Study MTT structure forensics
   
4. **Explore AV1**: Future codec
   - Minimal forensic literature
   - Advanced transforms and partitioning present challenges
   - Early research opportunity
   
5. **Container Analysis**: MKV metadata and structural forensics
   - Complement codec analysis
   - Identify processing history
   - Source tool fingerprinting

---

## Part 8: Document Access Notes

All referenced documents are available through:
- **Academic Databases**: arXiv.org, IEEE Xplore, MDPI, PMC NCBI
- **Institutional Repositories**: University websites, Research group pages
- **Open Source**: GitHub repositories with public code
- **Standards Bodies**: ITU-T, ISO/IEC, IETF RFCs
- **Professional Publications**: Fraunhofer HHI, Forensic Focus

### Key Open Access Resources:
- **arXiv**: Preprints of research papers
- **GitHub**: Open source implementations
- **Zenodo**: Research data and papers with DOI
- **Official Standards**: ITU-T Recommendations, ISO specifications available for purchase or public review

---

## Conclusion

The field of video double compression detection is most mature for H.264 and H.265 codecs, with well-established non-machine learning methods (particularly VPF analysis). Detection capability decreases significantly for newer codecs (H.266/VVC) and emerging formats (AV1), presenting opportunities for novel research. The container format (MKV) itself is codec-agnostic but can provide supplementary forensic information through metadata and structural analysis.

For forensic practitioners, starting with proven H.264/H.265 methods using tools like Amped Authenticate or implementing VPF analysis provides immediate practical capabilities. Researchers should focus on emerging standards where the forensic toolset is underdeveloped.
