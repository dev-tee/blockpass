<?php

  include 'connect.php';

  $usertype = $_GET['usertype'];
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

  // Empty search terms should not return anything.
  $searchterm = $_GET['searchterm'];
  if (empty($searchterm)) {
    // echo "Error: Empty search terms are not allowed.";
    exit(1);
  }

  $query = $mysqli->prepare("SELECT {$idcolumn}, address FROM {$usertype} WHERE {$idcolumn} LIKE CONCAT('%', ?, '%')");
  if (!$query) {
    echo $mysqli->error;
    exit(1);
  }

  $query->bind_param("{$idtype}", $searchterm);
  $query->execute();
  $query->bind_result($id,$address);
  
  echo "OK";
  while ($query->fetch()) {
    echo ":{$id}+{$address}";
  }

  include 'cleanup.php';

?>