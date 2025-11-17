# Video Codec Architecture, Compression Artifacts, and Forensic Exploitation
## Comprehensive Document Repository

---

## Part 1: H.264/AVC (Advanced Video Coding) - Codec Architecture & Forensics

### 1.1 Codec Architecture Overview

**H.264/AVC Standard Specifications**
- **Official Standards**: ITU-T H.264 (February 2016) | ISO/IEC 14496-10
- **Standardization**: Joint Video Team (JVT) of ISO/IEC MPEG and ITU-T VCEG
- **Also Known As**: MPEG-4 Part 10 | MPEG-4 AVC
- **Publication Date**: May 2003 (baseline), ongoing updates

**Core Compression Architecture**

1. **Block-Based Motion Compensation**
   - Motion estimation and compensation at block level
   - Variable block sizes: 16×16, 16×8, 8×16, 8×8 pixels
   - Sub-macroblock partitions: 8×8, 8×4, 4×8, 4×4 pixels
   - 7 different inter-prediction block size combinations
   - Integer-pel and fractional-pel motion vectors

2. **Macroblock Structure (Fundamental Unit)**
   - Fixed size: 16×16 pixels for luminance
   - Chroma blocks: 8×8 pixels for 4:2:0 sampling
   - Each macroblock can be:
     - I-MB (Intra coded)
     - P-MB (Inter predicted from one reference picture)
     - B-MB (Bi-directional predicted)
     - Skip MB (Motion vector and residual approximated)

3. **Transform Coding**
   - Integer Discrete Cosine Transform (integer DCT)
   - 4×4 blocks: Primarily used for luma residuals
   - 8×8 blocks: Optional, uses Hadamard transform for DC coefficients
   - No multiplication required (fixed-point arithmetic)
   - Reduces computational complexity vs. floating-point DCT

4. **Quantization Process**
   - Quantization Parameter (QP): Values 0-51
   - QP doubles every 6 increments (logarithmic structure)
   - Scalar quantization with variable step size
   - Different QP per macroblock possible (spatially varying)
   - Directly impacts compression ratio and visual quality

5. **Entropy Coding Methods**
   - **CAVLC** (Context-Adaptive Variable Length Coding)
     - Simple variable-length codes
     - Adapted based on context
     - Lower complexity, moderate compression
   - **CABAC** (Context-Adaptive Binary Arithmetic Coding)
     - Binary arithmetic coding
     - Multiple context models
     - 10-15% better compression than CAVLC
     - Higher computational cost

6. **In-loop Filtering**
   - Deblocking filter applied during encoding
   - Reduces blocking artifacts at macroblock boundaries
   - Applied to both horizontal and vertical edges
   - Adaptive filter strength based on QP
   - Two filter strength parameters for each edge

7. **Intra Prediction Modes**
   - 4×4 intra prediction: 9 directional modes
   - 16×16 intra prediction: 4 modes (vertical, horizontal, DC, plane)
   - Neighboring pixel prediction
   - Spatial redundancy reduction

8. **Inter Prediction**
   - Multiple reference frames (up to 16)
   - Variable block sizes for motion estimation
   - Quarter-pel accuracy motion vectors
   - Weighted prediction for temporal consistency
   - List prioritization (List 0, List 1)

**Reference Material**: ITU-T Recommendation H.264 specification (2016), MPEG-4 Part 10 standard

### 1.2 H.264 Compression Artifacts

#### Blocking Artifacts (Most Common)
- **Cause**: Independent coding of 16×16 macroblocks with discontinuous edges
- **Mechanism**: Quantization removes high-frequency components at block boundaries, creating visible step transitions
- **Visual Manifestation**: Grid-like pattern appearing across frames, especially visible at low bitrates
- **QP Dependency**: More pronounced with higher QP values
- **Detection Forensic Value**: Periodic artifact patterns at 16-pixel intervals indicate specific compression history

#### Blurring Artifacts
- **Cause**: High quantization parameter (high QP) eliminates high-frequency DCT coefficients
- **Mechanism**: Low-frequency components dominate after quantization, smoothing edges
- **Visual Effect**: Loss of fine details, edge softening
- **Critical QP Threshold**: Becomes visible at QP > 35
- **Forensic Implication**: Degree of blur correlates with quantization strength during encoding

#### Ringing Artifacts (Gibb's Effect)
- **Cause**: Oscillations around edges from truncated DCT expansions
- **Mechanism**: High-frequency components quantized to zero, creating undershoot/overshoot near sharp transitions
- **Visual Pattern**: Wavy distortions around object edges
- **QP Relationship**: More severe with higher QP values
- **Forensic Significance**: Asymmetric ringing patterns may indicate manipulation at specific frame regions

#### Staircase Artifacts
- **Cause**: Blocking combined with directional edge representation
- **Mechanism**: Smooth diagonal lines appear as staircases due to rectangular macroblock boundaries
- **QP Dependency**: Proportional to quantization parameter
- **Perceptual Significance**: Highly noticeable in diagonal lines, text, and edges

#### Mosquito Noise (Temporal Flickering)
- **Cause**: Alternating block boundary artifacts across consecutive frames
- **Mechanism**: Variable macroblock QP values create temporal inconsistency
- **Temporal Pattern**: Artifacts "flicker" as different blocks are encoded differently frame-to-frame
- **Detection Method**: Temporal noise analysis across frame sequences
- **Forensic Value**: Temporal pattern indicates specific encoder behavior

#### Basis Function Artifacts
- **Cause**: Single non-zero DCT coefficient after high quantization
- **Mechanism**: Block coded with only one basis function remaining after quantization
- **Visual Result**: Checkerboard or basis pattern visible
- **QP Threshold**: Appears at very high QP (>45) or low bitrates
- **Reconstruction**: Inverse transform produces basis function pattern (checkerboard)

### 1.3 H.264 Forensic Exploitation Techniques

#### 1.3.1 Macroblock Type Distribution Analysis
**Principle**: Different encoding scenarios produce different distributions of macroblock types.

**Forensic Application**:
- **Original Encoding**: Natural distribution of I-MB, P-MB, B-MB, Skip based on content
- **Re-encoding (Double Compression)**: First compression forces I-frames at GOP boundaries, altering MB type distribution
- **Detection Method**: Statistical analysis of MB type frequencies
- **Feature Vector**: Count of each MB type per frame normalized by frame size
- **Advantage**: Works across different GOP structures

**Exploitation Strategy**:
```
Calculate histograms of:
- I-MB (Intra macroblock) percentage
- P-MB (Predicted macroblock) percentage  
- B-MB (Bi-predicted macroblock) percentage
- Skip macroblock percentage

Compare against known encoder profiles
Identify anomalies indicating double compression
```

