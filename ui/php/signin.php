<?php

  include 'connect.php';

  $usertype = $_GET['usertype'];
  $id = $_GET['id'];
  $password = $_GET['password'];
  $idcolumn;
  $table;

  if ($usertype == 'student') {
    $idcolumn = 'matrikelnr';
    $table = 'students';
  } else if ($usertype == 'supervisor') {
    $idcolumn = 'uaccountid';
    $table = 'supervisors';
  }

  $query = "SELECT address FROM {$usertype}s WHERE {$idcolumn} = {$id} AND password = '{$password}'";

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