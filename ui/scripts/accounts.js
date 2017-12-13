// Cache the pre-verified login information
// in session storage variant of web storage.
function cacheCredentials(address, password, usertype) {
  sessionStorage['address'] = address;
  sessionStorage['password'] = password;
  sessionStorage['usertype'] = usertype;
}

// Navigate to the logged in users landing page.
function enter() {
  if (!isLoggedIn()) {
    return;
  }
  var home = 'personal/courses.html';
  window.location.assign(home);
}

// Verify credentials by signing a message and checking it afterwards.
//
// UNUSED BECAUSE:
// Call with optional password parameter
// not supported in parity v1.6.10-stable.
function checkCredentials(address, password) {
  var message = "CredentialCheck";
  
  var signature = web3.personal.sign(message, address, password);
  console.log("Signature: " + signature);
  var recoveredAddress = web3.personal.ecRecover(message, signature);
  console.log("Recovered address: " + recoveredAddress);
  
  return address == recoveredAddress;
}

// Check whether a specific userid has not been taken yet.
function checkAvailability(id, value, callback) {
  var xhr = createXMLHttpRequest();
  xhr.onreadystatechange = (event) => {
    if (event.target.readyState == XMLHttpRequest.DONE
        && event.target.status == 200)
    {
      if (event.target.response != 'OK') {
        callback(false);
      } else {
        callback(true);
      }
    }
  };
  var requestData = id + '=' + value;
  xhr.open('GET', 'php/check.php?' + requestData, true);
  xhr.send();
}

// Check credentials and log the user in on success.
function signin(usertype, id, password) {  
  var xhr = createXMLHttpRequest();
  xhr.onreadystatechange = (event) => {
    console.log(event.target.response);
    if (event.target.readyState == XMLHttpRequest.DONE
        && event.target.status == 200)
    {
      if (!event.target.response.startsWith('OK:')) {
        alert("Benutzer oder Passwort falsch.");
      } else {
        var address = event.target.response.substring(3);
        cacheCredentials(address, password, usertype);

        // console.log(checkCredentials(address, password));
        enter();
      }
    }
  };

  var requestData = 'usertype=' + usertype + '&id=' + id + '&password=' + password;
  xhr.open('GET', 'php/signin.php?' + requestData, true);
  xhr.send();
}

// Sign the user up with the provided credentials
// and log them in on success.
function signup(name, usertype, id, password) {
  var xhr = createXMLHttpRequest();
  xhr.onreadystatechange = (event) => {
    if (event.target.readyState == XMLHttpRequest.DONE
        && event.target.status == 200)
    {
      console.log(event.target.response);
      if (event.target.response != 'OK') {
        alert("Fehler beim Registrieren.");
      } else {
        cacheCredentials(address, password, usertype);

        // console.log(checkCredentials(address, password));
        var data;
        if (usertype == 'student') {
          data = accountmanagerInstance.registerStudent.getData(address, name, id);
        } else if (usertype == 'supervisor') {
          data = accountmanagerInstance.registerSupervisor.getData(address, name, id);
        }
        signAndSend(data, accountmanagerInstance.address, (error, result) => {
          if (!error) {
            enter();
          }
        });
      }
    }
  };

  var address = web3.personal.newAccount(password);
  var requestData = 'usertype=' + usertype + '&id=' + id + '&address=' + address+ '&password=' + password;
  xhr.open('POST', 'php/signup.php', true);
  xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
  xhr.send(requestData);
}

