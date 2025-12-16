# Digital Forensics: CC2 Review Guide
## Questions & Réponses Détaillées (Sélection de Langue Unique)

---

## 1. Traces of image editing: histogram equalization

<details open>
<summary>English</summary>

**Histogram equalization** is an image processing technique used to adjust contrast.

* **Principle:** It effectively increases the **dynamic range** of an image's pixel values by subjecting them to a mapping such that the distribution of output pixel values becomes approximately **uniform**.
* **Detectable Characteristics:**
    * The operation is characterized by a **linear Cumulative Density Function (CDF)**.
    * For histogram-equalized saturated images, the **location of the impulsive component** is often shifted.
* **Detection:** To identify this edit, forensic analysts calculate the **"uniformity"** of the histogram. An unnaturally flat histogram or one showing "combing" artifacts (regular gaps due to stretching discrete values) is a strong trace of editing.
</details>

<details>
<summary>Français</summary>

**L'égalisation d'histogramme** est une technique de traitement d'image utilisée pour ajuster le contraste.

* **Principe :** Elle augmente la **gamme dynamique** des valeurs de pixels en les soumettant à une transformation (mapping) de sorte que la distribution des pixels de sortie soit approximativement **uniforme**.
* **Caractéristiques détectables :**
    * L'opération est caractérisée par une **fonction de densité cumulative (CDF) linéaire**.
    * Dans les images saturées ayant subi cette égalisation, la **position de la composante impulsive** est souvent décalée.
* **Détection :** Pour identifier si une image a subi ce traitement, on calcule la **"l'uniformité"** de l'histogramme. Un histogramme anormalement plat ou peigne (avec des trous réguliers dus à l'étirement des valeurs discrètes) est un indice fort de modification.
</details>

---

## 2. Tampering detection: pixel-based and format-based techniques

<details open>
<summary>English</summary>

These techniques aim to detect tampering by analyzing the building blocks of the image (pixels) or its encoding structure (format).

* **Pixel-based Techniques:**
    * The core premise is that manipulation disrupts the natural **statistical properties** and **correlations** of pixels.
    * **Cloning (Copy-Move):** Detecting duplicated regions within the same image (can be any shape/location).
    * **Resampling:** Resizing or rotating introduces specific **periodic correlations** between neighboring pixels (often invisible to the eye but detectable mathematically).
    * **Splicing:** Inserting part of one image into another disrupts **higher-order Fourier Statistics**.
* **Format-based Techniques:**
    * These rely on specificities of image compression (e.g., JPEG artifacts).
    * **Double JPEG Compression:** If an image is opened, modified, and saved again, traces of double compression appear.
    * **JPEG Ghost Detection:** Based on quality mismatch. It detects if a lower-quality image patch has been spliced into a higher-quality image, often revealing that the **JPEG blocking grid** of the inserted part does not align with the background grid.
</details>

<details>
<summary>Français</summary>

Ces techniques visent à détecter les manipulations (tampering) en analysant les blocs constitutifs de l'image (pixels) ou son encodage (format).

