##1 Suppression des lignes non-valides

#Importation et visualisation du fichier csv
Accidents <- read.csv("/ISEN/CIR-3/BigData/Projet/local/stat_acc_V3.csv", sep=";")
View(Accidents)
summary(Accidents)

#Suppression des lignes ne contenant aucunes valeurs
Accidents_no_NA <- na.omit(Accidents)
View(Accidents_no_NA)
summary(Accidents_no_NA)

#On remarque la présence de valeurs maximales absurdes concernant la longitude et la latitude
#Exemple 1: Ligne 3683 -> longitude > 90
#Exemple 2: Ligne 3684 -> latitude > 90

#Supression des lignes contenant des valeurs absurdes en suivant la condition suivante :
Condition <- Accidents_no_NA$longitude < -90 | Accidents_no_NA$longitude > 90 | Accidents_no_NA$latitude < -90 | Accidents_no_NA$latitude > 90
Accidents_filtre <- subset(Accidents_no_NA, !Condition)
summary(Accidents_filtre)
