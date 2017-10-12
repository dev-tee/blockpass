<?php

  $thread_id = $mysqli->thread_id;
  $mysqli->kill($thread_id);
  $mysqli->close();

?>