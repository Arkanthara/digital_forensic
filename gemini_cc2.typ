#import "@preview/tablem:0.3.0": tablem
// Main report file
#import "template.typ": make-report, report-footnote
#import "metadata.typ": my-report

#show: make-report.with(my-report)


= Image Editing

== Traces de retouche d'image : Égalisation d'histogramme

L'égalisation d'histogramme est une technique de traitement d'image visant à *augmenter le contraste* d'une image. Elle y parvient en réattribuant les valeurs de pixels (leur luminance ou couleur) de manière à ce que la distribution des nouvelles valeurs soit approximativement *uniforme*. Cela a pour effet d'étaler la gamme dynamique des pixels, rendant les détails plus visibles, notamment dans les zones sombres ou très claires.

- *Identification :* Pour détecter si cette technique a été appliquée, on analyse l'*histogramme* de l'image. On cherche à calculer sa « uniformité ».
- *Caractéristique Clé (CDF) :* Une image ayant subi une égalisation d'histogramme se caractérise par une *fonction de répartition cumulative (CDF)* de ses valeurs de pixels qui est de forme *linéaire*. C'est cette linéarité de la CDF qui garantit la distribution uniforme des pixels en sortie.
- *Cas des images saturées :* L'application de l'égalisation à des images présentant des zones de *saturation* (valeurs de pixels maximales ou minimales atteintes) entraîne souvent un *déplacement* des *pics impulsifs* de l'histogramme, ce qui peut *complexifier la détection* de la manipulation.
- *Détection Compliquée par la Saturation :* La détection de l'égalisation repose souvent sur l'observation de l'*alignement des marches* ou de la *linéarité* de la CDF. Dans les images avec des zones de saturation (pixels à 0 ou 255), l'égalisation force ces grandes masses de pixels à *s'étaler* sur la nouvelle gamme dynamique. Cela a pour conséquence de *déplacer* les *pics impulsifs* (les marches abruptes) de l'histogramme vers des positions inattendues. Ce déplacement *perturbe les modèles statistiques* utilisés pour juger de la « propreté » de la distribution des pixels, rendant plus difficile de confirmer ou d'infirmer la présence d'une égalisation.

#pagebreak()

== Détection d'altération (_Tampering Detection_)

L'altération ou *forgerie* d'image (_tampering_) est l'application de techniques d'édition et de retouche après la prise de vue originale, dans le but de créer une _illusion_ ou une *tromperie*.

- Elle regroupe typiquement *cinq catégories* de techniques principales.

=== Détection d'altération : Techniques basées sur les pixels et le format

==== Techniques basées sur les pixels (_Pixel-based_)

Les pixels étant les unités fondamentales d'une image, toute manipulation perturbe leurs *propriétés statistiques* intrinsèques. L'analyse directe ou indirecte de ces propriétés révèle des *corrélations* spécifiques introduites par la retouche.

- La *manipulation d'image* corrompt les propriétés statistiques des pixels, notamment les statistiques *locales* qui peuvent devenir artificiellement lissées.
- *Clonage :* Consiste à copier/coller une région (de toute forme et emplacement) à l'intérieur de la même image.
- *Rééchantillonnage (_Resampling_) :* Introduit des *corrélations périodiques* spécifiques entre les pixels voisins, souvent détectables par l'analyse fréquentielle.
- *Épissage (_Splicing_) :* Technique de collage d'une partie d'image provenant d'une autre source, ce qui perturbe les *statistiques de Fourier d'ordre supérieur*.

*Identification par les pixels :*
- L'histogramme seul est peu informatif. Il faut analyser le *voisinage immédiat* des pixels.
- Un indice fort de modification est la *présence de deux régions exactement égales* dans une image, car deux photos d'un même objet, même prises dans des conditions identiques, n'auraient jamais les mêmes propriétés statistiques de bruit et de capteur.

==== Techniques basées sur le format (_Format-based_)

Ces techniques reposent sur l'analyse des spécificités et des *artefacts* introduits par la *compression avec perte* (_lossy compression_), le format JPEG étant le plus courant.

- La compression avec perte (comme JPEG) introduit des *artefacts* spécifiques dans l'image.
- Ces méthodes exploitent les particularités des schémas de compression pour détecter la forgerie.

===== Exemples

- *Double compression JPEG :* Lorsqu'une image déjà compressée en JPEG est éditée puis *recompressée* en JPEG, la deuxième compression laisse des motifs d'artefacts très reconnaissables.
- *Artefacts de blocage JPEG :* Si une zone est épissée, il est probable que la grille de compression JPEG du fragment inséré ne soit *pas alignée* sur celle de l'image de fond, créant des frontières d'artefacts.
- *Détection de fantômes JPEG (_JPEG Ghost detection_) :* Basée sur l'analyse des artefacts de double compression. Elle permet de détecter l'insertion de patchs d'image de *faible qualité* dans une image de *meilleure qualité*, signalant que différentes parties de l'image ont subi des niveaux de compression différents.

#pagebreak()

== Détection d'altération : Techniques basées sur la caméra, la physique et la géométrie

Ces techniques se concentrent sur l'analyse des propriétés intrinsèques liées au *processus de capture* ou à la *cohérence spatiale* de l'image.

==== Techniques basées sur la caméra (_Camera-based_)

Elles exploitent les caractéristiques spécifiques laissées par le capteur et le traitement interne de l'appareil photo.

- *Aberrations chromatiques :* Les variations dans les motifs d'aberration chromatique (franges de couleur aux contrastes) au sein d'une image peuvent signaler une *zone insérée* ou *altérée*, car elles devraient être uniformes.
- *Bruit du capteur (_Sensor Noise_) :* Toute altération _distorsionne_ le motif unique de bruit du capteur (le *PRNU* - _Photo-Response Non-Uniformity_), qui est comme l'empreinte digitale du capteur.
- *Mosaïque de filtres de couleur (_Color Filter Arrays - CFA_) :*
  - Le calcul des couleurs (_dématriçage_ ou _demosaicing_) à partir des pixels voisins introduit des *corrélations reconnaissables* entre les pixels d'une image.
  - Différents appareils photo utilisent des motifs de filtres différents (Bayer, Diagonal Bayer, Stripes, etc.) et des algorithmes d'interpolation _propriétaires_.
  - Ces méthodes, appliquées de manière répétée et selon des hypothèses bien connues, permettent de *détecter une incohérence* lorsqu'une partie de l'image a été traitée par un filtre différent.

==== Techniques basées sur la physique (_Physics-based_)

Ces méthodes vérifient si *la lumière et les ombres* dans l'image sont *cohérentes* avec la géométrie des objets, signalant si un objet a été inséré ou si les sources lumineuses sont impossibles.

- *Vérification des normales de surface (2D vs 3D) :*
  - Les *normales de surface* représentent l'*orientation* de la surface d'un objet par rapport à la source lumineuse (elles sont essentielles pour déterminer l'intensité de l'ombre/lumière).
  - *Éclairage 2D :* Cette approche simplifiée analyse les normales de surface (_surfaces normals_) en ne considérant que le *contour* d'un objet (sa _frontière d'occlusion_) dans le plan bidimensionnel de l'image.
  - *Éclairage 3D :* Utilise des modèles de scène plus complexes (parfois inspirés par la perception humaine) pour déterminer les *normales 3D* de la surface, permettant une vérification beaucoup plus précise de la *cohérence spatiale* entre la source de lumière, les objets, et les ombres.

===== Clarification : Analyse d'Éclairage 2D

L'approche d'Éclairage 2D est une technique *simplifiée* visant à déterminer la direction de la source lumineuse et la cohérence des ombres portées, sans avoir besoin de reconstruire l'espace 3D complet de la scène.

- *Principe des Normales de Surface :* La quantité de lumière (la luminosité) réfléchie par un point sur la surface d'un objet dépend de l'*angle* entre la *normale de surface* (la ligne perpendiculaire à la surface à ce point) et la *direction de la source lumineuse*.
- *Analyse 2D Simplifiée :* Pour simplifier le calcul, l'approche 2D se concentre uniquement sur la *frontière d'occlusion* (le *contour* de l'objet) dans l'image.
  - L'analyse suppose que le *changement d'intensité lumineuse* le long de ce contour est directement lié à la direction de la lumière.
  - Par exemple, le côté d'un objet faisant face directement à la lumière devrait être plus lumineux, tandis que le côté opposé (le contour d'ombre) devrait s'assombrir rapidement.
- *Détection de Forgerie :* L'objectif est de s'assurer que l'intensité lumineuse aux bords de l'objet inséré (_fragment épissé_) est *compatible* avec l'intensité lumineuse des bords des objets de l'image de fond. Si un objet inséré n'a pas été éclairé par la même lumière que l'arrière-plan, l'intensité des pixels le long de son contour trahira l'incohérence.
- *Limitation :* Cette méthode ignore la *courbure* interne et les *détails 3D* de la surface de l'objet, car elle ne regarde que sa projection 2D (le contour). Elle est donc *moins robuste* que l'analyse 3D, mais beaucoup plus rapide à calculer.

- *Analyse de l'environnement lumineux :*
  - Cette technique détermine la *direction* et la *nature* de la source lumineuse.
  - Elle simplifie souvent l'analyse en utilisant l'approximation d'une surface *Lambertienne* (une surface idéale qui réfléchit la lumière de manière *parfaitement diffuse* dans toutes les directions).
  - L'analyse se concentre ensuite sur la *limite occlusale* (le contour) d'un objet pour vérifier si l'éclairage sur cet objet est *compatible* avec l'éclairage du reste de la scène. Une incohérence signale qu'un objet a été inséré après coup.

==== Techniques basées sur la géométrie (_Geometric-based_)

Elles utilisent des principes de perspective pour vérifier si la scène et les objets insérés respectent les lois de la géométrie de projection.

- *Estimation du point principal (_Principal Point Estimation_) :* Le point principal est la projection du *centre optique* de la caméra sur le plan de l'image.
  - Lorsqu'un objet est *déplacé* (_translaté_) dans l'image, le point principal associé à cet objet doit se déplacer *proportionnellement* si la perspective est respectée. La détection vérifie cette proportionnalité.
- *Mesures métriques :* Emploie des outils de *géométrie projective* pour :
  - *Redresser* (_rectifier_) des surfaces planes (murs, sols).
  - Permettre, sous certaines conditions (si l'on connaît des éléments de référence), de prendre des *mesures réelles* à partir de la surface plane de l'image, révélant ainsi les incohérences d'échelle.

#pagebreak()

= Digital Forensics of Printed Document

== Principes généraux de l'analyse forensique des documents imprimés

Malgré la numérisation de la société, les documents imprimés (paiement, publicité, traçabilité, etc.) restent *largement utilisés* et *essentiels*, car certains contiennent des informations *capitales*.

- *Objectif :* Le but est de garantir l'_authenticité_ de ces documents (vérification de codes QR, d'étiquettes, lutte contre la contrefaçon, etc.).
- *Exemple :* Dans les magasins sans caisse (_stafless stores_), l'analyse forensique peut aider à s'assurer que l'article acheté correspond à l'article enregistré.

=== Effets négatifs et enjeux

L'un des défis majeurs est que les *mêmes technologies d'impression* professionnelles sont désormais *accessibles* et relativement *bon marché* pour le grand public et les contrefacteurs.

- *Fausses devises :* La production de fausse monnaie peut *détruire l'économie* d'un pays. Il arrive que la contrefaçon soit techniquement *mieux réalisée* que la monnaie originale.
- *Faux emballages de produits :* Création d'emballages pour des produits contrefaits, ce qui est *extrêmement critique* dans le domaine des *médicaments* où cela met en danger la santé publique.
- *Faux documents d'identité :* Création de faux documents d'identité intégrant des *attaques adversariales biométriques*.
- *Attaque par impression* (_Print Spoof Attack_) : C'est la forme la plus simple d'attaque contre les systèmes d'authentification biométrique (exemples : imprimer le visage d'une personne pour déverrouiller la reconnaissance faciale, ou utiliser des photos, vidéos, ou masques).

=== Protection contre la contrefaçon

- Pour contrer ces menaces, de nombreuses *entreprises sont spécialisées* dans le développement de solutions *anti-contrefaçon* (encres spéciales, motifs de sécurité, etc.).

#pagebreak()

== Attribution d'appareil : concepts de base

