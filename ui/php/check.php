<?php

  include 'connect.php';

  $column;
  $table;
  
  if (isset($_GET['matrikelnr'])) {
    $id = $_GET['matrikelnr'];
    $column = 'matrikelnr';
    $table = 'students';
  } else if (isset($_GET['uaccountid'])) {
    $id = $_GET['uaccountid'];
    $column = 'uaccountid';
    $table = 'supervisors';
  }

  $query = "SELECT {$column} FROM {$table} WHERE {$column} = '{$id}'";
  $result = $mysqli->query($query);
  
  if ($result) {
    if ($result->num_rows == 0) {
      echo "OK";
    }
  } else {
    echo "Fehler: " . $query . PHP_EOL . $mysqli->error;
  }

  include 'cleanup.php';

?>