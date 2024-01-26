'use strict';

//------------------------------------------------------------------------------
//--- ajaxRequest --------------------------------------------------------------
//------------------------------------------------------------------------------
// Effectue une requête Ajax.
// \param type Le type de la requête (GET, DELETE, POST, PUT).
// \param url L'URL avec les données.
// \param callback Le rappel à appeler lorsque la requête réussit.
// \param data Les données associées à la requête.
function ajaxRequest(type, url, callback, data = null) {
  let xhr;

  // Crée une instance de la requête XML HTTP.
  xhr = new XMLHttpRequest();

  // Vérifie si la requête est de type GET et si des données sont fournies.
  // Si oui, les données sont ajoutées à l'URL sous la forme de paramètres de requête.
  if (type == 'GET' && data != null)
    url += '?' + data;

  // Initialise la requête.
  xhr.open(type, url);

  // Définit l'en-tête Content-Type de la requête.
  xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

  // Ajoute la fonction onload.
  // Cette fonction sera appelée lorsque la requête sera terminée.
  xhr.onload = () => {
    switch (xhr.status) {
      case 200:
      case 201:
        callback(JSON.parse(xhr.responseText));
        // Appelle le rappel avec les données de réponse parsées en tant qu'objet JSON.
        break;
      default:
        httpErrors(xhr.status);
        // En cas d'erreur, appelle la fonction httpErrors pour afficher un message d'erreur approprié.
    }
  };

  // Envoie la requête XML HTTP.
  xhr.send(data);
}

//------------------------------------------------------------------------------
//--- httpErrors ---------------------------------------------------------------
//------------------------------------------------------------------------------
// Affiche un message d'erreur en fonction d'un code d'erreur.
// \param errorCode Le code d'erreur (par exemple, un code de statut HTTP).
function httpErrors(errorCode) {
  let messages = {
    400: 'Requête incorrecte',
    401: 'Authentifiez-vous',
    403: 'Accès refusé',
    404: 'Page non trouvée',
    500: 'Erreur interne du serveur',
    503: 'Service indisponible'
  };

  // Affiche l'erreur.
  if (errorCode in messages) {
    $('#errors').html('<i class="fa fa-exclamation-circle"></i> <strong>' +
      messages[errorCode] + '</strong>');
    $('#errors').show();
  }
}
