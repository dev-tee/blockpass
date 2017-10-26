<?php

  include 'connect.php';

  $usertype = $_POST['usertype'];
  if ($usertype != 'student' && $usertype != 'supervisor') {
    echo "Error: Unknown usertype '{$usertype}'";
    exit(1);
  }

  if ($usertype == 'student') {
    $idcolumn = 'matrikelnr';
    $idtype = 'i';
  } else if ($usertype == 'supervisor') {
    $idcolumn = 'uaccountid';
    $idtype = 's';
  }

  $id = $_POST['id'];
  $address = $_POST['address'];
  $password = $_POST['password'];
  $pwhash = password_hash($password, PASSWORD_BCRYPT);

  $query = $mysqli->prepare("INSERT INTO {$usertype} VALUES(?, ?, ?)");
  if (!$query) {
    echo $mysqli->error;
    exit(1);
  }

  $query->bind_param("{$idtype}ss", $id, $address, $pwhash);
  if (!$query->execute()) {
    echo $mysqli->error;
    exit(1);
  }

  echo "OK";

  include 'cleanup.php';

?>