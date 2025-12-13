= Image Editing

== Traces de retouche d'image : Égalisation d'histogramme

L'égalisation d'histogramme est une technique de traitement d'image visant à *augmenter le contraste* d'une image. Elle y parvient en réattribuant les valeurs de pixels (leur luminance ou couleur) de manière à ce que la distribution des nouvelles valeurs soit approximativement *uniforme*. Cela a pour effet d'étaler la gamme dynamique des pixels, rendant les détails plus visibles, notamment dans les zones sombres ou très claires.

- *Identification :* Pour détecter si cette technique a été appliquée, on analyse l'*histogramme* de l'image. On cherche à calculer sa « uniformité ».
- *Caractéristique Clé (CDF) :* Une image ayant subi une égalisation d'histogramme se caractérise par une *fonction de répartition cumulative (CDF)* de ses valeurs de pixels qui est de forme *linéaire*. C'est cette linéarité de la CDF qui garantit la distribution uniforme des pixels en sortie.
- *Cas des images saturées :* L'application de l'égalisation à des images présentant des zones de *saturation* (valeurs de pixels maximales ou minimales atteintes) entraîne souvent un *déplacement* des *pics impulsifs* de l'histogramme, ce qui peut *complexifier la détection* de la manipulation.
- *Détection Compliquée par la Saturation :* La détection de l'égalisation repose souvent sur l'observation de l'*alignement des marches* ou de la *linéarité* de la CDF. Dans les images avec des zones de saturation (pixels à 0 ou 255), l'égalisation force ces grandes masses de pixels à *s'étaler* sur la nouvelle gamme dynamique. Cela a pour conséquence de *déplacer* les *pics impulsifs* (les marches abruptes) de l'histogramme vers des positions inattendues. Ce déplacement *perturbe les modèles statistiques* utilisés pour juger de la « propreté » de la distribution des pixels, rendant plus difficile de confirmer ou d'infirmer la présence d'une égalisation.

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

= Deep learning methods in digital forensics
