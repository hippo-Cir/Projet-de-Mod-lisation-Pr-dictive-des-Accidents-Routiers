'use strict';
var dateControl = document.querySelector('input[type="datetime-local"]');

// Obtenir la date d'aujourd'hui
var today = new Date();

// Formater la date au format requis (YYYY-MM-DD)
var year = today.getFullYear();
var month = String(today.getMonth() + 1).padStart(2, '0');
var day = String(today.getDate()).padStart(2, '0');
var formattedDate = `${year}-${month}-${day}`;

// Définir la valeur de dateControl.max avec la date d'aujourd'hui à 08:30
dateControl.max = formattedDate + 'T08:30';

$(document).ready(function(){
    $("#submit_button").on("submit", function(event){
      event.preventDefault();
      var formData = $(this).serialize();
      $.ajax({
        url: "../php/ajout.php",
        type: "POST",
        cache: false,
        data: formData,
        success: function(response){
          data = JSON.parse(response);
          if(data.error == "0") {
            $("#submit_button").trigger("reset");
            //console.log(data.message);
          } else if(data.error == "1") {
            //console.log(data.message);
          }
        }
      });
    });
});

// Fonction qui échappe les guillemets simples pour éviter les erreurs dans les requêtes SQL
function escapeQuotes(str) {
    return str.replace(/'/g, "\\'");
}

var addForm = document.getElementById('addForm');
addForm.addEventListener('submit', function(event) {
    event.preventDefault();

    // Récupération des valeurs du formulaire
    var date_heure = document.getElementById("date_heure").value;
    var age = document.getElementById("age").value;
    var descr_athmo = document.getElementById("descr_athmos").value;
    var id_code_insee = document.getElementById('ville').value;
    var descr_lum = document.getElementById('descr_lumi').value;
    var descr_dispo_secu = document.getElementById('descr_dispo_secur').value;
    var descr_etat_surf = document.getElementById('descr_etat_surfa').value;
    var descr_cat_veh = document.getElementById('descr_cat_vehi').value;
    var descr_agglo = document.getElementById('descr_agglos').value;
    var descr_type_col = document.getElementById('descr_type_coli').value;

    // Modification si besoin des valeurs en ajoutant un \ devant les '
    // pour éviter les erreurs de requête SQL
    descr_athmo = escapeQuotes(descr_athmo);
    id_code_insee = escapeQuotes(id_code_insee);
    descr_lum = escapeQuotes(descr_lum);
    descr_dispo_secu = escapeQuotes(descr_dispo_secu);
    descr_etat_surf = escapeQuotes(descr_etat_surf);
    descr_cat_veh = escapeQuotes(descr_cat_veh);
    descr_agglo = escapeQuotes(descr_agglo);
    descr_type_col = escapeQuotes(descr_type_col);

    // Construire les données à envoyer au serveur
    var data = "date_heure=" + date_heure + "&age=" + 
    age + "&descr_athmo=" + descr_athmo + "&id_code_insee=" + id_code_insee + "&descr_lum=" + descr_lum + 
    "&descr_dispo_secu=" + descr_dispo_secu + "&descr_etat_surf=" + descr_etat_surf + "&descr_cat_veh=" + descr_cat_veh +
    "&descr_agglo=" + descr_agglo + "&descr_type_col=" + descr_type_col;

    // Envoyer la requête AJAX
    ajaxRequest('POST', 'php/ajout.php/form', function(response) {
        if(response == "L'accident a été ajouté"){
            addForm.innerHTML = `<p>${response}</p> <br> <a class="retour" href="tableau.html">Retourner au tableau</a>`;
        } else {
            addForm.innerHTML = `<p>${response}</p>`;
        }
        //console.log(response);
    }, data);
});
