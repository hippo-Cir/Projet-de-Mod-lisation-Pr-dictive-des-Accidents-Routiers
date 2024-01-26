<?php
//Author: Emilie Le Rouzic
//Login : etu115
//Groupe: ISEN BREST GROUPE 1
//Annee:2023

require_once('database.php');

// Connexion à la base de donnée
$db = dbConnect();
if (!$db) {
  header('HTTP/1.1 503 Service Unavailable');
  exit;
}

// Check the request.
$requestMethod = $_SERVER['REQUEST_METHOD'];
//les get ?url
$request = substr($_SERVER['PATH_INFO'], 1);
$request = explode('/', $request);
$requestRessource = array_shift($request);

/***********************************************************/
/*requête qui renvoit la liste des accidents de 2009       */
/*_________________________________________________________*/

if ($requestMethod == 'GET' && $requestRessource == 'liste') {
  if (isset($_COOKIE['limit'])) {
    // Le cookie "limit" existe
    $limit = $_COOKIE['limit'];
  } else {
    $limit = "1000";
  }
  try {
  $request = 'SELECT *,DATE_FORMAT(date_heure,"%d\/%m\/%Y à %Hh%i") AS date_heure FROM grande_table_accidents WHERE 1=1 ';

  if (isset($_COOKIE['age']) && $_COOKIE['age'] != '') {
    if ($_COOKIE['age'] === '0-20') {
      $request .= " AND age >= 0 AND age <= 20";
    } elseif ($_COOKIE['age'] === '20-40') {
      $request .= " AND age > 20 AND age <= 40";
    } elseif ($_COOKIE['age'] === '40-60') {
      $request .= " AND age > 40 AND age <= 60";
    } elseif ($_COOKIE['age'] === '60-80') {
      $request .= " AND age > 60 AND age <= 80";
    } elseif ($_COOKIE['age'] === '80-90') {
      $request .= " AND age > 80 AND age <= 90";
    }
  }
  if (isset($_COOKIE['mois']) && $_COOKIE['mois'] != '') {
    $request .= " AND MONTH(`date_heure`) = '" . $_COOKIE['mois'] . "'";
  }
  if (isset($_COOKIE['gravite']) && $_COOKIE['gravite'] != '') {
    $request .= " AND descr_grav = '" . $_COOKIE['gravite'] . "'";
  }
  $request .= " ORDER BY RAND() LIMIT " . $limit;
    $statement = $db->prepare($request);
    $statement->execute();
    $result = $statement->fetchAll(PDO::FETCH_ASSOC);
    $data = $result;
  } catch (PDOException $e) {
    $data = array('error' => $e->getMessage());
  }
}

/***********************************************************/
/*requête qui renvoit la liste des nouveaux accidents      */
/*_________________________________________________________*/

if ($requestMethod == 'GET' && $requestRessource == 'liste2') {
  if (isset($_COOKIE['limit'])) {
    // Le cookie "limit" existe
    $limit = $_COOKIE['limit'];
  } else {
    $limit = "1000";
  }
  try{
    $request = 'SELECT *, ville.ville as ville,ville.longitude as longitude, ville.latitude as latitude, DATE_FORMAT(accidents.date_heure, "%d\/%m\/%Y à %Hh%i") AS date_heure FROM accidents JOIN ville ON accidents.id_code_insee = ville.id_code_insee LIMIT ' . $limit;

    $statement = $db->prepare($request);
    $statement->execute();
    $result = $statement->fetchAll(PDO::FETCH_ASSOC);
    $data = $result;
  } catch (PDOException $e) {
    $data = array('error' => $e->getMessage());
  }
}

/***********************************************************/
/*requête qui renvoit la liste des clusters précalculés    */
/*_________________________________________________________*/

if ($requestMethod == 'GET' && $requestRessource == 'cluster') {
  try{
    $request = 'SELECT * FROM culster';

    $statement = $db->prepare($request);
    $statement->execute();
    $result = $statement->fetchAll(PDO::FETCH_ASSOC);
    $data = $result;
  } catch (PDOException $e) {
    $data = array('error' => $e->getMessage());
  }
}

