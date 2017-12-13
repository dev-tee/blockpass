<?php

  // This script is responsible for signing up a registered user.

  include 'connect.php';

  // Check that the given usertype is a valid one.
  $usertype = $_POST['usertype'];
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

  // Read out the other values that were provided.
  $id = $_POST['id'];
  $address = $_POST['address'];
  $password = $_POST['password'];

  // Hash the password using PHP's password hashing API.
  $pwhash = password_hash($password, PASSWORD_BCRYPT);

  // Save the credentials in the database with a prepared statement.
  $query = $mysqli->prepare("INSERT INTO {$usertype} VALUES(?, ?, ?)");
  if (!$query) {
    echo $mysqli->error;
    exit(1);
  }

  // Bind the input parameters, execute and check for errors.
  $query->bind_param("{$idtype}ss", $id, $address, $pwhash);
  if (!$query->execute()) {
    echo $mysqli->error;
    exit(1);
  }

  // Return a success value.
  echo "OK";

  include 'cleanup.php';

?>