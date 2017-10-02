<?php

  include 'connect.php';

  $usertype = $_GET['usertype'];
  $id = $_GET['id'];
  $password = $_GET['password'];
  $idcolumn;

  if ($usertype == 'student') {
    $idcolumn = 'matrikelnr';
  } else if ($usertype == 'supervisor') {
    $idcolumn = 'uaccountid';
  }

  $query = "SELECT address FROM {$usertype}s WHERE {$idcolumn} = '{$id}' AND password = '{$password}'";

  $result = $mysqli->query($query);

  if ($result) {
    if ($result->num_rows == 1) {
      $row = $result->fetch_array();
      echo "OK:{$row['address']}";
    }
  } else {
    echo "Fehler: " . $query . PHP_EOL . $mysqli->error;
  }

  include 'cleanup.php';

?>