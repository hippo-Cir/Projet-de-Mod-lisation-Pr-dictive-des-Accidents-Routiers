#-----------------------#
#---fichier Fonctions---#
#-----------------------#

#fonction pour comparer la regression de 
comparer_regessions <- function(resultats) {
  
  #récupéré la reponse quel est le meilleur pour prédire:
  niveau_agregation <- resultats$niveau_agregation
  # Extraire les résultats des régressions
  regression_mois <- resultats$regression_mois
  regression_semaine <- resultats$regression_semaine
  
  # Analyser les performances de la régression
  performance_mois <- summary(regression_mois)$r.squared
  performance_semaine <- summary(regression_semaine)$r.squared
  
  
  # Calculer les intervalles de confiance à 95% pour ces estimateurs
  intervalle_confiance_mois <- confint(regression_mois)
  intervalle_confiance_semaine <- confint(regression_semaine)
  
  # Calculer les R2 et R2 ajusté pour les deux modèles
  r2_mois <- summary(regression_mois)$r.squared
  r2_ajuste_mois <- summary(regression_mois)$adj.r.squared
  r2_semaine <- summary(regression_semaine)$r.squared
  r2_ajuste_semaine <- summary(regression_semaine)$adj.r.squared
  
  # Afficher les résultats
  cat("Performances de la régression (R2) :\n")
  cat("Régression mois :", r2_mois, "\n")
  cat("Régression semaine :", r2_semaine, "\n\n")
  
  cat("Performances de la régression ajustée (R2 ajusté) :\n")
  cat("Régression mois :", r2_ajuste_mois, "\n")
  cat("Régression semaine :", r2_ajuste_semaine, "\n\n")
  
  cat("Erreurs types associées aux estimateurs :\n")
  cat("Régression mois :", erreur_type_mois, "\n")
  cat("Régression semaine :", erreur_type_semaine, "\n\n")
  
  cat("Intervalles de confiance à 95% pour les estimateurs :\n")
  cat("Régression mois :\n")
  print(intervalle_confiance_mois)
  cat("\nRégression semaine :\n")
  print(intervalle_confiance_semaine)
  cat("Le meilleur :",niveau_agregation,"\n")
  
}

carte_r <- function(E2,data,code,titre) {
  
  # Créer une palette de couleurs en fonction du nombre d'accidents
  palette <- colorRampPalette(c("#AED9E0","#7BC4E2","#1F8FC2",
                                "#175C85",
                                "#A0DED6",
                                "#3BB4B0",
                                "#00A79D",
                                "#008C69",
                                "#FFF6A5",
                                "#FFD542",
                                "#FFA642",
                                "#FF7F00",
                                "#FF6B6B",
                                "#FF4040",
                                "#B83232"))(length(unique(data$Taux_accidents)))
  
  region_colors <- setNames(palette, unique(data$Taux_accidents))

  data$couleur <- region_colors[as.character(data$REG)]
  
  E2 <- left_join(E2, data, by = code)
  
  # Création de la carte
  Sys.setenv("MAPBOX_TOKEN" = "pk.eyJ1IjoiZW1pZTE4IiwiYSI6ImNsaTFjYjh6ODAzcjIzcnBkY3MwMGR6ODIifQ.NRJJK2MO77bUnhmVznl46A")
  
  fig <- plot_ly(E2, type = "scattermapbox", mode = "markers",
                 lat = ~latitude, lon = ~longitude,
                 color = ~Taux_accidents, colors = palette,
                 text = ~paste("Région : ", nom_region, "<br>Taux d'accidents:", Taux_accidents)) %>%
    layout(mapbox = list(
      accesstoken = Sys.getenv('MAPBOX_TOKEN'),
      center = list(lon = 2.554071, lat = 46.603354),
      zoom = 4,
      style = 'mapbox://styles/mapbox/light-v10'),
      title = list(text = titre, x = 0.5))
  
  show(fig)
}

carte_d <- function(E2,data,code,titre) {
  
  # Créer une palette de couleurs en fonction du nombre d'accidents
  palette <- colorRampPalette(c("#AED9E0","#7BC4E2","#1F8FC2",
                                "#175C85",
                                "#A0DED6",
                                "#3BB4B0",
                                "#00A79D",
                                "#008C69",
                                "#FFF6A5",
                                "#FFD542",
                                "#FFA642",
                                "#FF7F00",
                                "#FF6B6B",
                                "#FF4040",
                                "#B83232"))(length(unique(data$Taux_accidents)))
  
  region_colors <- setNames(palette, unique(data$Taux_accidents))
  
  data$couleur <- region_colors[as.character(data$REG)]
  
  E2 <- left_join(E2, data, by = code)
  
  # Création de la carte
  Sys.setenv("MAPBOX_TOKEN" = "pk.eyJ1IjoiZW1pZTE4IiwiYSI6ImNsaTFjYjh6ODAzcjIzcnBkY3MwMGR6ODIifQ.NRJJK2MO77bUnhmVznl46A")
  
  fig <- plot_ly(E2, type = "scattermapbox", mode = "markers",
                 lat = ~latitude, lon = ~longitude,
                 color = ~Taux_accidents, colors = palette,
                 text = ~paste("Département :",nom_departement, "<br>Taux d'accidents:", Taux_accidents)) %>%
    layout(mapbox = list(
      accesstoken = Sys.getenv('MAPBOX_TOKEN'),
      center = list(lon = 2.554071, lat = 46.603354),
      zoom = 4,
      style = 'mapbox://styles/mapbox/light-v10'),
      title = list(text = titre, x = 0.5))
  
  show(fig)
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

