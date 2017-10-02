function init3() {
  var web3Provider = "http://localhost:8545";

  // Use our node provided web3.
  web3 = new Web3(new Web3.providers.HttpProvider(web3Provider));

  if (web3.isConnected()) {
    document.dispatchEvent(new Event('init3'));
  } else {
    alert("Fehler beim Verbinden mit Ethereum-Node unter: " + web3Provider);
  }
}

function signAndSend(data, destination) {
  var tx = {
    "from": sessionStorage['address'],
    "to": destination,
    "data": data
  };
  tx.gas = web3.eth.estimateGas(tx);
  console.log("Estimated gas cost: " + tx.gas);
  web3.personal.sendTransaction(tx, sessionStorage['password']);
}

function logout() {
  sessionStorage.clear();
  window.location.assign('/index.html');
}

function isLoggedIn() {
  return Boolean(sessionStorage['address']) && Boolean(sessionStorage['password']);
}

function isAccessAllowed() {
  // Format of path name: '/usertype/page.html'.
  var request = window.location.pathname.split('/')[1];
  return sessionStorage['usertype'] == request;
}

function checkAccess() {
  var home = '/index.html';
  var registration = '/register.html';
  if (!isLoggedIn() && !(window.location.pathname == home || window.location.pathname == registration)) {
    window.location.assign(home);
    return;
  }

  home = '/' + sessionStorage['usertype'] + home;
  if (isLoggedIn() && !isAccessAllowed()) {
    window.location.assign(home);
    return;
  }
}

// Check whether the user is logged in.
// Redirect if that is not the case.
checkAccess();
// Finally call our initialisation sequence.
init3();