#### 1.3.2 Motion Vector Field Analysis
**Principle**: Motion vectors reveal compression history through distribution patterns.

**Forensic Significance**:
- **Zero Motion Vectors**: Encoded blocks with no motion typically indicate low activity areas or static content
- **Vector Distribution**: Quantization during first encoding creates residual patterns in MVs
- **Motion Consistency**: Discontinuities indicate re-encoding artifacts
- **MV Magnitude Statistics**: First compression affects MV distribution
- **Detection Feature**: Motion vector histogram analysis per frame

**Exploitation Method**:
```
Extract motion vectors for each inter-coded macroblock
Analyze:
- Distribution of MV magnitudes (0, 1-2 pixels, >2 pixels)
- Percentage of zero MVs vs. non-zero MVs
- Spatial consistency of MV fields
- Temporal consistency of MV patterns across frames

Double compression creates deviation from original encoder profiles
```

**Reference Document**: "Efficient Temporally-Aware DeepFake Detection using H.264 Motion Vectors" (Grönquist et al., 2023)
- Shows H.264 motion vectors effectively capture temporal inconsistencies
- Demonstrates motion vectors from compressed bitstream without pixel decoding

#### 1.3.3 DCT Coefficient Histogram Analysis
**Principle**: Quantization creates periodic patterns in DCT coefficient distributions.

**Forensic Mechanism**:
- **First Compression**: Quantizes DCT coefficients with step size \(q_1\)
- **Decompression**: Loss of information at quantization boundaries
- **Re-quantization**: Second compression with step size \(q_2\)
- **Result**: Double quantization creates characteristic histogram peaks at multiples of \(q_1 \times q_2\)

**Exploitation for H.264**:
```
1. Extract DCT coefficients from compressed bitstream (no full decompression needed)
2. Build histograms at specific frequency bands
3. Analyze periodic patterns:
   - Single compression: Peaks at multiples of single QP
   - Double compression: Double-periodic patterns emerge
   - Peak positions reveal first quantization parameter

4. Feature vectors from DCT histograms:
   - DC component (frequency 0,0) distribution
   - AC components at corners (high-frequency)
   - AC components at edges (mid-frequency)
   - Co-occurrence matrices across frequency bands
```

**Reference Document**: "DHNet: Double MPEG-4 Compression Detection via Multiple DCT Histograms" (Nam et al., IEEE MultiMedia 2021)
- Demonstrates DCT histogram effectiveness for MPEG-4 (similar structure to H.264)
- Neural network learns patterns invisible to traditional statistical analysis

#### 1.3.4 Variation of Prediction Footprint (VPF) Analysis
**Principle**: Motion prediction residuals show periodic patterns from GOP structure.

**H.264 VPF Mechanism**:
- **GOP Structure**: Fixed I-frame interval creates predictable patterns
- **First Compression**: Encodes with GOP length \(G_1\)
- **After Decompression**: Residual patterns reflect original GOP boundaries
- **Re-encoding**: Second compression with different GOP \(G_2\) creates visible periodicity
- **Detection**: Fourier analysis reveals periodic components at original GOP frequency

**Forensic Exploitation**:
```
Extract prediction residuals (difference between prediction and actual values)
Analyze frame-by-frame variation patterns
Compute periodogram (power spectral density)

Results:
- Single compression: Smooth periodogram
- Double compression: Sharp peaks at 1/G₁ (inverse of first GOP)
- Frequency of peaks directly indicates first GOP length
- Enables identification of encoding history
```

**Advantage**: Works when GOP sizes differ between compressions, no threshold tuning needed

**Reference Document**: "A Contrario Detection of H.264 Video Double Compression" (Li et al., ICIP 2023, Zenodo 2023)
- Novel a contrario framework automatically detects double compression
- Exploits GOP-based periodicity of frame residuals
- Open source code available: https://zenodo.org/records/8373063

#### 1.3.5 Encoder Mode Selection Analysis
**Principle**: Different hardware encoders preferentially select specific coding modes.

**Forensic Exploitation**:
- **Hardware Encoder Profiling**: Each encoder implementation has characteristic mode selection patterns
- **Subset Usage**: Encoders typically use subset of available modes based on implementation
- **Pattern Recognition**: Compare test video mode usage against known encoder profiles
- **Source Identification**: Identifies specific encoder software/hardware used

**Exploitation Method**:
```
For each coded unit:
1. Extract coding mode selection (Intra mode, Inter partition size, etc.)
2. Build mode frequency histogram
3. Compare against encoder profiles:
   - Software encoders (FFmpeg, x264, x265): Specific optimization characteristics
   - Hardware encoders: Subset of modes used, specific parameter defaults
   - Mobile encoders: Resource constraints affect mode selection

4. Calculate deviation from known profiles
5. Indicates specific encoder or re-encoding operation
```

**Reference Document**: "Detection of Double-Compressed Videos Using Descriptors of Video Encoders" (Lee et al., 2022)
- Compares encoding mode usage for double compression detection
- H.264 and HEVC encoders analyzed
- Achieves differentiation between original and re-encoded videos

#### 1.3.6 Splicing Detection via Compression Artifacts
**Principle**: Spliced regions have different compression history than surrounding content.

**Forensic Mechanism**:
- **Splice Boundary**: Transition point between two video sources
- **Artifact Mismatch**: Different original compressions create visible artifact differences
- **DCT Histogram Discontinuity**: Histogram changes at splice boundary
- **Motion Vector Discontinuity**: MV patterns differ at boundary

**Exploitation Method**:
```
Analyze DCT coefficient histograms across frame spatially:
- Divide each frame into regions
- Compute DCT histograms per region
- Detect sudden changes in histogram statistics at boundaries
- Peaks in feature change map indicate splice location

Temporal analysis:
- Compute motion field consistency
- Splices show motion field discontinuities
- Sudden changes in prediction accuracy
```

**Reference Document**: "CAT-Net: Compression Artifact Tracing Network for Detection and Localization of Image Splicing"
- Demonstrates DCT coefficient-based splicing detection
- Periodic patterns in DCT histograms indicate authentic regions
- Method extends to video frames

#### 1.3.7 Ghost Artifacts for Tampering Detection
**Principle**: Modifying decoded content and re-encoding creates double quantization artifacts.

**Forensic Mechanism**:
- **Original Quantization**: \(q_1\) with quantization step \(\Delta_1\)
- **Tampering**: Modify decoded frame (uncompressed state)
- **Re-quantization**: \(q_2\) with different step \(\Delta_2\)
- **Result**: Ghost artifacts visible at quantization boundaries where \(q_1 \neq q_2\)

