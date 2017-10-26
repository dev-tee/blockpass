<?php

  include 'connect.php';

  if (isset($_GET['matrikelnr'])) {
    $id = $_GET['matrikelnr'];
    $idtype = 'i';
    $column = 'matrikelnr';
    $table = 'student';
  } else if (isset($_GET['uaccountid'])) {
    $id = $_GET['uaccountid'];
    $idtype = 's';
    $column = 'uaccountid';
    $table = 'supervisor';
  } else {
    echo "Error: Unknown ID";
    exit(1);
  }

  $query = $mysqli->prepare("SELECT {$column} FROM {$table} WHERE {$column} = ?");
  if (!$query) {
    echo $mysqli->error;
    exit(1);
  }

  $query->bind_param("{$idtype}", $id);
  $query->execute();
  $query->bind_result($result);

  if ($query->fetch() === FALSE) {
    echo $mysqli->error;
    exit(1);
  }

  if (!isset($result)) {
    echo "OK";
  }

  include 'cleanup.php';

?>