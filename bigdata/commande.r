library(tidyverse)
library(plotly)
library(dplyr)
library(lubridate)
source("C:/Users/Emilie/Documents/ISEN 2022/projet_bigdata/bigdata/fonctions_Emi.r")
source("C:/Users/Emilie/Documents/ISEN 2022/projet_bigdata/bigdata/fonction_regression.r")

#ouverture des fichier csv
database <- read.csv("C:/Users/Emilie/documents/ISEN 2022/stat_acc_V3.csv", header = TRUE, sep = ";",encoding = "UTF-8")
tot_habitants <- read.csv("C:/Users/Emilie/Documents/ISEN 2022/Regions.csv", header = TRUE, sep = ";",encoding = "UTF-8")
regions <- read.csv("C:/Users/Emilie/Documents/ISEN 2022/communes-departement-region.csv", header = TRUE, sep = ";",encoding = "UTF-8")
tot_habitants_departement <-read.csv("C:/Users/Emilie/Documents/ISEN 2022/ptot_departement.csv", header = TRUE, sep = ",",encoding = "UTF-8")
#-------CHANGER LE CHEMIN D'ACCES-----------------#
fichier_type <- "C:/Users/Emilie/documents/ISEN 2022/type.txt"


#Nettoyage des données
E1 <- Nettoyage_des_donnees(database)
database <- Nettoyage_des_donnees(database)

#suppression du fichier s'il existe
if (file.exists(fichier_type)) {
  file.remove(fichier_type)
}

#convertion des types en chiffre
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


#appel de la fonction pour contruire la chronologie
re <- construire_series_chronologiques(E1)
regression_semaine<- re$regression_semaine
regression_mois <- re$regression_mois
accidents_par_mois_cumulee <- re$accidents_par_mois_cumulee
accidents_par_semaine_cumulee <- re$accidents_par_semaine_cumulee
niveau_agregation<- re$niveau_agregation

#plot(accidents_par_mois_cumulee,main="Régression linéaire d'accidents par mois")
#abline(coef(regression_mois))

#plot(accidents_par_semaine_cumulee,main="Régression linéaire d'accidents par semaine")
#abline(coef(regression_semaine))

#R2_m <-cor(accidents_par_mois_cumulee,c(1:12))^2
#R2_m
#x_m <-cbind(rep(1,12),accidents_par_mois_cumulee)
#R2_m_ajust <- R2_m-(1-R2_m)/(length(x_m)-1-1)
#R2_m_ajust

#R2_s <-cor(accidents_par_semaine_cumulee,c(1:53))^2
#R2_s
#x_s <-cbind(rep(1,53),accidents_par_semaine_cumulee)
#R2_s_ajust <- R2_s-(1-R2_s)/(length(x_s)-1-1)
#R2_s_ajust

E2_dep<- ajout_departement(E1,regions)
#ajouter les regions à E1
E3_reg<-ajout_region(E1,tot_habitants,regions)

resultats <- calculer_accidents(E3_reg, E2_dep, tot_habitants, tot_habitants_departement)

# Récupération des résultats dans des variables individuelles
accidents_par_region <- resultats$accidents_par_region
accidents_par_departement <- resultats$accidents_par_departement
accidents_graves_par_region <- resultats$accidents_graves_par_region
accidents_graves_par_departement <- resultats$accidents_graves_par_departement

accidents_par_departement <- rename(accidents_par_departement,REG=nom_departement)
accidents_graves_par_departement <- rename(accidents_graves_par_departement,REG=nom_departement)

#afficher les cartes des accidents par régions et par départements
carte_r(E3_reg,accidents_par_region,"code_region","Taux d'accidents par région pour 100k/habitants en 2009")
carte_r(E3_reg,accidents_graves_par_region,"code_region","Taux d'accidents grave par région pour 100k/habitants en 2009")
carte_d(E2_dep,accidents_par_departement,"code_departement","Taux d'accidents par département pour 100k/habitants en 2009")
carte_d(E2_dep,accidents_graves_par_departement,"code_departement","Taux d'accidents grave par département pour 100k/habitants en 2009")


#ajouter les regions à E1
E_100k<-ajout_region2(E1,tot_habitants,regions)

