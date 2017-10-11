function cacheCredentials(address, password, usertype) {
  localStorage['address'] = address;
  localStorage['password'] = password;
  localStorage['usertype'] = usertype;
}

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

function createXMLHttpRequest() {
  var xhr = new XMLHttpRequest();
  xhr.timeout = 4 * 1000;
  xhr.ontimeout = (event) => {
    alert("Zeitüberschreitung beim Verbinden mit Datenbank.");
  }
  return xhr;
}

function signin(usertype, id, password) {
  
  var xhr = createXMLHttpRequest();
  xhr.onreadystatechange = (event) => {
    if (event.target.readyState == XMLHttpRequest.DONE
        && event.target.status == 200)
    {
      if (!event.target.response.startsWith('OK:')) {
        alert("Benutzer oder Passwort falsch.");
      } else {
        var address = event.target.response.split(':')[1];
        cacheCredentials(address, password, usertype);

        // console.log(checkCredentials(address, password));
        goHome();
      }
    }
  };

  var requestData = 'usertype=' + usertype + '&id=' + id + '&password=' + password;
  xhr.open('GET', 'php/signin.php?' + requestData, true);
  xhr.send();
}

function signup(name, usertype, id, password) {

  var xhr = createXMLHttpRequest();
  xhr.onreadystatechange = (event) => {
    if (event.target.readyState == XMLHttpRequest.DONE
        && event.target.status == 200)
    {
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
        signAndSend(data, accountmanagerInstance.address);

        goHome();
      }
    }
  };

  var address = web3.personal.newAccount(password);
  var requestData = 'usertype=' + usertype + '&id=' + id + '&address=' + address+ '&password=' + password;
  xhr.open('POST', 'php/signup.php', true);
  xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
  xhr.send(requestData);
}

function showLabelledInput(id, state) {
  document.getElementById(id).hidden = !state;
  document.getElementById(id).disabled = !state;
  document.getElementById('label_' + id).hidden = !state;
}

function switchID(event) {
  if (event.target.value == 'student') {
    showLabelledInput('matrikelnr', true);
    showLabelledInput('uaccountid', false);
  } else if (event.target.value == 'supervisor') {
    showLabelledInput('matrikelnr', false);
    showLabelledInput('uaccountid', true);
  }
}
