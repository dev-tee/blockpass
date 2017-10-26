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

  $searchterm = $_GET['searchterm'];

  $query = $mysqli->prepare("SELECT {$idcolumn}, address FROM {$usertype} WHERE {$idcolumn} LIKE CONCAT('%', ?, '%')");
  if (!$query) {
    echo $mysqli->error;
    exit(1);
  }

  $query->bind_param("{$idtype}", $searchterm);
  $query->execute();
  $query->bind_result($id,$address);
  
  echo "OK";
  while ($query->fetch()) {
    echo ":{$id}+{$address}";
  }

  include 'cleanup.php';

?>