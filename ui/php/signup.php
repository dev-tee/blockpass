<?php

  include 'connect.php';

  $usertype = $_POST['usertype'];
  $id = $_POST['id'];
  $password = $_POST['password'];
  $address = $_POST['address'];

  $query = "INSERT INTO {$usertype}s VALUES('{$id}', '{$address}', '{$password}')";
  $result = $mysqli->query($query);

  if ($result == true) {
    echo "OK";
  } else {
    echo "Fehler: " . $query . PHP_EOL . $mysqli->error;
  }

  include 'cleanup.php';

?>