**Exploitation**:
```
1. Look for regions with double DCT quantization traces
2. Ghost artifacts appear as slight value misalignment at block boundaries
3. Tampered regions have different quantization history than surrounding pixels
4. Detection score = deviation from consistent quantization pattern

Assumption: Re-encoding at lower quality than original produces detectable artifacts
If q₂ > q₁ (lower quality re-encoding): Clear ghost artifact traces
If q₂ ≤ q₁ (same/higher quality): More subtle, may not be detected
```

**Reference Document**: "Detecting Deepfakes in H.264 Video Data Using Compression Ghost Artifacts" (Frick et al., Fraunhofer Institute 2020)
- Applies ghost artifact method to H.264 deepfake detection
- Detects face-swapped regions based on quantization inconsistencies
- Face2Face and other manipulation techniques leave detectable traces

### 1.4 Key H.264 Forensic Papers & References

1. **"Digital Video Manipulation Detection Technique Based on Compression Algorithms"** (arXiv 2024)
   - Analyzes H.264 macroblock information and motion vectors
   - SVM classifier for manipulation detection
   - Features: MB types, MV statistics

2. **"Efficient Temporally-Aware DeepFake Detection using H.264 Motion Vectors"** (Grönquist et al., arXiv 2023)
   - Motion vector analysis from compressed bitstream
   - Real-time detection without full decompression
   - Demonstrates temporal inconsistencies in deepfakes

3. **"A Contrario Detection of H.264 Video Double Compression"** (Li et al., ICIP 2023)
   - VPF-based automatic detection
   - No threshold tuning required
   - Open source implementation available

4. **"Detecting Deepfakes in H.264 Video Data Using Compression Ghost Artifacts"** (Frick et al., 2020)
   - Ghost artifact method for H.264
   - Tampering localization at frame region level
   - FaceForensics++ dataset validation

---

## Part 2: H.265/HEVC (High Efficiency Video Coding) - Codec Architecture & Forensics

### 2.1 HEVC Codec Architecture Overview

**HEVC/H.265 Standard Specifications**
- **Official Standards**: ITU-T H.265 (2013, updated regularly) | ISO/IEC 23008-2 (MPEG-H Part 2)
- **Developer**: Joint Collaborative Team on Video Coding (JCT-VC)
- **Key Goals**: 50% bitrate reduction vs H.264 at same quality
- **Compression Efficiency**: 2× bitrate reduction compared to H.264

**Revolutionary Architectural Change: Macroblock → Coding Tree Unit**

The fundamental shift from H.264's fixed 16×16 macroblocks to HEVC's flexible Coding Tree Units (CTUs) is the primary architectural change enabling HEVC's efficiency gains.

**1. Hierarchical Block Structure (Quad-Tree Decomposition)**

**Coding Tree Unit (CTU) - Top Level**:
- **Fixed Size**: 16×16, 32×32, or 64×64 pixels (typically 64×64 in modern implementations)
- **Alternative**: 16×16 for low-complexity profiles
- **Flexibility**: Can be recursively split or processed as single unit
- **Decision**: Quad-tree decomposition determines optimal partitioning

**Coding Unit (CU) - Second Level**:
- **Sizes**: CTU recursively split to create CUs: 64×64, 32×32, 16×16, 8×8 pixels
- **Quad-Tree Recursive**: Each larger CU can split into 4 equal-sized sub-CUs
- **Minimum Size**: 8×8 pixels (typically, can be 4×4 in intra)
- **Optimization**: Complex areas split more, simple areas use larger CUs
- **Spatial Adaptation**: Enables fine grain encoding of complex regions

**Prediction Unit (PU) - Prediction Level**:
- **Intra-PU Modes**: Directional prediction from neighboring samples
- **Inter-PU Modes**: Block sizes for motion prediction (2N×2N, N×2N, 2N×N, etc.)
- **Partition Flexibility**: PU size independent of CU size (within constraints)
- **Purpose**: Determines prediction signal for residual calculation

**Transform Unit (TU) - Transform Level**:
- **Nested Quad-Tree**: Separate quad-tree from CU partitioning
- **Transform Sizes**: 4×4, 8×8, 16×16, 32×32 pixels
- **Independence**: TU boundaries don't align with CU/PU boundaries
- **Residual Transformation**: Applied to prediction residuals

**Forensic Implication - Block Structure Artifacts**:
```
CU/PU/TU structure creates detectable patterns:
- CU size distribution reflects content complexity
- First compression changes CU size selection (smoothing effect)
- Re-encoding creates different CU patterns
- PU type distribution (intra vs inter) changes with double compression
- TU size patterns altered by quantization noise from first compression
```

**2. Advanced Prediction Mechanisms**

**Intra Prediction (35 Modes)**:
- **DC Mode (0)**: Average of neighboring samples
- **Planar Mode (1)**: Interpolation from four sides
- **Angular Modes (2-34)**: 33 directional prediction modes
- **Mode Selection**: Rate-distortion optimization selects best mode
- **Neighboring Dependency**: Uses already-encoded left and top samples
- **High Directional Specificity**: Captures directional patterns efficiently

**Forensic Artifact**:
```
Intra-prediction mode distribution:
- Original encoding: Natural distribution based on content
- Double compression: First compression quantization affects neighboring pixels
  → Mode selection changes in re-encoding
- Detection: Analyze mode frequency histogram
- Feature: Count modes 0-34 per frame, normalized by CU count
```

**Inter Prediction (Advanced)**:
- **Multiple Reference Frames**: Up to 16 reference pictures
- **Variable Block Sizes**: More flexible than H.264 (2N×2N down to 4×4)
- **Bilateral Prediction**: Both forward and backward references
- **Weighted Prediction**: Temporal weighting for better compression
- **Sample-Adaptive Offset (SAO) Filtering**: Non-linear filtering after deblocking

**3. Transform and Quantization**

**Transform Types**:
- **Integer DCT**: Similar to H.264 but larger sizes (up to 32×32)
- **DST (Discrete Sine Transform)**: For 4×4 intra blocks
- **Multiple Sizes**: 4×4, 8×8, 16×16, 32×32 possible
- **Implicit Transform**: Determined by CU/TU size and prediction mode

**Quantization Parameter (QP)**:
- **Range**: 0-51 (same as H.264)
- **Logarithmic**: Step size doubles every 6 increments
- **Spatial Variation**: Different QP per coding unit possible
- **Chroma QP**: Derived from luma QP via lookup tables

