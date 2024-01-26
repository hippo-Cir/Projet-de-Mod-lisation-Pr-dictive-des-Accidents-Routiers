#-----------------------#
#---fichier fonctions---#
#-----------------------#

#Fonction permettant de nettoyer les données, enlever les lignes non-valides que ce soit avec des valeurs manquantes ou absurdes
Nettoyage_des_donnees <- function(database){

  
  #On remarque la présence de valeurs maximales absurdes concernant la longitude et la latitude
  #Exemple 1: Ligne 3683 -> longitude > 90
  #Exemple 2: Ligne 3684 -> latitude > 90
  
  #On remarque aussi que certains accidents possèdent un nombre de place NULL :
  #Exemple 3: Ligne 52127 -> place = NULL
  
  #Supression des lignes contenant des valeurs absurdes en suivant la condition suivante :
  Condition <- database$longitude < -5.2667 | database$longitude > 9.6625 | database$latitude < 41.3333 | database$latitude > 51.1242 | database$place == 'NULL'
  database <- subset(database, !Condition)
  #summary(database)
  
  #Convertir en valeurs numériques
  suppressWarnings({
    variables_numeriques <- c("age", "place", "an_nais", "code_INSEE", "id_usa")
    database <- database %>% mutate(across(all_of(variables_numeriques), as.numeric))
  })
  
  #Convertir les variables de date en format date
  variables_dates <- c("date")
  database <- database %>% mutate(across(all_of(variables_dates), as.Date))
  
  #Suppression des lignes en double
  duplicated_rows <- duplicated(database)
  data_unique <- database[!duplicated_rows, ]
  
  #Suppression des lignes ne contenant aucunes valeurs
  database <- na.omit(database)
  
  #Moodification de l'âge:
  database$age <- database$age - 14
  return(database)
  
}

#Fonction permettant la conversion de certaines colonnes
valeur_num_type <- function(database, col_name,fichier_type) {
  
  table_types <- table(database[[col_name]])
  print(table_types)
  
  
  types_uniques <- unique(database[[col_name]])
  chiffres_associes <- numeric(length(types_uniques))
  
  for (i in 1:length(types_uniques)) {
    chiffres_associes[i] <- i
  }
  
  correspondance <- data.frame(Type = types_uniques, Chiffre = chiffres_associes)
  
  #Ajout dans un fichier texte des types et de leurs chiffres associés
  correspondance_text <- paste(correspondance$Chiffre, correspondance$Type)
  
  #Création d'un fichier text contenant les types et leur chiffre  associé :
  write(correspondance_text, file = fichier_type, append = TRUE, sep = "\n")
  
  for (i in 1:length(database[[col_name]])) {
    database[[col_name]][i] <- chiffres_associes[match(database[[col_name]][i], types_uniques)]
  }
  variables_numeriques <- c(col_name)
  database[variables_numeriques] <- lapply(database[variables_numeriques], as.numeric)
  
  return(database)
}

#Fonction pour construire une base de donnée
construire_series_chronologiques <- function(data) {
  
  #Agréger par mois
  accidents_par_mois <- data %>%
    mutate(Mois = floor_date(date, "month")) %>%
    group_by(Mois) %>%
    summarise(Nombre_accidents = n())
  
  #Agréger par semaine
  accidents_par_semaine <- data %>%
    mutate(Semaine = floor_date(date, "week")) %>%
    group_by(Semaine) %>%
    summarise(Nombre_accidents = n())
  
  #Régression linéaire pour les séries mensuelles
  regression_mois <- lm(Nombre_accidents ~ as.Date(Mois), data = accidents_par_mois)
  
  #Régression linéaire pour les séries hebdomadaires
  regression_semaine <- lm(Nombre_accidents ~ as.Date(Semaine), data = accidents_par_semaine)
  
  #Calcul des erreurs de prédiction
  erreur_mois <- sum(regression_mois$residuals^2)
  erreur_semaine <- sum(regression_semaine$residuals^2)
  
  #Détermination du niveau d'agrégation offrant la meilleure prédiction
  niveau_agregation <- ifelse(erreur_mois < erreur_semaine, "le meilleur niveau pour la prédiction est : mois", "le meilleur niveau pour la prédiction est :semaine")
  
  #Résultats
  resultats <- list(accidents_par_mois = accidents_par_mois,
                    accidents_par_semaine = accidents_par_semaine,
                    regression_mois = regression_mois,
                    regression_semaine = regression_semaine,
                    erreur_mois = erreur_mois,
                    erreur_semaine = erreur_semaine,
                    niveau_agregation = niveau_agregation)
  
  return(resultats)
}

#Fonction pour ajouter les région à la base de données
ajout_region <- function(E1,tot_habitants,regions){
  
  #Stocker les colonnes du fichier csv "regions"  qui nous intéressent dans une nouvelle variable
  reg <- regions[,c("code_INSEE", "code_region")]
  
  #Identifier les lignes avec des valeurs en double dans la colonne clé (ici "code"_INSEE")
  duplicates <- duplicated(regions$code_INSEE)
  
  #Sélectionner uniquement les lignes uniques
  regions <- subset(regions, !duplicates)
  
  #Vérifier les duplications dans la colonne clé "id_code_insee"
  if (any(duplicated(regions$code_INSEE))) {
    stop("La colonne 'code_INSEE' dans le fichier 'regions' contient des valeurs en double.")
  }
  
  #Jointure de deux tableaux
  E1 <- merge(E1, reg, by ="code_INSEE", all.x = TRUE)
  
  #Stocker les colonnes du fichier csv "tot_habitants" qui nous intéressent dans une nouvelle variable
  pop <- tot_habitants[, c("code_region", "PTOT", "REG")]
  
  E1 <- merge(E1, pop, by="code_region", all.x = TRUE)
  
  return(E1)
}

