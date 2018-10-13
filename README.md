# Devfest 2018, Valeuriad
Sources & Ressources du talk AI Takeover du DevFest Nantes 2018 

## game_logic
Contient les sources relatives à l'entraînement et au run du bot et du moteur de jeu.

### Sources
1. src/train\_ruler.py : entraîne un nouveau moteur de jeu (autorise ou non les déplacements, retourne les codes de victoire & défaite)
2. src/app\_ruler.py : web service flask exposant le modèle du moteur de jeu et la map (rentrée en dur à partir d'une des 3 maps stockées au format RDS dans data/ ) sur le port 5000
3. src/rldql.R : script R permettant d'entraîner un nouveau bot via [deep q learning](https://medium.freecodecamp.org/an-introduction-to-deep-q-learning-lets-play-doom-54d02d8017d8)
4. src/Agent.R : script R contenant la logique de l'agent (le bot) & exposant une api permettant de requeter son prochain mouvement en fonction de l'état de la map 
5. src/mapGeneration.R : script R permettant de faire tourner un [algo génétique](https://en.wikipedia.org/wiki/Genetic_algorithm) pour générer une nouvelle map 
6. run\_bot.R : script R permettant d'exposer l'api de Agent.R derrière un webservice (via plumber)

### Données
game\_logic/data contient 3 maps générées par l'algo génétique ainsi qu'un modèle de deep q learning contrôlant le comportement du bot.
game\_logic/img contient une illustration du comportement du bot.

## graphes
Contient le script R permettant de générer des graphiques au format [xkcd](http://xkcd.r-forge.r-project.org/). Pourquoi ? Parce qu'on peut.

## graphics
Contient les scripts python permettant de faire tourner un [GAN](https://skymind.ai/wiki/generative-adversarial-network-gan). Un [ACGAN](https://arxiv.org/abs/1610.09585) a également été essayé.

1. data/proc contient les données sérialisées des différents sprites qui ont été scrapés (block: les blocks ;), gm: ghost monster, pacman : pacman, pg: pacman ghost, tiles: tiles)
2. img/ contient quelques exemples d'images générées
3. src/scraper.py : permet de scraper des images sur google image (python scraper.py -s pacman -n 200 -d path/to/download)
4. scr/scraper.R : script R permettant de lancer scraper.py et de pré-processer les images (resize en 28x28 grayscale et 28x28 color; passage du background en blanc; normalisation des différents color channel) et sérialise les images dans data/proc (data.dat = grayscale, cdata.dat = color) 
5. src/acgan.R & src/gan.R sont des scripts R permettant de faire tourner un gan ou un gan conditionnel directement à partir des données contenues dans data/proc
6. src/acgan/acgan.py et gan.py sont les équivalents python, c'est le gan.py qui a été utlisé pour les images présentées lors du talk. Les deux se basent non pas sur les données .RDS (format R) mais sur les données .csv
7. src/cdata_to_csv.R : script R permettant de transformer les données RDS (cdata.dat) au format csv (pour lecture sous python: /!\ pandas & R n'utilisent pas le même ordonnancement des données matricielles)

## pacman-ai 
Projet angular contenant l'UI du jeu

## Docker
Le projet peut être lancé via un container docker. 

### Depuis Dockerhub :
    docker pull valeuriad/pacman
    docker run -p 4242:4242 -p 5000:5000 -p 4200:4200 valeuriad/pacman 

### Build : 
    docker build -t pacman-ai .
    docker run -p 4242:4242 -p 5000:5000 -p 4200:4200 pacman-ai
