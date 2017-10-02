function cacheCredentials(address, password, usertype) {
  sessionStorage['address'] = address;
  sessionStorage['password'] = password;
  sessionStorage['usertype'] = usertype;
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
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = (event) => {
    console.log(event);
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
  var data = id + '=' + value;
  xhr.open('GET', 'php/check.php?' + data, true);
  xhr.send();
}

function signin(usertype, id, password) {
  
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = (event) => {
    if (event.target.readyState == XMLHttpRequest.DONE
        && event.target.status == 200)
    {
      console.log(event);
      if (!event.target.response.startsWith('OK:')) {
        alert("Fehler beim Anmelden!");
      } else {
        var address = event.target.response.split(':')[1];
        cacheCredentials(address, password, usertype);

        // console.log(checkCredentials(address, password));
        directToRespectiveHome();
      }
    }
  };

  var data = 'usertype=' + usertype + '&id=' + id + '&password=' + password;
  xhr.open('GET', 'php/signin.php?' + data, true);
  xhr.send();
}

function signup(name, usertype, id, password) {

  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = (event) => {
    if (event.target.readyState == XMLHttpRequest.DONE
        && event.target.status == 200)
    {
      console.log(event);
      if (event.target.response != 'OK') {
        alert("Fehler beim Registrieren!");
      } else {
        cacheCredentials(address, password, usertype);

        // console.log(checkCredentials(address, password));
        var data;
        if (usertype == 'student') {
          data = accountmanagerInstance.registerStudent.getData(address, name, id);
        } else if (usertype == 'supervisor') {
          data = accountmanagerInstance.registerSupervisor.getData(address, name);
        }
        signAndSend(data, accountmanagerInstance.address);

        directToRespectiveHome();
      }
    }
  };

  var address = web3.personal.newAccount(password);
  var data = 'usertype=' + usertype + '&id=' + id + '&address=' + address+ '&password=' + password;
  xhr.open('POST', 'php/signup.php', true);
  xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
  xhr.send(data);
}

function directToRespectiveHome() {
  window.location.assign('/' + sessionStorage['usertype'] + '/index.html');
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
