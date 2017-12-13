<?php

  // This script is responsible for checking whether a user id already exists or not.

  include 'connect.php';

  // Setup the variables according to the requested user type - student or supervisor.
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

  // Select the values that match the requested user id with a prepared statement.
  $query = $mysqli->prepare("SELECT {$column} FROM {$table} WHERE {$column} = ?");
  if (!$query) {
    echo $mysqli->error;
    exit(1);
  }

  // Bind the input parameters and execute.
  $query->bind_param("{$idtype}", $id);
  $query->execute();
  $query->bind_result($result);

  // Check for errors.
  if ($query->fetch() === FALSE) {
    echo $mysqli->error;
    exit(1);
  }

  // Return success if the user id has not been taken yet.
  if (!isset($result)) {
    echo "OK";
  }

  include 'cleanup.php';

?>