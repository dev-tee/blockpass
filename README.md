# Praktikum Bachelorarbeit

Topic: "Blockchain: Report of Academic Records"  
Original title: "Blockchain: Prüfungspass"

An exploration of a blockchain system for reports of academic records on the basis of ethereum and smart contracts.

## Table of Contents
* [Files and Folder Contents](#files-and-folder-contents)
* [System Requirements for Users](#system-requirements-for-users)
* [Project Setup](#project-setup)
    * [Hardware Prerequisites](#hardware-prerequisites)
    * [Build Environment](#build-environment)
    * [Blockchain Configuration](#blockchain-configuration)
    * [Setup Guide](#setup-guide)
* [Links](#links)

## Files and Folder Contents

Folders will usually contain CONTENTS.md files that provide an overview of the folder's contents and file descriptions.
Additionally, source files for code used in the system have their own descriptions near the top of their files.

**ui - folder**  
Files for the website.

**helper - folder**  
Helper scripts for compilation and setup of js-bindings.

**contracts - folder**  
Solidity code for the system's smart contracts.

**doc - folder**  
Documentation and diagrams (source and exported).

## System Requirements (for Users)

To run and use this project, the only software requirement for your users is a mordern web browser.
Although modern is relative, the browser has to at least support HTML5 as well as JavaScript Arrow Functions and the WebStorage API.

As the person setting up this system you will also need a web browser with the same capabilities.

### Tested Browsers

Mobile versions of web browsers listed below might not be supported properly.
These are the supported desktop versions:

| Firefox | Safari | Chrome    | Edge           |  
| ------- | ------ | --------- | -------------- |  
| 57.0.3  | 11.0.2 | 63.0.3239 | 40.15063.674.0 |  

## Project Setup

In order to set this project up, there are a number of steps that need to completed.
In addition to that there is also hard- and software that needs to be acquired beforehand.

---

### Hardware Prerequisites

Although the prerequisites listed below are not strictly hardware, for this project they were deployed on different machines.
It is also safe to assume that this would also be the case for a real world application.

#### SQL Database

**MySQL-Server**  
`5.5.5-10.1.14-MariaDB`

The sql database that was used in this project was provided through the university of vienna's student services.
It should be possible to exchange it for any other sql database.

#### PHP Server

**Apache**  
`2.2.15 (Red Hat)`

**PHP-Version**  
`5.6.32`

The php server that was used in this project was provided through the university of vienna's student services.
It should be noted that changing the php server might also require looking into how access to sensitive files (see [php folder contents](./ui/php/CONTENTS.md)) can be restricted on different php server software.

#### Blockchain Node Software

**Parity**  
`v1.7.11-stable-a5ed4cf-20171228/x86_64-macos/rustc1.22.1`

**Geth**  
`1.6.7-stable`

During the duration of this project, two different nodes were used.
Parity during the majority of the development time and Geth for the final version.

----

### Build Environment

As can be seen under [Files and Folder Contents](#files-and-folder-contents), the source for the program as well as it's documentation files are available.
To build either one, the software that was used to create and/or compile it is listed below.

#### Source Code

**Solc Solidity Compiler**  
`0.4.16+commit.d7661dd9.Darwin.appleclang`

**Shell**  
`GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin16)`

Although the shell scripts (see [compile.sh](./helper/compile.sh) and [init.sh](./helper/init.sh)) are there to compile and export the files, this can also be done by hand since they are only there as helpers.
Check their contents and execute the solidity compiler by hand if necessary.

#### Documentation

**PlantUML**  
`1.2017.18 (Fri Oct 06 18:56:32 CEST 2017)`

**Java**  
`Java (TM) SE Runtime Environment (build 1.8.0_131-b11)`

**draw.io** (or simply online)  
`7.5.6`

For the documentation, the respective source files are provided (see [documentation source](./doc/diagrams/source/)).
PlantUml was used for the class and sequence diagrams, while one other diagram that represents the entity relationship model was created through the draw.io online editor (see [draw.io - Webpage](https://www.draw.io)).

----

### Blockchain Configuration

The blockchain that you will be using needs to be configured beforehand.
At the same time changes need to be made to the source files in order to interact with **your** chain.

#### Blockchain Network

This project uses a custom private blockchain that is run by BlockchainSci-Lab at the University of Vienna.

To replicate this work you will need to create your own private blockchain.  
Check your node's documentation (eg. [Private Network](https://github.com/ethereum/go-ethereum/wiki/Private-network) for Geth or [Chain Specification](https://wiki.parity.io/Chain-specification.html) if you are using Parity) for a guide on how to set one up.

When creating your blockchain you should also ensure that the block gas limits are sufficiently high since our smart contracts use a lot of gas (see [optimized gas](./doc/optimized gas.txt) and [unoptimized gas](./doc/unoptimized gas.txt)).

#### Web3 APIs

**Web3 Library** (included)  
`0.20.1`

This project uses the web3 JavaScript library in order to talk to the blockchain.
In order for it to work correctly the eth, personal and web3 APIs need to be exposed through the http interface (see [JSON RPC API](https://wiki.parity.io/JSONRPC) for Parity and [Management - APIs](https://github.com/ethereum/go-ethereum/wiki/Management-APIs) for Geth).
These APIs provide different functions that are used by our web interface.

**eth**  
The functions exposed through the eth namespace provide ways to interact with the blockchain.
It handles everything that can be seen as data that is on the blockchain.
Calling smart contracts, reading block contents and providing watch filters to listen for changes on the blockchain are some of the things its functions can do.
In general it can be argued that apart from connection setup duties it handles all communications between the blockchain and the interface.

*Examples*
```javascript
// Setup an interface through which we can call our contract's functions.
var contractInstance = web3.eth.contract(contractABI).at(contractAddress);

// Estimate the gas cost a transaction would have if executed now.
var gasEstimate = web3.eth.estimateGas(tx);

// Setup a watcher that listens for newly created blocks on the blockchain.
var filter = web3.eth.filter('latest');
filter.watch((error, result) => { ... });

// Get the transactions that the block at 'blocknumber' contains.
var transactions = web3.eth.getBlock(blockNumber).transactions;
```

**personal**  
The personal API namespace has to be activated, in order to provide account management functionality.
This way new accounts can be created through the web interface.
Sending as well as signing transactions is also made possible because of it.

*Examples*
```javascript
// Create a new account on our node with the given password.
var accountAddress = web3.personal.newAccount(password);

// If the password is correct, send a transaction using its from address as the sender account and sign it.
var transactionHash = web3.personal.sendTransaction(transaction, password);
```

**web3**  
Used to setup the connection to the blockchain.
Among other functions it also provides ways to convert between datatypes.

*Examples*

```javascript
// Setup a connection to a node located at 'web3Provider'.
var web3Provider = "http://blockpass.cs.univie.ac.at:8545";
var web3 = new Web3(new Web3.providers.HttpProvider(web3Provider));

// Check whether we are connected to a node.
web3.isConnected()
```

#### Connection

Once your blockchain is setup, the JavaScript files that handle connecting to it will need to be modified before you can set up the system as described under [Setup Guide](#setup-guide).

The files and lines in question; [common.js: line 8 to 11](./ui/scripts/common.js#L8-11) and [init3.js: line 7 to 10](./ui/scripts/init3.js#L7-10).

For example from

```javascript
var web3Provider = "http://blockpass.cs.univie.ac.at:8545";
...
var web3 = new Web3(new Web3.providers.HttpProvider(web3Provider));
```

to

```javascript
var web3Provider = "http://localhost:8545";
...
var web3 = new Web3(new Web3.providers.HttpProvider(web3Provider));
```

The `web3Provider` variable needs to point to the location of your node's rpc endpoint (see [JSON RPC Endpoint](https://github.com/ethereum/wiki/wiki/JSON-RPC#json-rpc-endpoint)).

----

### Setup Guide

#### Requirements
1. The project’s code as well as its documentation.
2. Access to an Ethereum node that exposes web3, eth and personal APIs over the HTTP endpoint.
3. A suitable genesis block with sufficiently high block gas limit (check gas costs in doc folder)
4. A Solidity compiler.
5. A PHP server.
6. An SQL database.

#### Setup
1. Create an account on your node if you don’t have one already  
`geth account new`
2. Lower gas cost to 0  
`miner.setGasPrice(0)`
3. Start miner  
`miner.start()`
4. Set up database with correct tables  

    ```sql
    CREATE TABLE ‘student‘ (
      ‘matrikelnr‘ int(16) NOT NULL,
      ‘address‘ varchar(42) NOT NULL,
      ‘pwhash‘ varchar(255) NOT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
    CREATE TABLE ‘supervisor‘ (
      ‘uaccountid‘ varchar(128) NOT NULL,
      ‘address‘ varchar(42) NOT NULL,
      ‘pwhash‘ varchar(255) NOT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
    ALTER TABLE ‘student‘
      ADD PRIMARY KEY (‘matrikelnr‘),
      ADD UNIQUE KEY ‘address‘ (‘address‘);
    ALTER TABLE ‘supervisor‘
      ADD PRIMARY KEY (‘uaccountid‘),
      ADD UNIQUE KEY ‘address‘ (‘address‘);
    ```

5. Fill in the database’s credentials in sampleconfig.ini and rename it to .config.ini
6. Compile solidity code with the helper script to a combined json file  
`./compile.sh`
7. Serve all the files in the ui folder to localhost on port 8000
8. Open the setup web page and deploy contracts to create the API file (use the previously created account to set everything up)  
`localhost:8000/blockpass/admin/setup.html`
9. Copy the API file with the helper script to the ui folder  
`./init.sh`
10. Register all contracts on the contract manager by using the register page (use the previously created account to set everything up)  
`localhost:8000/blockpass/admin/manager.html`
11. Stop serving the ui folder on localhost
12. Publish all files in the ui folder on the PHP server
13. Finally, use the system by registering students and supervisors.

## Links

[Live-Website](http://homepage.univie.ac.at/a1308076/PBA/blockpass)

Website provides access to the working system that was implemented in this project.
Requires connection to the University of Vienna's data network.
See [university data network](https://zid.univie.ac.at/en/services/services-from-a-z/u/uni-datennetz/), [eduroam](https://zid.univie.ac.at/en/wi-fi/) or [uniVPN](https://zid.univie.ac.at/vpn/).

[Ethereum](https://www.ethereum.org)

[DApps](https://dapps.ethercasts.com)