// Search for another registered user's id.
function find(usertype, searchterm, callback) {
  if (!isLoggedIn()) {
    console.error('Log in to use this feature.');
  }

  var xhr = createXMLHttpRequest();
  xhr.onreadystatechange = (event) => {
    if (event.target.readyState == XMLHttpRequest.DONE
        && event.target.status == 200)
    {
      if (!event.target.response.startsWith('OK:')) {
        callback("Keine Übereinstimmungen");
      } else {
        var tuples = event.target.response.substring(3).split(':');
        var result = {};

        for (var i = 0; i < tuples.length; i++) {
          var tuple = tuples[i].split('+');
          var id = tuple[0];
          var address = tuple[1];
          result[id] = address;
        }

        callback(false, result);
      }
    }
  };

  var requestData = 'usertype=' + usertype + '&searchterm=' + searchterm;
  // Go up one folder since we are calling it from within
  // personal, student or supervisor.
  // Since we don't want to request the php file from an unknown place
  // we checked the logged in state beforehand.
  xhr.open('GET', '../php/finduser.php?' + requestData, true);
  xhr.send();
}

// List the user-ids a user has added to their selection.
function getSelections() {
  var addresses = [];
  for (var variable in helpers) {
    if (helpers.hasOwnProperty(variable)
      && helpers[variable] != sessionStorage['address'])
    {
      addresses.push(helpers[variable]);
    }
  }
  return addresses;
}

// Remove a user from the selection.
function removeSelection(that) {
  var address = that.getAttribute('data-address');
  var id = that.getAttribute('data-id');
  
  delete helpers[id];
  render(undefined, helpers);
}

// Add a user to the selection.
function addSelection(that) {
  var address = that.getAttribute('data-address');
  var id = that.getAttribute('data-id');

  helpers[id] = address;
  render(undefined, helpers);
}

// Render the ui for searching and selecting other users.
function render(suggested, selected) {
  var suggestions = [];
  suggestions.push('<ul class="suggestions">');
  for (var variable in suggested) {
    if (suggested.hasOwnProperty(variable)
      && suggested[variable] != sessionStorage['address']) {
      suggestions.push(`<li>${variable}`);
      suggestions.push(`<span
        data-id="${variable}"
        data-address="${suggested[variable]}"
        onclick="addSelection(this)"
        class="action"> + </span>`);
    }
  }
  suggestions.push('</ul>');
  
  var selections = [];
  selections.push('<ul class="selections">');
  for (var variable in selected) {
    if (selected.hasOwnProperty(variable)
      && selected[variable] != sessionStorage['address']) {
      selections.push(`<li>${variable}`);
      selections.push(`<span
        data-id="${variable}"
        data-address="${selected[variable]}"
        onclick="removeSelection(this)"
        class="action"> - </span>`)
    }
  }
  selections.push('</ul>');

  if (suggestions.length == 2) suggestions = [];
  if (selections.length == 2) selections = [];

  renderelement.innerHTML = suggestions.join('') + selections.join('');
}

// Parse input and update search ui with results.
function parseAndFind(event) {
  var helper = event.target.value;
  var usertype = sessionStorage['usertype'];
  find(usertype, helper, (error, result) => {
    if (error) {
      render(undefined, helpers);
    } else {
      render(result, helpers);
    }
  });
}

// Initialise the user interface for searching for other user's ids.
function setupSearch(element) {
  helpers = {};
  renderelement = document.createElement('div');
  element.insertAdjacentElement('afterend', renderelement);
  element.addEventListener('input', parseAndFind);
}

// Create a generic XMLHttpRequest with a predefined timeout.
function createXMLHttpRequest() {
  var xhr = new XMLHttpRequest();
  xhr.timeout = 4 * 1000;
  xhr.ontimeout = (event) => {
    alert("Zeitüberschreitung beim Verbinden mit Datenbank.");
  }
  return xhr;
}

// Show or hide input elements based on the current state.
function showLabelledInput(id, state) {
  document.getElementById(id).hidden = !state;
  document.getElementById(id).disabled = !state;
  document.getElementById('label_' + id).hidden = !state;
}

// Switch to the ID that is relevant for the current user type.
function switchID(event) {
  if (event.target.value == 'student') {
    showLabelledInput('matrikelnr', true);
    showLabelledInput('uaccountid', false);
  } else if (event.target.value == 'supervisor') {
    showLabelledInput('matrikelnr', false);
    showLabelledInput('uaccountid', true);
  }
}
