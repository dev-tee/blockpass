<?php

  // This script is responsible for searching for user ids.

  include 'connect.php';

  // Check that the requested usertype is a valid one.
  $usertype = $_GET['usertype'];
  if ($usertype != 'student' && $usertype != 'supervisor') {
    echo "Error: Unknown usertype '{$usertype}'";
    exit(1);
  }

  // Setup the variables according to the requested user type - student or supervisor.
  if ($usertype == 'student') {
    $idcolumn = 'matrikelnr';
    $idtype = 'i';
  } else if ($usertype == 'supervisor') {
    $idcolumn = 'uaccountid';
    $idtype = 's';
  }

  // Parse the search term and exit if it is empty since those should not return anything.
  $searchterm = $_GET['searchterm'];
  if (empty($searchterm)) {
    // echo "Error: Empty search terms are not allowed.";
    exit(1);
  }

  // Select the values that match or partially match the search term with a prepared statement.
  $query = $mysqli->prepare("SELECT {$idcolumn}, address FROM {$usertype} WHERE {$idcolumn} LIKE CONCAT('%', ?, '%')");
  if (!$query) {
    echo $mysqli->error;
    exit(1);
  }

  // Bind the input parameters and execute.
  $query->bind_param("{$idtype}", $searchterm);
  $query->execute();
  $query->bind_result($id,$address);
  
  // Return a concatenated string of user ids and their adressess.
  echo "OK";
  while ($query->fetch()) {
    echo ":{$id}+{$address}";
  }

  include 'cleanup.php';

?>