/***********************************************************/
/*requête qui renvoit 1 accident avec en entrée son id     */
/*_________________________________________________________*/

if ($requestMethod == 'POST' && $requestRessource == 'un_accident') {
  try {
    $id_accident = $_POST['id_accident'];

    // Utilisation de requête préparée avec un paramètre
    $request = 'SELECT *, ville.ville as ville, ville.longitude as longitude, ville.latitude as latitude FROM accidents JOIN ville ON accidents.id_code_insee = ville.id_code_insee WHERE id_accident = :id';
    $statement = $db->prepare($request);
    $statement->bindParam(':id', $id_accident, PDO::PARAM_INT);
    $statement->execute();
    $result = $statement->fetchAll(PDO::FETCH_ASSOC);
    $data = $result;
  } catch (PDOException $e) {
    // Capture de l'erreur et la mettre dans le tableau $data
    $data = array('error' => $e->getMessage());
  }
}

/******************************************************************/
/*requête qui renvoit la liste des des accidents avec un filtre   */
/*________________________________________________________________*/

if ($requestMethod == 'POST' && $requestRessource == 'filtre') {

  //Récupérer les informations du filtre
  $mois = $_POST['mois'];
  $descr_grav = $_POST['descr_grav'];
  $age = $_POST['age'];
  $choix = $_POST['choix'];
  $limit = $_POST['limit'];

  // Définir la durée de validité du cookie (1 heure)
  $expiration = time() + 3600;

  // Enregistrer la valeur dans les cookies
  setcookie('limit', $limit, $expiration);
  setcookie('age', $age, $expiration);
  setcookie('gravite', $descr_grav, $expiration);
  setcookie('mois', $mois, $expiration);

  $request = "";
  try {
    $db->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    if ($choix == "0") {
      $request = 'SELECT *,DATE_FORMAT(date_heure,"%d\/%m\/%Y %Hh%i") AS date_heure FROM grande_table_accidents WHERE 1=1';
    } else {
      $request = "SELECT *, c.ia_cat,  c.ia_cat,  agg.ia_agglo,  l.ia_lum,  m.ia_athmo,  r.ia_route,  col.ia_col, secu.ia_secu,ville.longitude as longitude,ville.latitude as latitude, DATE_FORMAT(a.date_heure,'%d\/%m\/%Y à %Hh%i') AS date_heure  FROM accidents a  LEFT JOIN cat_vehicule c ON a.descr_cat_veh = c.descr_cat_veh  LEFT JOIN agglomeration agg ON a.descr_agglo = agg.descr_agglo  LEFT JOIN luminosite l ON a.descr_lum = l.descr_lum  LEFT JOIN meteo m ON a.descr_athmo = m.descr_athmo  LEFT JOIN etat_route r ON a.descr_etat_surf = r.descr_etat_surf  LEFT JOIN type_collision col ON a.descr_type_col = col.descr_type_col  LEFT JOIN ceinture secu ON a.descr_dispo_secu = secu.descr_dispo_secu  LEFT JOIN ville ON a.id_code_insee = ville.id_code_insee WHERE 1 = 1 ";
    }
    //si mois n'est pas vide alors on rajoute un filtre sur le mois
    if (!empty($mois)) {
      $request .= " AND MONTH(`date_heure`) = :mois";
    }
    //si la gravite n'est pas vide alors on rajoute un filtre sur la gravité
    if (!empty($descr_grav)) {
      $request .= " AND descr_grav = :descr_grav";
    }
    //si age n'est pas vide alors on rajoute un filtre sur l'age
    if (!empty($age)) {
      if ($age === '0-20') {
        $request .= " AND age >= 0 AND age <= 20";
      } elseif ($age === '20-40') {
        $request .= " AND age > 20 AND age <= 40";
      } elseif ($age === '40-60') {
        $request .= " AND age > 40 AND age <= 60";
      } elseif ($age === '60-80') {
        $request .= " AND age > 60 AND age <= 80";
      } elseif ($age === '80-90') {
        $request .= " AND age > 80 AND age <= 90";
      }
    }

    if ($choix == "0") {
      $request .= " ORDER BY RAND() LIMIT :limit";
    } else {
      $request .= " LIMIT :limit";
    }
    $statement = $db->prepare($request);
    if (!empty($mois)) {
      $statement->bindParam(':mois', $mois);
    }
    if (!empty($descr_grav)) {
      $statement->bindParam(':descr_grav', $descr_grav);
    }
    $statement->bindParam(':limit', $limit, PDO::PARAM_INT);
    $statement->execute();
    $result = $statement->fetchAll(PDO::FETCH_ASSOC);
    $data = $result;
  } catch (PDOException $e) {
    $data = array('error' => $e->getMessage());
  }
}

