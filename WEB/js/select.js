// Effectue une requête AJAX pour récupérer les données météo et les affiche dans un menu déroulant
ajaxRequest('GET', 'php/request.php/meteos', affiche_athmo);
function affiche_athmo(data){
  var sel = document.getElementById('descr_athmos');
  data.forEach(elem => {
    let opt = document.createElement('option');
    opt.value = elem.descr_athmo;
    opt.textContent += elem.descr_athmo;
    sel.appendChild(opt);
  });
}

// Effectue une requête AJAX pour récupérer les données de luminosité et les affiche dans un menu déroulant
ajaxRequest('GET', 'php/request.php/luminosites', affiche_lum);
function affiche_lum(data){
  var sel = document.getElementById('descr_lumi');
  data.forEach(elem => {
    let opt = document.createElement('option');
    opt.value = elem.descr_lum;
    opt.textContent += elem.descr_lum;
    sel.appendChild(opt);
  });
}

// Effectue une requête AJAX pour récupérer les données de disponibilité de sécurité et les affiche dans un menu déroulant
ajaxRequest('GET', 'php/request.php/ceintures', affiche_dispo_secu);
function affiche_dispo_secu(data){
  var sel = document.getElementById('descr_dispo_secur');
  data.forEach(elem => {
    let opt = document.createElement('option');
    opt.value = elem.descr_dispo_secu;
    opt.textContent += elem.descr_dispo_secu;
    sel.appendChild(opt);
  });
}

// Effectue une requête AJAX pour récupérer les données d'état de surface des routes et les affiche dans un menu déroulant
ajaxRequest('GET', 'php/request.php/routes', affiche_etat_surf);
function affiche_etat_surf(data){
  var sel = document.getElementById('descr_etat_surfa');
  data.forEach(elem => {
    let opt = document.createElement('option');
    opt.value = elem.descr_etat_surf;
    opt.textContent += elem.descr_etat_surf;
    sel.appendChild(opt);
  });
}

// Effectue une requête AJAX pour récupérer les données de catégorie de véhicules et les affiche dans un menu déroulant
ajaxRequest('GET', 'php/request.php/vehicules', affiche_cat_veh);
function affiche_cat_veh(data){
  var sel = document.getElementById('descr_cat_vehi');
  data.forEach(elem => {
    let opt = document.createElement('option');
    opt.value = elem.descr_cat_veh;
    opt.textContent += elem.descr_cat_veh;
    sel.appendChild(opt);
  });
}

// Effectue une requête AJAX pour récupérer les données d'agglomérations et les affiche dans un menu déroulant
ajaxRequest('GET', 'php/request.php/agglos', affiche_agglo);
function affiche_agglo(data){
  var sel = document.getElementById('descr_agglos');
  data.forEach(elem => {
    let opt = document.createElement('option');
    opt.value = elem.descr_agglo;
    opt.textContent += elem.descr_agglo;
    sel.appendChild(opt);
  });
}

// Effectue une requête AJAX pour récupérer les données de types de collisions et les affiche dans un menu déroulant
ajaxRequest('GET', 'php/request.php/collisions', affiche_type_col);
function affiche_type_col(data){
  var sel = document.getElementById('descr_type_coli');
  data.forEach(elem => {
    let opt = document.createElement('option');
    opt.value = elem.descr_type_col;
    opt.textContent += elem.descr_type_col;
    sel.appendChild(opt);
  });
}

// Effectue une requête AJAX pour récupérer les données de villes et les affiche dans un menu déroulant
ajaxRequest('GET', 'php/request.php/ville', affiche_ville);
function affiche_ville(data){
  var sel = document.getElementById('ville');
  data.forEach(elem => {
    let opt = document.createElement('option');
    opt.value = elem.id_code_insee;
    opt.textContent += elem.ville;
    sel.appendChild(opt);
  });
}
