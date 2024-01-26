// Sélectionner l'option correspondante en fonction de la valeur du cookie

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
  ajaxRequest('GET', 'php/request.php/prediction', ajoute_lignes_tableau_petit)
  }else{
  ajaxRequest('GET', 'php/request.php/liste', ajoute_lignes_tableau_grand)
  }
});

// Récupérer le formulaire et ajouter un gestionnaire d'événement pour la soumission
var filterForm = document.getElementById('filtreForm');
filterForm.addEventListener('submit', function (event) {
  event.preventDefault(); // Empêcher la soumission du formulaire par défaut
  var existingButton = document.getElementById("predictionButton");
  if (existingButton) {
    // Supprimer le bouton existant s'il est présent
    existingButton.parentNode.removeChild(existingButton);
  }
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
  if(choix == "1"){
    ajaxRequest('POST', 'php/request.php/filtre', ajoute_lignes_tableau_petit , data);
  }else{
    ajaxRequest('POST', 'php/request.php/filtre', ajoute_lignes_tableau_grand , data);
  }
  
});

function ajoute_lignes_tableau_petit(data){
  var tableau = document.querySelector('#affiche table');
  tableau.innerHTML = `<th>Ville</th>
  <th>Age du conducteur</th>
  <th>Date</th>
  <th>Météo</th>
  <th>Longitude</th>
  <th>Latitude</th>
  <th>Luminosité</th>
  <th>Dispositif de sécurité</th>
  <th>État de la toute</th>
  <th>Prédire le cluster</th>
  <th>Prédire la gravité</th>`;

  if(data == ""){
    tableau.innerHTML = `Il n'y a pas d'accidents`;
  }
  data.forEach(elem => {
   var ligne = document.createElement('tr');

  ligne.innerHTML = `
    <td>${elem.ville}</td>
    <td>${elem.age} ans</td>
    <td>${elem.date_heure}</td>
    <td>${elem.descr_athmo}</td>
    <td>${elem.longitude}</td>
    <td>${elem.latitude}</td>
    <td>${elem.descr_lum}</td>
    <td>${elem.descr_dispo_secu}</td>
    <td>${elem.descr_etat_surf}</td>
    <td>
      <button type="button" onClick=trouver_cluster(${elem.longitude},${elem.latitude},${elem.id_accident})>Trouver</button>
    </td>
    <td>
      <input type="radio" name="accident_radio" value="${elem.id_accident},${elem.ia_cat},${elem.ia_agglo},${elem.ia_lum},${elem.ia_athmo},${elem.ia_route},${elem.ia_col},${elem.ia_secu},${elem.longitude},${elem.latitude}">
    </td>
    `;

   tableau.appendChild(ligne);
});

// Vérifier si le bouton existe déjà
var existingButton = document.getElementById("predictionButton");
if (existingButton) {
  // Supprimer le bouton existant s'il est présent
  existingButton.parentNode.removeChild(existingButton);
}

// Créer un nouveau bouton
var bouton = document.createElement('button');
bouton.innerText = "Prédire la gravité";
bouton.id = "predictionButton";

// Ajouter un écouteur d'événement au bouton
bouton.addEventListener('click', function() {
  var selectedRadio = document.querySelector('input[name="accident_radio"]:checked');
  if (selectedRadio) {
    var accidentData = selectedRadio.value.split(',');
    prédire_la_gravité(accidentData);
  } else {
    alert("Veuillez sélectionner un accident.");
  }
});

// Ajouter le bouton à l'élément parent du tableau
tableau.parentElement.appendChild(bouton);

// var bouton = document.createElement('button');
//   bouton.innerText = "Prédire la gravité";
//   bouton.addEventListener('click', function() {
//     var selectedRadio = document.querySelector('input[name="accident_radio"]:checked');
//     if (selectedRadio) {
//       var accidentData = selectedRadio.value.split(',');
//       prédire_la_gravité(accidentData);
//     } else {
//       alert("Veuillez sélectionner un accident.");
//     }
//   });
//   tableau.parentElement.appendChild(bouton);
}

function ajoute_lignes_tableau_grand(data){
  var tableau = document.querySelector('#affiche table');
  tableau.innerHTML = `
  <th>Ville</th>
  <th>Age du conducteur</th>
  <th>Date</th>
  <th>Météo</th>
  <th>Longitude</th>
  <th>Latitude</th>
  <th>Luminosité</th>
  <th>Dispositif de sécurité</th>
  <th>État de la toute</th>
  <th>Gravité</th>
  `;

  if(data == ""){
    tableau.innerHTML = `Il n'y a pas d'accidents`;
  }

  data.forEach(elem => {
  var ligne = document.createElement('tr');

  ligne.innerHTML = `
      <td>${elem.ville}</td>
      <td>${elem.age} ans</td>
      <td>${elem.date_heure}</td>
      <td>${elem.descr_athmo}</td>
      <td>${elem.longitude}</td>
      <td>${elem.latitude}</td>
      <td>${elem.descr_lum}</td>
      <td>${elem.descr_dispo_secu}</td>
      <td>${elem.descr_etat_surf}</td>
      <td>${elem.descr_grav}</td>
    `;

  tableau.appendChild(ligne);
});
}
function trouver_cluster(longitude, latitude,id_accident) {

  fetch('/cgi/scriptkmean.py?longitude=' + longitude + '&latitude=' + latitude)
    .then(response => response.text())
    .then(result => {
      //document.getElementById('resultat').innerText = "Le numéro du cluster est :"+result ;
      // Construire l'URL de redirection avec les paramètres de requête
      var url = "IAcluster.html?id_accident=" + encodeURIComponent(id_accident) + "&resultat=" + encodeURIComponent(result);

      // Changer de page
      window.location.href = url;
    });

}

function prédire_la_gravité(accidentData) {
  var longitude = accidentData[8];
  var latitude = accidentData[9];
  var descr_cat_veh = accidentData[1];
  var descr_agglo = accidentData[2];
  var descr_lum = accidentData[3];
  var descr_athmo = accidentData[4];
  var descr_etat_surf = accidentData[5];
  var descr_type_col = accidentData[6];
  var descr_dispo_secu = accidentData[7];

  fetch('/cgi/prediction.py?descr_cat_veh=' + descr_cat_veh + '&descr_agglo=' + descr_agglo+'&descr_lum='+descr_lum+'&descr_athmo='+descr_athmo+'&descr_etat_surf='+descr_etat_surf+'&descr_type_col='+descr_type_col+'&latitude='+latitude+'&longitude='+longitude+'&descr_dispo_secu='+descr_dispo_secu)
    .then(response => response.text())
    .then(result => {
      var id_accident = accidentData[0];
      var url = "IAgravite.html?id_accident=" + encodeURIComponent(id_accident) + "&resultat=" + encodeURIComponent(result);
      window.open(url, "_blank");
    });
}
