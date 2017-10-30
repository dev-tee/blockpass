// Create common object
// to prevent littering global namespace.
// TODO: Actually use it!
var blockpass = {};

function init3() {
  // var web3Provider = "http://localhost:8545";
  var web3Provider = "http://blockpass.cs.univie.ac.at:8545";

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

  transactionHash = web3.personal.sendTransaction(tx, sessionStorage['password']);

  transactioninfo.innerText = `Warte auf Transaktion mit Hash: ${transactionHash}...`;
}

function logout() {
  sessionStorage.clear();
  web3.eth.defaultAccount = undefined;
  
  window.location.assign('../index.html');
}

function isLoggedIn() {
  return Boolean(sessionStorage['address']) && Boolean(sessionStorage['password']);
}

function isStudent() {
  return sessionStorage['usertype'] == 'student';
}

function isSupervisor() {
  return sessionStorage['usertype'] == 'supervisor';
}

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

function goHome() {
  if (!isLoggedIn()) {
    return;
  }
  var home = '../personal/courses.html';
  window.location.assign(home);
}

blockpass.parseIDs = function() {
  var searchParameters = new URLSearchParams(window.location.search);
  blockpass.ids = {
    course: searchParameters.get('courseid'),
    assignment: searchParameters.get('assignmentid'),
    test: searchParameters.get('testid'),
    submission: searchParameters.get('submissionid')
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

// Check whether the user is logged in.
// Redirect if that is not the case.
checkPage();
// Finally call our initialisation sequence.
init3();
