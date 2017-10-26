<?php

  include 'connect.php';

  $usertype = $_GET['usertype'];
  if ($usertype != 'student' && $usertype != 'supervisor') {
    echo "Fehler: Unbekannter Benutzertyp '{$usertype}'";
    exit(1);
  }

  if ($usertype == 'student') {
    $idcolumn = 'matrikelnr';
    $idtype = 'i';
  } else if ($usertype == 'supervisor') {
    $idcolumn = 'uaccountid';
    $idtype = 's';
  }

  $id = $_GET['id'];
  $password = $_GET['password'];

  $query = $mysqli->prepare("SELECT address, pwhash FROM {$usertype} WHERE {$idcolumn} = ?");
  if (!$query) {
    echo $mysqli->error;
    exit(1);
  }

  $query->bind_param("{$idtype}", $id);
  $query->execute();
  $query->bind_result($address, $pwhash);

  if ($query->fetch() === FALSE) {
    echo $mysqli->error;
    exit(1);
  }

  if (password_verify($password, $pwhash)) {
    echo "OK:{$address}";
  }

  include 'cleanup.php';

?>