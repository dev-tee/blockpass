// Define the project's namespace.
// TODO: Actually use it!
var blockpass = {};

// Initialise the connection to the ethereum node.
function init3() {
  var web3Provider = "http://localhost:8545";
  // var web3Provider = "http://blockpass.cs.univie.ac.at:8545";

  // Use our node provided web3.
  web3 = new Web3(new Web3.providers.HttpProvider(web3Provider));

  if (web3.isConnected()) {
    if (isLoggedIn()) {
      web3.eth.defaultAccount = sessionStorage['address'];
    }
    document.dispatchEvent(new Event('init3'));
  } else {
    alert("Fehler beim Verbinden mit Ethereum-Node unter: " + web3Provider);
  }
}

// Sign a transaction with the specified data and destination.
// Uses the password and address cached in web storage.
// Displays an overlay while the transaction is being mined.
function signAndSend(data, destination, callback) {
  var tx = {
    "from": sessionStorage['address'],
    "to": destination,
    "data": data,
    "gasPrice": 0
  };
  tx.gas = web3.eth.estimateGas(tx);
  console.log("Estimated gas cost: " + tx.gas);
  tx.gas = Math.round(tx.gas * 1.25);
  console.log("Heightened to: " + tx.gas);

  var blockgaslimit = web3.eth.getBlock('latest').gasLimit;
  if (tx.gas >= blockgaslimit * 0.8) {
    alert("Kosten zu hoch. Transaktion zurzeit nicht möglich.");
    return;
  }
  var transactionHash;

  var row = document.createElement('div');
  row.className = "row sticky-row";
  var transactioninfo = document.createElement('div');
  transactioninfo.className = "column center-column hover-column";

  row.insertAdjacentElement('beforeend', transactioninfo);
  document.getElementsByClassName('container')[0].insertAdjacentElement('beforeend', row);

  blockpass.latestfilter = web3.eth.filter('latest');
  blockpass.latestfilter.watch((error, result) => {
    if (!error) {
      var transactionHashes = web3.eth.getBlock(result).transactions;
      console.log(transactionHashes);
      console.log(transactionHash);
      for (var i = 0; i < transactionHashes.length; ++i) {
        if (transactionHashes[i] == transactionHash) {
          transactioninfo.innerText = "Fertig";
          blockpass.latestfilter.stopWatching();
          callback(false, true);
          break;
        }
      }
    }
  });

  transactioninfo.innerText = "Sende Transaktion...";

  setTimeout(() => {
    transactionHash = web3.personal.sendTransaction(tx, sessionStorage['password']);
    transactioninfo.innerText = `Warte auf Transaktion mit Hash: ${transactionHash}...`;
  }, 1 * 1000);
}

function blockInput() {
  // Disable the form or button on the current page to prevent duplicate transactions.
  var form = document.getElementById("form");
  if (form != null) {
    var elements = form.elements;
    for (var i = 0, len = elements.length; i < len; ++i) {
        elements[i].disabled = true;
    }
  } else {
    var button = document.getElementById("register");
    if (button != null) {
      button.disabled = true;
    }
  }
}

// Logout the current user by clearing web storage
// and navigating to the home page.
function logout() {
  sessionStorage.clear();
  web3.eth.defaultAccount = undefined;
  
  window.location.assign('../index.html');
}

// Check whether the user is currently logged in
// by looking at the cached values in web storage.
function isLoggedIn() {
  return Boolean(sessionStorage['address']) && Boolean(sessionStorage['password']);
}

// Check whether the user is a student by
// looking at the cached values in web storage.
function isStudent() {
  return sessionStorage['usertype'] == 'student';
}

// Check whether the user is a supervisor by
// looking at the cached values in web storage.
function isSupervisor() {
  return sessionStorage['usertype'] == 'supervisor';
}

// Check whether the requested page is accessible by the user.
// Redirect for faulty requests.
function checkPage() {
  var path = window.location.pathname;
  if (path.search('/$') == -1
    && path.search('index.html') == -1
    && path.search('signup.html') == -1)
  {
    if (isLoggedIn()) {
      if (path.search('/personal/') == -1 && path.search(sessionStorage['usertype']) == -1) {
        window.location.assign('../personal/courses.html');
        return;
      }
    }
    else {
      window.location.assign('../index.html');
      return;
    }
  } else if (isLoggedIn()) {
    window.location.assign('personal/courses.html');
    return;
  }
}

// Navigate the user to the home page.
function goHome() {
  if (!isLoggedIn()) {
    return;
  }
  var home = '../personal/courses.html';
  window.location.assign(home);
}

// Parse IDs that are located in the url string and update
// the values on the rendered page that depend on them.
blockpass.parseIDs = function() {
  var parameters = {};
  var searchParameters = window.location.search.substr(1).split('&');
  for (var i = 0; i < searchParameters.length; i++) {
    var tuple = searchParameters[i].split('=');
    var key = tuple[0];
    var value = tuple[1];
    parameters[key] = value;
  }

  blockpass.ids = {
    course: parameters['courseid'],
    assignment: parameters['assignmentid'],
    test: parameters['testid'],
    submission: parameters['submissionid']
  }

  for (var variable in blockpass.ids) {
    if (blockpass.ids.hasOwnProperty(variable) && blockpass.ids[variable] != null) {
      var id = blockpass.ids[variable];

      var elements = document.getElementsByClassName(`${variable}dependentlink`);
      for (var i = 0; i < elements.length; i++) {
        if (elements[i].href.search('\\?') == -1) {
          elements[i].href += '?';
        } else {
          elements[i].href += '&';
        }
        elements[i].href += `${variable}id=${id}`;
      }
    }
  }
}

// Show information about the current user.
// Activate buttons with userdependent functions.
function showUserPanel() {
  var usertype = "";
  var useridtype = "";
  var username = "";
  var userid = "";
  var functions;
  if (isSupervisor()) {
    usertype = "LV-LeiterIn";
    useridtype = "uaccount-ID";
    username = supervisordbInstance.getSupervisor(sessionStorage.address)[0];
    userid = supervisordbInstance.getSupervisor(sessionStorage.address)[1];

    functions = document.getElementById('supervisorfunctions');
  }
  else if (isStudent()) {
    usertype = "StudentIn";
    useridtype = "MatrNr";
    username = studentdbInstance.getStudent(sessionStorage.address)[0];
    userid = studentdbInstance.getStudent(sessionStorage.address)[1];

    functions = document.getElementById('studentfunctions');
  }
  document.getElementById('usertype').innerHTML = usertype;
  document.getElementById('useridtype').innerHTML = useridtype;
  document.getElementById('username').innerHTML = username;
  document.getElementById('userid').innerHTML = userid;

  if (functions != null) {
    functions.hidden = false;
  }
}

checkPage();
init3();