L'attribution d'appareil (_Device Attribution_) est un ensemble de techniques de vision par ordinateur appliquées à une version numérique d'un document, visant à identifier sa *source d'origine* (la machine qui l'a produit).

- L'attribution se fait en cherchant deux types de *signatures* ou *empreintes digitales* :
  - *Intrinsèques* (_Intrinsic / Blind_) : Artefacts présents naturellement dans le document, issus du processus de capture ou d'impression.
  - *Extrinsèques* (_Extrinsic / Watermarking_) : Informations insérées _intentionnellement_ par l'appareil (ex: micro-points de traçabilité).

- L'attribution vise à répondre à deux questions :
  - Quelle *marque* et quel *modèle* d'appareil a produit ce document ?
  - Quel *appareil spécifique* (série, unité) a produit ce document ?

=== Étapes de l'attribution

- *Compréhension du fonctionnement :* Il faut d'abord savoir comment fonctionne l'appareil (scanner, imprimante laser, etc.).
- *Recherche de l'unicité :* On cherche un *comportement unique* laissé par l'appareil dans le document.
  - *Empreintes courantes :* La *texture* des motifs d'impression, le *bruit* (_noise_), les *distorsions*, et d'autres imperfections comme la *poussière* ou les *rayures* (qui créent une empreinte digitale unique).
  - Ces comportements sont généralement le résultat du *processus de fabrication* ou de l'*usure* de l'appareil au fil du temps.
- *Description :* On modélise et décrit ces comportements uniques pour les utiliser dans l'attribution.

=== Principe de fonctionnement du scanner

- Les scans ont une *meilleure qualité* que les photographies prises avec un appareil photo.
- Une *lampe* éclaire le document à travers une vitre. La lumière est réfléchie par le papier.
- Un système de *miroirs* et de *lentilles* concentre la lumière réfléchie sur un *capteur* (_CCD_ ou _CMOS_).
- Les données analogiques du capteur sont numérisées par un *convertisseur analogique-numérique* (_ADC_).

=== Principe de l'impression laser

Le processus implique l'utilisation de la charge électrostatique, du toner et de la chaleur pour fixer l'encre.

- Le *tambour* (_drum_) est d'abord chargé positivement.
- Un *faisceau laser* décharge (_discharge_) les zones du tambour où l'encre doit être déposée.
- Le *toner* (poudre d'encre chargée positivement) adhère aux zones déchargées du tambour (conformément à l'image à imprimer).
- Le toner est ensuite transféré sur le papier.
- Le *four de fusion* (_fuser_) fixe définitivement les particules d'encre sur le document grâce à une *compression* et une *haute température*.

- *Avantage :* L'impression laser offre une *résolution plus élevée* que de nombreuses autres méthodes.

=== Artefacts de l'impression laser

L'œil humain ayant tendance à interpoler les petits détails, les imprimantes laser utilisent de *petits points très rapprochés* (_halftones_) pour simuler la couleur globale. Les différences subtiles entre les machines sont souvent visibles dans ces *demi-tons* (_halftones_).

- Les composants *électro-mécaniques* des imprimantes laser se comportent différemment d'une machine à l'autre.
- *Banding :* Motif texturé composé de *lignes sombres, horizontales, périodiques et à basse fréquence*. Il est causé par les variations des composants du laser, des *vibrations*, ou une mauvaise régulation de la vitesse de déplacement du papier (perpendiculaire au mouvement).
- *Jitter :* Artefacts *horizontaux* mais avec une gamme de fréquence et une durée différentes. Ils sont causés par des perturbations *oscillatoires* du tambour de l'imprimante et du rouleau de développement (_developer roller_).
- *Jitter incliné* (_Skewed Jitter_) : Artefact *périodique* similaire, mais il se manifeste par des *lignes verticales*.

==== Clarification : Causes des Artefacts d'Impression Laser

Les imprimantes laser sont des machines de haute précision qui s'appuient sur un alignement et une vitesse de rotation et de translation *parfaits*. Les artefacts (Banding, Jitter) résultent des *imperfections* inhérentes aux composants électro-mécaniques et à leur usure.

- *Causes Générales :*
  - La production de masse fait que les composants (tambour, rouleaux, moteurs) ont de légères *tolérances* de fabrication différentes d'une machine à l'autre.
  - Ces différences entraînent des *variations de vitesse* et des *oscillations* minimes, mais régulières.

- *1. Banding :*
  - *Cause :* Le *Banding* (_lignes sombres horizontales_) est principalement dû aux incohérences dans le *mouvement du papier* et le *processus de charge*.
  - *Mécanisme :*
    - *Régulation de vitesse :* Le moteur qui tire le papier n'a pas une vitesse parfaitement constante. Si le papier ralentit ou accélère légèrement pendant l'impression d'une ligne, cela crée une variation de la densité d'encre (une bande plus sombre ou plus claire).
    - *Vibrations :* Les vibrations des rouleaux ou d'autres composants, perpendiculaires à la direction d'impression, affectent la qualité de la ligne sur de grandes zones, créant un motif de *basse fréquence*.

- *2. Jitter :*
  - *Cause :* Le *Jitter* (_flottement horizontal_) est directement lié à la *rotation* des deux composants critiques que sont le *tambour* (_drum_) et le *rouleau de développement* (_developer roller_).
  - *Mécanisme :*
    - Ces rouleaux ne sont jamais parfaitement cylindriques ni parfaitement stables. Ils présentent de légères *oscillations* ou *excentricités* pendant leur rotation.
    - Ces micro-oscillations font que l'application du toner sur le tambour (et donc sur le papier) est *décalée horizontalement* d'une ligne à l'autre. Ce décalage crée des bords irréguliers et des artefacts de *haute fréquence* (car ils sont liés à la rotation rapide).

- *3. Jitter incliné* (_Skewed Jitter_) :
  - *Cause :* Bien que similaire au Jitter, le *Jitter incliné* se manifeste par des *lignes verticales* ou obliques.
  - *Mécanisme :* Il est souvent causé par un *défaut d'alignement* ou un problème dans l'optique du *faisceau laser* lui-même, plutôt que par les rouleaux. La ligne laser qui écrit sur le tambour peut ne pas être parfaitement perpendiculaire ou suivre un alignement constant sur toute la largeur du tambour, résultant en une distorsion périodique verticale.

Ces trois artefacts constituent une *signature physique* de l'appareil, utilisable pour l'attribution.

#pagebreak()

== Authentification de documents imprimés : Approche active

=== Analyse forensique active sur les documents imprimés

L'approche *active* consiste à *insérer intentionnellement* des informations (des signatures _extrinsèques_) dans le document ou durant le processus d'impression, dans le but de faciliter l'*identification de son authenticité*.

- Ces signatures extrinsèques peuvent être détectées : *visuellement*, à l'aide de *logiciels* ou via des *procédures physico-chimiques*.
- *Exemples de techniques actives :*
  - Stéganographie par l'imprimante (_Printer Steganography_).
  - Codes-barres 2D (_2D Barcodes_).

- *Code d'identification de la machine (_Machine Identification Code_) :*
  - Xerox a été le pionnier de ce mécanisme dès le milieu des années 80 (méthode non publique jusqu'en 2004).
  - Il s'agit d'une *matrice de points jaunes minuscules* (_yellow dots_) dispersés sur toute la zone d'impression.
  - Ce code encode le *numéro de série* de l'appareil, la *date* et l'*heure* de l'impression, et est répété plusieurs fois.
  - Des scientifiques (notamment à l'Université de Dresde) ont découvert au moins quatre schémas d'encodage différents après analyse.

==== Désavantages des codes d'identification de machine

- Ils sont principalement utilisés dans les imprimantes vendues aux *États-Unis* (exigence du FBI).
- Ils peuvent être *anonymisés* ou *retirés* (par exemple, en ajoutant d'autres points jaunes pour perturber le code).

#pagebreak()

== Approches pour la détection de la source de texte imprimé (Attribution passive)

L'attribution passive (_Passive Source Attribution_) vise à identifier la source d'un document imprimé en analysant les *empreintes digitales* (_fingerprints_) _intrinsèques_ laissées par l'appareil d'impression (généralement laser ou jet d'encre).

=== Empreintes digitales du texte imprimé (_Printed Text Fingerprints_)

Les imperfections physiques du processus d'impression laser créent des *micro-motifs* qui sont uniques à chaque machine.

- Les zones d'un document pouvant être utilisées pour l'analyse d'attribution sont :
  - Les *caractères* : L'analyse se concentre sur les *irrégularités* des contours et du remplissage des lettres (_appliqué sur le texte_).
  - Les *zones segmentées* : On isole des cadres ou des blocs de texte/image pour analyser les motifs locaux d'artefacts (comme le *Jitter* ou le *Banding*) (_appliqué sur le texte et les images_).
  - Le *document entier* : Une analyse globale pour extraire le motif de bruit moyen du document (_appliqué sur le texte et les images_).

=== Avantages de l'approche passive

L'approche passive est privilégiée pour sa robustesse et sa pérennité par rapport à l'approche active (qui utilise des codes d'identification insérés).

- *Résistance aux modifications :* La modification du document (par exemple, en insérant un faux code d'identification d'imprimante) ne *corrompt pas* les résultats de l'analyse passive, car celle-ci repose sur les *imperfections physiques* et non sur des données encodées.
- *Indépendance temporelle :* Elle fonctionne même si le document a été imprimé il y a *longtemps* et que les systèmes d'identification actifs (_Machine Identification Codes_) ont évolué ou ne sont plus supportés. Les *signatures mécaniques* de l'appareil restent pertinentes.

#pagebreak()

== Attribution par imprimante laser (_Laser Printer Attribution_)

L'attribution par imprimante laser est la recherche de la signature de la machine dans le document imprimé. Selon la nature du document analysé, elle peut être divisée en trois catégories :

- *Texte* (uniquement).
- *Images / Documents couleur*.
- *Texte et images / Documents couleur* (combinés).

=== Amélioration de la précision par l'imagerie et le post-traitement

Pour augmenter la *précision* des méthodes d'attribution, les experts forensiques utilisent souvent *différents types de scanners* et des techniques de post-traitement.

- L'utilisation de *différents scanners* (ou de scanners avec des paramètres différents) est cruciale car la *grille du capteur* de chaque scanner interagit différemment avec les motifs d'artefacts (Jitter, Banding).
- Si la grille du scanner est *alignée* avec un artefact d'impression, elle peut *ne pas le révéler* clairement. En utilisant un scanner dont la grille est *désalignée*, les motifs fins et périodiques de l'imprimante deviennent plus visibles.
- Le scan est parfois suivi de *post-traitement* (filtrage, amélioration) pour isoler et accentuer les artefacts.
- C'est en combinant les informations révélées par ces différents scans que l'on peut calculer l'*empreinte digitale* (_fingerprint_) complète du document.

=== Attribution par imprimante laser par Ali et coll.

Cette méthode est un exemple d'approche passive de détection de source d'imprimante laser :

- *Cible :* Elle est appliquée spécifiquement sur des *caractères* de texte (la lettre _I_ est souvent choisie pour sa *simplicité* structurelle).
- *Empreinte :* Des *projections* (valeurs de pixels) du caractère sont utilisées comme empreintes.
- *Pré-traitement :* Comme les caractères extraits peuvent avoir des tailles et des polices différentes, et pour éviter le problème de la *malédiction de la dimensionnalité* (_curse of dimensionality_) en apprentissage automatique, les images sont pré-traitées par *Analyse en composantes principales* (_Principal Component Analysis_ - PCA).
- *Classification :* Un classifieur d'*apprentissage automatique* (souvent un Modèle de mélange gaussien - _Gaussian Mixture Model_ - GMM) est entraîné pour *reconnaître* ces motifs de texture uniques pour chaque imprimante.

- *Limitation de la méthode :*
  - La précision est *faible* lorsque les imprimantes testées proviennent de la *même génération* (ex : les modèles LJ1000 et LJ1200 de la même marque).
  - Un *problème pratique* est que la lettre "_I_" n'apparaît pas assez fréquemment dans tous les documents pour garantir l'extraction d'un nombre suffisant d'échantillons.

#pagebreak()

== Attribution par imprimante laser : Approche GLCM (Mikkilineni et coll.)

Cette méthode utilise l'analyse statistique de texture pour caractériser l'empreinte d'une imprimante laser.

- *Cible :* Les *caractères* de texte (souvent la lettre "_E_" sont analysés).
- *Description :* Les lettres sont décrites par les *statistiques* de la *Matrice de cooccurrence des niveaux de gris* (_Gray-Level Co-occurrence Matrices_ - GLCM), en considérant plusieurs directions de voisinage.
- *Classification :* Les vecteurs de caractéristiques extraits de la GLCM sont ensuite utilisés comme entrée dans un classifieur d'*apprentissage automatique* multi-classes.

- *Matrice GLCM :* La matrice de cooccurrence est un *histogramme 2D* qui donne un aperçu de la *fréquence* à laquelle une valeur de pixel apparaît à côté d'une autre valeur de pixel dans une direction et à une distance donnée.
- *Statistiques extraites (normalisées) :*
  - *Contraste :* Mesure de la différence d'intensité entre un pixel et ses voisins (texture rugueuse vs lisse).
  - *Corrélation :* Degré de relation linéaire d'un pixel avec ses voisins (homogénéité).
  - *Énergie :* Mesure de la régularité ou de la répétition des paires de pixels (texture uniforme).
  - *Homogénéité :* Mesure de la proximité de la distribution des éléments de la GLCM par rapport à sa diagonale (texture homogène).

- *Avertissement :* Le fait de *changer le toner* ou d'autres consommables peut *effacer* ou *modifier* certaines propriétés locales de l'impression, perturbant l'empreinte digitale.

===== Détail de la Matrice de Cooccurrence des Niveaux de Gris (_GLCM_)

La *Matrice de Cooccurrence des Niveaux de Gris* (_Gray-Level Co-occurrence Matrix_ - GLCM) est un outil statistique largement utilisé pour *analyser la texture* des images. Elle quantifie la fréquence à laquelle différentes paires de valeurs de pixels (niveaux de gris) se produisent à une *distance* et dans une *direction* spécifiée.

- *Principe de base :* La GLCM est un *histogramme 2D* qui capture les *relations spatiales* entre les pixels voisins.
  - Si l'image a $N$ niveaux de gris (par exemple, 256), la GLCM est une matrice de taille $N times N$.
  - Chaque entrée $(i, j)$ de la matrice stocke le *nombre de fois* où un pixel avec la valeur d'intensité $i$ apparaît immédiatement voisin (selon un angle et une distance donnés) d'un pixel avec la valeur d'intensité $j$.

- *Paramètres Clés :* La GLCM doit être calculée en fonction de deux paramètres fondamentaux :
  - *La Distance ($delta$) :* C'est l'écart spatial entre les deux pixels analysés (généralement $delta=1$ pixel pour l'attribution d'imprimante).
  - *L'Angle ($theta$) :* C'est la direction du voisinage (souvent 0°, 45°, 90°, 135°, etc.). Le *GLCM multi-directionnel* utilise plusieurs de ces angles pour obtenir une caractérisation complète.

- *Application à l'Imprimante Laser :*
  - La *signature* d'une imprimante (ses défauts mécaniques) se manifeste par des *motifs de points* et des *irrégularités* qui changent la manière dont les pixels clairs et foncés sont voisins.
  - En calculant la GLCM, on capture l'aspect *micro-textural* de ces imperfections. Par exemple, une imprimante avec beaucoup de *Jitter* aura une GLCM différente d'une imprimante avec un motif de *Banding* prononcé.

- *Extraction de Caractéristiques (Statistiques) :*
  - La matrice elle-même est trop grande pour être utilisée directement. On en extrait donc des *statistiques* appelées *caractéristiques de Haralick* (comme le Contraste, l'Homogénéité, la Corrélation, l'Énergie), qui sont des nombres synthétiques décrivant la texture.
  - *Exemple - Contraste :* Les imprimantes ayant des bords de caractères très irréguliers (une texture "rugueuse") auront des valeurs de contraste (différence d'intensité) élevées entre les pixels voisins.
  - *Normalisation :* Ces coefficients sont *normalisés* pour s'assurer qu'ils sont indépendants de la taille du bloc analysé (lettre ou _frame_).

==== Attribution par imprimante laser par Ferreira et coll.

Cette approche est une *amélioration* de la méthode de Mikkilineni et coll.

- *Principes :* Elle propose une *analyse de texture multi-échelle et multi-directionnelle* dans le matériau imprimé.
  - L'approche repose sur le fait qu'il existe des motifs d'impression (_printing patterns_) *multi-échelles* et *multi-directionnels* (zones avec un gradient spécifique) dans le document.
  - Elle peut être appliquée sur le *document entier*, des *lettres* ou des *régions d'intérêt* (_frames_).
- *Amélioration :* Elle utilise un *descripteur _ad-hoc_* ainsi qu'une *fusion des résultats* de la méthode de Mikkilineni et de ce nouveau descripteur.
- *Analogie PRNU :* Similaire à l'extraction du *PRNU* pour les caméras, on prend *plusieurs échantillons* (plusieurs lettres ou régions) pour obtenir une *lettre moyenne* ou une *empreinte moyenne* plus stable de l'imprimante.

- *Nouveautés de cette méthode :*
  - Approche *GLCM multi-directionnelle*.
  - Approche *GLCM multi-directionnelle et multi-échelle*.
  - Approche par *Filtre de Texture de Gradient Convolutionnel* (_Convolutional Gradient Texture Filter_ - CGTF).
  - Étude sur des *blocs* (_chunks_) de documents (_frames_).
  - Utilisation de la *réduction de dimensionnalité* (_dimensionality reduction_).

=== Approche GLCM multi-directionnelle (GLCM-MD)

- *Principe :* La GLCM est utilisée comme un *histogramme 2D* pour décrire le voisinage des pixels dans une direction et un décalage donné.
- *Vecteur de caractéristiques :* On utilise *huit directions* (_directions_) de voisinage différentes, générant huit matrices.
  - Pour chaque direction de voisinage, *22 statistiques* sont calculées.
  - Cela résulte en un vecteur de caractéristiques de $22 times 8 = 176$ dimensions utilisé pour identifier la texture de l'imprimante.
- *Processus :* Document -> Extraction des lettres -> Différentes échelles -> Calcul du vecteur de caractéristiques GLCM -> Réduction de dimensionnalité -> Classification.

=== Approche GLCM multi-directionnelle et multi-échelle

- Cette approche ajoute à la précédente la *décomposition pyramidale gaussienne* (_Gaussian Pyramidal Image Decomposition_).
- *Échelles :* *Quatre échelles* sont considérées : l'originale, deux réductions de taille (_downscales_) et une augmentation de taille (_up-scale_).
- *Vecteur de caractéristiques :* À chaque échelle, *176 caractéristiques statistiques* sont extraites, ce qui augmente considérablement le nombre de descripteurs.

=== Étude sur les blocs de documents (_Frames_)

Cette analyse s'effectue sur des blocs d'images (_blocks_) du document, souvent utilisée lorsque le document est considéré comme une *image complète*, par opposition à l'analyse sur une seule lettre.

- *Objectif :* Étudier les signatures d'imprimante laser dans des *zones segmentées* du document.
- *Définition du bloc :* Les blocs sont des zones *rectangulaires* de l'image contenant *suffisamment de matériel imprimé*.
  - *Exemple :* Le document est divisé en une matrice de blocs (par exemple, cinq colonnes par six rangées).
  - *Validation du bloc :* Pour qu'un bloc soit considéré comme *valide*, il doit contenir un *ratio minimal acceptable* entre les pixels foncés (noir/gris foncé) et les pixels clairs (blanc/gris clair), par exemple un ratio minimum de 0.02.
  - L'analyse se concentre généralement sur des blocs d'*intensité moyenne*.
- *Résultat :* La description et la classification des empreintes sont effectuées sur ces zones.

=== Approche GLCM Multi-directionnelle vs GLCM Simple

La différence fondamentale réside dans la *granularité de l'analyse spatiale*. Là où l'approche simple tend à "lisser" les informations, l'approche multi-directionnelle (_GLCM-MD_) conserve les spécificités de chaque angle pour créer une signature beaucoup plus riche.

=== GLCM Simple (Approche Standard)

- *Méthode :* Elle calcule généralement la matrice de cooccurrence sur *une seule direction* (souvent horizontale à $0^degree$) ou effectue la *moyenne* des statistiques obtenues sur quatre directions principales ($0^degree, 45^degree, 90^degree, 135^degree$).
- *Limitation :* En ne regardant qu'une direction ou en faisant une moyenne, cette méthode *écrase* les détails directionnels. Elle suppose implicitement que la texture est similaire dans toutes les directions.
- *Risque :* Elle peut manquer des artefacts spécifiques qui n'apparaissent que sous un angle précis (par exemple, un défaut mécanique oblique).

=== GLCM Multi-directionnelle (_GLCM-MD_)

- *Méthode :* Elle ne fait *aucune moyenne*. Elle calcule *séparément* les matrices et les statistiques pour un ensemble élargi de directions (typiquement *huit directions* distinctes).
- *Exploitation de l'Anisotropie :* Elle part du principe que les défauts d'imprimante (Banding, Jitter) sont *orientés* :
  - Le *Banding* crée des motifs horizontaux forts (détectés par la direction $0^degree$).
  - Le *Jitter* ou les rayures créent des motifs verticaux ou diagonaux (détectés par les directions $90^degree$ ou obliques).
- *Signature enrichie :* Au lieu d'obtenir une valeur globale de contraste pour l'image, on obtient un *profil de contraste* selon l'orientation.
  - Le classifieur peut ainsi apprendre : "Cette imprimante a un fort contraste à $90^degree$ mais un faible contraste à $0^degree$".
- *Explosion des caractéristiques :* C'est ce qui explique la taille du vecteur.
  - *GLCM Simple :* 22 statistiques (moyennées).
  - *GLCM-MD :* 22 statistiques $times$ 8 directions = *176 caractéristiques* distinctes.

#pagebreak()

== Descripteur de filtre de gradient de texture convolutionnel (_Convolutional Texture Gradient Filter_ - CTGF)

Cette méthode calcule les textures voisines dans des zones spécifiques (intervalles) de gradient pour créer une signature d'imprimante sous forme d'histogramme.

- Elle repose sur l'idée que les *textures dans les zones presque plates* (à faible gradient) sont générées *intentionnellement* par le *firmware* de l'imprimante (techniques de _dithering_ ou demi-tons) et contiennent une signature très discriminante.

=== Étapes de l'algorithme

- *Étape 1 : Négatif*
  - Les pixels $s$ de l'image scannée $S$ sont inversés selon la formule $n = 255 - s$.
  - Les valeurs proches de 0 deviennent le blanc, et 255 le noir. Cela produit l'image négative $N$, ce qui simplifie les calculs suivants.
- *Étape 2 : Recadrage des bordures*
  - On élimine *6% des pixels* sur chaque bord de l'image négative $N$ (produisant la matrice $R$).
  - *But :* Supprimer le *bruit de numérisation* souvent présent aux bords (lumière externe, pliure du papier, artefacts mécaniques du scanner).
- *Étape 3.1 : Convolution (Somme)*
  - On calcule la *somme* des voisins dans une fenêtre $n times n$ pour chaque pixel de $R$.
  - Cela correspond à une *convolution* de $R$ avec une matrice $n times n$ remplie de 1. Le résultat est la matrice des sommes de textures $C$.
- *Étape 3.2 : Calcul du Gradient (R)*
  - En parallèle, on calcule le gradient (la différence absolue maximale) entre un pixel central et ses voisins ($n^2 - 1$).
  - La matrice de gradient final $G$ est construite ainsi :
    $
      G(i, j) = cases(0 "si le pixel est au bord", max_(i - 1 <= p <= i + 1 \ j - 1 <= q <= j + 1)(d_(R_(i, j), R_(p, q))) "sinon")
    $
    où $d_(x, y) = |x - y|$.
- *Étape 4 : Filtre de Gradient*
  - On ne conserve que les valeurs de textures de la matrice $C$ dont le gradient correspondant dans $G$ se situe dans un *intervalle optimal* $[g_("low"), g_("high")]$ (trouvé expérimentalement).
  - La matrice finale $T$ est donc $C$ épurée des valeurs hors de la plage de gradient pertinente.
- *Étape 5 : Construction de l'Histogramme*
  - On construit un histogramme de la distribution des valeurs dans $T$.
  - L'échelle des valeurs va de 0 à $255 times n^2$. Le vecteur $H$ a donc cette dimension.
- *Étape 6 : Normalisation Min-Max*
  - Le vecteur final $V$ est normalisé pour ramener ses composantes dans l'intervalle $[0, 1]$.

=== Réduction de dimensionnalité

Un filtre CTGF $3 times 3$ génère un vecteur de 2295 dimensions, ce qui entraîne la *malédiction de la dimensionnalité* (_curse of dimensionality_) pour les classifieurs.

- *Problème :* Certaines composantes ne varient pas assez pour être utiles à la classification.
- *Solution :*
  - On empile toutes les caractéristiques de l'ensemble d'entraînement dans une matrice $F$.
  - On calcule l'*étendue* (_range_) des valeurs pour chaque composante (Max - Min).
  - On calcule la *moyenne* de toutes ces étendues.
  - *KeepVector :* On élimine les composantes dont l'étendue est *inférieure à la moyenne*.

- *Note :* L'extraction se concentre sur les *bords* (ou les zones de gradient spécifique) car c'est là que résident les variations subtiles permettant de distinguer des imprimantes, même celles ayant des signatures très similaires.

=== Explication approfondie du CTGF

Le *CTGF* (_Convolutional Texture Gradient Filter_) est une méthode avancée pour extraire l'*empreinte digitale* d'une imprimante laser à partir d'un document scanné.

==== À quoi ça sert ?

L'objectif est de capturer le *micro-motif d'impression* (la manière dont l'encre est déposée) sans être perturbé par le contenu du texte (la forme des lettres).

- Les imprimantes laser ne peuvent pas imprimer de "gris" réel. Pour simuler du gris, elles placent des points noirs plus ou moins espacés. C'est le *tramage* (_halftoning_).
- Chaque marque et modèle d'imprimante utilise un algorithme de tramage et une mécanique différents.
- Le CTGF sert à *isoler* et *quantifier* ce motif de tramage spécifique, qui est invisible à l'œil nu mais unique à l'imprimante.

==== Pourquoi ces étapes de calcul ?

Chaque étape de l'algorithme a une raison physique précise pour "nettoyer" le signal et ne garder que la signature de l'imprimante :

- *1. Le Négatif :*
  - C'est une commodité mathématique. En inversant l'image, l'encre (noire) devient des valeurs élevées (blanches) et le papier (blanc) devient 0. Cela rend les sommes et les calculs de "quantité d'encre" plus intuitifs.

- *2. Le Recadrage des bords :*
  - Les bords d'un scan sont souvent "sales" (ombres, distorsion de la lumière, bords du papier). Ces artefacts viennent du *scanner*, pas de l'imprimante. On les supprime pour ne pas fausser l'analyse.

- *3. La Convolution (Somme sur voisinage $n times n$) :*
  - *Le but :* Au lieu de regarder un pixel isolé (qui est soit noir, soit blanc), on regarde la *densité d'encre* dans une petite zone (le voisinage).
  - Cela permet de transformer une grille de points binaires en une valeur de "texture" ou de niveau de gris local. C'est ce qui révèle le motif de tramage.

- *4. Le Gradient et le Filtre (L'étape cruciale) :*
  - *Pourquoi ?* On ne veut pas analyser *tout* le document.
    - Les zones totalement blanches (papier vide) n'ont pas d'encre, donc pas de signature.
    - Les bords nets des lettres (texte noir pur) ont un contraste trop fort qui masque les micro-détails.
  - *Le filtre :* On calcule le gradient (le changement d'intensité). On ne garde que les pixels qui ont un gradient *moyen* (ni plat, ni bordure abrupte).
  - C'est dans ces zones de transition douce (les bords flous ou les zones grisées) que le *firmware* de l'imprimante laisse sa signature la plus visible (le motif de points artificiels).

- *5. L'Histogramme :*
  - Une fois qu'on a isolé ces valeurs de texture "pure", on ne garde pas l'image (trop lourde). On compte simplement *combien de fois* chaque type de texture apparaît.
  - Cette distribution (l'histogramme) devient la signature unique : "Cette imprimante produit beaucoup de textures de type A et peu de type B".

=== Importance de l'Histogramme de Texture (CTGF)

Le fait de savoir qu'une imprimante produit *beaucoup* de texture A et *peu* de texture B est la *clé de l'attribution d'appareil*. Cette distribution est le *profil statistique* unique qui remplace l'image.

==== La Signature Unique d'une Imprimante

- *Texture A et Texture B :* Dans le contexte du CTGF, la *Texture A* pourrait représenter, par exemple, une somme de voisinage qui indique un motif de quatre points serrés. La *Texture B* pourrait être un motif de deux points lâches.
- *Raison Physique :* La fréquence (la distribution) de ces motifs n'est pas aléatoire. Elle est déterminée par :
  - *Le Firmware :* L'algorithme de tramage (_halftoning_) intégré par le fabricant dans le logiciel de l'imprimante (le *firmware*) décidera *exactement* comment les zones grises seront converties en points. Ce choix est unique à la marque/modèle.
  - *La Mécanique :* Les micro-défauts de l'appareil (légères variations de la vitesse du laser, du tambour ou du moteur) vont *distordre* la distribution idéale. Une imprimante légèrement défectueuse sur son axe horizontal pourrait favoriser la texture A au détriment de la texture B.

==== Pourquoi l'Histogramme est la Signature

- *Quantification :* L'histogramme est la manière la plus simple et la plus *efficace* de quantifier cette signature. Il ne contient que des nombres (les comptes de fréquences) et non des millions de pixels.
- *Distribution Caractéristique :* Deux imprimantes du même modèle, mais qui ont été utilisées différemment (usure, poussière, environnement) auront des *distributions* (_histogrammes_) *très proches* mais *jamais identiques*. L'histogramme de l'imprimante \#1 peut présenter un pic à 500 (texture A) et l'imprimante \#2 un pic à 510. C'est cette *micro-variation* qui permet la distinction.
- *Analyse par Apprentissage Automatique :*
  - Le classifieur d'apprentissage automatique (_Machine Learning_) (l'étape finale) n'a pas besoin de savoir *ce que* sont la texture A et la texture B.
  - Il apprend simplement que le *vecteur de fréquences* (l'histogramme) $["Fréquence_A", "Fréquence_B", "Fréquence_C", ...]$ correspond à l'Imprimante X, tandis que le vecteur $["Fréquence'_A", "Fréquence'_B", "Fréquence'_C", ...]$ correspond à l'Imprimante Y.
  - La *différence dans la distribution* (le fait que le pic soit à 500 au lieu de 510) devient le *critère discriminant* pour l'attribution.

- *Conclusion :* L'histogramme de texture est donc une *représentation numérique* de l'empreinte digitale laissée par le *firmware* et la *mécanique* de l'imprimante.

#pagebreak()

== Apprentissage profond pour l'attribution de source d'imprimante laser

L'utilisation de l'apprentissage profond (_Deep Learning_ - DL) est une approche *passive* visant à automatiser l'extraction des signatures fines d'une imprimante laser.

- *Méthode :* Les caractères (souvent les lettres "_A_" et "_E_" pour leur fréquence) sont extraits puis caractérisés par un *ensemble* (_ensemble_) de Réseaux Neuronaux Convolutionnels (_Convolutional Neural Networks_ - CNN).
  - Les caractérisations (caractéristiques extraites) sont *fusionnées*.
  - La classification finale est obtenue par un *vote majoritaire* de classifieurs SVM (_Support Vector Machine_) individuels.

- *Réseau en Ensemble :* Chaque membre de l'ensemble de CNN travaille sur des *entrées différentes* de l'image du caractère :
  - L'image brute (_raw image_).
  - Le *résidu médian* (_median residual_).
  - Le *résidu moyen* (_average residual_).

- *Rôle du CNN :* Les réseaux agissent comme des *extracteurs de caractéristiques*. Leurs sorties de l'avant-dernière couche sont fusionnées et ces *vecteurs de caractéristiques* sont ensuite envoyés aux classifieurs SVM.

- *Architecture :* L'approche proposée utilise généralement un CNN très *peu profond* (_very shallow CNN_) optimisé pour des entrées de $28 times 28$ pixels.

=== Avantages et défis de l'Apprentissage Profond (DL)

- *Avantages :* Le DL permet de traiter un *grand nombre de classes* (par exemple, 100 producteurs avec 10 modèles = 1000 classes maximum). Il n'est *pas limité par la mémoire* ou les heures de bureau (une fois entraîné).
- *Défis :*
  - L'*interprétation des résultats* peut être difficile.
  - La *préparation des données* doit être très rigoureuse.
  - Ces réseaux nécessitent une *grande quantité de données* pour l'entraînement.

=== Les Images Résiduelles (Images de Bruit)

- *Résidus :* On utilise les images de *résidu médian* et de *résidu moyen* pour l'analyse, car elles *isolent la signature* de l'imprimante (le bruit et les défauts).
- *Focus sur la transition :* L'analyse se concentre uniquement sur la *zone de transition* (le contour des caractères) car les histogrammes sont ensuite utilisés, et ceux-ci sont *indépendants de la forme* (_shape independent_). L'important est le *motif de texture* dans cette zone, et non la forme de la lettre elle-même.

- *Solution optimale :* La meilleure solution forensique est souvent une *combinaison* des capacités humaines d'interprétation et des performances de l'intelligence artificielle pour l'extraction de caractéristiques.

=== Rôle du SVM et combinaison avec les CNN

L'approche décrite utilise les Réseaux Neuronaux Convolutionnels (_CNN_) pour une tâche (extraction) et les Machines à Vecteurs de Support (_Support Vector Machines_ - SVM) pour une autre (classification).

==== Pourquoi utiliser le SVM plutôt que le CNN seul ?

L'utilisation d'un SVM après l'extraction des caractéristiques par le CNN présente plusieurs avantages stratégiques, particulièrement en *analyse forensique* où les ensembles de données (documents imprimés pour chaque imprimante) sont souvent limités :

- *1. Le CNN comme Extracteur de Caractéristiques :*
  - Le CNN est *excellent* pour apprendre automatiquement les *caractéristiques visuelles* pertinentes (les motifs de texture, le bruit) laissées par l'imprimante (similaire à la GLCM, mais en beaucoup plus sophistiqué).
  - Après l'apprentissage, on utilise la sortie de l'avant-dernière couche du CNN (le *vecteur de caractéristiques*) qui est une *représentation dense* de la signature de l'imprimante.

- *2. Efficacité et Robustesse du SVM :*
  - Les SVM sont particulièrement *efficaces* pour la classification lorsque le *nombre d'échantillons* par classe est *faible* (ce qui est souvent le cas pour l'attribution forensique spécifique d'une machine).
  - Un SVM est intrinsèquement conçu pour trouver la *meilleure frontière* de décision (l'*hyperplan*) qui maximise la marge entre les classes. Il est très robuste face à la *grande dimensionnalité* des vecteurs de caractéristiques fournis par le CNN.
  - *Le risque avec un CNN de bout en bout :* Utiliser le CNN pour l'extraction *et* la classification pourrait nécessiter beaucoup plus de données d'entraînement pour atteindre une généralisation satisfaisante, et il risquerait de faire du *surapprentissage* (_overfitting_) sur de petits ensembles de données.

- *3. Fusion des Caractéristiques :*
  - Dans cette approche, les caractéristiques provenant de *plusieurs réseaux* (entraînés sur l'image brute, les résidus médians, etc.) sont *fusionnées*. Un SVM est très adapté pour classer ces *vecteurs de caractéristiques fusionnés* de haute dimension.

==== Qu'est-ce qu'une Machine à Vecteurs de Support (SVM) ?

Une *Machine à Vecteurs de Support* (_Support Vector Machine_ - SVM) est un algorithme de classification très populaire et robuste en *apprentissage supervisé*.

- *Principe :* L'objectif du SVM est de trouver un *hyperplan* dans un espace multidimensionnel qui sépare les classes de données de la manière la plus nette possible.
- *Hyperplan et Marge :*
  - L'*hyperplan* est la frontière de décision.
  - Le SVM choisit l'hyperplan qui possède la *marge la plus large* (la distance la plus grande) entre la frontière et les points de données les plus proches de chaque classe.
- *Vecteurs de Support :* Les points de données les plus proches de l'hyperplan sont appelés les *vecteurs de support*. Ce sont ces points critiques qui déterminent la position et l'orientation de l'hyperplan.
- *Espace de Caractéristiques :* Pour séparer les classes non linéairement (lorsque la frontière n'est pas une simple ligne droite), le SVM utilise des *fonctions de noyau* (_kernel functions_) pour projeter les données dans un *espace de plus haute dimension* où la séparation linéaire devient possible.

#pagebreak()

== Attribution de source des images imprimées : Approches et Objectifs

L'*objectif principal* de l'attribution de source pour les images imprimées est d'*isoler et de quantifier* les *défauts microscopiques* introduits par la *mécanique* et les *algorithmes d'impression* (_firmware_) d'une machine spécifique. Ces défauts, qui sont la *signature* (_fingerprint_) de l'imprimante, se manifestent souvent dans le *bruit* et la *texture* de l'impression.

=== 1. Attribution par bruit résiduel (Lee et Choi - GLCM)

Cette approche cherche à révéler l'empreinte de l'imprimante en se concentrant sur les *irrégularités de dépôt d'encre*.

- *Espace couleur :* Les documents sont convertis en *CMY* (Cyan, Magenta, Jaune), ou *CMYK* (avec le Noir, utilisé massivement car *moins coûteux*), car c'est l'espace de couleur physique dans lequel l'encre est déposée.
- *Isolation du bruit résiduel :*
  - Le bruit résiduel est isolé en soustrayant l'image originale de sa version *filtrée* (généralement par le *filtre de Wiener*).
  - *Objectif :* Le filtre de Wiener supprime le bruit aléatoire tout en préservant le contenu visuel principal (le signal). Ce qui reste après soustraction est la *signature d'impression* (les micro-motifs du tramage et les artefacts).
- *Extraction de caractéristiques (GLCM) :* Les *statistiques de texture* (_GLCM_) sont calculées à partir de ce bruit résiduel.
  - *Homogénéité :* Mesure la régularité de la texture. Une valeur élevée indique un dépôt d'encre très uniforme.
  - *Contraste :* Mesure l'écart de densité de l'encre (entre les micro-points clairs et foncés). Révèle la "rugosité" du dépôt.
  - *Énergie :* Mesure la régularité et la répétition des motifs.
  - *Corrélation et Covariance :* Quantifient la dépendance linéaire entre les pixels voisins. Révèlent l'organisation spatiale des défauts.

- *Classification :* Ces descripteurs statistiques sont transmis à un classifieur d'apprentissage automatique (_Machine Learning_) pour l'identification.

=== 2. Attribution par Transformée en Ondelettes (Lee et Choi - DWT)

Cette méthode utilise l'analyse fréquentielle, qui est plus sensible aux *structures périodiques* comme le *Banding* ou le *Jitter*.

- *Méthode :* Basée sur la *Transformée en Ondelettes Discrète* (_Discrete Wavelet Transform_ - DWT).
- *Avantage DWT :* La DWT utilise des filtres *directionnels* pour décomposer l'image. Cela la rend plus *précise* que la GLCM pour capturer les artefacts orientés (horizontaux, verticaux, diagonaux) laissés par la mécanique de l'imprimante.
- *Sous-bande HH :* La DWT divise l'image en quatre sous-bandes (LL, LH, HL, *HH*).
  - La sous-bande *HH* (_High High_) représente les *informations de haute fréquence* (les détails fins et les textures) dans les deux directions (horizontale et verticale, donc diagonale). Les *artefacts* de l'imprimante sont très concentrés dans cette sous-bande.
- *Extraction :* On extrait *39 caractéristiques statistiques* de la sous-bande HH.
  - *Écart-type (_SDV_) :* Mesure la dispersion des valeurs, indiquant la *quantité* de bruit/texture.
  - *Asymétrie (_Skewness_) et Kurtosis :* Décrivent la *forme* de la distribution du bruit. Sont très discriminants pour les motifs de bruit non gaussiens.
  - *Corrélation et Covariance :* Mesurent la relation spatiale du bruit haute fréquence.

- *Problème :* L'attribution est un *problème en ensemble fermé* (_closed-set problem_). Le classifieur ne peut identifier l'imprimante que si elle a été incluse dans l'ensemble de données d'entraînement.

=== 3. Attribution par DWT (Tsai)

L'approche de Tsai est une variante de l'analyse DWT qui explore un espace de caractéristiques plus large.

- *Extraction :* Elle utilise également la DWT, mais extrait *45 caractéristiques* à partir de *trois* sous-bandes (HH, HL, LH).
- *Compromis :* En utilisant trois sous-bandes, elle capture plus d'informations directionnelles, mais l'auteur choisit de négliger l'espace couleur *CMYK*, préférant travailler avec des données brutes moins transformées (RGB).
- *Optimisation :* Pour contrer la grande quantité de données DWT, elle s'appuie sur des *algorithmes de sélection de caractéristiques* (_feature selection_) afin de ne retenir que les descripteurs les plus pertinents et d'optimiser la performance.

=== Remarques Générales et Conclusion

- *Résolution de scan :* Pour ne pas manquer les artefacts sub-pixel, il est souvent nécessaire de scanner à une *résolution supérieure* (ex: 1200 DPI) à celle de l'impression (ex: 600 DPI).
- *Amélioration de la précision :* Si la précision est insuffisante (ex: 88%), il faut *combiner* les méthodes, *enrichir* les caractéristiques ou *affiner* les classifieurs.
- *Défis de l'avenir :*
  - La forensique doit s'adapter aux *nouvelles technologies* (impression 3D, nouvelles encres).
  - La *flexibilité* des algorithmes est essentielle pour traiter les *scénarios en ensemble ouvert* (nouvelles imprimantes inconnues).
  - La menace croissante des *attaques adversariales* (où un contrefacteur tente de reproduire ou d'effacer intentionnellement l'empreinte d'une imprimante) nécessite le développement de méthodes *robustes*.

#pagebreak()

= Deep learning methods in digital forensics

== Tatouage des Réseaux Neuronaux Profonds (_DNN Watermarking_)

Le tatouage des DNN est une approche récente proposée pour *protéger les droits de propriété intellectuelle* (_IPR_) des modèles d'apprentissage profond et, surtout, pour *authentifier* et *tracer* les contenus médiatiques générés par l'IA (_contenus synthétiques_).

=== Changement de paradigme (_Shift of Paradigm_)

Historiquement, le problème de l'authenticité des images a été posé à la fin des années 90, avec la diffusion des outils d'édition faciles à utiliser. Les premières solutions (_Multi-Media Forensics_ - MMF) ont émergé au début des années 2000. L'avènement des IA génératives a nécessité un changement d'approche :

- *Ancienne idée (Irréalisable) :* Intégrer un filigrane invisible (_watermark_) dans *toutes* les images générées ou éditées par l'IA pour vérifier l'origine, tracer l'historique et détecter les abus.
  - *Problème :* Impossible d'*appliquer* ce marquage à *tous* les logiciels et à *toutes* les images générées dans le monde.

- *Nouvelle idée (Plus réalisable) :* Travailler *avec* les entreprises d'IA générative pour *tatouer les modèles* eux-mêmes.
  - *Principe :* Tatouer le modèle DNN de sorte que *toutes* les images qu'il produit contiennent la signature intégrée.
  - *Justification :* Seule une *poignée* d'entreprises sont capables d'entraîner ces modèles génératifs à partir de zéro, rendant l'application plus gérable.

=== Le tatouage de DNN en bref

Le *DNN watermarking* est une forme de *tatouage de fonction* (_function watermarking_) qui intègre de manière *indissociable* une information dans le modèle DNN.

- *Objectif :* Permettre de *détecter* et de *tracer* les contenus synthétiques jusqu'au modèle qui les a générés. C'est l'approche "_Faire d'une pierre deux coups_" (_Kill two birds with one bullet_).
- *Robustesse :* Le filigrane doit résister aux modifications courantes du modèle, y compris :
  - *L'élagage* (_pruning_).
  - La *compression*.
  - L'*affinage* (_fine tuning_).
  - Le *transfert d'apprentissage* (_transfer learning_).

- *Types de watermarking :*
  - *Boîte blanche* (_White-box_) : L'attaquant/vérificateur a accès aux poids et à l'architecture du modèle.
  - *Boîte noire* (_Black-box_) : L'attaquant/vérificateur n'a accès qu'aux entrées et sorties du modèle (le modèle est une boîte noire).
  - *Sans boîte* (_Box-free_) : *Tatouage conjoint* du DNN et du média. C'est le type privilégié pour la traçabilité des images générées.

- *Nature du problème :* Il est considéré comme un *problème de communication numérique* (tatouage multi-bits).

=== Détail : Tatouage sans boîte (_Box-free Watermarking_)

Le tatouage sans boîte (_Box-free watermarking_) est la méthode la plus prometteuse pour la forensique des contenus générés par l'IA, car elle résout le problème de la *dissociation* entre le modèle (la source de l'empreinte) et le contenu final (l'image).

- *Principe Fondamental :* Il s'agit d'un *tatouage conjoint* (_Joint DNN and Media Watermarking_). Le filigrane est conçu pour être à la fois *intégré* dans les poids du *Modèle DNN* et *injecté* dans le *Média de sortie* (l'image générée) par le processus de génération lui-même.

=== Pourquoi "Sans Boîte" ?

Contrairement aux méthodes *Boîte Blanche* (qui nécessitent l'accès aux poids internes du modèle) et *Boîte Noire* (qui ne regardent que le comportement du modèle), le tatouage sans boîte se concentre sur la *preuve de l'origine* contenue dans le fichier de sortie, même si celui-ci a été fortement altéré :

- *Traçabilité :* Lorsqu'un utilisateur reçoit l'image générée, l'information du filigrane est *directement lisible* dans l'image (le média), sans qu'il soit nécessaire d'interroger le modèle DNN en ligne.
- *Robustesse :* Le filigrane est encodé de manière à être *statistiquement* ou *visuellement* présent dans l'image, le reliant au modèle créateur. Il est conçu pour résister aux altérations courantes (compression JPEG, redimensionnement, recadrage, bruit).
- *Solution idéale pour la Génération :* Dans le cas d'une IA générative (comme DALL-E ou Midjourney), cette méthode permet de :
  1. *Signer le modèle* lors de son entraînement.
  2. Assurer que la *signature est transférée* dans chaque image produite.
  3. Vérifier la *signature de l'image* pour confirmer quel modèle spécifique l'a générée.

=== Comment est-ce réalisé ?

Bien que la théorie exacte soit en cours de développement, l'implémentation repose souvent sur :

1. *Modification de la Fonction de Perte :* Pendant l'entraînement du modèle DNN, la *fonction de perte* est modifiée pour non seulement optimiser la qualité de l'image générée, mais aussi pour s'assurer que l'image produite porte un *motif ou une statistique invisible* spécifique (le filigrane).
2. *Injection Subtile :* Le filigrane est généralement injecté dans les *textures haute fréquence* de l'image (le bruit), ce qui le rend presque indétectable pour l'œil humain, mais facile à lire par un algorithme de vérification forensique.

Le tatouage sans boîte est donc la clé pour *identifier les abus* et assurer l'*utilisation éthique* des médias générés par l'IA.

=== Le contexte : La révolution des médias par l'IA

L'omniprésence de l'IA rend la forensique multimédia conventionnelle (_MMF_) de plus en plus difficile :

- Les images de téléphones portables sont déjà *modifiées* à la source (par le *firmware*).
- Les outils d'édition par IA sont *facilement accessibles* et produisent des modifications *crédibles*.
- Le volume de modifications et les progrès de l'IA *dépassent* les capacités de la MMF traditionnelle.
- Dans le futur, même le fait qu'une image ait été "manipulée" par un outil d'IA pourrait ne *plus* être une information significative, d'où la nécessité de connaître la *source* exacte.

=== Les défis du tatouage de DNN

Plusieurs défis majeurs doivent être relevés pour que le DNN watermarking soit efficace :

- *Théorie :* Le développement d'une *toute nouvelle théorie* du tatouage de fonctions.
- *Robustesse au niveau du modèle :* Assurer que le filigrane résiste aux modifications structurelles (élagage, compression).
- *Robustesse au niveau de l'image :* Assurer que le filigrane sur les images générées résiste aux altérations de l'image (compression JPEG, bruit, recadrage).
- *Modèle de sécurité :* Définir précisément :
  - L'information intégrée.
  - Le rôle de chaque acteur (_Qui fait quoi_).
  - La *gestion des clés* (_Keyword management_).
- *Sécurité contre les attaques intentionnelles :* Protéger le filigrane contre les tentatives actives de suppression ou de falsification.

#pagebreak()

== Tatouage de GAN : solutions précoces et nouvelles

Le tatouage des GAN (_Generative Adversarial Networks_) est un cas spécifique du tatouage des DNN. Il vise à insérer une signature dans le modèle générateur, rendant chaque image qu'il produit traçable. La difficulté majeure est la *robustesse* du filigrane face aux attaques courantes visant à le supprimer.

=== Robustesse face aux attaques de Post-traitement et de Modèle

#tablem[
  | Attaque | Description et Objectif | Robustesse du Watermark |
  | :--- | :--- | :--- |
  | *Traitement d'image* (_Image processing_) | Application d'opérations courantes sur l'image générée : compression JPEG, ajout de bruit, filtrage, recadrage. | Le filigrane est généralement *assez résistant* à ces opérations, car il est souvent encodé dans les fréquences où la compression est la moins agressive (fréquences moyennes).  |
  | *Élagage du modèle* (_Model Pruning_) | Suppression intentionnelle d'une fraction des poids (neurones et connexions) du modèle (pour réduire sa taille ou tenter de supprimer la signature). | Le filigrane est très *bien conservé*. Il est possible de *couper jusqu'à $1/4$* (25%) du réseau sans détruire le filigrane. Cela suggère que l'information est *distribuée* de manière redondante sur l'ensemble du réseau. |
  | *Quantification du modèle* (_Model Quantization_) | Réduction de la précision des coefficients (poids) du modèle (ex: passer de nombres flottants 32 bits à 16 bits) pour accélérer l'inférence. | Le filigrane est *préservé* même avec une quantification agressive (ex: jusqu'à une précision de *3 nombres après la virgule*). Si la précision est réduite au-delà de ce seuil, la performance du modèle lui-même se dégrade fortement, rendant l'attaque non viable. |
  | *Affinage* (_Fine Tuning_) | Réentraînement du modèle sur un nouvel ensemble de données. C'est l'une des attaques les plus puissantes. | L'objectif est de s'assurer que l'intégration du filigrane (via une fonction de perte personnalisée) *pèse* suffisamment dans l'entraînement pour qu'un affinage modéré ne puisse pas "l'écraser". Le filigrane est conçu pour être une caractéristique *intrinsèque* du modèle, difficile à réapprendre sans dégrader la qualité du générateur. |
  | *Super Résolution* (_Super Resolution_) | Application d'un autre modèle d'IA pour améliorer la résolution de l'image. | Le filigrane doit être conçu pour *résister à l'upscaling* ou pour être *reproduit* par le processus de super résolution. Idéalement, la signature (le motif de bruit) est si bien encodée qu'elle est *amplifiée* (ou du moins préservée) lorsque l'image est augmentée en résolution. |
]

=== Le Tatouage Supervisé (_Supervised Watermarking_)

Le tatouage supervisé est une approche d'apprentissage profond pour rendre le filigrane indissociable du contenu généré.

- *Principe :* Il s'agit d'entraîner le modèle DNN pour qu'il remplisse *deux objectifs simultanément* :
  1. Générer une image de *haute qualité* (objectif principal).
  2. *Intégrer le filigrane* (_watermark_) (objectif secondaire, contrôlé par une fonction de perte spécifique).

- *Fonctionnement :* Le processus est souvent visualisé comme suit :
  - Un *encodeur* (_Encoder_) prend le contenu de l'image et le filigrane désiré.
  - Le *réseau générateur* (_Generator network_) apprend à créer l'image avec le filigrane intégré.
  - Un *réseau discriminateur* (_Discriminator network_) tente de distinguer l'image tatouée d'une image normale, forçant le générateur à rendre le filigrane *invisible*.
  - Un *réseau vérificateur* (_Verifier network_) est entraîné pour *extraire* le filigrane de l'image, garantissant qu'il est *lisible* en fin de chaîne.

#pagebreak()

== Tatouage sans réentraînement (_Retraining-free Fingerprinting_)

Le tatouage de Réseaux Neuronaux Profonds (DNN) est souvent coûteux en ressources, car l'intégration d'un nouveau filigrane (_watermark_) nécessite généralement un *réentraînement* (_retraining_) complet et lourd du modèle. Pour certaines applications (par exemple, identifier la version spécifique d'un modèle d'IA distribué à différents utilisateurs), il est nécessaire d'intégrer *différents filigranes* pour différentes versions.

=== La Solution : Le Réseau de Génération de Paramètres (_ParamGen Network_)

Pour contourner le coût du réentraînement, la solution proposée consiste à rendre l'intégration du filigrane *paramétrable* :

- *Couche Personnalisée :* Une *couche de normalisation personnalisée* (_personalized layer_) est introduite dans le réseau générateur (le GAN). Les paramètres de cette couche sont les seuls responsables de l'intégration du filigrane.
- *Réseau ParamGen :* Les paramètres de cette couche personnalisée ne sont pas appris par réentraînement du générateur, mais sont *générés* (_feedforward_) par un réseau distinct appelé *Réseau de Génération de Paramètres* (_ParamGen Network_).
- *Fonctionnement :* Pour obtenir un modèle avec un filigrane donné, il suffit d'exécuter le réseau *ParamGen* qui, en fonction du filigrane souhaité (les *bits* à encoder), génère les *poids spécifiques* de la couche de normalisation personnalisée.
  - *Modification par Utilisateur :* De petites modifications sont apportées au filigrane de base pour créer un *filigrane unique pour chaque utilisateur* (ou chaque version).
- *Étape de Normalisation :* La couche personnalisée est souvent une couche de normalisation (_Normalization Layer_) visant à standardiser les activations (par exemple, *moyenne = 0* et *écart-type = 1*), ce qui est un point d'injection idéal pour un filigrane subtil.

- *Avantage :* Le modèle est tatoué avec un nouveau filigrane *sans nécessiter de réentraînement* du générateur principal.

=== Validation des Résultats

Cette approche a été testée avec succès sur divers modèles GAN de pointe, démontrant sa polyvalence :

- *Modèles testés :* Boundary Equilibrium GAN (_BEGAN_), Spectral Normalization GAN (_SNGAN_), et Progressive Growing GAN (_PGGAN_).
- *Application :* Génération de visages (entraîné sur l'ensemble de données _CelebA_).
- *Implémentation :* Le réseau *ParamGen* est généralement un réseau entièrement connecté (_fully connected network_) avec des couches ReLU (Rectified Linear Unit (unité linéaire rectifiée): fonction d'activation en Deep Learning), entraîné pour générer des paramètres à partir d'un filigrane de *128 bits*.
- *Importance de $L_("const")$ :* Une fonction de perte de *constance* ($L_("const")$) est cruciale pour garantir que les modèles tatoués avec différents bits de filigrane conservent un *comportement uniforme* (c'est-à-dire que la qualité des images générées ne change pas en fonction du filigrane).

=== Conclusion sur la Forensique à l'Ère de l'IA

- *Limites du MMF Classique :* La forensique multimédia traditionnelle (_MMF_) reste *valide dans des scénarios spécifiques et étroits*. Cependant, elle est *difficile (voire impossible)* à appliquer à grande échelle face aux *campagnes de désinformation* et à la quantité massive de contenu synthétique.
- *Solution active par DNN :* Le tatouage actif basé sur les DNN (_DNN-based active fingerprinting_) offre une solution complémentaire indispensable.
  - *Défis :* Des défis majeurs (robustesse aux attaques, sécurité) doivent encore être résolus.
  - *Complémentarité :* Le tatouage DNN n'est pas une solution universelle, mais un *complément valide et nécessaire* aux méthodes passives de MMF traditionnelles.

- *Nécessité de Flexibilité :* La capacité de générer des filigranes différents sans réentraîner est essentielle pour fournir la *flexibilité* et la *traçabilité* requises par les applications de sécurité et d'authentification futures.

#pagebreak()

= Modern Steganography

== Méthodes de Dissimulation d'Information (_Information Hiding_)

Le principe de la *dissimulation d'information* est un concept fondamental en informatique et en sécurité numérique. Il consiste à *masquer* la présence d'un message ou de données dans un support qui n'est pas destiné à les contenir.

- *Définition générale (Informatique) :* En génie logiciel, l'idée est de séparer les décisions de conception d'un programme susceptibles de changer. Cela protège les autres parties du programme contre des modifications étendues si la décision initiale est altérée.

- *Définition (Sécurité et Multimédia) :* Dans le contexte de la forensique et de la sécurité, la dissimulation d'information regroupe les techniques visant à insérer un message secret (_payload_) dans un média _porteur_ (_cover media_) de manière *furtive* ou *invisible*.

=== Techniques de Dissimulation

Il existe deux techniques principales de dissimulation, dont les objectifs et les propriétés de robustesse sont différents :

- *1. Stéganographie* (_Steganography_) :
  - *Objectif :* Dissimuler l'*existence* même du message secret. Le support modifié (_stego-media_) doit être visuellement et statistiquement *indiscernable* du support original.
  - *Enjeux :* L'attaquant (le stéganalyste) tente de prouver qu'un message existe. La stéganographie est une *guerre de la détection*.
  - *Catégories :*
    - *Linguistique :* Dissimulation dans le texte (ex: acrostiches, choix de mots spécifiques).
    - *Technique/Numérique :* Dissimulation dans les données numériques (images, audio, vidéo). La méthode la plus courante est l'altération du *bit de poids faible* (_Least Significant Bit - LSB_) des pixels d'une image.
  - *Robustesse :* Le message est souvent *fragile* et facilement détruit par une compression ou un filtre standard.

- *2. Tatouage numérique* (_Watermarking_) :
  - *Objectif :* Intégrer un message (le filigrane) dans le support d'une manière *robuste* (difficile à supprimer) mais *invisible* (non intrusif). Le filigrane sert souvent à prouver la *propriété*, l'*authenticité* ou la *traçabilité*.
  - *Enjeux :* L'attaquant tente de *supprimer* le filigrane. Le tatouage est une *guerre de la suppression*.
  - *Types de filigranes :*
    - *Fragile :* Le filigrane est altéré par la moindre modification (utilisé pour prouver l'*authenticité*).
    - *Robuste :* Le filigrane résiste aux altérations courantes (compression, bruit, édition) (utilisé pour prouver la *propriété*).
  - *Applications :* Les méthodes de *DNN Watermarking* que nous avons étudiées sont une application avancée de cette technique pour la traçabilité des modèles d'IA.



=== Domaine d'Application

Ces techniques sont essentielles pour la *forensique multimédia*, car elles alimentent les mécanismes de défense et d'attaque :

- *Attribution de source (Forensique) :* L'analyse forensique cherche à *détecter* la stéganographie (_steganalysis_) ou à *vérifier* l'absence/présence d'un tatouage (_watermark detection_).
- *Défense contre la contrefaçon :* Les filigranes robustes sont utilisés pour marquer les documents de valeur ou les images soumises au droit d'auteur.

#pagebreak()

== Principes de base de la Cryptographie (_Basics of Cryptography_)

La cryptographie est la *science de la communication sécurisée*. Son objectif principal est de garantir que seuls l'émetteur et le destinataire prévu d'un message puissent en *visualiser* et en *comprendre* le contenu.

- *Étymologie :* Le terme est dérivé du mot grec *kryptos* ($kappa rho upsilon pi tau o sigma.alt$), qui signifie *caché* ou *secret*.

=== Cryptographie et Chiffrement

La cryptographie est étroitement associée au concept de *chiffrement* (_Encryption_), mais ces termes ne sont pas strictement synonymes :

- *Chiffrement :* C'est l'*acte* de transformer un texte ordinaire et lisible (appelé *texte clair* ou *clairtexte* - _plaintext_) en un message brouillé et incompréhensible (appelé *texte chiffré* ou *cryptogramme* - _ciphertext_).
- *Déchiffrement :* C'est l'opération inverse, qui permet de reconvertir le *texte chiffré* en *texte clair* à l'arrivée.

=== Objectifs Fondamentaux de la Cryptographie

La cryptographie moderne va bien au-delà de la simple dissimulation de l'information (confidentialité). Elle repose sur quatre piliers essentiels pour garantir la sécurité des communications :

- *1. Confidentialité* (_Confidentiality_) :
  - *Définition :* Assurer que le contenu du message ne peut être lu que par les parties autorisées.
  - *Mécanisme :* Le *chiffrement* est la technique principale pour atteindre cet objectif.

- *2. Intégrité* (_Integrity_) :
  - *Définition :* Garantir que le message n'a pas été *modifié* ou *altéré* pendant sa transmission, que ce soit intentionnellement ou accidentellement.
  - *Mécanisme :* Utilisation de *fonctions de hachage* (_Hashing Functions_) et de *codes d'authentification de message* (_Message Authentication Codes_ - MAC).

- *3. Authenticité / Authentification* (_Authenticity / Authentication_) :
  - *Définition :* Vérifier l'*identité* de l'émetteur du message et/ou de la validité de la source.
  - *Mécanisme :* Utilisation de *signatures numériques* (_Digital Signatures_) et de *certificats*.

- *4. Non-Répudiation* (_Non-Repudiation_) :
  - *Définition :* Empêcher l'émetteur d'un message (ou le destinataire) de *nier* ultérieurement avoir envoyé (ou reçu) ce message.
  - *Mécanisme :* S'appuie également sur la *signature numérique*, qui crée une preuve irréfutable.



=== Relation avec d'autres Domaines

La cryptographie est un vaste domaine qui chevauche plusieurs disciplines :

- *Cryptologie :* Le terme générique englobant la cryptographie (la conception des algorithmes) et la *cryptanalyse* (l'étude des méthodes pour casser ou attaquer ces algorithmes).
- *Stéganographie :* Bien que la stéganographie cache l'*existence* du message, tandis que la cryptographie cache le *contenu*, les deux sont souvent utilisées ensemble (chiffrer un message avant de le cacher stéganographiquement).

#pagebreak()

== Principes de base de la Stéganographie (_Basics of Steganography_)

La *stéganographie* est l'*art* et la *science* de *dissimuler l'existence même* d'une communication ou d'un message.

- *Étymologie :* Le terme est dérivé des mots grecs :
  - *STEGANOS* ($sigma tau epsilon gamma alpha nu o sigma.alt$) : Signifie "_Couvert_" ou "_Caché_".
  - *GRAPHIE* ($gamma rho alpha phi iota alpha$) : Signifie "_Écriture_".

=== Objectif Principal

- *Contraste avec la Cryptographie :* En cryptographie, l'ennemi est autorisé à intercepter et à modifier les messages, mais il ne peut pas en violer la sécurité (*le contenu est caché*). En stéganographie, l'objectif est de *cacher le message dans d'autres messages inoffensifs* de manière à ce que l'ennemi *ne puisse même pas détecter sa présence*.
- *But :* Cacher le message de manière à ce que la transmission n'éveille *aucune suspicion*. Si la présence du message secret est détectée, le but de la stéganographie est échoué.

- *Mécanisme :* Cela est réalisé en dissimulant l'information secrète (_secret message_) dans un support qui semble anodin et inoffensif (le *support porteur* - _harmless carrier / cover_).
- *Support Porteur :* Le support peut être du *texte*, une *image*, une *vidéo*, de l'*audio*, etc.

=== Notes Historiques

La stéganographie est une pratique aussi ancienne que l'humanité, utilisée pour la communication secrète à travers les âges :

- *Hérodote (Antiquité Grecque) :*
  - *Esclaves rasés :* Des messages étaient tatoués sur la tête rasée d'un esclave. Une fois ses cheveux repoussés, le message était caché jusqu'à ce que l'esclave soit de nouveau rasé.
  - *Tablettes de cire :* Un message était gravé sur une tablette de bois, puis recouvert de cire. La tablette ressemblait à une tablette de cire vierge. La cire devait être fondue pour récupérer le message.
- *Chinois Anciens :*
  - *Balles de cire :* Les messages écrits sur de la soie étaient enfermés dans des boules de cire, qui pouvaient être facilement dissimulées sur le messager.
  - *Masques de papier :* L'émetteur et le destinataire partageaient des masques avec des trous coupés aléatoirement. Le message était lisible uniquement à travers les trous du masque placé sur le texte.
- *Techniques Médiévales et Modernes :*
  - *Acrostiches :* Des messages secrets sont formés par les *initiales* des mots, des lignes ou des strophes (ex: *L'Amorosa Visione* de Boccaccio). *Exemple :* L'analyse cryptographique peut révéler un message à partir d'une série de lettres filtrées.
  - *Encres invisibles :* Des substances naturelles (jus de citron, urine) qui noircissent après avoir été chauffées, révélant le message. Des techniques chimiques (sels d'ammoniac) ou biologiques ont également été utilisées.
  - *Édition moderne :* Utilisation de *micro-points* imperceptibles, d'*espacements de ligne* intentionnels, ou de *lacunes* et d'erreurs intentionnelles pour coder l'information.

=== Stéganographie à l'Ère Numérique

Le domaine a connu un regain d'intérêt à partir des années 1990 :

- *Technologies Clés :*
  - *Canaux de communication large bande :* Permettent de masquer de *grandes quantités* de données (charge utile - _payload_) dans des fichiers volumineux (images, vidéos).
  - *Diffusion de contenus multimédias :* Les images et vidéos sont si courantes que l'envoi d'un fichier stéganographié n'est pas suspect.
  - *Techniques automatisées :* Permettent d'atteindre des *charges utiles élevées* (_high payloads_) sans dégrader la qualité du support.
- *Motivations :*
  - *Espionnage et Terrorisme :* Échanger des informations secrètes sans être détecté.
  - *Dissidents :* Contourner la *censure* et protéger la *liberté d'expression* dans des régimes restrictifs.
  - *Protection de la vie privée :* Éviter la surveillance de masse (_big-brother scenarios_).

=== Stéganalyse (_Steganalysis_)

La *stéganalyse* est le domaine d'étude complémentaire à la stéganographie. C'est l'art et la science de *détecter* la présence de messages secrets dissimulés dans un support porteur, même si ces messages ne peuvent pas être décryptés ou lus.

- *Objectif :* Révéler la présence de messages cachés (éventuellement sans les déchiffrer).

- *Motivation :*
  - *Renseignement et police :* Utilisée par les agences de renseignement et les forces de l'ordre pour déceler les communications illicites ou terroristes.
  - *Contrôle de l'opinion publique :* Peut être employée pour surveiller la diffusion de messages non autorisés (dans les contextes de censure, par exemple).

- *Intérêt fondamental :* Indépendamment des motivations (sécuritaires ou éthiques), l'étude de la stéganalyse est *nécessaire* pour *déterminer la sécurité* des techniques stéganographiques.
  - *Principe :* Si une technique de stéganographie résiste aux meilleurs outils de stéganalyse, alors elle est considérée comme *sûre* et *indétectable*. La stéganalyse alimente donc la conception de méthodes stéganographiques plus robustes.

#pagebreak()

== Exigences de la Stéganographie Moderne

La conception d'une méthode stéganographique efficace est un exercice d'équilibrisme entre deux exigences *opposées* : la dissimulation (invisibilité) et la quantité de données cachées (capacité).

- *1. Invisibilité (Statistique)*
- *2. Capacité (Charge utile - _Payload_)*

=== 1. Le Critère d'Invisibilité

L'invisibilité est l'exigence la plus stricte. Elle doit être considérée sous deux angles :

- *Invisibilité Perceptuelle :*
  - Le message caché doit être *indiscernable* par l'œil humain. L'image originale (_cover image_) et l'image modifiée (_stego-image_) doivent paraître identiques.
  - Cette exigence doit être maintenue *même après* l'application de techniques courantes de *traitement du signal* (légère compression, recadrage, etc.).

- *Invisibilité Statistique :*
  - Le critère le plus difficile à satisfaire. Les *statistiques* de l'image modifiée ne doivent pas différer significativement de celles de l'image originale.
  - *Conséquence :* Le stéganalyste (le "gardien" - _warden_) ne doit pas pouvoir détecter la présence du message par l'analyse statistique (histogrammes, moments, etc.) ou l'apprentissage automatique.
  - *Exemple pratique :* Une simple compression JPEG de 2-3% peut détruire ou révéler certains messages stéganographiques s'ils n'ont pas été conçus pour résister à cette altération statistique.

- *Hypothèses de Kerckhoff :* La conception d’un bon algorithme stéganographique (tout comme en cryptographie) doit respecter le *Principe de Kerckhoff* : le système doit rester sûr *même si l'ennemi connaît l'algorithme* utilisé et *connaît les statistiques de l'image source* d'Alice.

- *Limitation :* L'invisibilité seule ne suffit pas, car la réalité et les modèles d'attaque des stéganalystes sont souvent plus complexes que les modèles mathématiques initiaux.

=== 2. Le Critère de Capacité (Charge utile)

- *Définition :* C'est la *quantité de données* (_payload_) que l'on souhaite communiquer secrètement.
- *Compromis :* Plus la capacité est élevée, plus il faut modifier le support porteur. Plus on modifie le support, plus les altérations statistiques sont importantes, compromettant l'invisibilité.

=== Choix du Domaine de Dissimulation

Le choix du domaine où le message est caché a un impact majeur sur la capacité et la sécurité :

- *Domaine Spatial/Pixel (_Spatial/Pixel Domain_) :*
  - *Méthode :* Le message est caché en modifiant directement les valeurs de pixels (ex: modification du bit de poids faible - LSB).
  - *Avantages :* *Facile à utiliser*, *haute capacité* (le récepteur peut garantir une extraction parfaite du message). Simple à évaluer pour l'invisibilité perceptuelle.
  - *Désavantages :* *Faible robustesse* à la compression ou au bruit. Détection statistique relativement aisée.

- *Domaine des Transformations/Compressé (_Transform/Compressed Domain_) :*
  - *Méthode :* Le message est codé en modifiant les *coefficients de la DCT* (_Discrete Cosine Transform_) (utilisée dans la compression JPEG).
  - *Avantages :* *Meilleure résistance* à la compression (car les modifications sont faites directement dans le format compressé). Profite de la *grande diffusion* des images JPEG.
  - *Désavantages :* *Capacité plus faible* et *sécurité inférieure* (en raison de l'existence de bons modèles statistiques pour décrire les coefficients DCT).
  - *Exemples d'algorithmes :* *F5*, *OutGuess*, *Jsteg*.

#pagebreak()

== Stéganographie dans le Domaine Spatial (_Steganography in Spatial Domain_)

La stéganographie dans le domaine spatial est la méthode de dissimulation la plus directe et la plus intuitive. Elle consiste à *modifier directement les valeurs des pixels* de l'image porteuse (_cover image_) pour y encoder le message secret.

- *Principe :* L'information secrète est insérée dans les *bits de poids faible* (_Least Significant Bits_ - LSB) des pixels. Ces bits sont ceux qui contribuent le moins à la perception visuelle du pixel, assurant l'invisibilité perceptuelle.

=== La Méthode du Bit de Poids Faible (LSB)

La technique LSB est la plus courante dans le domaine spatial :

- *Fonctionnement :*
  - Un pixel est généralement représenté par 8 bits (valeur de 0 à 255). Le LSB est le bit qui a la plus faible influence sur la valeur finale du pixel.
  - L'algorithme *remplace* un ou plusieurs LSB du pixel porteur par un ou plusieurs bits du message secret.

- *Exemple (sur 1 LSB) :*
  - Valeur originale du pixel : $1011010cal(1)$ (181 en décimal).
  - Si le bit secret à cacher est $cal(0)$, le nouveau pixel devient : $1011010cal(0)$ (180 en décimal).
  - La différence de valeur est de seulement 1 (ou $-1$ si l'on passe de $cal(0)$ à $cal(1)$). Cette variation est *indétectable* par l'œil humain.
  - *Conséquence :* Pour cacher un bit secret, l'algorithme modifie au maximum la valeur du pixel de $plus.minus 1$.

- *Capacité :* La capacité est très élevée, car on peut utiliser jusqu'à 3 LSB par canal de couleur (Rouge, Vert, Bleu) dans un pixel, permettant de cacher une grande quantité de données.

=== Avantages

1. *Facilité d'Utilisation :* La mise en œuvre est simple et rapide.
2. *Haute Capacité :* Elle permet la dissimulation de la *charge utile* (_payload_) la plus importante possible, car l'insertion se fait sur la quasi-totalité des pixels. Le récepteur est ainsi assuré d'une *extraction parfaite* du message.
3. *Invisibilité Perceptuelle :* La modification des LSB est généralement suffisante pour assurer que l'image modifiée (_stego-image_) soit visuellement identique à l'image originale.

=== Désavantages et Vulnérabilité

1. *Faible Robustesse :* Le filigrane LSB est *très fragile* et facilement détruit. La moindre manipulation de l'image (compression JPEG, ajout de bruit, redimensionnement) affectera les LSB de manière aléatoire, rendant le message irrécupérable.
2. *Détection Statistique Aisée :* La stéganalyse est relativement simple dans ce domaine. La modification de nombreux LSB *altère la distribution statistique* des couleurs dans l'image.
  - *Exemple :* L'insertion LSB a tendance à rendre les LSB plus aléatoires. Les *histogrammes* de l'image modifiée présentent souvent des anomalies ou des motifs statistiques non naturels que les algorithmes de stéganalyse peuvent facilement détecter.

En conclusion, la stéganographie dans le domaine spatial est idéale pour la *grande capacité* et la *simplicité*, mais sa *faible sécurité* la limite aux contextes où l'image n'est soumise à *aucune altération* ou compression après l'insertion.

#pagebreak()

== Stéganographie dans le Domaine des Transformations (_Transform Domain Steganography_)

La stéganographie dans le domaine des transformations est une approche plus sophistiquée que le domaine spatial, privilégiée pour sa *meilleure robustesse* face aux opérations courantes sur les images, en particulier la compression JPEG.

- *Principe :* Le message secret est dissimulé non pas dans les valeurs directes des pixels, mais dans les *coefficients* obtenus après une transformation mathématique appliquée à l'image (comme la DCT ou la DWT).

=== Le Cas de la Compression JPEG et de la DCT

Dans le cas des images JPEG, la dissimulation d'information se fait au niveau des coefficients de la *Transformée en Cosinus Discrète* (_Discrete Cosine Transform_ - DCT).

- *Processus JPEG :* La compression JPEG commence par diviser l'image en blocs de $8 times 8$ pixels, puis applique la DCT à chaque bloc. La DCT convertit l'information spatiale en information fréquentielle (coefficients).
- *Coefficients DCT :*
  - Le coefficient $(0, 0)$ est le coefficient de *faible fréquence* (composante continue ou *DC*) qui représente la couleur moyenne du bloc.
  - Les autres coefficients représentent les *hautes fréquences* (détails et changements rapides de couleur).
- *Méthode de dissimulation :*
  - Le message est codé en modifiant subtilement les *coefficients AC de fréquence moyenne* et *haute*.
  - Les coefficients *DC* (très sensibles) et les coefficients de très *haute fréquence* (souvent mis à zéro lors de la quantification et de la compression) sont généralement évités.

=== Avantages

1. *Meilleure Robustesse :* Puisque les modifications sont faites directement dans le domaine fréquentiel et sont encodées dans les coefficients qui sont *les moins affectés* par la quantification (l'étape de perte d'information de la compression JPEG), le message résiste mieux à une recompression ou à une légère altération.
2. *Large Diffusion :* Les images JPEG sont le format d'image le plus répandu, offrant un *support porteur* très commun et peu suspect.

=== Désavantages et Défis

1. *Capacité Plus Faible :* Pour garantir l'invisibilité, seuls certains coefficients peuvent être modifiés, ce qui réduit la quantité de données (_payload_) pouvant être cachée par rapport au domaine spatial.
2. *Sécurité Inférieure (Stéganalyse) :* La détection statistique peut être paradoxalement *plus facile*.
  - Les modèles statistiques décrivant la distribution des coefficients DCT sont bien connus (ex: distribution de Laplace).
  - Les algorithmes de stéganographie (même sophistiqués comme *F5* ou *OutGuess*) ont du mal à préserver *parfaitement* la distribution statistique naturelle des coefficients, rendant les anomalies détectables.

=== Algorithmes Notables

De nombreux algorithmes célèbres travaillent dans ce domaine :

- *Jsteg :* Un des premiers algorithmes basés sur la DCT.
- *OutGuess :* Une méthode qui tente de *corriger* la distribution statistique après l'insertion du message pour contrecarrer la stéganalyse.
- *F5 :* Un algorithme avancé qui utilise une *technique de codage matriciel* (_matrix encoding_) pour minimiser le nombre de modifications des coefficients DCT, augmentant ainsi la sécurité.

#pagebreak()

== Stéganographie par Sélection du Support Porteur (_Steganography by Cover Selection_)

La stéganographie par sélection du support porteur (_Cover Selection_) est une approche qui inverse le processus traditionnel de dissimulation. Au lieu de modifier un support existant pour y cacher un message, Alice *choisit* un support déjà existant dans une base de données qui correspond au message qu'elle souhaite envoyer.

- *Principe :* Alice et Bob partagent une très grande *base de données* d'images (ou tout autre média). Alice n'envoie *aucune* donnée modifiée ; elle envoie seulement l'*indice* ou l'*image elle-même* (non modifiée) qui est associée au message secret.

=== Comment le message est-il encodé ?

Le message secret peut être lié à une image spécifique dans la base de données selon divers critères prédéfinis :

1. *Contenu Sémantique de l'Image :* Le message peut être lié au sujet ou au thème de l'image. (Exemple : envoyer l'image d'un chat pour signifier "OK", et l'image d'un chien pour signifier "Annuler").
2. *Valeur d'un Sous-ensemble de LSB :* L'image est choisie parce qu'un *sous-ensemble* de ses bits de poids faible (LSB) correspond *déjà* aux bits du message secret.
3. *Hachage de l'Image (ou sous-image) :* Le message secret peut être le résultat du hachage (_hash_) de l'image (ou d'une partie de celle-ci). Alice cherche l'image dont le hachage correspond au message.

=== Avantages

- *Sécurité (Invisibilité) presque Parfaite :*
  - C'est le principal avantage. L'image transmise *n'est pas modifiée*. Elle est parfaitement *authentique* et *statistiquement pure*.
  - Les algorithmes de *stéganalyse* sont totalement *inefficaces*, car ils ne peuvent pas détecter d'altération. La stéganalyse ne peut qu'espérer détecter que l'image a été "choisie", ce qui est extrêmement difficile sans la base de données partagée.

=== Désavantages

- *Capacité (Charge utile) Extrêmement Faible :* C'est la limitation majeure de cette méthode.
  - La longueur du message est directement limitée par la *taille de la base de données* ($cal(D)$).
  - Si le message secret comporte 8 caractères (soit 64 bits), cela signifie qu'il doit y avoir au moins $2^64$ images différentes dans la base de données ($approx 10^19$ images) pour garantir qu'il existe une image pour chaque message possible.
- *Base de Données Gigantesque :* Avoir une base de données aussi vaste est impraticable pour un usage courant, même avec les ressources de stockage actuelles.

=== Conclusion

Cette méthode est une démonstration théorique de la relation inverse entre capacité et sécurité : en obtenant une sécurité presque parfaite, on sacrifie presque toute la capacité utile. Elle est principalement utilisée dans des scénarios où la charge utile est très limitée (quelques bits) ou dans des expériences de laboratoire.

#pagebreak()

== Stéganographie par Synthèse du Support Porteur (_Steganography by Cover Synthesis_)

La stéganographie par synthèse du support porteur est une technique *active* où l'émetteur (Alice) *génère de toutes pièces* (_on-the-fly_) le support (_cover image_) spécifiquement pour encoder le message secret. L'objectif est de s'assurer que l'image porte le message *dès sa création*, garantissant ainsi une sécurité statistique maximale.

=== Principe 1 : Synthèse par Assemblage de Blocs (Méthode Traditionnelle)

Cette méthode est historiquement utilisée pour contourner la difficulté de créer des images réalistes artificiellement :

- *Matériaux Sources :* Alice doit posséder un ensemble de *plusieurs clichés* de la *même scène* (ou de scènes très similaires) pour que les pièces s'emboîtent.
- *Processus d'Encodage :*
  - L'image est divisée en petits *blocs* ou tuiles.
  - Le message secret est encodé par la *sélection* du bloc : Alice choisit, pour chaque position dans l'image finale, le bloc provenant de ses images sources dont les *propriétés locales* (ex: un sous-ensemble des LSB) correspondent aux bits du message à ce point.
  - L'image finale est construite par *assemblage* des blocs choisis.

- *Avantage Clé :* *Bonne sécurité statistique*. Comme chaque bloc est un morceau d'une *vraie image*, les statistiques locales sont moins susceptibles d'être détectées par un stéganalyste que dans le cas d'une modification LSB artificielle.
- *Limites :*
  - *Faible charge utile* (_low payload_) : Nécessite une quantité énorme de blocs sources pour encoder un message de taille moyenne, rendant l'approche impraticable.
  - *Défauts de Bordure :* Le principal point faible réside dans les *jonctions* entre les blocs. Même si la scène est la même, les différences d'éclairage ou de bruit peuvent créer des lignes visibles (_block borders_) que le stéganalyste peut exploiter.

=== Principe 2 : Synthèse du Support par IA (_Cover Synthesis by AI_)

L'utilisation de l'Intelligence Artificielle générative a transformé cette approche, résolvant les problèmes de réalisme et de bords.

- *Modèles Génératifs :* Les *GAN* (_Generative Adversarial Networks_) et les modèles de diffusion (_diffusion models_) génèrent des faux visuellement indistinguables du réel (_visually plausible fakes_).
- *Formulation par Théorie des Jeux :* Cette méthode repose sur une *formulation adversariale* inspirée de la *Théorie des Jeux* (_Game-theoretic formulation_) :
  - *Le Générateur (Alice) :* C'est un CNN qui est entraîné non seulement à créer une image de haute qualité (réaliste), mais aussi à *y injecter le message secret* de la manière la plus indétectable possible.
  - *Le Stéganalyste (Le Gardien) :* C'est un autre CNN entraîné à *détecter* si le message est présent ou non dans l'image.
  - *Lutte :* Les deux réseaux s'entraînent en même temps, le succès du Stéganalyste forçant le Générateur à cacher le message de manière plus subtile, et vice-versa.
- *Résultat :* Le Générateur apprend à cacher l'information dans les *textures* ou les *fréquences de bruit* de l'image de sortie, là où l'œil humain et même les outils d'analyse traditionnels peinent à le trouver. Le message est intégré dans l'image *dès la première passe de génération*.

Cette approche est la plus prometteuse pour la stéganographie moderne, car elle permet une *haute sécurité* en garantissant que les propriétés statistiques du support synthétisé sont presque idéales.

#pagebreak()

== Stéganographie par Modification du Support Porteur (_Steganography by Cover Modification_)

La stéganographie par modification du support porteur est, *de loin, l'approche la plus courante* (_by far the most common approach_) et traditionnelle pour dissimuler de l'information. Elle consiste à insérer le message secret en *altérant légèrement* le média existant (texte, image, audio, vidéo).

=== Principe Général

- *Mécanisme :* L'émetteur (Alice) prend un média existant (le support porteur) et le modifie de manière *subtile* ou *statistiquement insignifiante* afin d'y insérer le message secret (_payload_).
- *Invisibilité Perceptuelle :* La modification est conçue pour être indétectable par l'œil ou l'oreille humaine.
- *Domaines d'Application :* Cette méthode est employée dans tous les domaines que nous avons précédemment étudiés :
  - *Domaine spatial* (_Spatial domain_) : Modification directe des bits de poids faible (LSB) des pixels.
  - *Domaine des transformations* (_Transform domain_) : Modification des coefficients DCT ou DWT.

=== Avantages Principaux

- *Charge utile élevée (_Large Payloads_) :* C'est le principal avantage. Étant donné que l'on peut généralement modifier de nombreux éléments du support (par exemple, chaque pixel d'une image), il est possible d'encoder une *grande quantité* de données secrètes. La capacité est directement liée à la taille du support.
- *Simplicité :* Dans des domaines comme le LSB, la mise en œuvre est extrêmement simple.

=== Le Défi de la Sécurité Statistique

Bien que cette méthode permette des charges utiles élevées, la *sécurité doit être étudiée avec soin* (_security must be studied carefully_). C'est le cœur de la *stéganalyse* :

- *Altération Statistique :* L'insertion d'un message, même en modifiant uniquement les LSB, introduit une *irrégularité* dans la distribution statistique naturelle du support porteur.
- *Vulnérabilité à la Stéganalyse :* Les stéganalystes utilisent des modèles sophistiqués (basés sur l'apprentissage automatique ou des statistiques d'ordre supérieur) pour détecter ces altérations statistiques.
- *Compromis :* Pour augmenter la sécurité (réduire la détectabilité), les méthodes modernes (comme *WOW* ou *HUGO*) sont devenues très complexes, sélectionnant les points d'insertion de manière *adaptative* pour minimiser l'impact sur les statistiques. Cela réduit souvent la charge utile effective par rapport au potentiel théorique, mais améliore considérablement la sécurité.

=== Catégories de Méthodes de Modification

La modification du support se divise en deux catégories selon la manière dont les points d'insertion sont choisis :

- *Méthodes Aléatoires/Séquentielles :* Les bits sont insérés de manière simple (ex: séquentiellement dans l'ordre de balayage de l'image ou pseudo-aléatoirement). Ces méthodes sont largement dépassées et facilement détectables.
- *Méthodes Adaptatives (_Adaptive Steganography_) :* L'algorithme analyse le contenu local du support porteur et insère le message uniquement dans les *zones de texture complexe* ou de *bruit important*. Ces zones sont naturellement plus aléatoires, ce qui permet de masquer plus facilement l'altération statistique de l'insertion.

#pagebreak()

== Stéganographie LSB (_LSB Steganography_)

La stéganographie par le *Bit de Poids Faible* (_Least Significant Bit_ - LSB) est la technique de dissimulation la plus élémentaire. Elle opère par *remplacement* direct des bits les moins significatifs du support porteur par les bits du message secret.

- *Mécanisme :* Les *bits de poids faible* des pixels d'une image (ou, dans des variantes du domaine compressé, des coefficients DCT) sont remplacés par le message chiffré.
- *Capacité :* Le remplacement d'un LSB par pixel permet une charge utile (_payload_) de *1 bit par pixel* (_1bpp_), offrant une très grande capacité d'encodage.

=== Imperceptibilité Visuelle (_Visual Imperceptibility_)

- *Principe :* Le remplacement LSB atteint une *imperceptibilité visuelle* quasi parfaite. L'altération du LSB modifie la valeur du pixel d'au maximum $\pm 1$ (si le pixel est encodé sur 8 bits).
- *Propriété du LSB :* Le plan de bits LSB d'une image naturelle (non modifiée) est déjà très proche du *bruit blanc* (_noise_). L'insertion d'un message chiffré (qui est lui-même très proche du bruit aléatoire) dans ce plan n'entraîne *aucune altération perceptible* par l'œil humain.

=== Attaque du Remplacement LSB (_Attacking LSB Replacement_)

La stéganalyse démontre que le remplacement LSB est statistiquement *facile à détecter*, surtout pour une charge utile élevée, car il modifie la relation naturelle entre les paires de valeurs de pixels.

- *Altération de la Parité :*
  - Si la valeur du pixel $x(i)$ est *paire* (ex : $01100000$), l'insertion d'un $1$ (bit secret) la rend *impaire* ($01100001$). L'insertion d'un $0$ la laisse *paire*.
  - Si $x(i)$ est *impaire* (ex : $01100001$), l'insertion d'un $0$ la rend *paire* ($01100000$). L'insertion d'un $1$ la laisse *impaire*.
- *Conséquence sur la Distribution :* L'insertion d'un message aléatoire (où les $0$ et les $1$ sont équiprobables) *force l'égalisation* des fréquences des valeurs paires et impaires adjacentes.
- *Exemple :* En considérant la paire de valeurs $(0, 1)$ :
  - Environ *la moitié* des pixels de valeur $0$ (paire) passent à $1$ (impaire) pour encoder un $1$.
  - Environ *la moitié* des pixels de valeur $1$ (impaire) passent à $0$ (paire) pour encoder un $0$.
  - *Résultat :* Après l'insertion (hstego), la fréquence des pixels de valeur $k$ devient très proche de la fréquence des pixels de valeur $k+1$, annulant la légère asymétrie naturelle présente dans les images non modifiées. Les détecteurs (comme l'analyse RS ou le décalage d'histogramme) peuvent exploiter cette *anomalie statistique*.

=== Contre-mesures (_Countermeasures_)

La stéganographie *parfaite* exigerait que *toutes* les statistiques de l'image soient préservées, mais cela est impraticable (impossible de modéliser parfaitement les images, complexité excessive).

Quatre approches empiriques sont utilisées en pratique pour améliorer la sécurité statistique :

- *1. Stéganographie préservant le modèle* (_Model-preserving steganography_) : Cherche à corriger les altérations après l'insertion pour maintenir certaines statistiques de bas niveau (ex : moments d'histogramme) connues pour être exploitées par les stéganalystes.
- *2. Modulation stochastique* (_Stochastic modulation_) : Utilise l'insertion d'un bruit contrôlé ou adapte la méthode pour rendre le processus plus aléatoire, masquant l'altération introduite par le message.
- *3. Stéganographie consciente de la stéganalyse* (_Steganalysis-aware steganography_) : Utilise les résultats d'un classifieur stéganalytique pour déterminer dynamiquement où insérer le message, en choisissant les emplacements qui minimisent le risque de détection.
- *4. Minimisation de la distorsion* (_Distortion minimization_) : L'approche la plus efficace (ex : *HUGO*, *WOW*). Elle choisit de manière *adaptative* les points d'insertion qui provoquent la *plus petite modification* possible aux statistiques de l'image, en se concentrant sur les zones de texture complexe.

=== Exploitation de l'Anomalie Statistique LSB

L'anomalie principale créée par l'insertion LSB est que la relation statistique naturelle entre les valeurs de pixels consécutives est *régularisée* ou *égalée* de manière artificielle. Les stéganalystes exploitent ce phénomène en mesurant la *modification des paires de valeurs* ou la *corrélation spatiale* des pixels.

==== Principe d'Altération Statistique (Rappel)

Dans une image naturelle non modifiée, l'histogramme présente une certaine irrégularité et une *légère asymétrie* entre les paires de valeurs adjacentes $(k, k+1)$.

L'insertion aléatoire du message LSB (pour une charge utile élevée) force environ la moitié des pixels de valeur $k$ à devenir $k+1$, et la moitié des pixels de valeur $k+1$ à devenir $k$.

- *Conséquence :* La fréquence des valeurs $k$ et $k+1$ tend à s'équilibrer ($"hstego"(k) approx "hstego"(k+1)$), ce qui est un *signe artificiel* de modification.

==== Méthodes d'Exploitation de l'Anomalie

Deux grandes familles de techniques stéganalytiques exploitent cette régularisation forcée :

===== 1. Analyse par Histogramme de Paires (_Pair-of-Values Analysis_)

Ces méthodes observent les fréquences de paires de valeurs spécifiques (souvent des paires d'ordre inférieur) :

- *Décalage d'Histogramme ( _Histogram Shift Analysis_ ) :*
  - Cette technique se concentre sur l'observation des histogrammes. Si l'insertion LSB est utilisée, la fréquence des valeurs $k$ et $k+1$ dans l'image modifiée s'écarte des fréquences attendues pour une image naturelle.
  - Pour une charge utile de 1 bpp (1 _bit per pixel_), l'altération est maximale et le stéganalyste peut quantifier l'écart entre la distribution observée et la distribution théorique d'une image naturelle pour en déduire la *probabilité* qu'un message soit caché.

===== 2. Analyse RS (_RS Analysis_)

L'analyse RS est la méthode classique et la plus puissante pour détecter l'insertion LSB. Elle exploite la *relation spatiale* entre les pixels :

- *Principe :* Elle mesure la *facilité* avec laquelle des groupes de pixels voisins sont modifiés ou conservés sous une transformation simple (généralement la modification de parité).
- *Groupes Modifiables (R) et Singuliers (S) :*
  - L'image est divisée en petits groupes de pixels (ex : $2 times 2$).
  - On applique une *fonction de discrimination* sur ces groupes.
  - L'analyse compte le nombre de groupes qui deviennent *plus réguliers* (groupes $R$) ou *plus singuliers* (groupes $S$) après une *opération de permutation* (un décalage de parité, par exemple).
- *L'Exploitation :*
  - L'insertion LSB aléatoire *augmente* le nombre de groupes qui se comportent comme des groupes réguliers ($R$) et *diminue* le nombre de groupes singuliers ($S$) lorsque l'on applique l'opération de permutation sur le plan LSB.
  - Si l'image n'est pas stéganographiée, les courbes $R$ et $S$ se comportent d'une certaine manière. Si elle l'est, elles *se croisent* à un point caractéristique.
  - Le stéganalyste peut *quantifier* l'écartement des courbes pour *estimer la taille* (charge utile) du message caché.

=== Conclusion

L'anomalie statistique créée par la régularisation des valeurs de pixels (l'égalisation de $"hstego"(k)$ et $"hstego"(k+1)$) fournit une *signature quantitative* de la modification. Les techniques de stéganalyse utilisent cette signature pour prouver l'existence du message, réalisant ainsi l'objectif inverse de la stéganographie.

#pagebreak()

== Approches Empiriques de la Stéganographie : Amélioration de la Sécurité

Les approches empiriques modernes visent à surmonter les faiblesses statistiques de la stéganographie simple (comme le remplacement LSB) en rendant les modifications *moins détectables* par les outils de stéganalyse.

=== Stéganographie Basée sur Modèle (_Model-based Steganography_)

- *Principe :* Un *modèle statistique* est identifié pour décrire l'image source. La stéganographie agit de manière à insérer le message *sans modifier les paramètres de ce modèle*.
- *Restauration Statistique :* Le message est inséré dans un sous-ensemble de pixels ou de coefficients. Les autres pixels sont ensuite *modifiés* pour restaurer le modèle statistique (par exemple, l'histogramme).
- *Exemple :* L'algorithme *OutGuess* utilise ce principe dans le domaine DCT pour réaligner les statistiques après l'insertion.
- *Sécurité :* La sécurité est presque parfaite *tant que* la stéganalyse se repose *uniquement* sur le modèle statistique adopté. En pratique, ce n'est jamais le cas, car les stéganalystes utilisent des modèles d'ordre supérieur.

=== Modulation Stochastique (_Stochastic Modulation_)

- *Principe :* Cette technique *simule le bruit* naturellement ajouté à l'image lors de la phase d'acquisition. La stéganographie travaille en ajoutant un bruit qui ressemble au bruit d'acquisition.
- *Types de Bruit Simulé :*
  - Bruit thermique (_Thermal noise_).
  - Bruit de quantification (_Quantization noise_).
  - Bruit de non-uniformité de réponse des pixels (_PRNU_ - _Photo-Response Non-Uniformity_).
- *Charge utile :* Permet des charges utiles relativement *élevées* (jusqu'à $0,8$ _bpp_ - _bit per pixel_).

=== Stéganographie Consciente de la Stéganalyse (_Steganalysis-aware Steganography_)

- *Principe :* Extension de la modulation stochastique. Le stéganographe agit activement pour *éliminer ou réduire* les artefacts connus exploités par le stéganalyste (souvent par *convolution* du message et de l'image source). C'est l'une des méthodes les *plus difficiles à détecter*.
- *Exemple :* *$plus.minus 1$-steg* :
  - Si le LSB est incorrect, l'algorithme *ajoute ou soustrait 1* de manière *aléatoire* (conditionnelle), au lieu de simplement basculer le LSB.
  - *Observation :* Cela ne modifie pas uniquement le LSB (ex : $01111111 + 1 = 10000000$), ce qui est une *sommation conditionnelle* permettant l'extraction du message.
- *Impact :* La sécurité augmente *drastiquement* car l'histogramme ne change pas de manière significative. L'algorithme *F5* utilise $plus.minus 1$-steg dans le domaine fréquentiel.

=== Minimisation de la Distorsion (_Distortion (Impact) Minimization_)

- *Principe :* L'approche la plus *moderne*. Elle définit une *fonction de coût* qui quantifie le "dommage" statistique causé par la modification d'un pixel.
- *Coût :* La fonction de coût $ρ(i)$ mesure le coût de modification d'un pixel donné.
- *Coût Global :* Le coût total est donné par la formule : $sum_(i=1)^n ρ(i)[x(i) - y(i)]^2$.
- *Règle d'Insertion :* L'algorithme cherche une règle d'insertion qui *minimise ce coût global*.
- *Exemple :* *F5* est considéré comme optimum de ce point de vue dans le domaine DCT.

=== Charges Utiles Typiques

- *Domaine Pixel :* De $0,1$ à $0,5$ _bpp_ (_bit per pixel_). Pour une image de $1000 × 1000$, cela représente environ $40 "Ko"$ de données cachées.
- *Domaine DCT :* Jusqu'à $0,8$ _bpnzc_ (_bit per non-zero coefficient_). La charge utile réelle dépend du contenu. Une valeur réaliste est d'environ $20 "Ko"$ pour une image de $1000 × 1000$.

=== Stéganalyse

La stéganalyse est l'étude des méthodes pour détecter les messages cachés. Le succès dépend fortement du *scénario d'application* et des informations disponibles au Gardien (_warden_).

- *Scénarios :*
  - *Stéganalyse aveugle (_Blind_) :* L'algorithme utilisé est inconnu.
  - *Stéganalyse ciblée (_Targeted_) :* L'algorithme est connu (principe de Kerckhoff).
- *Connaissances du Gardien :* Dépend de la connaissance des statistiques de l'image source (_cover image_) et de la charge utile (_payload_).

=== Formulation par Test d'Hypothèse (_Hypothesis Test_)

La stéganalyse est formulée comme un *test d'hypothèse rigoureux* :

- *Hypothèses :*
  - $H_0$ : L'observation $y$ *ne contient pas* de message caché.
  - $H_1$ : L'observation $y$ *contient* un message caché.
- *Critères de Décision :*
  - *Critère de Neyman-Pearson (N-P) :* Utilisé pour la stéganalyse. Il vise à *minimiser la probabilité de non-détection* ($P_m$, _Missed detection probability_) pour une *probabilité de fausse alarme* ($P_f$, _False alarm probability_) fixée.

=== Courbe ROC et Métrique de Performance

- *Courbe ROC (_Receiver Operating Characteristic_) :* Trace le taux de détection correcte ($P_d = 1 - P_m$) en fonction du taux de fausse alarme ($P_f$).
- *AUC (_Area Under Curve_) :* L'aire sous la courbe ROC évalue la bonté d'un stéganalyste. Un système plus précis a une *grande AUC* (proche de 1).
  - *Sécurité Parfaite :* Les performances équivalent à une devinette aléatoire (_random guess_), la courbe ROC est sur la diagonale ($text(A U C) = 0,5$).

=== Test du Chi-Carré (_Chi-Square Test_)

- *Principe :* Utilisé si la distribution de l'image source (_pdf_ - _probability density function_) est connue.
- *Statistique :* La statistique du $χ^2$ est calculée par : $χ^2 = sum_(i=1)^n (n_i - n p_i)^2 / (n p_i)$.
- *Décision :* Les *valeurs élevées* de la statistique $χ^2$ sont prises comme une preuve en faveur de $H_1$ (présence d'un message).

=== Choix des Statistiques (_Feature Selection_)

- *Stéganalyse Ciblée :* Utilise peu de statistiques *ad-hoc*.
  - *Exemple LSB :* Le test $χ^2$ utilise une *distribution de probabilité massique* (_pmf_) sous $H_1$ où les bins consécutifs de l'histogramme sont égalisés : $h_(H_1)(2k) = h_(H_1)(2k + 1) = (h(2k) + h(2k + 1)) / 2$.
- *Stéganalyse Aveugle :* Nécessite des approches basées sur l'apprentissage automatique :
  - On calcule *plus de 100 caractéristiques* (_features_) qui ne dépendent pas du contenu de l'image.
  - On entraîne un *classifieur* (_SVM_) avec des exemples appropriés.
  - Les *CNN* appliqués directement dans le domaine pixel sont en train de remplacer les SVM, bien qu'ils puissent sacrifier la précision en l'absence de pré-traitement.

=== Résumé

- *Stéganographie :* De nombreuses techniques existent, mais la sécurité n'est pas triviale. Une connaissance des principes est essentielle pour éviter les attaques simples.
- *Stéganalyse :* Elle est *fiable* dans des cas sélectionnés (stéganalyse ciblée, charge utile élevée), mais *difficile* dans le cas général (stéganalyse aveugle).
- *Domaine Actif :* Ces domaines restent des sujets de recherche intense (_work in progress_).

#pagebreak()

= Biometric forensics

== Criminalistique Biométrique : Classification des Attaques sur les Systèmes Biométriques (_Attacks on Biometric Systems_)

Les systèmes biométriques, bien que conçus pour la sécurité, présentent plusieurs points de vulnérabilité qui peuvent être exploités par des attaquants. Ces attaques sont généralement classées en deux catégories principales, selon le point d'injection du signal contrefait dans l'architecture du système.

=== 1. Attaques Directes (_Direct Attacks_)

Les attaques directes, également appelées *attaques de présentation* (_Presentation Attacks_ - PAs) ou *usurpation d'identité* (_spoofing_), sont les plus simples et les plus courantes. Elles se produisent au niveau du *capteur* :

- *Localisation :* Point 1 (Interface utilisateur / Capteur).
- *Principe :* L'attaquant tente de tromper le capteur en présentant une *contrefaçon* d'une caractéristique biométrique légitime (une imitation de l'échantillon biométrique) sans modifier ou manipuler le capteur lui-même.
- *Exemples :*
  - Utiliser un *faux doigt* en gélatine ou silicone sur un scanner d'empreintes digitales.
  - Utiliser une *photographie* ou une *vidéo* pour tromper un système de reconnaissance faciale.
  - Utiliser un *enregistrement audio* pour contourner un système de reconnaissance vocale.
- *Contre-mesure :* La *détection d'attaque de présentation* (_Presentation Attack Detection_ - PAD) ou détection de *vivacité* (_liveness detection_) est la principale défense contre ce type d'attaque.

=== 2. Attaques Indirectes (_Indirect Attacks_)

Les attaques indirectes sont plus sophistiquées. Elles sont menées *à l'intérieur du système biométrique* en ciblant les modules de traitement ou les canaux de communication :

- *Localisation :* Points 2 à 8 dans l'architecture interne du système.
- *Principe :* L'attaquant n'a pas besoin d'un échantillon physique. Il manipule les données numériques et les processus internes.

=== Vulnérabilités Spécifiques dans les Attaques Indirectes

Les attaques indirectes ciblent plusieurs modules critiques du système :

- *Canaux de Communication (Points 2, 4, 7, 8) :*
  - L'attaquant peut *intercepter* et *manipuler* les données biométriques (l'échantillon brut, les caractéristiques, le score de correspondance) lorsqu'elles transitent entre les différents modules.
  - Il peut par exemple injecter un *jeu de caractéristiques valides* (_valid features_) à l'intérieur du canal (Point 2) avant l'extracteur de caractéristiques.
- *Module d'Extraction des Caractéristiques (Point 3) :*
  - L'attaquant *contourne* le module d'extraction et injecte directement un ensemble de *caractéristiques biométriques synthétiques* (ou volées) dans le comparateur.
- *Module de Comparaison (Point 5) :*
  - L'attaquant manipule le *comparateur* pour qu'il génère un score de correspondance élevé, garantissant l'accès.
- *Base de Données des Références (Point 6) :*
  - Cible critique. L'attaquant peut *manipuler* ou *remplacer* les *références biométriques* (_biometric references_) stockées (les gabarits ou _templates_).
  - Une technique courante est le *plantage de gabarit* (_template planting_) : l'attaquant insère son propre gabarit valide pour un utilisateur légitime, lui donnant un accès permanent.

=== Importance de la Cryptographie

Les attaques indirectes soulignent l'importance de la *cryptographie* et des *mécanismes anti-sabotage* pour protéger les données stockées (Point 6) et les canaux de communication (Points 2, 4, 7, 8). La criminalistique biométrique se concentre sur l'analyse de ces failles pour renforcer la sécurité globale.

== Biometric forensics: classification: Attacks on biometric systems

- Direct attacks (spoofing or presentation attacks - PAs) are performed at the sensor level: the sensor is fooled but not replaced or tampered.
- Indirect attacks are performed inside the system by:
  - bypassing the feature extractor or the comparator (3, 5)
  - manipulating the biometric references in the biometric reference database (6)
  - exploiting possible weak points in communication channels (2, 4, 7, 8)

#pagebreak()

== Attaques de Présentation (_Presentation Attacks_)

Les attaques de présentation (PA), souvent appelées *usurpation d'identité* (_spoofing_), sont des attaques *directes* menées au niveau du capteur biométrique. Elles consistent à présenter à l'interface de capture un artéfact ou une imitation dans le but de se faire passer pour un utilisateur légitime.

- *Principe :* L'attaquant présente une contrefaçon matérielle ou numérique de la caractéristique biométrique (visage, empreinte, voix, etc.) au capteur.
- *Vulnérabilité :* Ces attaques exploitent le fait que la plupart des capteurs ne vérifient pas la *vitalité* ou le caractère *vivant* (_liveness_) de l'échantillon présenté.

=== Exemples d'Attaques de Présentation par Modèle Biométrique

- *Reconnaissance Faciale (_FaceID_) :*
  - *Photos :* Utilisation de *photographies* de haute résolution (sur papier ou écran) pour tromper les systèmes de base.
  - *Masques en silicone :* Utilisation de *masques en silicone* réalistes ou de prothèses 3D pour simuler le visage de la victime.
  - *Deepfake 2D :* Des images faciales *réalistes* sont générées à l'aide de *Réseaux Génératifs Antagonistes* (_Generative Adversarial Networks_ - GAN) pour être affichées sur un écran devant la caméra.

- *Empreintes Digitales (_Fingerprint_) :* L'usurpation d'empreintes est souvent réalisée à l'aide de *doigts factices* (_fake fingers_) ou *doigts gélatineux* (_gummy fingers_).
  - *Avec Coopération (ou accès à la victime) :* Des matériaux comme la *gélatine* ou la *colle à bois* (_wood glue_) sont utilisés pour créer un moule (ou une empreinte positive) du doigt légitime.
  - *Sans Coopération :* Une *empreinte latente* (_latent fingerprint_) (laissée sur une surface) est *relevée* et transférée sur un support (comme un *circuit imprimé* - _PCB_) pour servir de moule à la création du doigt factice.

- *Reconnaissance de l'Iris (_Iris_) :*
  - *Usurpation d'Iris :* Utilisation d'images de l'iris imprimées sur du *papier de haute qualité* à l'aide d'une imprimante à jet d'encre (_inkjet printer_) ou affichées sur des lentilles de contact.

- *Veines du Doigt (_Finger-vein_) :*
  - *Usurpation de veines :* Contrefaçon sophistiquée ciblant les systèmes de reconnaissance des motifs veineux internes.

- *Reconnaissance Vocale (_Voice_) :*
  - *Attaque Vocale :* Lecture d'un *enregistrement vocal* (_playback of a voice recording_), utilisation d'une *synthèse vocale* (_synthesised speech_) générée par ordinateur, ou d'une *voix convertie* (_converted voice_) pour tromper le microphone.

=== Défense contre les PAs

La principale défense contre ces attaques est la *Détection d'Attaque de Présentation* (_Presentation Attack Detection_ - PAD), qui utilise des techniques pour vérifier la *vitalité* ou les propriétés physiques (chaleur, mouvement, réflectivité) de l'échantillon présenté.

#pagebreak()

== Méthodes de Défense contre les Attaques de Présentation (_Presentation Attack Defense Methods_)

La défense contre les attaques de présentation (_Presentation Attacks_ - PAs) est essentielle pour garantir l'intégrité des systèmes biométriques. Ces méthodes, collectivement appelées *Détection d'Attaque de Présentation* (_PAD - Presentation Attack Detection_) ou détection de *vivacité* (_liveness detection_), sont classées selon la nature de l'analyse effectuée.

=== Classification des Méthodes de Défense

- *Basées sur Logiciel (_Software-based_) :*
  - Le système analyse les *données biométriques* brutes ou transformées provenant du capteur unique existant.
  - L'analyse se concentre sur des caractéristiques qui distinguent un échantillon original/vivant d'un échantillon contrefait/attaqué (exemples : analyse de la *texture*, du *mouvement*, du *clignement d'yeux*).
  - *Avantage :* Généralement moins coûteux à mettre en œuvre, car il ne nécessite pas de nouveau matériel.

- *Basées sur Matériel (_Hardware-based_) :*
  - Un ou plusieurs *capteurs additionnels* sont utilisés.
  - Les données de ces capteurs sont analysées pour confirmer la *vitalité* de la source.
  - *Exemples :* Mesure de la *température* de la peau, détection du *pouls* (flux sanguin), analyse de la *conductivité* ou des *propriétés électriques*.

- *Défi-Réponse (_Challenge-Response_) :*
  - L'utilisateur doit interagir avec le système de manière *non prédictible* pour prouver sa vivacité.
  - *Exemples :* Demander à l'utilisateur de répéter un *texte aléatoire* (pour la reconnaissance vocale) ou d'effectuer une *séquence de mouvements* spécifiques (pour la reconnaissance faciale).

=== Défense en Bande Optique Unique (_With only optical band_)

Lorsque le système n'utilise qu'un seul capteur optique (bande visible), la détection repose sur des analyses d'images avancées :

- *Flux Optiques (_Optical Flows_) :*
  - Analyse du *gradient des changements* entre des images consécutives.
  - Utilisé pour vérifier si le mouvement est *naturel* (3D) ou s'il s'agit d'un simple mouvement 2D d'une photo ou d'un écran.
  - *Limite :* Ces caractéristiques sont souvent *locales* et moins efficaces contre les masques sophistiqués.

- *Analyse de Texture (_Texture Analysis_) :*
  - Utilise des descripteurs (comme LBP, SIFT) pour analyser la *structure de la surface* de l'échantillon présenté.
  - Permet de détecter les différences de texture entre la peau humaine et les matériaux des contrefaçons (papier, silicone, gélatine).
  - Combine des caractéristiques *globales* et *locales* pour alimenter un *classifieur* (_classifier_).

=== Défense par Spectre Multiple du Visage (_Multi-spectral face presentation attack defense_)

L'utilisation de capteurs multiples ou de caméras multispectrales améliore considérablement la robustesse :

- *Profondeur (_Depth_) :* Les systèmes qui mesurent la profondeur (caméras 3D ou structurées) protègent efficacement *contre les photos* et les images 2D (qui n'ont pas de profondeur).
- *Infrarouge (IR) :* Les capteurs IR peuvent être utilisés pour analyser la *réflexion de la peau*, le motif veineux sous la surface, ou pour détecter les *masques* (qui peuvent bloquer ou réfléchir différemment les longueurs d'onde IR).
- *Thermique (_Thermal_) :* Les capteurs thermiques mesurent la *chaleur corporelle*. Une photo ou un masque n'émet pas un profil thermique cohérent avec celui d'un être vivant.
- *Couleur :* Analyse des couleurs spectrales pour détecter les anomalies de couleur des matériaux contrefaits.

=== Importance de la Réversibilité des Biométries

- *Conclusion :* Les données biométriques sont par nature *très uniques* et *irremplaçables* (_very unique and irreplacable_). Si une empreinte digitale ou un gabarit d'iris est compromis, il est impossible de le révoquer et d'en choisir un nouveau (contrairement à un mot de passe).
- *Conséquence :* Pour les scénarios où la sécurité est critique, il est préférable de privilégier des mécanismes de défense biométrique *très robustes* ou de les utiliser en *combinaison* avec d'autres facteurs (comme un *mot de passe*, _password_) pour garantir la révocabilité en cas de compromission.

== Méthodes de Défense contre les Attaques de Présentation (_Presentation Attack Defense Methods_)

Les méthodes de Détection d'Attaque de Présentation (_PAD_) visent à vérifier la *vivacité* (_liveness_) de l'échantillon pour contrer le *spoofing* au niveau du capteur.

=== Classification des Méthodes de Défense

- *Basées sur Logiciel (_Software-based_) :*
  - Analyse les *données biométriques* du capteur pour détecter des signes de contrefaçon (exemples : analyse de la *texture*, du *mouvement* ou du *clignement*).
  - *Avantage :* Coût de mise en œuvre faible.

- *Basées sur Matériel (_Hardware-based_) :*
  - Utilise des *capteurs additionnels* pour mesurer des propriétés physiques non imitables.
  - *Exemples :* Mesure de la *température* de la peau, détection du *pouls* ou analyse de la *conductivité*.

- *Défi-Réponse (_Challenge-Response_) :*
  - L'utilisateur doit interagir de manière *non prédictible* (exemples : répéter un *texte aléatoire*, effectuer un *mouvement spécifique*).

=== Techniques Spécifiques

- *Bande Optique Unique :*
  - *Flux Optiques (_Optical Flows_) :* Analyse du *gradient des changements* entre les images pour distinguer les mouvements 2D (photo/écran) des mouvements 3D (vivant).
  - *Analyse de Texture (_Texture Analysis_) :* Utilise des descripteurs pour distinguer la texture de la peau humaine de celle des matériaux contrefaits (silicone, papier).

- *Spectre Multiple (Défense Avancée) :*
  - *Profondeur (_Depth_) :* Protège *contre les photos* et les images 2D.
  - *Infrarouge (IR) :* Analyse la *réflexion de la peau* ou les motifs veineux, efficace *contre les masques*.
  - *Thermique (_Thermal_) :* Mesure la *chaleur corporelle* (profil thermique).

=== Note sur la Sécurité Biométrique

- *Irremplaçabilité :* Les données biométriques sont *uniques et irremplaçables*. Si un gabarit est compromis, il ne peut pas être révoqué comme un mot de passe.
- *Recommandation :* Il est crucial d'utiliser des mécanismes *PAD très robustes* ou de combiner la biométrie avec d'autres facteurs (comme un mot de passe) dans les scénarios de haute sécurité.
