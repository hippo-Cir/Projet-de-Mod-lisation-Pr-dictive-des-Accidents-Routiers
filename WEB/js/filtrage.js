
var selectElement = document.getElementById('choix');
var graviteSelect = document.getElementById('descr_grav');
var limitSelect = document.getElementById('limit');
var moisSelect = document.getElementById('mois');
var ageSelect = document.getElementById('age');
var graviteSelect = document.getElementById('descr_grav');

var cookieValue = document.cookie.replace(/(?:(?:^|.*;\s*)choix\s*\=\s*([^;]*).*$)|^.*$/, "$1");
var limitValue = document.cookie.replace(/(?:(?:^|.*;\s*)limit\s*\=\s*([^;]*).*$)|^.*$/, "$1");
var moisValue = document.cookie.replace(/(?:(?:^|.*;\s*)mois\s*\=\s*([^;]*).*$)|^.*$/, "$1");
var ageValue = document.cookie.replace(/(?:(?:^|.*;\s*)age\s*\=\s*([^;]*).*$)|^.*$/, "$1");
var graviteValue = document.cookie.replace(/(?:(?:^|.*;\s*)gravite\s*\=\s*([^;]*).*$)|^.*$/, "$1");

if (limitValue && limitSelect) {
  limitSelect.value = limitValue;
}
if(moisValue && moisSelect){
  moisSelect.value = moisValue
}
if(ageValue && ageSelect){
  ageSelect.value = ageValue
}
if(graviteValue && graviteSelect){
  graviteSelect.value = graviteValue
}

// Vérifier la valeur du cookie et mettre à jour l'état grisé/dégrisé du select "gravite"
if (cookieValue === "1") {
  graviteSelect.value = "";
  graviteSelect.disabled = true; // Griser le select
} else {
  graviteSelect.disabled = false; // Dégriser le select
}

// Gérer l'état grisé/dégrisé du select "gravite" en fonction de la valeur de "selectElement"
selectElement.addEventListener('change', function () {
  if (selectElement.value === "1") {
    graviteSelect.value = "";
    graviteSelect.disabled = true; // Griser le select
  } else {
    graviteSelect.disabled = false; // Dégriser le select
  }
});

if (cookieValue === "1") {
  selectElement.value = "1";
} else {
  selectElement.value = "0";
}

window.addEventListener('load', function () {
  if(cookieValue =="1"){
  ajaxRequest('GET', 'php/request.php/prediction', updateMap)
  }else{
  ajaxRequest('GET', 'php/request.php/liste', updateMap)
  }
});
// window.addEventListener('load', function () {
//   if(cookieValue =="1"){
//   ajaxRequest('GET', 'php/request.php/prediction', updateMap)
//   }else{
//   ajaxRequest('GET', 'php/request.php/liste', updateMap)
//   }
// });

// Récupérer le formulaire et ajouter un gestionnaire d'événement pour la soumission
var filterForm = document.getElementById('filtreForm');
filterForm.addEventListener('submit', function (event) {
  event.preventDefault(); // Empêcher la soumission du formulaire par défaut

  // Récupérer les valeurs des filtres
  var mois = document.querySelector('#mois').value;
  var descr_grav = document.querySelector('#descr_grav').value;
  var age = document.getElementById('age').value;

  var choix = document.getElementById('choix').value;
  var limit = document.getElementById('limit').value;

  // Définir la date d'expiration du cookie (1 heure)
  var expiration = new Date();
  expiration.setTime(expiration.getTime() + (60 * 60 * 1000));

  // Enregistrer les valeurs dans les cookies "choix" et "limit"
  document.cookie = "choix=" + choix + "; expires=" + expiration.toUTCString();
  document.cookie = "limit=" + limit + "; expires=" + expiration.toUTCString();
  document.cookie = "mois=" + mois + "; expires=" + expiration.toUTCString();
  document.cookie = "age=" + age + "; expires=" + expiration.toUTCString();
  document.cookie = "gravite=" + descr_grav + "; expires=" + expiration.toUTCString();

  // Construire les données à envoyer au serveur
  var data = "mois=" + mois + "&descr_grav=" + descr_grav + "&age=" + age + "&choix=" + choix+ "&limit=" + limit;

  // Envoyer la requête AJAX
  ajaxRequest('POST', 'php/request.php/filtre', function (response) {
    // Mettre à jour la carte avec les nouveaux marqueurs
    if (response == "") {
      const info = document.getElementById('info');
      info.innerHTML = `<strong>Il n'y a pas d'accident !</strong>`;
    }
    updateMap(response);

  }, data);
});


// Fonction pour mettre à jour la carte avec les marqueurs filtrés
function updateMap(data) {
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
       <br><strong>latitude </strong> ${item.latitude} <strong> longitude :</strong> ${item.longitude}
       <br><strong>conditions atmosphériques:</strong> ${item.descr_athmo}
       <br><strong>luminosité:</strong> ${item.descr_lum}
       <br><strong>Etat de la surface:</strong> ${item.descr_etat_surf}
       <br><strong>disposition sécurité:</strong> ${item.descr_dispo_secu}`;
    });
  });
}
