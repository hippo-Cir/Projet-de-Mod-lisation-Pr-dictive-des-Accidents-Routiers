// Fonction pour récupérer les paramètres de requête de l'URL
function getQueryVariable(variable) {
    var query = window.location.search.substring(1);
    var vars = query.split("&");
    for (var i = 0; i < vars.length; i++) {
      var pair = vars[i].split("=");
      if (decodeURIComponent(pair[0]) === variable) {
        return decodeURIComponent(pair[1]);
      }
    }
    return null;
  }
  
  // Récupérer les variables depuis l'URL
  var id_accident = getQueryVariable("id_accident");
  var resultat = getQueryVariable("resultat");
  
  // Sélectionner l'élément HTML où vous souhaitez afficher les résultats
  var resultatElement = document.getElementById("resultat");
  
  // Mettre à jour le contenu de l'élément avec les résultats
  var resultatObjet = JSON.parse(resultat);
  var methodes = Object.keys(resultatObjet);
  
  // Créer une chaîne contenant les résultats avec le format souhaité
  var resultatHtml = "";
  for (var i = 0; i < methodes.length; i++) {
    var methode = methodes[i];
    var descr_grav = resultatObjet[methode].descr_grav;
    resultatHtml += "<p>" + methode + ": <span>" + descr_grav + "</span></p>";
  }
  
  // Mettre à jour le contenu de l'élément avec la chaîne contenant les résultats
  resultatElement.innerHTML = resultatHtml;