#Jeu de données pour ACP
E_100k <- JDD_accidents_regions(E_100k)

comparer_regessions(re)

# Supprimer les avertissements lors de la conversion en numérique
suppressWarnings({
  variables_numeriques <- c("age", "place", "an_nais", "id_code_insee", "id_usa")
  E1[variables_numeriques] <- lapply(E1[variables_numeriques], as.numeric)
})

# Convertir la colonne de date/heure en format POSIXct
E1$date <- as.POSIXct(E1$date, format = "%Y-%m-%d %H:%M:%S")

# Extraire l'heure à partir de la colonne de date/heure et créer une nouvelle colonne "heure"
E1$heure <- format(E1$date, "%H:%M:%S")

# Diviser les heures en plages horaires (0-6h, 6-12h, 12-18h, 18-24h)
plages_horaires <- cut(as.numeric(format(E1$date, "%H")), 
                       breaks = c(0, 6, 12, 18, 24), 
                       labels = c("0-6h", "6-12h", "12-18h", "18-24h"),
                       include.lowest = TRUE)

# Ajouter la colonne des plages horaires au dataframe
E1$plages_horaires <- plages_horaires

# Convertir la colonne de date en format DATE
variables_dates <- c("date")
E1[variables_dates] <- lapply(E1[variables_dates], as.Date)

# Construire des séries chronologiques d'accidents par semaine et par mois
re <- construire_series_chronologiques(E1)
accidents_par_semaine <- re$accidents_par_semaine
accidents_par_mois <- re$accidents_par_mois

# Créer le graphique des accidents par semaine
graphique_semaine <- creer_graphique_barres_v2(accidents_par_semaine, "Semaine", "Nombre_accidents", "Semaine", "Nombre d'accidents", "Nombre d'accidents par semaine")

# Créer le graphique des accidents par mois
graphique_mois <- creer_graphique_barres_v2(accidents_par_mois, "Mois", "Nombre_accidents", "Mois", "Nombre d'accidents", "Nombre d'accidents par mois")

# Afficher le résultat de la construction des séries chronologiques
print(re)

####AF####
# Création d'une table avec le nombre d'accidents par ville
table_villes <- E1 %>% count(ville, sort = TRUE)

# Sélection des 30 premières villes
top_villes <- head(table_villes, 30)

# Calculer le nombre d'accidents par jour de la semaine
accidents_par_jour_semaine <- E1 %>%
  mutate(Jour_semaine = wday(date, label = TRUE)) %>%
  count(Jour_semaine) %>%
  arrange(match(Jour_semaine, c("lun", "mar", "mer", "jeu", "ven", "sam", "dim")))

# Créer le graphique à barres avec Plotly pour les accidents par jour de la semaine
plot <- plot_ly(accidents_par_jour_semaine, x = ~Jour_semaine, y = ~n, type = "bar", marker = list(color = "steelblue"))

# Personnaliser l'axe x et y du graphique
plot <- plot %>% layout(xaxis = list(title = "Jour de la semaine"), yaxis = list(title = "Nombre d'accidents"), title = "Nombre d'accidents par jour de la semaine")

# Créer le graphique à barres avec les conditions atmosphériques
creer_graphique_barres_v1(database, "descr_athmo", "n", "Conditions atmosphériques", "Nombre d'accidents", "Nombre d'accidents en fonction des conditions atmosphériques")

# Créer le graphique à barres avec la description de la surface
creer_graphique_barres_v1(database, "descr_etat_surf", "n", "Description de la surface", "Nombre d'accidents", "Nombre d'accidents en fonction de la description de la surface")

# Créer le graphique à barres avec la gravité des accidents
creer_graphique_barres_v1(database, "descr_grav", "n", "Gravité", "Nombre d'accidents", "Nombre d'accidents en fonction de la gravité")

# Créer le graphique à barres avec les top 30 des villes par nombre d'accidents
creer_graphique_barres_v2(top_villes, "ville", "n", "Ville", "Nombre d'accidents", "Top 30 des villes par nombre d'accidents")

# Créer le graphique à barres avec les tranches horaires
creer_graphique_barres_v1(E1, "plages_horaires", "n", "Tranches horaires", "Nombre d'accidents", "Nombre d'accidents par tranches horaires")