* **Techniques basées sur les pixels (Pixel-based) :**
    * L'hypothèse est que la manipulation perturbe les **propriétés statistiques** naturelles et les **corrélations** entre pixels.
    * **Clonage (Copy-Move) :** Détection de régions dupliquées (peuvent être de n'importe quelle forme/emplacement).
    * **Rééchantillonnage (Resampling) :** Le redimensionnement ou la rotation introduit des **corrélations périodiques spécifiques** entre les pixels voisins (souvent invisibles à l'œil nu mais détectables mathématiquement).
    * **Épissage (Splicing) :** L'insertion d'une partie d'une image dans une autre perturbe les **statistiques de Fourier d'ordre supérieur**.
* **Techniques basées sur le format (Format-based) :**
    * Elles reposent sur les artefacts spécifiques introduits par la compression (ex: JPEG).
    * **Double compression JPEG :** Si une image est ouverte, modifiée puis resauvegardée, des artefacts de double compression apparaissent.
    * **JPEG Ghost Detection :** Détecte des disparités de qualité. Si une zone (patch) de basse qualité est insérée dans une image de haute qualité, les artefacts de blocs JPEG ne seront pas alignés sur la grille de l'image de fond.
</details>

---

## 3. Tampering detection: camera-based, physics-based and geometry-based techniques

<details open>
<summary>English</summary>

These approaches verify the consistency of the image regarding the capture process and physical laws.

* **Camera-based Techniques:**
    * **Chromatic Aberrations:** Patterns should be consistent across the image; variations suggest tampering.
    * **Sensor Noise (PRNU):** Every sensor has a unique noise fingerprint. Distortions or absence of this pattern in a specific region indicate manipulation.
    * **Color Filter Arrays (CFA):** Interpolation (demosaicing) introduces recognizable correlation patterns. Breaks in these patterns or inconsistencies (e.g., different interpolation algorithms like Bayer vs. others) are red flags.
* **Physics-based Techniques:**
    * **2D/3D Lighting:** Analyzes shadows and surface normals to check if the light direction is consistent across all objects. Often uses a **Lambertian surface** approximation.
* **Geometry-based Techniques:**
    * **Principal Point:** The projection of the camera center onto the image plane. If an object is translated within the image, the estimated principal point moves, violating perspective consistency.
    * **Metric Measurements:** Using projective geometry to check if real-world measurements remain consistent on planar surfaces.
</details>

<details>
<summary>Français</summary>

Ces approches vérifient la cohérence de l'image par rapport au processus de capture et aux lois physiques.

* **Basées sur la caméra (Camera-based) :**
    * **Aberrations chromatiques :** Les variations doivent être cohérentes sur toute l'image ; une incohérence signale une modification.
    * **Bruit du capteur (PRNU) :** Chaque capteur a un motif de bruit unique. Une distorsion ou absence de ce motif dans une zone indique une manipulation.
    * **Matrices de filtres colorés (CFA) :** L'interpolation (demosaicing) crée des corrélations spécifiques. Des algorithmes différents (Bayer, etc.) ou une rupture dans le motif de corrélation indiquent une anomalie.
* **Basées sur la physique (Physics-based) :**
    * **Éclairage 2D/3D :** On analyse les ombres et les normales de surface pour voir si la direction de la lumière est cohérente sur tous les objets. On utilise souvent une approximation de **surface Lambertienne**.
* **Basées sur la géométrie (Geometry-based) :**
    * **Point principal :** C'est la projection du centre de la caméra sur le plan image. Si un objet est déplacé (translaté), le point principal estimé pour cet objet change, brisant la cohérence de la perspective.
    * **Mesures métriques :** Utilisation de la géométrie projective pour vérifier si les mesures du monde réel sont respectées sur les surfaces planes.
</details>

---

## 4. Printed documents forensics: general principles

<details open>
<summary>English</summary>

Printed document forensics is critical because paper remains a major vector for information (payments, contracts, tracking).

* **Main Objectives:**
    * Ensure the **authenticity** of official documents.
    * Fight against **counterfeiting** (fake currency, medicine packaging, fake products).
    * Detect **presentation attacks** (spoofing) against biometric systems (e.g., printing a face to unlock a phone).
* **The Issue:** High-quality printing technologies are cheap and publicly available, allowing counterfeiters to produce fakes that are sometimes better made than originals (risking economic destabilization and public health).
</details>

<details>
<summary>Français</summary>

L'analyse forensique des documents imprimés est cruciale car le papier reste un vecteur majeur d'information (paiements, contrats, traçabilité).

* **Objectifs principaux :**
    * Garantir l'**authenticité** des documents officiels.
    * Lutter contre la **contrefaçon** (fausse monnaie, emballages de médicaments, faux produits).
    * Détecter les **attaques par présentation** (spoofing) contre les systèmes biométriques (ex: imprimer un visage pour débloquer un téléphone).
* **Le problème :** Les technologies d'impression de haute qualité sont bon marché et accessibles, permettant aux faussaires de produire des faux parfois mieux réalisés que les originaux (déstabilisation économique, risques sanitaires).
</details>

---

## 5. Device attribution: basic concepts

<details open>
<summary>English</summary>

Device attribution aims to identify the source of a digitized printed document.

* **Two Levels of Identification:**
    1.  Which **brand and model** produced the document?
    2.  Which **specific device** produced it?
* **Types of Artifacts (Signatures):**
    * **Extrinsic (Watermarking):** Deliberately inserted by the printer (e.g., Machine Identification Codes).
    * **Intrinsic (Blind):** Unintentional flaws resulting from the manufacturing process or wear and tear (noise, distortions, scratches, printing pattern texture).
* **Laser Printing Process (Source of Artifacts):**
    * The **drum** is charged/discharged by a laser beam.
    * **Toner** adheres to the charged areas.
    * The **fuser** fixes the ink using heat and pressure.
    * Mechanical imperfections in these steps (vibrations, speed fluctuations) create unique signatures like **banding**.
</details>

<details>
<summary>Français</summary>

L'attribution de dispositif vise à identifier la source d'un document imprimé numérisé.

* **Deux niveaux d'identification :**
    1.  Quelle **marque et modèle** a produit le document ?
    2.  Quel **appareil spécifique** (unique) l'a produit ?
* **Types d'artefacts (signatures) :**
    * **Extrinsèques (Watermarking) :** Insérés délibérément par l'imprimante (ex: codes d'identification machine).
    * **Intrinsèques (Aveugles) :** Défauts involontaires issus du processus de fabrication ou de l'usure (bruit, distorsions, rayures, texture des motifs d'impression).
* **Processus d'impression Laser (Source d'artefacts) :**
    * Le **tambour (drum)** est chargé/déchargé par un laser.
    * Le **toner** se dépose sur les zones chargées.
    * Le **fuser** fixe l'encre par chaleur et pression.
    * Les imperfections mécaniques de ces étapes (vibrations, vitesse) créent des signatures uniques comme le **banding** (lignes horizontales).
</details>

---

## 6. Printed document authentication: active approach

<details open>
<summary>English</summary>

The active approach involves **insorting information** into the document or the printing process to aid authentication.

* **Extrinsic Signature:** Can be detected visually, via software, or chemically.
* **Key Example: Machine Identification Codes (MIC):**
    * Pioneered by Xerox, often a requirement by governments (e.g., FBI).
    * Consists of a matrix of **tiny yellow dots** spread across the print area.
    * These dots encode: the device's **serial number**, and the **date and time** of printing.
* **Limitations:** These codes can be anonymized or removed (by adding noise/extra dots) and are not present on all printers globally.
</details>

<details>
<summary>Français</summary>

L'approche active consiste à **insérer des informations** dans le document ou le processus d'impression pour faciliter l'authentification.

* **Signature extrinsèque :** Elle peut être détectée visuellement, par logiciel ou chimiquement.
* **Exemple clé : Machine Identification Codes (MIC) :**
    * Pionnier par Xerox, souvent exigé par les gouvernements (ex: FBI).
    * Consiste en une matrice de **minuscules points jaunes** (yellow dots) répartis sur la page.
    * Ces points encodent : le **numéro de série** de l'appareil, la **date** et l'**heure** de l'impression.
