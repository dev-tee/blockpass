<?php

  include 'connect.php';

  $usertype = $_GET['usertype'];
  $searchterm = $_GET['searchterm'];
  $idcolumn;

  if ($usertype == 'student') {
    $idcolumn = 'matrikelnr';
  } else if ($usertype == 'supervisor') {
    $idcolumn = 'uaccountid';
  }

  $query = "SELECT {$idcolumn},address FROM {$usertype}s WHERE {$idcolumn} LIKE '%{$searchterm}%'";

  $result = $mysqli->query($query);

  if ($result && $searchterm != '') {
    echo "OK";
    while ($row = $result->fetch_array()) {
      $id = $row[$idcolumn];
      $address = $row['address'];
      echo ":{$id}+{$address}";
    }
  } else {
    echo "Fehler: " . $query . PHP_EOL . $mysqli->error;
  }

  include 'cleanup.php';

?>