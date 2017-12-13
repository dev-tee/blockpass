<?php

  // This script is responsible for signing in a registered user.

  include 'connect.php';

  // Check that the given usertype is a valid one.
  $usertype = $_GET['usertype'];
  if ($usertype != 'student' && $usertype != 'supervisor') {
    echo "Error: Unknown usertype '{$usertype}'";
    exit(1);
  }

  // Setup the variables according to the given user type - student or supervisor.
  if ($usertype == 'student') {
    $idcolumn = 'matrikelnr';
    $idtype = 'i';
  } else if ($usertype == 'supervisor') {
    $idcolumn = 'uaccountid';
    $idtype = 's';
  }

  // Read out the user id and password.
  $id = $_GET['id'];
  $password = $_GET['password'];

  // Select the values that match the given user id with a prepared statement.
  $query = $mysqli->prepare("SELECT address, pwhash FROM {$usertype} WHERE {$idcolumn} = ?");
  if (!$query) {
    echo $mysqli->error;
    exit(1);
  }

  // Bind the input parameters and execute.
  $query->bind_param("{$idtype}", $id);
  $query->execute();
  $query->bind_result($address, $pwhash);

  // Check for errors.
  if ($query->fetch() === FALSE) {
    echo $mysqli->error;
    exit(1);
  }

  // Verify that the password matches the one in the database.
  // Do this using PHP's password hashing API.
  if (password_verify($password, $pwhash)) {
    echo "OK:{$address}";
  }

  include 'cleanup.php';

?>