**Forensic Artifact - DCT Coefficient Distribution**:
```
HEVC DCT characteristics:
- Larger transform sizes create smoother coefficient distributions
- Different quantization effects at different transform sizes
- Coefficient histograms show periodic patterns at quantization boundaries
- Double compression creates nested periodicity in histograms
```

**4. Entropy Coding**

**CABAC (Context-Adaptive Binary Arithmetic Coding)**:
- **Only Method**: HEVC uses only CABAC (no CAVLC)
- **Context Modeling**: Advanced adaptive probability models
- **10-15% Improvement**: Over H.264's CAVLC
- **Computational Cost**: Higher encoder complexity than CAVLC

### 2.2 HEVC Compression Artifacts

#### Blocking Artifacts (Similar to H.264 but different scale)
- **Mechanism**: CTU/CU boundaries create discontinuities
- **Difference from H.264**: 
  - Larger block sizes (up to 64×64) can create larger blocking artifacts
  - Adaptive block size means artifacts appear at variable grid spacing
  - More subtle in well-encoded content due to better optimization
- **Detection**: Artifacts at 8×8, 16×16, 32×32, 64×64 pixel intervals
- **Forensic Difference**: Mixed block size boundaries create irregular patterns vs. H.264's regular 16×16 grid

#### Blurring Artifacts
- **Cause**: High quantization removes high-frequency components
- **Mechanism**: Larger transform sizes (32×32) amplify blurring effect
- **Impact**: More pronounced on smooth regions due to adaptive CU sizing
- **QP Dependency**: Same as H.264 - threshold around QP > 35

#### Color Bleeding Artifacts
- **Cause**: Chrominance (color) components compressed more than luminance
- **Mechanism**: Chroma samples at lower spatial resolution (4:2:0 sampling)
- **Visual Effect**: Colors "bleed" across boundaries during reconstruction
- **Forensic Significance**: Indicates specific encoder behavior, potential manipulation indicator

#### Ringing Artifacts
- **Extended Range**: Larger transform sizes increase potential ringing
- **Sharper Appearance**: More pronounced than H.264
- **Edge Emphasis**: Around high-contrast transitions

#### Flickering (Temporal Pumping)
- **Cause**: Variable CU/QP selection across frames
- **Temporal Pattern**: Artifacts vary frame-to-frame
- **Detection**: Analyze CU structure consistency across consecutive frames

### 2.3 HEVC Forensic Exploitation Techniques

#### 2.3.1 Prediction Unit (PU) Type Distribution Analysis
**Principle**: PU type distribution reveals compression history.

**PU Types in HEVC**:
- **Intra-PU**: Self-prediction, indicates static/detailed regions
- **Inter-PU Skip**: Zero motion, indicates still regions
- **Inter-PU Merge**: Motion compensation with merge candidates
- **Inter-PU AMVP**: Explicit motion vectors
- **Symmetric vs Asymmetric**: Different partition types

**Forensic Exploitation**:
```
Extract PU type distribution:
- Count each PU type per frame
- Calculate ratio of intra to inter PUs
- Analyze Skip mode usage (percentage of CUs)

Double compression indicators:
- First compression: Introduces quantization noise
- Noise acts like texture: Increases mode selection complexity
- Re-encoding: Mode selection changes significantly
- Detection: Deviation from known encoder profiles

Feature Vector Construction:
- Intra PU percentage
- Skip mode percentage  
- Merge mode vs AMVP ratio
- Inter-symmetric vs asymmetric partition ratio
```

**Reference Document**: "Detection of Double Compression in HEVC Videos Containing B-Frames" (Furushita et al., 2025, PMC NCBI)
- First study on B-frame handling in HEVC double compression
- Bi-LSTM classifier analyzing frame-level features including CU types
- Achieves 80.06% accuracy detecting double compression

#### 2.3.2 Coding Unit (CU) Size Distribution
**Principle**: CU size distribution reflects content complexity and compression history.

**Forensic Mechanism**:
- **Original Encoding**: CU sizes selected based on actual content complexity
- **Quantization Noise**: First compression introduces noise-like artifacts
- **Re-encoding**: Noise causes different CU size selection (typically smaller CUs)
- **Feature**: Histogram of CU sizes per frame

**Exploitation Method**:
```
For each frame:
1. Extract CU sizes (8×8, 16×16, 32×32, 64×64)
2. Calculate percentage distribution of each size
3. Build histogram normalized by total CU count

Analysis:
- Large CU percentage (64×64): Smooth regions
- Mixed sizes: Detailed regions
- Double compression: Shifts distribution toward smaller CUs
- Reason: Quantization noise increases apparent complexity

Detection:
- Compare CU distribution to known encoder profiles
- Original: Typically 30-40% 64×64 CUs
- Double compressed: May shift to 50%+ smaller CUs
```

#### 2.3.3 Transform Unit (TU) Size Statistics
**Principle**: Transform size distribution changes with compression history.

**Forensic Exploitation**:
```
TU size distribution analysis:
- 4×4: Highest frequency (typical 50-70%)
- 8×8: Medium frequency (20-40%)
- 16×16: Lower frequency (5-15%)
- 32×32: Rare (1-5%)

Double compression effects:
- Quantization noise increases high-frequency content perception
- Encoder selects smaller TUs for better residual capture
- Distribution skews toward 4×4 and 8×8 TUs

Feature vector:
- Percentage of each TU size
- TU size histogram at different CU levels
- Co-occurrence of TU and CU sizes
```

#### 2.3.4 Intra Prediction Mode Analysis
**Principle**: Intra mode selection distribution reveals encoder behavior and compression history.

**Intra Mode Distribution in HEVC**:
- **DC Mode (0)**: Flat/uniform regions
- **Planar Mode (1)**: Smooth gradients
- **Directional Modes (2-34)**:
  - Horizontal direction modes (10, 25)
  - Vertical direction modes (26, 34)
  - Various angular modes

**Forensic Exploitation**:
```
Build intra mode frequency histogram:
- Count usage of each mode (0-34)
- Normalize by total intra-predicted CUs
- Analyze mode selection patterns

Double compression signature:
- First compression: Creates quantization boundaries
- Boundaries act as artificial directional patterns
- Re-encoding: Mode selection skewed toward specific angles
- Particularly affected: Modes 10, 18, 26 (cardinal directions)

Feature extraction:
- Mode frequency histogram (35-D vector)
- Mode distribution statistics (entropy, variance)
- Ratio of cardinal modes to diagonal modes
- Mode clustering around specific angles

Detection approach:
- Compare against known encoder profiles
- Statistical deviation indicates re-encoding
- Mode selection pattern fingerprints specific encoder
```

