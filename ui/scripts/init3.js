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

init3();