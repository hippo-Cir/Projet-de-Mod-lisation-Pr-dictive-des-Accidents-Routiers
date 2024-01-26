library(tidyverse)
library(plotly)
library(dplyr)
library(lubridate)
#####LIRE CSV####
database <- read.csv("C:/Users/33784/Desktop/stat_acc_V3.csv", header = TRUE, sep = ";",encoding = "UTF-8")

#Suppression des lignes ne contenant aucunes valeurs
Accidents_no_NA <- na.omit(database)
#summary(Accidents_no_NA)

#On remarque la présence de valeurs maximales absurdes concernant la longitude et la latitude
#Exemple 1: Ligne 3683 -> longitude > 90
#Exemple 2: Ligne 3684 -> latitude > 90

#On remarque aussi que certains accidents possèdent un nombre de place NULL :
#Exemple 3: Ligne 52127 -> place = NULL

#Supression des lignes contenant des valeurs absurdes en suivant la condition suivante :
Condition <- Accidents_no_NA$longitude < -90 | Accidents_no_NA$longitude > 90 | Accidents_no_NA$latitude < -90 | Accidents_no_NA$latitude > 90 | Accidents_no_NA$place == 'NULL'
database <- subset(Accidents_no_NA, !Condition)
#summary(database)


#####FONCTION####
valeur_num_type <- function(database, col_name) {
  # Tableau de fréquences des types de valeurs
  table_types <- table(database[[col_name]])
  print(table_types)
  
  # Valeurs uniques et chiffres associés
  types_uniques <- unique(database[[col_name]])
  chiffres_associes <- numeric(length(types_uniques))
  
  # Attribution d'un chiffre à chaque type unique
  for (i in 1:length(types_uniques)) {
    chiffres_associes[i] <- i
  }
  
  # Création d'un tableau de correspondance Type - Chiffre
  correspondance <- data.frame(Type = types_uniques, Chiffre = chiffres_associes)
  
  # Remplacement des valeurs par les chiffres correspondants dans la base de données
  for (i in 1:length(database[[col_name]])) {
    database[[col_name]][i] <- chiffres_associes[match(database[[col_name]][i], types_uniques)]
  }
  
  # Conversion des variables en type numérique
  variables_numeriques <- c(col_name)
  database[variables_numeriques] <- lapply(database[variables_numeriques], as.numeric)
  
  # Renvoi de la base de données modifiée
  return(database)
}


# Fonction pour créer un graphique à barres version 1
creer_graphique_barres_v1 <- function(E1, variable_x, variable_y, x_label, y_label, titre) {
  # Vérifier si la variable_x est "ville"
  if (variable_x == "ville") {
    # Créer le graphique à barres avec la variable_x en abscisse et le nombre d'occurrences en ordonnée
    plot_ly(E1 %>% count(!!sym(variable_x)), x = ~get(variable_x), y = ~n, type = "bar") %>%
      layout(xaxis = list(title = x_label), yaxis = list(title = y_label), title = titre)
  } else {
    # Créer le graphique à barres avec la variable_x en abscisse, le nombre d'occurrences en ordonnée et la couleur en fonction de la variable_x
    plot_ly(E1 %>% count(!!sym(variable_x)), x = ~get(variable_x), y = ~n, type = "bar", color = ~as.factor(get(variable_x))) %>%
      layout(xaxis = list(title = x_label), yaxis = list(title = y_label), title = titre)
  }
}

# Fonction pour créer un graphique à barres version 2
creer_graphique_barres_v2 <- function(E1, variable_x, variable_y, x_label, y_label, titre) {
  # Créer le graphique à barres avec la variable_x en abscisse, la variable_y en ordonnée et la couleur en fonction de la variable_x
  plot_ly(E1, x = ~get(variable_x), y = ~get(variable_y), type = "bar", color = ~get(variable_x)) %>%
    layout(xaxis = list(title = x_label), yaxis = list(title = y_label), title = titre)
}



construire_series_chronologiques <- function(data) {
  
  # Agréger par mois
  accidents_par_mois <- data %>%
    mutate(Mois = floor_date(date, "month")) %>%
    group_by(Mois) %>%
    summarise(Nombre_accidents = n())
  
  # Agréger par semaine
  accidents_par_semaine <- data %>%
    mutate(Semaine = floor_date(date, "week", week_start = getOption("lubridate.week.start", 7))) %>%
    group_by(Semaine) %>%
    summarise(Nombre_accidents = n())
  
  # Régression linéaire pour les séries mensuelles
  regression_mois <- lm(Nombre_accidents ~ as.Date(Mois), data = accidents_par_mois)
  
  # Régression linéaire pour les séries hebdomadaires
  regression_semaine <- lm(Nombre_accidents ~ as.Date(Semaine), data = accidents_par_semaine)
  
  # Calcul des erreurs de prédiction
  erreur_mois <- sum(regression_mois$residuals^2)
  erreur_semaine <- sum(regression_semaine$residuals^2)
  
  # Détermination du niveau d'agrégation offrant la meilleure prédiction
  niveau_agregation <- ifelse(erreur_mois < erreur_semaine, "le meilleur niveau pour la prédiction est : mois", "le meilleur niveau pour la prédiction est :semaine")
  
  # Résultats
  resultats <- list(accidents_par_mois = accidents_par_mois,
                    accidents_par_semaine = accidents_par_semaine,
                    regression_mois = regression_mois,
                    regression_semaine = regression_semaine,
                    erreur_mois = erreur_mois,
                    erreur_semaine = erreur_semaine,
                    niveau_agregation = niveau_agregation)
  
  return(resultats)
}



# Créer une variable E1 en utilisant la fonction valeur_num_type pour la colonne "descr_cat_veh"
E1 <- valeur_num_type(database, "descr_cat_veh")

# Utiliser à nouveau la fonction valeur_num_type pour la colonne "descr_agglo" et mettre à jour la variable E1
E1 <- valeur_num_type(E1, "descr_agglo")

# Utiliser à nouveau la fonction valeur_num_type pour la colonne "descr_athmo" et mettre à jour la variable E1
E1 <- valeur_num_type(E1, "descr_athmo")

# Utiliser à nouveau la fonction valeur_num_type pour la colonne "descr_lum" et mettre à jour la variable E1
E1 <- valeur_num_type(E1, "descr_lum")

# Utiliser à nouveau la fonction valeur_num_type pour la colonne "descr_etat_surf" et mettre à jour la variable E1
E1 <- valeur_num_type(E1, "descr_etat_surf")

# Utiliser à nouveau la fonction valeur_num_type pour la colonne "description_intersection" et mettre à jour la variable E1
E1 <- valeur_num_type(E1, "description_intersection")

# Utiliser à nouveau la fonction valeur_num_type pour la colonne "descr_dispo_secu" et mettre à jour la variable E1
E1 <- valeur_num_type(E1, "descr_dispo_secu")

# Utiliser à nouveau la fonction valeur_num_type pour la colonne "descr_grav" et mettre à jour la variable E1
E1 <- valeur_num_type(E1, "descr_grav")

# Utiliser à nouveau la fonction valeur_num_type pour la colonne "descr_motif_traj" et mettre à jour la variable E1
E1 <- valeur_num_type(E1, "descr_motif_traj")

# Utiliser à nouveau la fonction valeur_num_type pour la colonne "descr_type_col" et mettre à jour la variable E1
E1 <- valeur_num_type(E1, "descr_type_col")


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
creer_graphique_barres_v1(database, "descr_grav", "n", "Description de la surface", "Nombre d'accidents", "Nombre d'accidents en fonction de la gravité")

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





