<?php

  // This script is responsible for cleaning up the connection.

  $thread_id = $mysqli->thread_id;
  $mysqli->kill($thread_id);
  $mysqli->close();

?>