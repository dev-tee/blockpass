pragma solidity ^0.4.0;


contract Mapper {

    //walletaddress => matrikelnr
    mapping(address => uint) matrNrs;

    event Mapped(uint matrNr, address uAddress);

    modifier unmapped() {
        require(matrNrs[msg.sender] == 0);
        _;
    }

    function map(uint matrNr) unmapped {
        matrNrs[msg.sender] = matrNr;

        Mapped(matrNr, msg.sender);
    }
}