**Reference Document**: "Exposing Video Compression History by Detecting Transcoded HEVC Videos from AVC Coding" (MDPI 2019)
- Uses PU statistics and prediction mode analysis
- Distinguishes AVC-to-HEVC transcoding
- Mode selection patterns differ between codecs

#### 2.3.5 DCT Coefficient Histogram at Multiple Resolutions
**Principle**: Co-occurrence matrices of DCT coefficients reveal quantization patterns.

**Forensic Method**:
```
Build co-occurrence matrices of DCT coefficients:
1. Extract transform coefficients at different scales
2. Create 5×5 co-occurrence matrices:
   - Horizontal neighbors: One pixel separation
   - Vertical neighbors: One pixel separation
   - Main diagonal neighbors
   - Minor diagonal neighbors

3. Calculate statistics:
   - Correlation values
   - Entropy measures
   - Distribution peaks at quantization boundaries

Double compression detection:
- Single compression: Smooth distribution
- Double compression: Periodic peaks at double quantization intervals
- QP recovery: Peak spacing reveals first quantization parameter
```

**Reference Document**: "Double HEVC Compression Detection with Different Bitrates Based on Co-occurrence Matrix of PU Types and DCT Coefficients" (ITM Conferences)
- Combines PU type co-occurrence with DCT analysis
- Handles different bitrates between compressions
- Achieves high accuracy distinguishing single vs. double compression

#### 2.3.6 B-Frame Specific Analysis
**Principle**: B-frames (bi-directional prediction frames) provide unique forensic signatures.

**B-Frame Characteristics in HEVC**:
- **Multiple Reference Frames**: Forward and backward references
- **Complex Prediction**: Weighted combinations of multiple references
- **Prediction Mode Diversity**: I, P, and B frames all possible
- **Challenging for Forensics**: More complex prediction patterns

**Forensic Exploitation for Double Compression**:
```
B-Frame feature extraction:
1. Identify B-frames in sequence
2. Extract CU type distribution:
   - Intra-coded (BI)
   - Skip (BS)
   - Merged (BM)
   - Forward prediction (BP)
   - Bidirectional (BB)
   - Future prediction (BF)

3. Extract intra-prediction modes and directions (luminance/chrominance)

Double compression signature in B-frames:
- First compression: Constrains prediction reference availability
- Quantization noise: Changes optimal prediction mode selection
- Re-encoding: Different B-frame type distribution
- Feature: CU type ratios differ between single and double compression

Detection using Bi-LSTM:
- Temporal sequence of 28-dimensional vectors per frame
- Frame type, CU sizes, QP, prediction modes
- Bidirectional processing captures frame context
```

**Reference Document**: "Detection of Double Compression in HEVC Videos Containing B-Frames" (Furushita et al., 2025)
- 80.06% detection accuracy
- First systematic study of B-frame double compression
- Dataset: 129 HEVC videos from 43 original sequences
- Features: 28-D vector per frame for Bi-LSTM classifier

#### 2.3.7 Transcoding Detection (AVC→HEVC)
**Principle**: Transcoding from H.264 to H.265 leaves detectable traces.

**Forensic Mechanism**:
- **Different Block Structures**: AVC's fixed 16×16 vs. HEVC's adaptive CTU
- **Prediction Flexibility**: HEVC has more modes and larger transform sizes
- **Quantization History**: Original AVC quantization creates distinct patterns
- **Statistical Disruption**: AVC's regular blocks disrupt HEVC's adaptive optimization

**Exploitation**:
```
Detect AVC-to-HEVC transcoding:
1. Analyze CU size distribution
   - Original HEVC: Varied distribution based on content
   - Transcoded: Shows artifacts from AVC's fixed blocks
   
2. Check for AVC grid artifacts:
   - 16-pixel boundaries in CU divisions
   - Regular pattern at 16×16 spacing
   - Indicates previous AVC encoding

3. Quantization coefficient analysis:
   - Multi-level periodicity indicates previous quantization
   - Peak spacing reveals AVC QP levels
   
4. PU statistics:
   - Skewed toward certain partition sizes
   - Reflects AVC block constraints
```

**Reference Document**: "Exposing Video Compression History by Detecting Transcoded HEVC Videos from AVC Coding" (MDPI 2019)
- Uses PU statistics and DCT coefficient analysis
- Successfully distinguishes AVC-compressed then HEVC-transcoded from native HEVC
- Practical detection method for transcoding artifacts

#### 2.3.8 Fake Bitrate Detection
**Principle**: Videos falsely claiming high bitrate but upconverted from low-quality versions.

**Forensic Method**:
```
Feature extraction from prediction modes:
1. Intra-prediction mode frequency (35 modes):
   - Build histogram of mode usage
   - Deviation from expected distribution

2. PU partition distribution:
   - Histogram of PU types (HPP feature)
   - 25-D feature vector from PU partition statistics

3. Mode frequency features (PMF):
   - Intra-prediction mode frequencies from I-frames
   - Inter-prediction modes from P-frames (Skip, Merge, AMVP)
   - 10-D feature vector combining inter/intra features

Detection logic:
- High bitrate video but low-quality encoding signature
- Mismatch: High declared bitrate vs. low-bitrate encoding patterns
- Feature space shows clustering separating authentic from fake-bitrate videos
```

**Reference Document**: "A Review on HEVC Video Forensic Investigation under Compressed Domain" (MECS Press)
- Comprehensive review of fake bitrate detection methods
- Detection accuracies 95-99% depending on bitrate difference magnitude
- Survey of multiple feature approaches

### 2.4 Key HEVC Forensic Papers & References

1. **"Detection of Double Compression in HEVC Videos Containing B-Frames"** (Furushita et al., 2025)
   - First B-frame double compression study
   - Bi-LSTM classifier, 80.06% accuracy
   - 28-D feature vector per frame

2. **"Double HEVC Compression Detection with Different Bitrates Based on Co-occurrence Matrix of PU Types and DCT Coefficients"** (ITM Conferences)
   - Handles variable bitrates
   - Co-occurrence matrix analysis

3. **"Exposing Video Compression History by Detecting Transcoded HEVC Videos from AVC Coding"** (MDPI 2019)
   - AVC to HEVC transcoding detection
   - PU statistics exploitation

4. **"A Review on HEVC Video Forensic Investigation under Compressed Domain"** (MECS Press)
   - Comprehensive survey
   - Covers transcoding, fake bitrate, double compression detection

5. **"Understanding the Coding Tree Units Filter in Amped FIVE"** (Amped Software 2025)
   - Practical CTU analysis for forensic video analysis
   - Forensic tools implementation
   - CTU visualization for integrity analysis

