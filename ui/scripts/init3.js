function init3() {

  if (typeof web3 !== 'undefined') {
    web3 = new Web3(web3.currentProvider);
  } else {
    web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  }

  defaultCallback = (error, result) => {
    if (!error) console.log(result);
    else console.error(error);
  };

  web3.eth.getAccounts(defaultCallback);

  document.dispatchEvent(new Event('init3'));
}