* **Limitations :** Ces codes peuvent être anonymisés ou supprimés (en ajoutant de faux points), et ne sont pas présents sur toutes les imprimantes mondiales.
</details>

---

## 7. Approaches for text printed source detection

<details open>
<summary>English</summary>

These are **passive** approaches (no prior watermarking) to attribute printed text to its source.

* **Analysis Areas:**
    * **Isolated Characters:** Analysis of specific letters (often 'I' or 'e') due to high frequency.
    * **Segmented Areas (Frames):** Rectangular blocks of text/image.
    * **Whole Document.**
* **Methods:**
    * **Ali et al.:** Use the pixel value projection of the letter 'I'. To handle font/size differences, they preprocess with Principal Component Analysis (PCA) and classify using Gaussian Mixture Models (GMM).
    * **Limitation:** Accuracy drops significantly between printers of the same generation or model, and reliance on specific characters can be problematic if they don't appear often.
</details>

<details>
<summary>Français</summary>

Il s'agit d'approches **passives** (sans tatouage préalable) pour attribuer un texte imprimé à sa source.

* **Zones d'analyse :**
    * **Caractères isolés :** Analyse de lettres spécifiques (souvent 'I' ou 'e') car très fréquentes.
    * **Zones segmentées (Frames) :** Blocs rectangulaires de texte/image.
    * **Document entier.**
* **Méthodes :**
    * **Ali et al. :** Utilisent la projection des valeurs de pixels de la lettre 'I'. Pour gérer les différences de taille/police, ils utilisent l'Analyse en Composantes Principales (PCA) et classifient avec des modèles de mélange gaussien (GMM).
    * **Limitation :** La précision diminue fortement entre imprimantes de la même génération ou modèle, et dépend de la fréquence d'apparition des caractères choisis.
</details>

---

## 8. Laser Printer attribution

<details open>
<summary>English</summary>

Laser printer attribution relies on detecting specific electromechanical artifacts created during printing.

* **Document Types:** Text, images, or a mix of both.
* **Major Artifacts (Banding & Jitter):**
    * **Banding:** A textural pattern composed of **horizontal dark lines**, low frequency, and periodic. Caused by motor speed variations and vibrations perpendicular to the paper path.
    * **Jitter:** Horizontal artifacts with a different frequency range, caused by oscillatory disturbances of the drum or developer roller.
    * **Skewed Jitter:** Similar periodic artifact but formed by vertical lines.
* **Technique:** High-resolution scanners (e.g., 1200 DPI for a 600 DPI print) are often used to capture these micro-details.
</details>

<details>
<summary>Français</summary>

L'attribution des imprimantes laser repose sur la détection d'artefacts électromécaniques spécifiques créés lors de l'impression.

* **Types de documents :** Texte, images, ou mélange des deux.
* **Artefacts majeurs (Banding & Jitter) :**
    * **Banding :** Motif textural composé de **lignes sombres horizontales**, périodiques et de basse fréquence. Causé par les variations de vitesse du moteur et les vibrations perpendiculaires au mouvement du papier.
    * **Jitter :** Artefacts horizontaux mais de fréquence/durée différente, causés par des perturbations oscillatoires du tambour ou du rouleau développeur.
    * **Jitter biaisé (Skewed) :** Similaire mais formé de lignes verticales.
* **Technique :** On utilise souvent des scanners à haute résolution (ex: 1200 DPI pour une impression 600 DPI) pour capturer ces micro-détails.
</details>

---

## 9. GLCM approach for Laser printer attribution

<details open>
<summary>English</summary>

The **GLCM (Gray-Level Co-occurrence Matrix)** is a powerful statistical tool for analyzing texture (such as the texture left by a printer).

* **What is a GLCM?**
    * It is a matrix that counts how often a pair of pixels with specific gray values $(i, j)$ occurs adjacent to each other (or separated by a specific offset) in a specific direction.
    * It captures the spatial relationship between pixels (the "roughness" or pattern of the print).
* **Application (Mikkilineni et al.):**
    * Applied to characters (e.g., letter 'e').
    * Statistics are extracted from this matrix:
        * **Contrast:** Intensity of local variations.
        * **Correlation:** Linear dependency of neighboring gray levels.
        * **Energy:** Uniformity of the texture.
        * **Homogeneity:** Closeness of the distribution of elements to the GLCM diagonal.
* **Multidirectional Approach:** These matrices are calculated in multiple directions (e.g., 8 directions) to create a robust feature vector (e.g., 176 dimensions) for classification.
</details>

<details>
<summary>Français</summary>

La **GLCM (Gray-Level Co-occurrence Matrix)** est un outil statistique puissant pour analyser la texture (comme celle laissée par une imprimante).