6. **"H.265/HEVC: The Codec That Redefined Modern Surveillance"** (Hector Weyl 2025)
   - CTU architecture explained
   - Forensic implications of flexible block structure
   - Comparison with H.264 artifacts

---

## Part 3: H.266/VVC (Versatile Video Coding) - Emerging Forensics

### 3.1 VVC Codec Architecture (Forensic Perspective)

**H.266/VVC Standard**
- **Official Standards**: ITU-T H.266 | ISO/IEC 23090-3 (MPEG-I Part 3)
- **Finalized**: July 6, 2020
- **Developer**: Joint Video Experts Team (JVET)
- **Efficiency**: 30-50% bitrate reduction vs. HEVC
- **Complexity**: 10× encoding complexity vs. HEVC

**Revolutionary Architecture: Multi-Type Tree (MTT)**

Unlike HEVC's quad-tree, VVC introduces:

**Multi-Type Tree (MTT) Partitioning**:
- **Binary Tree (BT)**: Split into two equal parts (horizontal or vertical)
- **Ternary Tree (TT)**: Split into three parts (2:1 ratio)
- **Recursive Flexibility**: Enables more fine-grained partitioning
- **Maximum Size**: Up to 128×128 CTU down to 4×4 CU
- **Benefit**: Better adaptation to content patterns than quad-tree

**Forensic Implication**:
```
MTT creates unique partitioning signatures:
- More partition modes than HEVC (BT, TT vs. only quad-tree)
- Partition distribution reveals encoder behavior
- Re-encoding changes partition selection
- Binary/ternary split patterns detectable
- No forensic tools yet developed (emerging opportunity)
```

### 3.2 VVC Specific Encoding Tools (Forensic Relevance)

**1. Multiple Transform Selection (MTS)**
- **Flexibility**: Multiple transform types beyond DCT
- **Transforms**: DCT, DST, identity transforms
- **Size-Dependent**: Different transforms for different sizes
- **Forensic Feature**: Transform type selection histogram

**2. Intra-Picture Block Copy (IBC)**
- **Mechanism**: Copy coding units from already-encoded picture area
- **Application**: Intra-frame texture reuse
- **Forensic Relevance**: Block copy patterns indicate specific content/encoder

**3. Dependent Quantization (TCQ)**
- **Mechanism**: Trellis-coded quantization with state-dependent decisions
- **Benefit**: Better compression than standard scalar quantization
- **Forensic Feature**: Complex quantization trace patterns
- **Challenge**: More difficult to analyze than scalar quantization

**4. Chroma Residual Coding (JCbCr)**
- **Joint Coding**: Chrominance components coded jointly
- **Efficiency**: Better color compression
- **Forensic Implication**: Different DCT patterns than HEVC

### 3.3 VVC Forensic Challenges & Opportunities

**Current State**:
- **Minimal Research**: Very few published forensic methods for VVC
- **Immature Codec**: Recent standardization (2020)
- **Limited Implementation**: Few real-world VVC-encoded videos
- **Forensic Vacuum**: Opportunity for novel research

**Potential Forensic Approaches** (Theoretical):
```
1. MTT Partition Distribution Analysis
   - Extract partition tree structure
   - Analyze BT vs. TT frequency
   - Compare against known encoder profiles
   - Deviation indicates re-encoding

2. Multiple Transform Selection Patterns
   - Track which transforms selected
   - Build transform type histogram
   - First compression affects choice
   - Re-encoding creates different pattern

3. Intra Block Copy Exploitation
   - IBC references create unique spatial patterns
   - Copy source locations detectable
   - Re-encoding alters IBC usage
   - Forensic signature of specific encoder

4. Dependent Quantization Artifacts
   - State transitions leave traces
   - Trellis path patterns unique
   - Double compression affects state sequences
   - Quantization trace analysis (challenging)

5. Extended DCT Histogram Analysis
   - Multiple transform types create broader distributions
   - Periodic patterns still detectable
   - QP recovery more complex with TCQ
```

**Limitations**:
- Lack of forensic tools
- Insufficient research literature
- Limited training datasets
- Complex encoder parameters
- Difficult to analyze without source code access

**Reference Documents**:
- "Optimizing H.266/VVC Intra Coding with a Genetic Algorithm" (Ibraheem & Dvorkovich, 2024)
  - MTT partitions and optimization
  - Intra coding tools in VVC

- "Analysis of Next-Generation VVC/H.266 Standard for Gaming Content" (KIBME)
  - VVC coding tools impact
  - Intra block copy, multiple reference lines, matrix-based prediction

---

## Part 4: AV1 (AOMedia Video 1) - Emerging Codec with Minimal Forensic Research

### 4.1 AV1 Architecture Overview

**AV1 Standard**
- **Standardization**: Alliance for Open Media (AOM)
- **Royalty-Free**: Open standard, no licensing fees
- **Efficiency**: 30-50% better than H.264, comparable to H.265
- **Status**: Rapidly growing adoption in streaming services
- **Forensic Status**: **EXTREMELY LIMITED** existing forensic research

**Unique AV1 Architecture Elements**

**1. Superblock-Based Partitioning**
- **Superblock Size**: 128×128 or 64×64 pixels
- **Recursive Partitioning**: 10 different partition modes
  - Square 4-way split
  - Rectangular 2:1 and 1:2 splits
  - T-shaped partitions
  - 4:1 and 1:4 strips
- **Flexibility**: Unprecedented partition variety

**Forensic Implication**:
```
Partition mode distribution creates codec-specific signatures:
- 10 partition modes vs. HEVC's quad-tree
- Partition frequency histogram
- T-shaped patterns unique to AV1
- Re-encoding creates different mode selection
- Currently: No published detection methods
```

**2. Advanced Transform System**
- **Multiple Kernels**: 16 separable 2D transforms (not just DCT)
  - Discrete Cosine Transform (DCT)
  - Asymmetric Discrete Sine Transform (ADST)
  - Flexible ADST (fADST)
  - Identity (no transform)
- **Size Range**: 4×4 to 64×64 pixels
- **Implicit Selection**: Encoder determines optimal transform
- **Precision**: 10 or 12-bit internal processing

**Forensic Challenge**:
```
Multiple transforms complicate forensic analysis:
- DCT histograms cannot solely identify artifacts
- Different transforms create different coefficient distributions
- Quantization patterns specific to each transform type
- Currently undocumented forensically
- Requires transform-specific artifact models
```

