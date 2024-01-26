#Importation des librairies nécessaires au code
library(tidyverse)
library(plotly)
library(dplyr)
library(lubridate)
library(ggplot2)

#Inclusion des fonctions du code
source("C:/ISEN/CIR-3/BigData/projetBDIAWEB/bigdata/local/commande2G.R")

#Ouverture des fichier csv
database <- read.csv("C:/ISEN/CIR-3/BigData/projetBDIAWEB/bigdata/stat_acc_V3.csv", header = TRUE, sep = ";", encoding = "utf-8")
tot_habitants <- read.csv("C:/ISEN/CIR-3/BigData/projetBDIAWEB/bigdata/Regions.csv", header = TRUE, sep = ";", encoding = "utf-8")
regions <- read.csv("C:/ISEN/CIR-3/BigData/projetBDIAWEB/bigdata/communes-departement-region.csv", header = TRUE, sep = ";", encoding = "utf-8")

#-------CHANGER LE CHEMIN D'ACCES-----------------#
fichier_type <- "C:/ISEN/CIR-3/BigData/projetBDIAWEB/bigdata/type.txt"

#Nettoyage des données
E1 <- Nettoyage_des_donnees(database)

#suppression du fichier "type.txt" s'il existe
if (file.exists(fichier_type)) {
  file.remove(fichier_type)
}

#Convertion de certaines types du tableau
E1 <- valeur_num_type(E1, "descr_cat_veh",fichier_type)
E1 <- valeur_num_type(E1, "descr_agglo",fichier_type)
E1 <- valeur_num_type(E1, "descr_athmo",fichier_type)
E1 <- valeur_num_type(E1, "descr_lum",fichier_type)
E1 <- valeur_num_type(E1, "descr_etat_surf",fichier_type)
E1 <- valeur_num_type(E1, "description_intersection",fichier_type)
E1 <- valeur_num_type(E1, "descr_dispo_secu",fichier_type)
E1 <- valeur_num_type(E1, "descr_grav",fichier_type)
E1 <- valeur_num_type(E1, "descr_motif_traj",fichier_type)
E1 <- valeur_num_type(E1, "descr_type_col",fichier_type)

#Appel de la fonction pour contruire la chronologique
re <- construire_series_chronologiques(E1)

#Ajout des regions à E1
E1<-ajout_region(E1,tot_habitants,regions)

#Création du jeu de données et encodage utf-8 du tableau
E2 <- JDD_accidents_regions(E1,tot_habitants,regions)
Encoding(E2$REG) <- "UTF-8"

#Histogramme sur le nombre d'accidents par tranches d'âges
hist_accident(E1)

#Histogramme sur le nombre d'accidents par mois
hist_mensuel(E1)