* **Qu'est-ce qu'une GLCM ?**
    * C'est une matrice qui compte combien de fois une paire de pixels avec des valeurs de gris spécifiques $(i, j)$ apparaît côte à côte (ou séparée par une certaine distance) dans une direction donnée.
    * Elle capture la relation spatiale entre les pixels (la "rugosité" ou le motif de l'impression).
* **Application (Mikkilineni et al.) :**
    * Appliquée sur des caractères (ex: lettre 'e').
    * On extrait des statistiques de cette matrice :
        * **Contraste :** Intensité des différences locales.
        * **Corrélation :** Dépendance linéaire des niveaux de gris voisins.
        * **Énergie :** Uniformité de la texture.
        * **Homogénéité :** Proximité de la distribution des éléments par rapport à la diagonale de la GLCM.
* **Approche multidirectionnelle :** On calcule ces matrices dans plusieurs directions (ex: 8 directions) pour créer un vecteur de caractéristiques robuste (ex: 176 dimensions) pour la classification.
</details>

---

## 10. Convolutional Texture Gradient Filter (CTGF) descriptor

<details open>
<summary>English</summary>

The CTGF is a descriptor designed to capture printer signatures within document frames, focusing on texture gradients.

* **Algorithm Steps:**
    1.  **Negative:** Inverting the image ($n = 255 - s$) for calculation convenience (white becomes 0).
    2.  **Crop:** Removing borders (6%) to eliminate scanning noise and lighting artifacts.
    3.  **Convolution:** Summing neighbors within an $n \times n$ window.
    4.  **Gradient:** Calculating the absolute difference between a pixel and its neighbors.
    5.  **Gradient Filter:** Keeping only textures that fall within a specific gradient interval ($g_{low}$ to $g_{high}$), as printer signatures are most distinct in specific gradient ranges (often almost flat areas).
    6.  **Histogram:** Constructing a histogram of the filtered texture values.
    7.  **Normalization:** Min-Max scaling to generate the final feature vector.
* **Dimensionality Reduction:** Selecting the most useful features based on training set analysis.
</details>

<details>
<summary>Français</summary>

Le CTGF est un descripteur conçu pour capturer la signature de l'imprimante dans des zones (frames) du document, en se concentrant sur les gradients de texture.

* **Étapes de l'algorithme :**
    1.  **Négatif :** Inversion de l'image ($n = 255 - s$) pour simplifier le calcul (blanc devient 0).
    2.  **Rognage (Crop) :** Suppression des bordures (6%) pour éliminer le bruit de scan et d'éclairage.
    3.  **Convolution :** Somme des voisins dans une fenêtre $n \times n$.
    4.  **Gradient :** Calcul de la différence absolue entre un pixel et ses voisins.
    5.  **Filtre de Gradient :** On ne garde que les textures correspondant à un intervalle de gradient spécifique ($g_{low}$ à $g_{high}$), car les signatures d'imprimantes sont plus visibles dans certaines plages de gradient (zones presque plates).
    6.  **Histogramme :** Construction d'un histogramme des valeurs de texture filtrées.
    7.  **Normalisation :** Mise à l'échelle (Min-Max) pour obtenir le vecteur caractéristique final.
* **Réduction de dimension :** Sélection des caractéristiques les plus pertinentes via l'analyse sur un ensemble d'entraînement.
</details>

---

## 11. Deep Learning for Laser printer source attribution

<details open>
<summary>English</summary>

Deep Learning replaces or complements hand-crafted descriptors (like GLCM) for source attribution.

* **Methodology:**
    * Extraction of frequent letters (A and E).
    * Use of an ensemble of shallow **CNNs (Convolutional Neural Networks)** ($28 \times 28$ inputs).
    * CNNs operate on different inputs: raw image, median residual, average residual.
    * CNNs act as **feature extractors**.
    * Final classification is often performed by **SVM** (Support Vector Machines) with majority voting.
* **Pros/Cons:**
    * **Pro:** No need to define hand-crafted features manually.
    * **Con:** Requires significant data, difficult interpretability ("black box"), and struggles with "open set" scenarios (new printers unknown to the model).
</details>

<details>
<summary>Français</summary>

L'apprentissage profond (Deep Learning) remplace ou complète les descripteurs manuels (comme GLCM) pour l'attribution de source.

* **Méthodologie :**
    * Extraction de lettres fréquentes (A et E).
    * Utilisation d'un ensemble de **CNN (Réseaux de Neurones Convolutifs)** peu profonds (entrées $28 \times 28$).
    * Les CNN travaillent sur différentes entrées : image brute, résidu médian, résidu moyen.
    * Les CNN agissent comme **extracteurs de caractéristiques** (feature extractors).
    * La classification finale est souvent faite par **SVM** (Support Vector Machine) avec un vote majoritaire.
* **Avantages/Inconvénients :**
    * **Avantage :** Pas besoin de définir manuellement les caractéristiques ("hand-crafted features").
    * **Inconvénient :** Nécessite beaucoup de données, interprétabilité difficile ("boîte noire"), et le problème d'attribution en "monde ouvert" (nouvelles imprimantes non connues du modèle).
</details>

---

## 12. Approaches for Printed pictures source detection

<details open>
<summary>English</summary>

For printed pictures (not text), techniques differ as they analyze colors and halftones.

* **CMYK Approach (Lee and Choi):**
    * Convert scan to CMY (Cyan-Magenta-Yellow) color space.
    * Isolate **noise** by subtracting the Wiener-filtered image from the original.
    * Calculate GLCM features on these residual noises (Homogeneity, contrast, energy, correlation).
* **Wavelet Approach:**
    * Use of **Discrete Wavelet Transform (DWT)**.
    * Image is split into frequency sub-bands (HH, HL, LH, LL).
    * **High-frequency sub-bands (HH)** contain the most information about printer signatures.
    * Statistics extraction: standard deviation, skewness, kurtosis.
* **Note:** Using CMYK space is preferred as it is the native space of printers, avoiding RGB conversion approximations.
</details>

<details>
<summary>Français</summary>

Pour les images imprimées (et non le texte), les techniques diffèrent car on analyse les couleurs et les trames.

* **Approche CMYK (Lee et Choi) :**
    * Conversion du scan en espace colorimétrique CMY (Cyan-Magenta-Jaune).
    * Isolation du **bruit** par soustraction de l'image originale et de l'image filtrée (filtre de Wiener).
    * Calcul de caractéristiques GLCM sur ces bruits résiduels (Homogénéité, contraste, énergie, corrélation).
* **Approche Wavelet (Ondelettes) :**
    * Utilisation de la **Transformée en Ondelettes Discrète (DWT)**.
    * L'image est divisée en sous-bandes de fréquences (HH, HL, LH, LL).
    * Les sous-bandes **hautes fréquences (HH)** contiennent le plus d'informations sur les signatures d'impression.
    * Extraction de statistiques : écart-type, skewness (asymétrie), kurtosis (aplatissement).
* **Note :** L'utilisation de l'espace CMYK est préférable car c'est l'espace natif des imprimantes, évitant les approximations de conversion RGB.
</details>

---

## 13. Principles of DNN watermarking

<details open>
<summary>English</summary>

DNN (Deep Neural Network) watermarking represents a paradigm shift to protect the Intellectual Property Rights (IPR) of AI models.

* **Concept:** Indissolubly embedding information (watermark) directly into the **model weights** or its functional behavior.
* **Required Robustness:** The watermark must survive model modifications such as:
    * **Pruning** (cutting parts of the network).
    * **Compression** / quantization.
    * **Fine-tuning** and transfer learning.
* **Box-free watermarking:** A major application is to watermark the generative model itself, so that **all** images it generates contain an invisible trace. This helps detect "deepfakes" at the source.
</details>

<details>
<summary>Français</summary>

Le tatouage de réseaux de neurones profonds (DNN) est un changement de paradigme pour protéger la propriété intellectuelle (IPR) des modèles IA.

* **Concept :** Intégrer une information indissociable (watermark) directement dans les **poids du modèle** ou son comportement fonctionnel.
* **Robustesse requise :** Le tatouage doit résister aux modifications du modèle telles que :
    * Le **pruning** (élagage des neurones).
    * La **compression** / quantification.
    * Le **fine-tuning** et le transfer learning.
* **Box-free watermarking :** Une application majeure est de marquer le modèle génératif lui-même, de sorte que **toutes** les images qu'il génère contiennent une trace invisible. Cela permet de détecter les "deepfakes" à la source.
</details>

---

## 14. GAN watermarking

<details open>
<summary>English</summary>

This technique aims to solve the problem of detecting synthetic (AI-generated) images "in the wild".

* **Problem:** The arms race between fake generators and forensic detectors is unwinnable.
* **Solution:** Team up with model creators. We "watermark" the generative models (GANs) so their output is signed.
* **Mechanism:** Constraints are imposed during training or within the GAN structure so that the generated image contains an invisible pattern (watermark), allowing origin verification and manipulation tracing.
</details>

<details>
<summary>Français</summary>

Cette technique vise à résoudre le problème de la détection des images synthétiques (AI-generated) "in the wild".

* **Problème :** La course aux armements entre générateurs de faux et détecteurs est perdue d'avance.
* **Solution :** Collaborer avec les créateurs de modèles. On "tatoue" les modèles génératifs (GANs) pour que leur sortie soit signée.
* **Fonctionnement :** On impose des contraintes lors de l'entraînement ou de la structure du GAN pour que l'image générée contienne un motif invisible (watermark) permettant de vérifier son origine et de tracer l'historique de manipulation.
</details>

---

## 15. Supervised watermarking

<details open>
<summary>English</summary>

In the context of GANs, supervised watermarking involves training the network to produce images that already contain the watermark.

* **Approach:** A third-party network is used to embed the message, or the loss function is modified to force the generator to hide information in the output image.
* **Limitations:** This often requires a **complete retraining** of the model if one wants to change the watermark (e.g., to give a unique ID to each user).
</details>

<details>
<summary>Français</summary>

Dans le contexte des GANs, le tatouage supervisé implique d'entraîner le réseau à produire des images contenant déjà le tatouage.

* **Approche :** On utilise un réseau tiers pour incruster le message, ou on modifie la fonction de perte (loss function) pour forcer le générateur à cacher de l'information dans l'image de sortie.
* **Limitations :** Cela nécessite souvent un **ré-entraînement complet** du modèle si on veut changer le tatouage (par exemple, pour donner un identifiant unique à chaque utilisateur).
</details>

---

## 16. Retraining free fingerprinting

<details open>
<summary>English</summary>

This method allows assigning a unique watermark to each user of a model (e.g., ChatGPT or DALL-E) without retraining the giant model every time.

* **Problem:** Retraining is too costly in energy and time for every single user.
* **Solution:**
    * A **personalized layer** (often a normalization layer) is introduced into the generator.
    * A separate small network, the **ParamGen Network**, generates the weights for this specific layer based on the desired watermark.
    * The main model remains frozen; only the small ParamGen network calculates the slight modifications needed to insert the unique signature.
* **Result:** Each user gets a slightly different version of the model that produces images with their unique fingerprint.
</details>

<details>
<summary>Français</summary>

Cette méthode permet d'attribuer un tatouage unique à chaque utilisateur d'un modèle (ex: ChatGPT ou DALL-E) sans réentraîner le modèle géant à chaque fois.

* **Problème :** Le ré-entraînement est trop coûteux en énergie et temps pour chaque utilisateur.
* **Solution :**
    * On introduit une **couche personnalisée** (souvent de normalisation) dans le générateur.
    * Un petit réseau séparé, le **ParamGen Network**, génère les poids de cette couche spécifique à partir du tatouage désiré.
    * Le modèle principal reste figé ; seul le petit réseau ParamGen calcule les modifications légères nécessaires pour insérer la signature unique.
* **Résultat :** Chaque utilisateur obtient une version légèrement différente du modèle qui produit des images avec son empreinte unique.
</details>

---

## 17. Methods of information hiding

<details open>
<summary>English</summary>

In computer science, Information Hiding encompasses several disciplines:

1.  **Steganography:** The art of hiding the very **existence** of the message. (Linguistic or technical).
2.  **Watermarking:** Inserting a mark (visible or invisible) to protect rights (copyright) or prove authenticity. The message is inextricably linked to the carrier.
3.  **Cryptography:** Making the message unintelligible. The existence of the message is known, but its content is obscured.
</details>

<details>
<summary>Français</summary>

En informatique, la dissimulation d'information (Information Hiding) regroupe plusieurs disciplines :

1.  **Stéganographie :** Art de dissimuler l'**existence** même du message. (Linguistique ou technique).
2.  **Watermarking (Tatouage) :** Insertion d'une marque (visible ou non) pour protéger les droits (copyright) ou prouver l'authenticité. Le message est lié au contenant.
3.  **Cryptographie :** Rendre le message inintelligible. L'existence du message est connue, mais son contenu est caché.
</details>

---

## 18. Basics of cryptography

<details open>
<summary>English</summary>

* **Definition:** The study of secure communication techniques that allow only the sender and intended recipient to view the contents.
* **Origin:** From the Greek word *kryptos* (hidden).
* **Mechanism:** Relies on **encryption**, which scrambles ordinary text into ciphertext, and the reverse decryption process.
* **Key Difference:** Unlike steganography, in cryptography, an "enemy" is allowed to intercept the message and know it is a secret, but cannot read it without the key.
</details>

<details>
<summary>Français</summary>

* **Définition :** Étude des techniques de communication sécurisée permettant uniquement à l'émetteur et au destinataire prévu de voir le contenu.
* **Origine :** Du grec *kryptos* (caché).
* **Fonctionnement :** Repose sur le **chiffrement** (encryption), qui brouille un texte clair en un texte chiffré (ciphertext), et le déchiffrement inverse.
* **Différence clé :** Contrairement à la stéganographie, en cryptographie, un "ennemi" peut intercepter le message et savoir qu'il s'agit d'un secret, mais il ne peut pas le lire sans la clé.
</details>

---

## 19. Basics of steganography

<details open>
<summary>English</summary>

* **Definition:** The art and science of communicating by hiding the existence of the communication.
* **Etymology:** *Steganos* (covered) + *Graphie* (writing).
* **Principle:** Hiding a secret message inside a seemingly harmless carrier (text, image, audio) in a way that avoids drawing suspicion.
* **Goal:** If the presence of the message is suspected, the goal of steganography is defeated (even if the message is not decrypted).
* **History:** Wax tablets, shaved heads of messengers, invisible inks, microdots.
</details>

<details>
<summary>Français</summary>

* **Définition :** Art et science de communiquer en cachant l'existence de la communication.
* **Étymologie :** *Steganos* (couvert) + *Graphie* (écriture).
* **Principe :** Cacher un message secret à l'intérieur d'un porteur (carrier) inoffensif (texte, image, audio) de manière à ne pas éveiller les soupçons.
* **Objectif :** Si la présence du message est soupçonnée, le but de la stéganographie est échoué (même si le message n'est pas décrypté).
* **Historique :** Tablettes de cire, crânes rasés de messagers, encres invisibles, micro-points.
</details>

---

## 20. Requirements to modern steganography

<details open>
<summary>English</summary>

Designers must manage a trade-off between two opposing requirements:

1.  **Invisibility (Statistical & Perceptual):**
    * The message must not be visible to the naked eye.
    * More importantly: it must not alter the image statistics (to resist mathematical analysis).
2.  **Capacity (Payload):** The amount of data to be hidden. Increasing capacity usually decreases invisibility.

* **Kerckhoff's Principle:** It is assumed that the "Warden" (monitor) knows the steganographic algorithm. Security must rely only on the secret key, not on the obscurity of the algorithm.
</details>

<details>
<summary>Français</summary>

Les concepteurs doivent gérer un compromis (trade-off) entre deux exigences opposées :

1.  **Invisibilité (Statistique & Perceptuelle) :**
    * Le message ne doit pas être vu à l'œil nu.
    * Plus important : il ne doit pas modifier les statistiques de l'image (pour résister aux analyses mathématiques).
2.  **Capacité (Payload) :** La quantité de données que l'on veut cacher. Augmenter la capacité diminue généralement l'invisibilité.

* **Principe de Kerckhoffs :** On suppose que le "gardien" (celui qui surveille) connaît l'algorithme de stéganographie utilisé. La sécurité ne doit dépendre que de la clé secrète, pas de l'obscurité de l'algorithme.
</details>

---

## 21. Steganography in spatial domain

<details open>
<summary>English</summary>

* **Method:** The message is hidden directly in the array of integers (pixels) that makes up the image.
* **Common Technique:** LSB (Least Significant Bit) replacement.
* **Pros:**
    * Easy to use/implement.
    * **High capacity** payload.
    * Visually imperceptible.
* **Cons:**
    * Fragile to simple modifications (compression, resizing).
    * Easily detectable statistically if poorly implemented.
</details>

<details>
<summary>Français</summary>

* **Méthode :** Le message est caché directement dans le tableau de nombres entiers (pixels) qui constitue l'image.
* **Technique courante :** LSB (Least Significant Bit) replacement.
* **Avantages :**
    * Facile à mettre en œuvre.
    * **Haute capacité** de stockage.
    * Visuellement imperceptible.
* **Inconvénients :**
    * Fragile aux modifications simples (compression, redimensionnement).
    * Facilement détectable statistiquement si mal implémenté.
</details>

---

## 22. Steganography in transform domain

<details open>
<summary>English</summary>

* **Method:** The message is hidden in the image's transform coefficients, typically the **DCT (Discrete Cosine Transform)** used in **JPEG** compression.
* **Mechanism:** Modifying the quantized DCT coefficients (rather than pixels directly).
* **Pros:** Better resistance to JPEG compression (since it's embedded in the format structure).
* **Cons:**
    * Lower capacity than the spatial domain.
    * Lower security because very good statistical models exist for DCT coefficients (easier detection by tools like F5, Jsteg).
</details>

<details>
<summary>Français</summary>

* **Méthode :** Le message est caché dans les coefficients de transformation de l'image, typiquement la **DCT (Discrete Cosine Transform)** utilisée dans la compression **JPEG**.
* **Fonctionnement :** On modifie les coefficients DCT quantifiés (et non les pixels directement).
* **Avantages :** Résiste mieux à la compression JPEG (car intégré dans le format).
* **Inconvénients :**
    * Capacité plus faible que le domaine spatial.
    * Sécurité moindre car il existe de très bons modèles statistiques pour les coefficients DCT (détection plus aisée par les outils comme F5, Jsteg).
</details>

---

## 23. Steganography by cover selection

<details open>
<summary>English</summary>

* **Principle:** Alice does not *modify* the image. She has a huge database of images and **selects** one whose properties (e.g., Hash or semantic value) exactly match the message she wants to send.
* **Pros:** Almost perfect security (no statistical modification).
* **Cons:** Extremely low payload. To send just 8 characters (64 bits), one would need a database of $2^{64}$ images, which is unfeasible.
</details>

<details>
<summary>Français</summary>

* **Principe :** Alice ne *modifie* pas l'image. Elle possède une immense base de données d'images et en **choisit** une dont les propriétés (ex: le Hash ou une valeur sémantique) correspondent exactement au message qu'elle veut envoyer.
* **Avantages :** Sécurité presque parfaite (aucune modification statistique).
* **Inconvénients :** Capacité extrêmement faible. Pour envoyer juste 8 caractères (64 bits), il faudrait une base de données de $2^{64}$ images, ce qui est irréalisable.
</details>

---

## 24. Steganography by cover synthesis

<details open>
<summary>English</summary>

* **Principle:** Alice creates an image artificially (on-the-fly) that conveys the message.
* **Methods:**
    * Assembling texture blocks or patches from existing photos.
    * Modern AI use (**GANs**): Generating a realistic face or scene where the generated features depend on the secret message bits.
* **Pros:** Good security (no original "cover" to compare against).
* **Cons:** Difficult to create fully realistic images without artifacts at block borders (for older methods).
</details>

<details>
<summary>Français</summary>

* **Principe :** Alice crée une image artificiellement (à la volée) qui contient le message.
* **Méthodes :**
    * Assemblage de blocs de textures ou de photos existantes.
    * Utilisation moderne de l'IA (**GANs**) : générer un visage ou une scène réaliste où les caractéristiques générées dépendent des bits du message secret.
* **Avantages :** Bonne sécurité (pas d'original pour comparer).
* **Inconvénients :** Difficile de créer des images totalement réalistes sans artefacts aux frontières de blocs (pour les méthodes anciennes).
</details>

---

## 25. Steganography by cover modification

<details open>
<summary>English</summary>

* **Principle:** The most common approach. Taking an existing image and slightly modifying its values to embed the message.
* **Challenges:** Minimizing distortion. "Cost functions" are used to determine which pixels to modify so the statistical impact is minimized (Matrix embedding).
* **Risk:** Leaves statistical traces detectable by steganalysis (like the Pair of Values attack).
</details>

<details>
<summary>Français</summary>

* **Principe :** C'est l'approche la plus courante. On prend une image existante et on modifie légèrement ses valeurs pour y insérer le message.
* **Défis :** Minimiser la distorsion. On utilise des "fonctions de coût" pour déterminer quels pixels modifier pour que l'impact statistique soit le plus faible possible (Matrix embedding).
* **Risque :** Laisse des traces statistiques détectables par stéganalyse (comme l'attaque par paires de valeurs).
</details>

---

## 26. LSB steganography

<details open>
<summary>English</summary>

* **LSB (Least Significant Bit):** Replacing the last bit of each pixel with a message bit.
* **Visual Impact:** Invisible (a value change of $+/- 1$ out of 255 is imperceptible).
* **Detection (PoV Attack):** Histogram analysis reveals an anomaly. Pairs of values (e.g., $2k$ and $2k+1$) tend to equalize in frequency ($h(2k) \approx h(2k+1)$).
* **Countermeasure (LSB Matching / $\pm 1$ steg):** Instead of brutally replacing the bit, one randomly adds or subtracts 1 to match the target bit. This smooths the histogram and makes detection harder.
</details>

<details>
<summary>Français</summary>

* **LSB (Least Significant Bit) :** Remplacement du dernier bit de chaque pixel par un bit du message.
* **Impact visuel :** Invisible (le changement de valeur de $+/- 1$ sur 255 est imperceptible).
* **Détection (Attaque PoV) :** L'analyse de l'histogramme révèle une anomalie. Les paires de valeurs (ex: $2k$ et $2k+1$) tendent à s'égaliser en fréquence ($h(2k) \approx h(2k+1)$).
* **Contre-mesure (LSB Matching / $\pm 1$ steg) :** Au lieu de remplacer brutalement le bit, on ajoute ou soustrait 1 aléatoirement pour correspondre au bit cible. Cela lisse l'histogramme et rend la détection plus difficile.
</details>

---

## 27. Empirical approaches of steganography

<details open>
<summary>English</summary>

Since perfectly modeling all image statistics is impossible, empirical approaches are used:

1.  **Model-based Steganography:** Identifying a statistical model of the image and modifying data while restoring statistics (e.g., the histogram) so they adhere to the model.
2.  **Stochastic Modulation:** Simulating natural acquisition noise (thermal noise, PRNU). The message is hidden by adding noise that resembles this natural noise.
3.  **Steganalysis-aware Steganography:** Actively trying to eliminate artifacts that steganalyzers look for (e.g., reducing JPEG block artifacts).
4.  **Distortion Minimization:** Defining a cost function (how much does modifying a pixel "cost"?) and using coding theory (matrix embedding) to embed the message with the minimum number of changes.
</details>

<details>
<summary>Français</summary>

Puisqu'il est impossible de modéliser parfaitement toutes les statistiques d'une image, on utilise des approches empiriques :

1.  **Stéganographie préservant le modèle (Model-based) :** On identifie un modèle statistique de l'image et on modifie les données tout en restaurant les statistiques (ex: l'histogramme) pour qu'elles restent conformes au modèle.
2.  **Modulation stochastique :** On simule le bruit naturel d'acquisition (bruit thermique, PRNU). Le message est caché en ajoutant un bruit qui ressemble à ce bruit naturel.
3.  **Stéganographie consciente de la stéganalyse (Steganalysis-aware) :** On essaie d'éliminer les artefacts que les stéganalyseurs recherchent (ex: réduire les artefacts de blocs JPEG).
4.  **Minimisation de la distorsion :** Définir une fonction de coût (combien "coûte" la modification d'un pixel ?) et utiliser des codes correcteurs (codage matriciel) pour insérer le message en faisant le minimum de changements.
</details>

---

## 28. Biometric forensics: classification

<details open>
<summary>English</summary>

Attacks against biometric systems are classified into two categories:

1.  **Direct Attacks (Presentation Attacks):** Performed at the **sensor** level. The sensor is fooled by a fake biometric object (spoofing). No internal system access is required.
2.  **Indirect Attacks:** Performed inside the system.
    * Bypassing the feature extractor.
    * Manipulating the reference database.
    * Interception of communication channels.
</details>

<details>
<summary>Français</summary>

Les attaques contre les systèmes biométriques sont classées en deux catégories :

1.  **Attaques directes (Presentation Attacks) :** Effectuées au niveau du **capteur**. Le capteur est leurré par un faux objet biométrique (spoofing). Aucun accès interne au système n'est requis.
2.  **Attaques indirectes :** Effectuées à l'intérieur du système.
    * Contournement de l'extracteur de caractéristiques.
    * Manipulation de la base de données de référence.
    * Interception des canaux de communication.
</details>

---

## 29. Types of presentation attacks

<details open>
<summary>English</summary>

Presentation Attacks (PAs) use physical or digital artifacts to fool the sensor:

* **Face:** Silicon masks, high-res photos (FaceID), video replay, Deepfakes (GAN-generated).
* **Fingerprint:** Fake fingers made of gelatin or wood glue ("Gummy fingers"), PCBs etched with latent fingerprints.
* **Iris:** High-quality paper prints, cosmetic contact lenses.
* **Voice:** Replay of recordings, speech synthesis (Text-to-Speech), voice conversion.
</details>

<details>
<summary>Français</summary>

Les attaques par présentation (PAs) utilisent des artefacts physiques ou numériques pour tromper le capteur :

* **Visage :** Masques en silicone, photos haute résolution (FaceID), vidéos (replay), Deepfakes (générés par GAN).
* **Empreinte digitale :** Faux doigts en gélatine ou colle à bois ("Gummy fingers"), circuits imprimés gravés avec l'empreinte latente.
* **Iris :** Impression haute qualité sur papier, lentilles de contact cosmétiques.
* **Voix :** Replay d'enregistrement, synthèse vocale (Text-to-Speech), conversion de voix.
</details>

---

## 30. Defence from face presentation attacks

<details open>
<summary>English</summary>

To defend against these, systems use Liveness Detection:

* **Software-based:** Analyzing data from the standard sensor.
    * **Texture:** Skin has a different texture than paper or screens (micro-texture analysis, LBP).
    * **Motion:** Eye blinking, head movements.
* **Hardware-based:** Using additional sensors.
    * **Depth:** To counter 2D photos.
    * **Thermal:** To check body heat (against cold masks).
    * **Infrared (IR):** Skin reflection properties differ from artificial materials.
* **Challenge-Response:** Asking the user to perform an action (turn head, read text).
</details>

<details>
<summary>Français</summary>

Pour se défendre, les systèmes utilisent la détection du vivant (Liveness Detection) :

* **Basées sur le logiciel (Software-based) :** Analyse des données du capteur standard.
    * **Texture :** La peau a une texture différente du papier ou des écrans (analyse par micro-texture, LBP).
    * **Mouvement :** Clignement des yeux, mouvements de la tête.
* **Basées sur le matériel (Hardware-based) :** Utilisation de capteurs supplémentaires.
    * **Profondeur (Depth) :** Pour contrer les photos 2D.
    * **Thermique :** Pour vérifier la chaleur corporelle (contre les masques froids).
    * **Infrarouge (IR) :** Propriétés de réflexion de la peau différentes des matériaux artificiels.
* **Challenge-Response :** Demander à l'utilisateur d'effectuer une action (tourner la tête, lire un texte).
</details>