**3. Advanced Prediction Modes**
- **Intra Prediction**: Extended modes beyond angle-based
- **Inter Prediction**: Advanced motion estimation
- **Compound Prediction**: Weighted blending of multiple predictors
- **Overlapped Block Motion Compensation (OBMC)**

**4. Internal Precision**
- **10-bit or 12-bit Processing**: Internal calculations at higher precision
- **Reduced Rounding Errors**: Better accuracy than 8-bit only processing
- **Compression Impact**: Improved quality at same bitrate
- **Forensic Implication**: Different artifact characteristics than 8-bit codecs

### 4.2 AV1 Compression Artifacts

**Artifact Types** (Theoretically similar to H.264/H.265 but different manifestation):

#### Blocking Artifacts
- **Different Scale**: Artifacts at variable-size block boundaries (4×4 to 128×128)
- **T-Shaped Boundaries**: Asymmetric boundaries create different patterns
- **Severity**: Generally less severe due to advanced partitioning
- **Detection**: Non-regular grid patterns

#### Blurring and Ringing
- **Multiple Transforms**: Different artifacts per transform type
- **Reduced Ringing**: ADST and specialized transforms reduce ringing
- **Trade-offs**: Different visual/artifact profile than DCT-only codecs
- **High Quantization**: Similar effect at high QP values

#### Transform-Specific Artifacts
- **DCT Regions**: Blocking and ringing where DCT used
- **ADST Regions**: Smoother transitions, potential direction-bias artifacts
- **Identity Transform**: Minimal transform-domain artifact
- **Detection**: Transform type inference from artifact patterns

### 4.3 AV1 Forensic Status and Challenges

**Current State of Research**:
- **No Published Double Compression Detection**: No dedicated methods found
- **Limited Forensic Papers**: Essentially zero on AV1 forensics
- **Emerging Codec**: Only recently deployed widely
- **Minimal Training Data**: Few forensic datasets with AV1 content
- **Codec Complexity**: Advanced features make analysis difficult

**Fundamental Obstacles**:
1. **Partition Mode Complexity**: 10 modes vs. simpler codecs
2. **Transform Diversity**: 16 different transforms
3. **Prediction Complexity**: Advanced prediction modes
4. **Limited Standards Access**: Complete spec understanding needed
5. **Lack of Forensic Tools**: No established analysis frameworks
6. **Emerging Adoption**: Limited real-world forensic datasets

**Theoretical Forensic Approaches** (Unvalidated):
```
Potential methods:
1. Partition mode distribution analysis
   - Frequency of 10 partition types
   - T-shaped pattern frequency
   - Comparison against encoder profiles

2. Transform type frequency analysis
   - Which transforms selected per block
   - DCT vs. ADST vs. identity usage
   - First compression affects selection

3. Motion vector analysis
   - Similar to H.264 but more complex prediction
   - Advanced motion compensation patterns
   - Consistency analysis across frames

4. Quantization level inference
   - High-precision internal processing makes analysis harder
   - Coefficient distributions less obvious
   - May require multiple-frame analysis

Challenge: No validation, no published datasets, no practical implementation
```

**Reference Material**:
- "An Overview of Core Coding Tools in the AV1 Video Codec" (Chen et al., 2021)
  - Partition structure and transform coding
  - Intra and inter prediction tools
  - Advanced compression techniques

- "A Technical Overview of AV1" (arXiv 2021)
  - Design principles for hardware feasibility
  - Compression techniques explanation
  - Decoder specifications

- "Complexity and Compression Efficiency Analysis of libaom AV1 Video Codec" (2023)
  - Encoding complexity analysis
  - Superblock partitioning cost
  - Inter-prediction and transform computational load

---

## Part 5: MKV Container Format - Metadata & Structural Forensics

### 5.1 MKV Forensic Significance

**MKV as Evidence Container**:
- **Codec-Agnostic**: Container doesn't re-encode contained codec streams
- **Metadata Preservation**: Processing history captured in metadata
- **Tool Fingerprinting**: Creation/modification tools leave traces
- **Forensic Value**: Metadata analysis reveals processing history

### 5.2 MKV Metadata Forensic Exploitation

**1. File Metadata Analysis**
- **Timecode Information**: Reveals frame timing and potential frame drops/duplications
- **Duration Metadata**: Comparison with actual frame count may reveal tampering
- **Segment Information**: Multiple segments indicate editing/concatenation

**2. Track-Specific Metadata**
- **Video Track Properties**: Codec information, resolution, frame rate
- **Audio Track Properties**: Codec, channels, sampling rate
- **Language Tags**: May indicate editing from multiple sources
- **Track Names**: Custom metadata may reveal source or editing software

**3. Application Metadata**
- **Writing Application**: Software that created the MKV
- **Muxing Application**: Tool used for container creation
- **Encoder Signature**: Information about video encoder
- **Modification History**: Tools that modified the file

**Forensic Interpretation**:
```
Metadata analysis:
- Writing app: "libebml v1.3.0 libmatroska v1.5.0" → FFmpeg/mkvtoolnix
- Muxing tool: Specific version reveals approximate creation date
- Codec: H.265 indicates newer encoding than H.264
- Multiple encoders in metadata: Indicates complex processing history
- Discrepancies: Writing app doesn't match codec version → external modification
```

**4. Cue Point Analysis**
- **Seeking Indices**: Cue points indicate seekable frame locations
- **Cue Track Positions**: Reference frame numbers for seeking
- **Forensic Use**: Missing cues or inconsistent cue point numbering indicates tampering
- **Frame Gap Detection**: Cue point spacing reveals deleted/inserted frames

**5. Chapter and Attachment Analysis**
- **Chapter Information**: Embedded chapter markers indicate editing breaks
- **Attachments**: Embedded fonts or images reveal editing software
- **Cover Art**: May contain metadata from original source
- **Forensic Value**: Unusual chapter structure indicates splicing/editing

### 5.3 Container-Level Forgery Indicators

```
MKV Forensic Signatures:

1. Timestamp Inconsistencies:
   - Container duration vs. actual frame count
   - Timecode discontinuities indicating deleted frames
   - Frame rate mismatches

2. Codec-Container Mismatch:
   - Declared codec doesn't match actual bitstream
   - Metadata altered after encoding
   - Tool-specific codec parameters inconsistent

3. Multiple Codec Metadata:
   - Evidence of multiple encoders
   - SPS/PPS (sequence/picture parameter sets) from different encoders
   - Indicates transcoding or editing

4. Writing Application Anomalies:
   - Unknown/suspicious writing tools
   - Version mismatches with codec generation date
   - Discrepancies between stated and actual tools

5. Attachment Evidence:
   - Tools/fonts from specific software
   - Creation dates of attachments
   - Software-specific binary signatures
```