/***********************************************************/
/*requête qui renvoit la liste des descriptions athmo       */
/*_________________________________________________________*/

if ($requestMethod == 'GET' && $requestRessource == 'meteos') {
  try {
    $request = 'SELECT descr_athmo FROM meteo';
    $statement = $db->prepare($request);
    $statement->execute();
    $result = $statement->fetchAll(PDO::FETCH_ASSOC);
    $data = $result;
  } catch (PDOException $e) {
    // Gérer l'erreur ici
    $data = array('error' => $e->getMessage());
  }
}

/***********************************************************/
/*requête qui renvoit la liste des villes                  */
/*_________________________________________________________*/

if ($requestMethod == 'GET' && $requestRessource == 'ville') {
  try{
    $request = 'SELECT * FROM ville ORDER BY ville';
    $statement = $db->prepare($request);
    $statement->execute();
    $result = $statement->fetchAll(PDO::FETCH_ASSOC);
    $data = $result;
  } catch (PDOException $e) {
    // Gérer l'erreur ici
    $data = array('error' => $e->getMessage());
  }
}

/***************************************************************/
/*requête qui renvoit la liste des descriptions de luminosité  */
/*_____________________________________________________________*/

if ($requestMethod == 'GET' && $requestRessource == 'luminosites') {
  try{
    $request = 'SELECT descr_lum FROM luminosite';
    $statement = $db->prepare($request);
    $statement->execute();
    $result = $statement->fetchAll(PDO::FETCH_ASSOC);
    $data = $result;
  } catch (PDOException $e) {
    // Gérer l'erreur ici
    $data = array('error' => $e->getMessage());
  }
}

/***************************************************************/
/*requête qui renvoit la liste des descriptions de sécurité    */
/*_____________________________________________________________*/

if ($requestMethod == 'GET' && $requestRessource == 'ceintures') {
  try{
    $request = 'SELECT descr_dispo_secu FROM ceinture';
    $statement = $db->prepare($request);
    $statement->execute();
    $result = $statement->fetchAll(PDO::FETCH_ASSOC);
    $data = $result;
  } catch (PDOException $e) {
    // Gérer l'erreur ici
    $data = array('error' => $e->getMessage());
  }
}

/*************************************************************************/
/*requête qui renvoit la liste des descriptions de l'état de la route    */
/*_______________________________________________________________________*/

if ($requestMethod == 'GET' && $requestRessource == 'routes') {
  try{
    $request = 'SELECT descr_etat_surf FROM etat_route';
    $statement = $db->prepare($request);
    $statement->execute();
    $result = $statement->fetchAll(PDO::FETCH_ASSOC);
    $data = $result;
  } catch (PDOException $e) {
    // Gérer l'erreur ici
    $data = array('error' => $e->getMessage());
  }
}

/*************************************************************************/
/*requête qui renvoit la liste des descriptions de l'aggolomérations     */
/*_______________________________________________________________________*/

if ($requestMethod == 'GET' && $requestRessource == 'agglos') {
  try{
    $request = 'SELECT descr_agglo FROM agglomeration';
    $statement = $db->prepare($request);
    $statement->execute();
    $result = $statement->fetchAll(PDO::FETCH_ASSOC);
    $data = $result;
  } catch (PDOException $e) {
    // Gérer l'erreur ici
    $data = array('error' => $e->getMessage());
  }
}

/******************************************************************/
/*requête qui renvoit la liste des descriptions de véhicules      */
/*________________________________________________________________*/

