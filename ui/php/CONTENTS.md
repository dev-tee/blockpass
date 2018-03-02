## Contents

### .config.ini
Contains credentials that are used to connect to the database.

### .htaccess
Restricts access to .config.ini on Apache web servers.

### check.php
Used to check for available user ids in the database.

### cleanup.php
Used to cleanup the connection to the database.
Usually called by all the other scripts.

### connect.php
Established the connection to the database.

### finduser.php
Used to search for users in the database.

### sampleconfig.ini
Sample file that shows how .config.ini should be structured.
Remove ";" to get a working config.

### signin.php
Checks the users credentials with the database.

### signup.php
Creates a new user in the database.