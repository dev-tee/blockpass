function init3() {
  var web3Provider = "http://localhost:8545";

  // Use our node provided web3.
  web3 = new Web3(new Web3.providers.HttpProvider(web3Provider));

  if (web3.isConnected()) {
    if (isLoggedIn()) {
      web3.eth.defaultAccount = localStorage['address'];
    }
    document.dispatchEvent(new Event('init3'));
  } else {
    alert("Fehler beim Verbinden mit Ethereum-Node unter: " + web3Provider);
  }
}

function signAndSend(data, destination) {
  var tx = {
    "from": localStorage['address'],
    "to": destination,
    "data": data
  };
  // tx.gas = web3.eth.estimateGas(tx);
  // console.log("Estimated gas cost: " + tx.gas);
  web3.personal.sendTransaction(tx, localStorage['password']);
}

function logout() {
  localStorage.clear();
  web3.eth.defaultAccount = undefined;
  
  window.location.assign('../index.html');
}

function isLoggedIn() {
  return Boolean(localStorage['address']) && Boolean(localStorage['password']);
}

function isStudent() {
  return localStorage['usertype'] == 'student';
}

function isSupervisor() {
  return localStorage['usertype'] == 'supervisor';
}

function isAccessAllowed() {
  // Format of path name: 'usertype/page.html'.
  var path = window.location.pathname;
  if (path.search('personal') != -1) {
    return true;
  } else if (path.search(localStorage['usertype']) != -1) {
    return true;
  } else {
    return false;
  }
}

function checkAccess() {
  if (!isLoggedIn() && (window.location.pathname.search('student') != -1
                      ||window.location.pathname.search('supervisor') != -1
                      ||window.location.pathname.search('personal') != -1))
  {
    goHome();
  } else if (isLoggedIn() && !isAccessAllowed()) {
    goHome();
  }
}

function goHome() {
  var home = isLoggedIn() ? '../personal/index.html' : '../index.html';
  window.location.assign(home);
}

// Create common object
// to prevent littering global namespace.
// TODO: Actually use it!
var blockpass = {};

// Check whether the user is logged in.
// Redirect if that is not the case.
checkAccess();
// Finally call our initialisation sequence.
init3();