# Afficher le graphique des accidents par jour de la semaine
print(plot)

# Afficher le graphique des accidents par semaine
print(graphique_semaine)

# Afficher le graphique des accidents par mois
print(graphique_mois)


######ANALYSE#######
# Chargement des packages nécessaires
library(vcd)
library(lmtest)
library(zoo)

# Tableaux croisés et tests d'indépendance du chi2
table_croisee_1 <- table(database$descr_grav, database$descr_athmo)
table_croisee_2 <- table(database$descr_grav, database$descr_cat_veh)
table_croisee_3 <- table(database$descr_grav, database$descr_agglo)
table_croisee_4 <- table(database$descr_grav, database$descr_lum)
table_croisee_5 <- table(database$descr_grav, database$descr_etat_surf)
table_croisee_6 <- table(database$descr_grav, database$descr_dispo_secu)

# Tableaux croisés et tests d'indépendance du chi2 avec simulation
test_chi2_1 <- chisq.test(table_croisee_1)
test_chi2_2 <- chisq.test(table_croisee_2)
test_chi2_3 <- chisq.test(table_croisee_3)
test_chi2_4 <- chisq.test(table_croisee_4)
test_chi2_5 <- chisq.test(table_croisee_5)
test_chi2_6 <- chisq.test(table_croisee_6)

# Affichage des résultats des tests d'indépendance du chi2
print("Test d'indépendance du chi2 : descr_grav vs. descr_athmo")
print(test_chi2_1)
print("Test d'indépendance du chi2 : descr_grav vs. descr_cat_veh")
print(test_chi2_2)
print("Test d'indépendance du chi2 : descr_grav vs. descr_agglo")
print(test_chi2_3)
print("Test d'indépendance du chi2 : descr_grav vs. descr_lum")
print(test_chi2_4)
print("Test d'indépendance du chi2 : descr_grav vs. descr_etat_surf")
print(test_chi2_5)
print("Test d'indépendance du chi2 : descr_grav vs. descr_dispo_secu")
print(test_chi2_6)

# Ajustement pour rendre toutes les valeurs positives
residuals_adjusted_1 <- test_chi2_1$residuals
residuals_adjusted_2 <- test_chi2_2$residuals
residuals_adjusted_3 <- test_chi2_3$residuals
residuals_adjusted_4 <- test_chi2_4$residuals
residuals_adjusted_5 <- test_chi2_5$residuals
residuals_adjusted_6 <- test_chi2_6$residuals
residuals_adjusted_1 <- residuals_adjusted_1 - min(residuals_adjusted_1) + 1
residuals_adjusted_2 <- residuals_adjusted_2 - min(residuals_adjusted_2) + 1
residuals_adjusted_3 <- residuals_adjusted_3 - min(residuals_adjusted_3) + 1
residuals_adjusted_4 <- residuals_adjusted_4 - min(residuals_adjusted_4) + 1
residuals_adjusted_5 <- residuals_adjusted_5 - min(residuals_adjusted_5) + 1
residuals_adjusted_6 <- residuals_adjusted_6 - min(residuals_adjusted_6) + 1

# Représentation graphique avec mosaic plots


mosaicplot(table_croisee_1, 
           color = residuals_adjusted_1,
           las = 1,
           main = "Mosaic Plot: descr_grav vs. descr_athmo")
mosaicplot(table_croisee_2, 
           color = residuals_adjusted_2,
           las = 1,
           main = "Mosaic Plot: descr_grav vs. descr_cat_veh")
mosaicplot(table_croisee_3,
           color = residuals_adjusted_3,
           las = 1,
           main = "Mosaic Plot: descr_grav vs. descr_agglo")
mosaicplot(table_croisee_4, 
           color = residuals_adjusted_4,
           las = 1,
           main = "Mosaic Plot: descr_grav vs. descr_lum")
mosaicplot(table_croisee_5, 
           color = residuals_adjusted_5,
           las = 1,
           main = "Mosaic Plot: descr_grav vs. descr_etat_surf")
mosaicplot(table_croisee_6, 
           color = residuals_adjusted_6,
           las = 1,
           main = "Mosaic Plot: descr_grav vs. descr_dispo_secu")

# export :
write.csv2(x = E1, file = "export_IA.csv")
