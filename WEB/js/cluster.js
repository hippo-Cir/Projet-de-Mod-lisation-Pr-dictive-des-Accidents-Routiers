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

var div_resultat = document.getElementById('resultat');
div_resultat.innerHTML = "Résultat: " + `<span>` + resultat + `</span>`;

var data = "id_accident=" + id_accident;
var save = "";

// Envoyer la requête AJAX pour récupérer les informations de l'accident
ajaxRequest('POST', 'php/request.php/un_accident', function (response) {
  save = response;
}, data);

ajaxRequest('GET', 'php/request.php/cluster', function (data) {
  // Créer la carte
  mapboxgl.accessToken = 'pk.eyJ1IjoiZW1pZTE4IiwiYSI6ImNsaDdxdXB2dDAxZmYzZW1tM3hhbWR3b24ifQ.zjp20nsMooS-xVfxn982pA'; // Remplacez YOUR_ACCESS_TOKEN par votre propre jeton d'accès Mapbox
  var map = new mapboxgl.Map({
    container: 'map',
    style: 'mapbox://styles/mapbox/streets-v11', // Style de la carte (vous pouvez choisir un autre style)
    center: [2.554071, 46.603354], // Centre initial de la carte
    zoom: 4 // Niveau de zoom initial de la carte
  });

  // Parcourir les données et ajouter des marqueurs à la carte
  data.forEach(function (item) {
    // Créer un élément HTML personnalisé pour le marqueur
    var el = document.createElement('div');
    if (parseInt(item.ia_cluster) === parseInt(resultat)) {
      el.className = 'marker_res';
    } else {
      el.className = 'marker_cluster';
    }

    // Ajouter le marqueur à la carte
    var marker = new mapboxgl.Marker(el)
      .setLngLat([item.longitude, item.latitude])
      .addTo(map);
    el.innerHTML = `<p class="cluster">${item.ia_cluster}</p>`;
  });

  // Créer un marqueur pour l'accident spécifique
  var el = document.createElement('div');
  el.className = 'marker';
  var marker2 = new mapboxgl.Marker(el)
    .setLngLat([save[0].longitude, save[0].latitude])
    .addTo(map);
  marker2.getElement().addEventListener('mouseover', function () {
    const info = document.getElementById('info');

    info.innerHTML = `<strong>Ville:</strong> ${save[0].ville}
      <br><strong>Date:</strong> ${save[0].date_heure}
      <br><strong>Âge Conducteur:</strong> ${save[0].age}
      <br><strong>latitude:</strong> ${save[0].latitude} <strong> longitude:</strong> ${save[0].longitude}
      <br><strong>Conditions atmosphériques:</strong> ${save[0].descr_athmo}
      <br><strong>Luminosité:</strong> ${save[0].descr_lum}
      <br><strong>Etat de la surface:</strong> ${save[0].descr_etat_surf}
      <br><strong>Disposition sécurité:</strong> ${save[0].descr_dispo_secu}`;
  });
});

// Fonction pour mettre à jour la carte avec les marqueurs filtrés
function updateMap(data) {
  data.forEach(function (item) {
    // Créer un élément HTML personnalisé pour le marqueur
    var el = document.createElement('div');
    el.className = 'marker';

    // Ajouter le marqueur à la carte
    var marker = new mapboxgl.Marker(el)
      .setLngLat([item.longitude, item.latitude])
      .addTo(map);

    // Ajouter un événement de survol pour afficher les informations
    marker.getElement().addEventListener('mouseover', function () {
      const info = document.getElementById('info');

      info.innerHTML = `<strong>Ville:</strong> ${item.ville}
        <br><strong>Date:</strong> ${item.date_heure}
        <br><strong>Âge Conducteur:</strong> ${item.age}
        <br><strong>Latitude:</strong> ${item.latitude} <strong> Longitude:</strong> ${item.longitude}
        <br><strong>Conditions atmosphériques:</strong> ${item.descr_athmo}
        <br><strong>Luminosité:</strong> ${item.descr_lum}
        <br><strong>Etat de la surface:</strong> ${item.descr_etat_surf}
        <br><strong>Disposition sécurité:</strong> ${item.descr_dispo_secu}`;
    });
  });
}
setTimeout(function() {
  if (document.getElementsByClassName('marker').length === 0) {
    location.reload();
  }
}, 2000);
