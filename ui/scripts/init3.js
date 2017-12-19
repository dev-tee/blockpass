// Define the project's namespace.
var blockpass = {};

// Initialise the connection to the ethereum node.
blockpass.init3 = function() {
  var web3Provider = "http://localhost:8545";
  // var web3Provider = "http://blockpass.cs.univie.ac.at:8545";

  // Use our node provided web3.
  web3 = new Web3(new Web3.providers.HttpProvider(web3Provider));

  if (web3.isConnected()) {
    document.dispatchEvent(new Event('init3'));
  } else {
    alert("Fehler beim Verbinden mit Ethereum-Node unter: " + web3Provider);
  }
}

blockpass.init3();