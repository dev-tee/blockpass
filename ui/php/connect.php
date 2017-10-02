<?php
  
  $host = 'a1308076.mysql.univie.ac.at';
  $user = 'a1308076';
  $password = 'p1308076';
  $database = 'a1308076';

  $mysqli = new mysqli($host, $user, $password, $database);
  if ($mysqli->connect_errno) {
      echo "Fehler beim Verbinden mit MySQL-Server: (" . $mysqli->connect_errno . ") " . $mysqli->connect_error;
  }

?>