### 5.4 Combined MKV + Codec Analysis

**Integrated Forensic Approach**:
```
1. Extract container metadata
   - Identify writing/muxing applications
   - Extract codec parameter sets (SPS/PPS for H.264/H.265)
   
2. Analyze contained codec bitstream
   - Apply codec-specific forensic methods (VPF, DCT histograms, etc.)
   - Verify codec metadata matches actual bitstream
   
3. Cross-validation:
   - Container metadata consistency with codec stream
   - Timeline analysis (timecode vs. actual frame count)
   - Codec version consistency

4. Evidence integration:
   - Combine container-level and codec-level findings
   - Identify processing history
   - Detect manipulations or inconsistencies
```

### 5.5 Reference Documentation

- "Forensic Analysis of Video Files Using Metadata" (Xiang et al., 2021)
  - MP4 metadata forensic framework
  - Feature extraction and classification
  - Applicable to MKV with modifications

- "Video Source Identification from MP4 Data Based on Field Values in Atom/Box Attributes" (Gelbing et al.)
  - Atom/box tree analysis
  - Source identification from container structure
  - Methodologies applicable to MKV boxes

- "Matroska" (Wikipedia)
  - Complete container specification
  - EBML encoding details
  - Box/element structure reference

---

## Part 6: Comparison of Forensic Artifact Types Across Codecs

| Artifact Type | H.264 | H.265/HEVC | H.266/VVC | AV1 |
|---|---|---|---|---|
| **Blocking** | Regular 16×16 grid | Variable 8-64×64 | Variable with BTT | Variable 4-128×128 |
| **Blurring** | QP-dependent | QP-dependent | QP + TCQ dependent | Transform-specific |
| **Ringing** | DCT-based | DCT-based | Multi-transform | Multiple transforms |
| **MV Analysis** | 7 block sizes | Flexible sizes | More complex | Advanced |
| **DCT Histograms** | Well-documented | Well-documented | Limited research | Unexplored |
| **Mode Distribution** | 9 intra modes | 35 intra modes | New intra tools | Extended modes |
| **Block Structure** | Macroblock-based | CTU-based quad-tree | MTT partitioning | Superblock/10-modes |
| **Quantization Artifacts** | Clear patterns | Periodic patterns | TCQ complicates | High-precision confounds |
| **Forensic Maturity** | Mature | Mature | Emerging | Pre-research |

---

## Part 7: Practical Forensic Workflow

### 7.1 General Forensic Analysis Process

```
1. VIDEO ACQUISITION
   - Container format analysis (MP4, MKV, AVI, etc.)
   - Extract metadata
   - Identify contained codec

2. CODEC IDENTIFICATION
   - Parse codec bitstream
   - Determine H.264/H.265/H.266/AV1
   - Extract codec parameters (SPS, PPS)

3. CONTAINER-LEVEL ANALYSIS
   - Analyze writing/muxing applications
   - Check for metadata anomalies
   - Extract timecode/duration information
   - Identify attachment/chapter evidence

4. CODEC-LEVEL FORENSICS (Selected methods based on codec)
   
   H.264/H.265:
   - VPF analysis for GOP periodicity
   - Macroblock/CU type distribution
   - DCT histogram analysis
   - Intra/inter mode frequency

   H.266/VVC:
   - MTT partition distribution
   - Multiple transform analysis
   - New intra tools investigation

   AV1:
   - Partition mode analysis
   - Transform type frequency
   - Motion vector patterns

5. FORGERY DETECTION
   - Double compression indicators
   - Splicing boundary detection
   - Fake bitrate markers
   - Transcoding artifacts

6. EVIDENCE REPORTING
   - Document all findings
   - Provide visual evidence
   - Explain forensic methodology
   - Indicate confidence levels
```

### 7.2 Tool Recommendations

**Professional Software**:
- **Amped FIVE**: CTU visualization, macroblock analysis, professional tools
- **Belkasoft eDiscovery**: Video metadata analysis, compression investigation
- **MediaInfo**: Codec parameter extraction, metadata parsing

**Open Source Tools**:
- **FFmpeg**: Bitstream analysis, codec parameter extraction
- **FFprobe**: Detailed codec information
- **MediaInfo**: Open source codec analysis

**Research Implementation**:
- **GVPF Code**: GitHub IAPP-Group/GVPF (VPF analysis implementation)
- **H.264 Detection**: GitHub li-yanhao/gop_detection (a contrario detection)
- **Custom Analysis**: Python with OpenCV, NumPy for histogram analysis

---

## Conclusion

The field of video codec forensics demonstrates clear progression in maturity across codec generations:

1. **H.264/H.265**: Well-established methods with academic consensus
2. **H.266/VVC**: Emerging research with significant opportunity
3. **AV1**: Essentially virgin territory forensically, pre-research stage
4. **MKV Containers**: Supplementary forensic information, less critical than codec analysis

Each codec produces detectable artifacts exploitable for:
- Double compression detection
- Splicing identification
- Source attribution
- Tampering localization
- Transcoding detection
- Fake bitrate exposure

The fundamental principle underlying all forensic methods: **Compression creates reproducible, encoder-specific artifacts that persist through the encoding process and can be analyzed to reconstruct the encoding history.**

---

## References & Further Reading

### Comprehensive Reviews
- "A Review on HEVC Video Forensic Investigation under Different Scenarios" (MECS Press)
- "Forensic Analysis of Video File Formats" (DFRWS)
- "Image and Video Forensics" (PMC NCBI)
- "Interpol Review of Forensic Video Analysis, 2019–2022" (PMC, 2023)

### Technical Documentation
- ITU-T Recommendation H.264 (2016)
- ITU-T Recommendation H.265 (2013+)
- ITU-T Recommendation H.266 (2020)
- AOMedia AV1 Bitstream & Decoding Process Specification (2023)
- Matroska Specification (EBML-based)

### Forensic Methodology
- "Video Compression Artifacts and Quality Challenges" (Marco Fontani, Belkaday 2025)
- "Behind the Screen: Video Codecs and Formats Unveiled" (Amped Software 2024)
- "Compression Artifacts in Modern Video Coding" (Unterweger et al., 2024)
- "Forensic Analysis of Video Files Using Metadata" (Xiang et al., 2021)

### Open Source Resources
- GVPF Implementation: https://github.com/IAPP-Group/GVPF
- H.264 Detection: https://github.com/li-yanhao/gop_detection
- AV1 Codec Documentation: https://aomediacodec.github.io/
- Matroska Specification: https://www.matroska.org/
