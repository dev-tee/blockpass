<?php

  // This script is responsible for setting up the connection to the database.

  // Read out the credentials from the configuration file.
  $ini_array = parse_ini_file(".config.ini");

  $host = $ini_array['host'];
  $user = $ini_array['user'];
  $password = $ini_array['password'];
  $database = $ini_array['database'];

  // Connect to the database.
  $mysqli = new mysqli($host, $user, $password, $database);
  if ($mysqli->connect_errno) {
    echo "Connection error: (" . $mysqli->connect_errno . ") " . $mysqli->connect_error;
  }

?>