#Fonction permettant la création d'un jeu de données
JDD_accidents_regions <- function(E1, tot_habitants, regions) {
  
  #Stocker les données de "E1" qui nous intéressent dans une nouvelle variable
  grav <- E1[,c("REG", "code_region", "PTOT", "descr_grav")]
  
  #Variable du jeu de données
  data_final <- grav %>%
      #Grouper les données de contenues dans "grav" en fonction de la région et du code région
      group_by(REG, code_region) %>%
    
      #Compter le nombre de d'accidents et obtention de la première valeur de la variable de la colonne "PTOT" (population totale)
      summarise(nombre_accidents = n(), PTOT = first(PTOT)) %>%
    
      #Ajout d'une nouvelles colonnes permettant de calculer le nombre d'accident selon la gravité par région pour 100k habitants
      mutate(accidents_par_100k = (nombre_accidents / PTOT) * 100000)
  
    return(data_final)
  }


#Fonction pour affichier une carte avec les accidents en France en 2009
map_accident <- function(E1){
  
  #Définir les labels personnalisés pour la légende
  labels_legende <- c("Tué", "Blessé hospitalisé", "Blessé léger","Indemne")
  
  #Convertir la variable descr_grav en facteur avec les labels personnalisés
  E1$descr_grav <- factor(E1$descr_grav, levels = c("2", "3", "4","1"), labels = labels_legende)
  
  palette <- c("Tué" = "black", "Blessé hospitalisé" = "red", "Blessé léger" = "orange","Indemne" = "blue" )
  E1$couleur <- palette[as.character(E1$descr_grav)]
  
  accidents_par_region <- E1 %>%
    group_by(descr_agglo) %>%
    summarise(Quantite_accidents = n())
  
  #Création de la carte
  Sys.setenv("MAPBOX_TOKEN"="pk.eyJ1IjoiZW1pZTE4IiwiYSI6ImNsaDdxdXB2dDAxZmYzZW1tM3hhbWR3b24ifQ.zjp20nsMooS-xVfxn982pA")
  
  fig <- plot_ly(E1, type = "scattermapbox", mode = "markers",
                 lat = ~latitude, lon = ~longitude,
                 color = ~descr_grav, colors = palette) %>%
    layout(mapbox = list(accesstoken = Sys.getenv('MAPBOX_TOKEN'),
                         center = list(lon = 4, lat = 46),
                         zoom = 4.5,
                         style = 'mapbox://styles/mapbox/light-v10'),
           title = list(text = "Accidents en France en 2009", x = 0.5))
  
  show(fig)
  
}

hist_accident <- function(E1){
  
  #Création des tranches d'âges
  tranches <- cut(E1$age, breaks = c(0, 18, 25, 35, 45, 55, 65, Inf), labels = c("0-18", "19-25", "26-35", "36-45", "46-55", "56-65", "66+"))
  
  #Comptage du nombre d'accidents par tranche d'âge
  accidents_par_tranche <- table(tranches)
  
  #Création de l'histogramme avec Plotly
  histogramme <- plot_ly(x = names(accidents_par_tranche), y = accidents_par_tranche, type = "bar",
                         marker = list(color = "blue")) %>%
    layout(title = "Quantité d'accidents en fonction des tranches d'âges",
           xaxis = list(title = "Tranche d'âge"),
           yaxis = list(title = "Nombre d'accidents"))
  
}


hist_accident <- function(E1){
  #Création des tranches d'âges
  tranches <- cut(E1$age, breaks = c(0, 18, 25, 35, 45, 55, 65, Inf), labels = c("0-18", "19-25", "26-35", "36-45", "46-55", "56-65", "66+"))
  
  #Comptage du nombre d'accidents par tranche d'âge
  accidents_par_tranche <- table(tranches)
  
  #Définir les couleurs pour chaque barre
  couleurs <- c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b", "#e377c2")
  
  #Création de l'histogramme avec Plotly
  histogramme <- plot_ly(x = names(accidents_par_tranche), y = accidents_par_tranche, type = "bar", marker = list(color = couleurs)) %>%
    layout(title = "Quantité d'accidents en fonction des tranches d'âges",
          xaxis = list(title = "Tranche d'âge"),
           yaxis = list(title = "Nombre d'accidents"),
          bargap = 0)
  
  #Affichage de l'histogramme
  print(histogramme)
}

hist_mensuel <- function(E1) {
  #Création d'une colonne "mois" à partir de la colonne de dates
  E1$mois <- format(E1$date, "%m")
  
  #Comptage du nombre d'accidents par mois
  accidents_par_mois <- table(E1$mois)
  
  #Création du vecteur pour les mois
  mois <- c("a.JANV", "b.FEV", "c.MARS", "d.APR", "e.MAI", "f.JUIN", "g.JUIL", "h.AOUT", "i.SEPT", "j.OCT", "k.NOV", "l.DEC")
  
  #Définition les couleurs pour chaque barre
  couleurs <- c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf", "#9edae5", "#f0b7b7")
  
  #Création de l'histogramme avec Plotly
  histogramme <- plot_ly(x = mois, y = accidents_par_mois, type = "bar",
                         marker = list(color = couleurs)) %>%
    layout(title = "Quantité d'accidents en fonction des mois",
           xaxis = list(title = "Mois"),
           yaxis = list(title = "Nombre d'accidents"),
           bargap = 0)
  
  #Affichage de l'histogramme
  print(histogramme)
}
