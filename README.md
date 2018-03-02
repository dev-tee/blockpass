# Praktikum Bachelorarbeit

Topic: "Blockchain: Report of Academic Records"  
Original title: "Blockchain: Prüfungspass"

An exploration of a blockchain system for reports of academic records on the basis of ethereum and smart contracts.

## Table of Contents
* [Contents](#contents)
* [Setup Guide](#setup-guide)
* [Links](#links)

## Contents

Folders will usually contain CONTENTS.md files that provide an overview of the folder's contents and file descriptions.
Additionally, source files for code used in the system have their own descriptions near the top of their files.

### ui - folder
Files for the website.

### helper - folder
Helper scripts for compilation and setup of js-bindings.

### contracts - folder
Solidity code for the system's smart contracts.

### doc - folder
Documentation and diagrams (source and exported).

## Setup Guide

### Requirements
1. The project’s code as well as its documentation.
2. Access to an Ethereum node that exposes web3, eth and personal APIs over the HTTP endpoint.
3. A suitable genesis block with sufficiently high block gas limit (check gas costs in doc folder)
4. A Solidity compiler.
5. A PHP server.
6. An SQL database.

### Setup
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
Requires connection to the university of vienna data network.
See eduroam, uniVPN, etc.

[Ethereum](https://www.ethereum.org)

[DApps](https://dapps.ethercasts.com)