if ($requestMethod == 'GET' && $requestRessource == 'vehicules') {
  try{
    $request = 'SELECT descr_cat_veh FROM cat_vehicule';
    $statement = $db->prepare($request);
    $statement->execute();
    $result = $statement->fetchAll(PDO::FETCH_ASSOC);
    $data = $result;
  } catch (PDOException $e) {
    // Gérer l'erreur ici
    $data = array('error' => $e->getMessage());
  }
}

/***************************************************************/
/*requête qui renvoit la liste des descriptions de collision   */
/*_____________________________________________________________*/

if ($requestMethod == 'GET' && $requestRessource == 'collisions') {
  try{
    $request = 'SELECT descr_type_col FROM type_collision';
    $statement = $db->prepare($request);
    $statement->execute();
    $result = $statement->fetchAll(PDO::FETCH_ASSOC);
    $data = $result;
  } catch (PDOException $e) {
    // Gérer l'erreur ici
    $data = array('error' => $e->getMessage());
  }
}

/************************************************************************************/
/*requête qui renvoit la liste des accidents pour le tableau et les predictions     */
/*__________________________________________________________________________________*/

if ($requestMethod == 'GET' && $requestRessource == 'prediction') {

  if (isset($_COOKIE['limit'])) {
    // Le cookie "limit" existe
    $limit = $_COOKIE['limit'];
  } else {
    $limit = "1000";
  }

  $request = "SELECT *, c.ia_cat,  c.ia_cat,  agg.ia_agglo,  l.ia_lum,  m.ia_athmo,  r.ia_route,  col.ia_col, secu.ia_secu,ville.longitude as longitude,ville.latitude as latitude, DATE_FORMAT(a.date_heure,'%d\/%m\/%Y à %Hh%i') AS date_heure  FROM accidents a  LEFT JOIN cat_vehicule c ON a.descr_cat_veh = c.descr_cat_veh  LEFT JOIN agglomeration agg ON a.descr_agglo = agg.descr_agglo  LEFT JOIN luminosite l ON a.descr_lum = l.descr_lum  LEFT JOIN meteo m ON a.descr_athmo = m.descr_athmo  LEFT JOIN etat_route r ON a.descr_etat_surf = r.descr_etat_surf  LEFT JOIN type_collision col ON a.descr_type_col = col.descr_type_col  LEFT JOIN ceinture secu ON a.descr_dispo_secu = secu.descr_dispo_secu  LEFT JOIN ville ON a.id_code_insee = ville.id_code_insee WHERE 1 = 1 ";

  if (isset($_COOKIE['age'])) {
    if ($_COOKIE['age'] === '0-20') {
      $request .= " AND age >= 0 AND age <= 20";
    } elseif ($_COOKIE['age'] === '20-40') {
      $request .= " AND age > 20 AND age <= 40";
    } elseif ($_COOKIE['age'] === '40-60') {
      $request .= " AND age > 40 AND age <= 60";
    } elseif ($_COOKIE['age'] === '60-80') {
      $request .= " AND age > 60 AND age <= 80";
    } elseif ($_COOKIE['age'] === '80-90') {
      $request .= " AND age > 80 AND age <= 90";
    }
  }
  if (isset($_COOKIE['mois']) && $_COOKIE['mois'] != '') {
    $request .= " AND MONTH(`date_heure`) = '" . $_COOKIE['mois'] . "'";
  }

  $request .= " LIMIT " . $limit;
  //$request = str_replace(array("\r", "\n"), '', $request);
  try {
    $statement = $db->prepare($request);
    $statement->execute();
    $result = $statement->fetchAll(PDO::FETCH_ASSOC);
    $data = $result;
  } catch (PDOException $e) {
    // Gérer l'erreur ici
    $data = array('error' => $e->getMessage());
  }
}


// Send data to the client.
header('Content-Type: application/json; charset=utf-8');
header('Cache-control: no-store, no-cache, must-revalidate');
header('Pragma: no-cache');
header('HTTP/1.1 200 OK');
echo json_encode($data);
exit;
