# projetBDIAWEB
# Partie BigData

```
# Projet Web IA - Analyse de données de statistiques d'accidents

Ce projet utilise R pour analyser les données de statistiques d'accidents.

## Prérequis

Avant de commencer, assurez-vous d'avoir installé les packages suivants :

- tidyverse
- plotly
- dplyr
- lubridate

Vous pouvez les installer en exécutant la commande suivante :

```R
install.packages(c("tidyverse", "plotly", "dplyr", "lubridate"))
```

## Instructions

1. Assurez vous d'avoir les fichiers CSV suivants :

- stat_acc_V3.csv
- Regions.csv
- communes-departement-region.csv
- ptot_departement.csv

2. Exécutez le code du fichier commande.r dans RStudio ou tout autre environnement R.

## Nettoyage des données

Le code commence par charger les données à partir des fichiers CSV et effectue des opérations de nettoyage sur les données. Les données nettoyées sont stockées dans le dataframe `database`.

## Convertion des types en chiffre

Ensuite, le code convertit certaines variables catégorielles en variables numériques en utilisant la fonction `valeur_num_type`.

## Construction des séries chronologiques

Le code appelle la fonction `construire_series_chronologiques` pour construire les séries chronologiques des accidents par semaine et par mois. Les résultats sont stockés dans les variables `regression_semaine`, `regression_mois`, `accidents_par_mois_cumulee` et `accidents_par_semaine_cumulee`.

## Analyse des accidents par région et par département

Le code effectue une analyse des accidents par région et par département en utilisant les données sur la population totale. Les résultats sont stockés dans les variables `accidents_par_region`, `accidents_par_departement`, `accidents_graves_par_region` et `accidents_graves_par_departement`.

## Graphiques

Le code crée plusieurs graphiques pour visualiser les données, notamment des graphiques des accidents par semaine et par mois, des cartes des accidents par région et par département, et d'autres graphiques exploratoires.

## Analyse statistique

Enfin, le code effectue des analyses statistiques, y compris des tableaux croisés et des tests d'indépendance du chi2, sur différentes variables des données d'accidents.

